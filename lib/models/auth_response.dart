class UserData {
  final String id;
  final String email;

  const UserData({
    required this.id,
    required this.email,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? json['user_id'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }
}

class SessionData {
  final String accessToken;
  final int? expiresIn;

  const SessionData({
    required this.accessToken,
    this.expiresIn,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      accessToken: json['access_token'] ?? '',
      expiresIn: json['expires_in'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'expires_in': expiresIn,
    };
  }
}

class AuthData {
  final UserData? user;
  final SessionData? session;

  const AuthData({
    this.user,
    this.session,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      user: json['user'] != null ? UserData.fromJson(json['user']) : null,
      session: json['session'] != null ? SessionData.fromJson(json['session']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'session': session?.toJson(),
    };
  }
}

class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;

  const AuthResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
