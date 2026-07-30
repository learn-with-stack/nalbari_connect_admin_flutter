import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final int id;
  final String phone;
  final String? email;
  final String name;
  final String? aadhaar;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.phone,
    this.email,
    required this.name,
    this.aadhaar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      name: json['name'] as String? ?? '',
      aadhaar: json['aadhaar'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'aadhaar': aadhaar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, phone, email, name, aadhaar, createdAt, updatedAt];
}

class UserAuthResponse extends Equatable {
  final String token;
  final UserProfile user;
  final String? refreshToken;
  final int? expiresIn;

  const UserAuthResponse({
    required this.token,
    required this.user,
    this.refreshToken,
    this.expiresIn,
  });

  factory UserAuthResponse.fromJson(Map<String, dynamic> json) {
    return UserAuthResponse(
      token: json['token'] ?? json['accessToken'] ?? '',
      user: UserProfile.fromJson(json['user'] ?? {}),
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
    };
  }

  @override
  List<Object?> get props => [token, user, refreshToken, expiresIn];
}
