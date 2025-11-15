/// Authentication models matching the Rust server API
class User {
  final String id;
  final String email;
  final String username;
  final String role;
  final bool isActive;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.isActive,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      isEmailVerified: json['is_email_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLoginAt:
          json['last_login_at'] != null
              ? DateTime.parse(json['last_login_at'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'role': role,
      'is_active': isActive,
      'is_email_verified': isEmailVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
}

class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String email;
  final String username;
  final String password;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'username': username, 'password': password};
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final DateTime timestamp;
  final String requestId;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.timestamp,
    required this.requestId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      data:
          json['data'] != null && fromJsonT != null
              ? fromJsonT(json['data'])
              : json['data'] as T?,
      error: json['error'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      requestId: json['request_id'] as String,
    );
  }
}
