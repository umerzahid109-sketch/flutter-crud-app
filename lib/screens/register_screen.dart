// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../enums/app_enums.dart';
import '../validators/app_validator.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  final AuthController authController;

  const RegisterScreen({super.key, required this.authController});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  Gender? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a gender'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await widget.authController.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: _selectedGender!,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // back to login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              widget.authController.errorMessage ?? 'Registration failed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0F1E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Create Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Join Us Today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the details below to get started',
                  style: TextStyle(color: Colors.blue.shade200, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // Full Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  focusNode: _nameFocus,
                  nextFocusNode: _emailFocus,
                  validator: AppValidator.validateFullName,
                ),
                const SizedBox(height: 16),

                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  focusNode: _emailFocus,
                  nextFocusNode: _passwordFocus,
                  validator: AppValidator.validateEmail,
                ),
                const SizedBox(height: 16),

                // Gender Dropdown
                DropdownButtonFormField<Gender>(
                  value: _selectedGender,
                  dropdownColor: const Color(0xFF1A2340),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    labelStyle: TextStyle(color: Colors.blue.shade200),
                    filled: true,
                    fillColor: const Color(0xFF1A2340),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade900),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue.shade900),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: Color(0xFF2962FF), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  items: Gender.values
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g.label),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedGender = val),
                  validator: (_) => _selectedGender == null
                      ? 'Please select a gender'
                      : null,
                ),
                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter a strong password',
                  obscureText: !_showPassword,
                  focusNode: _passwordFocus,
                  nextFocusNode: _confirmFocus,
                  validator: AppValidator.validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blue.shade200,
                    ),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                const SizedBox(height: 8),

                // Password requirements hint
                _PasswordHints(password: _passwordController.text),
                const SizedBox(height: 16),

                // Confirm Password
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Re-type Password',
                  hint: 'Confirm your password',
                  obscureText: !_showConfirmPassword,
                  focusNode: _confirmFocus,
                  textInputAction: TextInputAction.done,
                  validator: (val) => AppValidator.validateConfirmPassword(
                      val, _passwordController.text),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blue.shade200,
                    ),
                    onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
                const SizedBox(height: 32),

                PrimaryButton(
                  label: 'SIGN UP',
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),

                // Link to login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: TextStyle(color: Colors.blue.shade200)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF2962FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordHints extends StatelessWidget {
  final String password;
  const _PasswordHints({required this.password});

  @override
  Widget build(BuildContext context) {
    final requirements = [
      ('At least 6 characters', password.length >= 6),
      ('At least 1 uppercase letter', RegExp(r'[A-Z]').hasMatch(password)),
      (
        'At least 1 special character',
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)
      ),
    ];

    return Column(
      children: requirements
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(
                      r.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 14,
                      color: r.$2 ? Colors.greenAccent : Colors.white38,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      r.$1,
                      style: TextStyle(
                        fontSize: 12,
                        color: r.$2 ? Colors.greenAccent : Colors.white38,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
