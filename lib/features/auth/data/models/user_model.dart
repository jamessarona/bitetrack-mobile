import 'package:bitetrack/features/auth/domain/entities/user.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String email;
  final String role;
  final String status;
  final String? firstName;
  final String? lastName;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      role: _parseRole(role),
      status: status,
      firstName: firstName,
      lastName: lastName,
    );
  }

  static UserRole _parseRole(String value) {
    switch (value.toUpperCase()) {
      case 'VENDOR':
        return UserRole.vendor;
      case 'ADMIN':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }
}

class AuthResponseModel {
  const AuthResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserModel user;
  final String accessToken;
  final String refreshToken;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponseModel(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
  }
}
