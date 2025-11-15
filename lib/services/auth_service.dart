import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  // Get base URL from environment or use default
  static String get baseUrl =>
      dotenv.maybeGet('AUTH_SERVER_URL') ?? 'http://127.0.0.1:8080/api/v1';

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';
  static const String _tokenExpiryKey = 'token_expiry';

  /// Register a new user
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          jsonResponse,
          (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          await _saveTokens(apiResponse.data!);
        }

        return apiResponse;
      } else {
        final Map<String, dynamic> errorJson = jsonDecode(response.body);
        return ApiResponse<AuthResponse>(
          success: false,
          error: errorJson['error'] as String? ?? 'Registration failed',
          timestamp: DateTime.now(),
          requestId: errorJson['request_id'] as String? ?? '',
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        error: 'Network error: $e',
        timestamp: DateTime.now(),
        requestId: '',
      );
    }
  }

  /// Login with email and password
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          jsonResponse,
          (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          await _saveTokens(apiResponse.data!);
        }

        return apiResponse;
      } else {
        final Map<String, dynamic> errorJson = jsonDecode(response.body);
        return ApiResponse<AuthResponse>(
          success: false,
          error: errorJson['error'] as String? ?? 'Login failed',
          timestamp: DateTime.now(),
          requestId: errorJson['request_id'] as String? ?? '',
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        error: 'Network error: $e',
        timestamp: DateTime.now(),
        requestId: '',
      );
    }
  }

  /// Logout (invalidate session on server)
  Future<bool> logout() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // Clear local storage regardless of server response
      await clearTokens();
      return response.statusCode == 200;
    } catch (e) {
      // Clear local storage on error too
      await clearTokens();
      return false;
    }
  }

  /// Refresh access token using refresh token
  Future<ApiResponse<AuthResponse>> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return ApiResponse<AuthResponse>(
          success: false,
          error: 'No refresh token available',
          timestamp: DateTime.now(),
          requestId: '',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final apiResponse = ApiResponse<AuthResponse>.fromJson(
          jsonResponse,
          (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          await _saveTokens(apiResponse.data!);
        }

        return apiResponse;
      } else {
        await clearTokens();
        return ApiResponse<AuthResponse>(
          success: false,
          error: 'Token refresh failed',
          timestamp: DateTime.now(),
          requestId: '',
        );
      }
    } catch (e) {
      return ApiResponse<AuthResponse>(
        success: false,
        error: 'Network error: $e',
        timestamp: DateTime.now(),
        requestId: '',
      );
    }
  }

  /// Get user profile
  Future<ApiResponse<User>> getProfile() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        return ApiResponse<User>(
          success: false,
          error: 'Not authenticated',
          timestamp: DateTime.now(),
          requestId: '',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ApiResponse<User>.fromJson(
          jsonResponse,
          (data) => User.fromJson(data as Map<String, dynamic>),
        );
      } else if (response.statusCode == 401) {
        // Try to refresh token
        final refreshResult = await refreshToken();
        if (refreshResult.success) {
          // Retry with new token
          return getProfile();
        }
        return ApiResponse<User>(
          success: false,
          error: 'Authentication expired',
          timestamp: DateTime.now(),
          requestId: '',
        );
      } else {
        return ApiResponse<User>(
          success: false,
          error: 'Failed to fetch profile',
          timestamp: DateTime.now(),
          requestId: '',
        );
      }
    } catch (e) {
      return ApiResponse<User>(
        success: false,
        error: 'Network error: $e',
        timestamp: DateTime.now(),
        requestId: '',
      );
    }
  }

  /// Save tokens and user data to local storage
  Future<void> _saveTokens(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, authResponse.accessToken);
    await prefs.setString(_refreshTokenKey, authResponse.refreshToken);
    await prefs.setString(_userKey, jsonEncode(authResponse.user.toJson()));

    // Calculate and save token expiry time
    final expiryTime = DateTime.now().add(
      Duration(seconds: authResponse.expiresIn),
    );
    await prefs.setString(_tokenExpiryKey, expiryTime.toIso8601String());
  }

  /// Get access token from local storage
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get refresh token from local storage
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Get stored user data
  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    return null;
  }

  /// Check if user is authenticated and token is valid
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    if (token == null) return false;

    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr == null) return false;

    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      // Token expired, try to refresh
      final refreshResult = await refreshToken();
      return refreshResult.success;
    }

    return true;
  }

  /// Clear all stored tokens and user data
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_tokenExpiryKey);
  }
}
