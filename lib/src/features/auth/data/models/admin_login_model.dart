import 'package:equatable/equatable.dart';

class AdminLoginRequest extends Equatable {
  final String username;
  final String password;

  const AdminLoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }

  @override
  List<Object?> get props => [username, password];
}

class OtpLoginRequest extends Equatable {
  final String firebaseIdToken;

  const OtpLoginRequest({required this.firebaseIdToken});

  Map<String, dynamic> toJson() {
    return {'firebaseIdToken': firebaseIdToken};
  }

  @override
  List<Object?> get props => [firebaseIdToken];
}

class AuthResponse extends Equatable {
  final String token;
  final String? refreshToken;
  final int? expiresIn;
  final Map<String, dynamic>? user;

  const AuthResponse({
    required this.token,
    this.refreshToken,
    this.expiresIn,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] as String?,
      expiresIn: (json['expiresIn'] ?? json['expiresInMs']) as int?,
      user: json['user'] as Map<String, dynamic>? ??
          {
            if (json['userId'] != null) 'id': json['userId'],
            if (json['role'] != null) 'role': json['role'],
          },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'user': user,
    };
  }

  @override
  List<Object?> get props => [token, refreshToken, expiresIn, user];
}
