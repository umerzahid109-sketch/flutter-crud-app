// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../enums/app_enums.dart';
import '../validators/app_validator.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;

  const LoginScreen({super.key, required this.authController});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final saved = await widget.authController.getSavedEmail();
    if (saved != null && mounted) {
      setState(() {
        _emailController.text = saved;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    widget.authController.setRememberMe(_rememberMe);
    setState(() => _isLoading = true);

    final success = await widget.authController.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            authController: widget.authController,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(widget.authController.errorMessage ?? 'Login failed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _goToRegister() {
    widget.authController.resetState();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(authController: widget.authController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Logo / Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2340),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF2962FF), width: 2),
                  ),
                  child: const Icon(Icons.lock_outline,
                      size: 40, color: Color(0xFF2962FF)),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your account',
                style: TextStyle(color: Colors.blue.shade200, fontSize: 16),
              ),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocus,
                      nextFocusNode: _passwordFocus,
                      validator: AppValidator.validateLoginEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: !_showPassword,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      validator: AppValidator.validateLoginPassword,
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
                    const SizedBox(height: 12),

                    // Remember Me
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v ?? false),
                            activeColor: const Color(0xFF2962FF),
                            side:
                                const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember Me',
                          style: TextStyle(
                              color: Colors.blue.shade200, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    PrimaryButton(
                      label: 'LOGIN',
                      onPressed: _login,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Register link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.blue.shade200),
                    ),
                    GestureDetector(
                      onTap: _goToRegister,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Color(0xFF2962FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
