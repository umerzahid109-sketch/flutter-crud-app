// lib/controllers/auth_controller.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../enums/app_enums.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  AuthState _state = AuthState.idle;
  UserModel? _currentUser;
  String? _errorMessage;
  bool _rememberMe = false;

  // In-memory user store (simulates a database)
  final Map<String, Map<String, dynamic>> _registeredUsers = {};

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isLoggedIn => _currentUser != null;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required Gender gender,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600)); // simulate network

    if (_registeredUsers.containsKey(email.toLowerCase())) {
      _state = AuthState.error;
      _errorMessage = 'An account with this email already exists.';
      notifyListeners();
      return false;
    }

    _registeredUsers[email.toLowerCase()] = {
      'fullName': fullName,
      'email': email,
      'password': password,
      'gender': gender.index,
    };

    _state = AuthState.success;
    notifyListeners();
    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600)); // simulate network

    final stored = _registeredUsers[email.toLowerCase()];

    if (stored == null) {
      _state = AuthState.error;
      _errorMessage = 'No account found with this email.';
      notifyListeners();
      return false;
    }

    if (stored['password'] != password) {
      _state = AuthState.error;
      _errorMessage = 'Incorrect password. Please try again.';
      notifyListeners();
      return false;
    }

    _currentUser = UserModel(
      fullName: stored['fullName'] as String,
      email: stored['email'] as String,
      gender: Gender.values[stored['gender'] as int],
    );

    if (_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('remembered_email', email);
    }

    _state = AuthState.success;
    notifyListeners();
    return true;
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('remembered_email');
  }

  Future<void> logout() async {
    _currentUser = null;
    _state = AuthState.idle;
    _errorMessage = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('remembered_email');
    notifyListeners();
  }

  void resetState() {
    _state = AuthState.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
