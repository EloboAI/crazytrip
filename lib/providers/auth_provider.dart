import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _initAuth();
  }

  /// Initialize authentication state from stored data
  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = await _authService.getStoredUser();
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<bool> register(String email, String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        email: email,
        username: username,
        password: password,
      );

      final response = await _authService.register(request);

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);

      final response = await _authService.login(request);

      if (response.success && response.data != null) {
        _user = response.data!.user;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.error ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } finally {
      _user = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user profile from server
  Future<void> refreshProfile() async {
    if (!_isAuthenticated) return;

    try {
      final response = await _authService.getProfile();
      if (response.success && response.data != null) {
        _user = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
