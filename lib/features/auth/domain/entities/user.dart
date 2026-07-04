import 'package:equatable/equatable.dart';
import 'package:bitetrack/core/theme/theme_preference.dart';

/// Internal account type from the API. Users start as [UserRole.customer];
/// vendor profiles and stores are enabled later through onboarding.
enum UserRole { customer, vendor, admin }

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.firstName,
    this.lastName,
    this.phone,
    this.themePreference = AppThemePreference.system,
  });

  final String id;
  final String email;
  final UserRole role;
  final String status;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final AppThemePreference themePreference;

  String get displayName {
    final name = [firstName, lastName].where((p) => p != null && p.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : email;
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    AppThemePreference? themePreference,
  }) {
    return User(
      id: id,
      email: email,
      role: role,
      status: status,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      themePreference: themePreference ?? this.themePreference,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        status,
        firstName,
        lastName,
        phone,
        themePreference,
      ];
}

class UpdateProfileInput extends Equatable {
  const UpdateProfileInput({
    this.firstName,
    this.lastName,
    this.phone,
  });

  final String? firstName;
  final String? lastName;
  final String? phone;

  @override
  List<Object?> get props => [firstName, lastName, phone];
}
