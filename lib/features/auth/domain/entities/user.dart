import 'package:equatable/equatable.dart';
import 'package:bitetrack/core/theme/theme_preference.dart';

/// Account type from the API. Seller status is derived from [businessCount], not role.
enum UserRole { customer, admin }

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.themePreference = AppThemePreference.system,
    this.businessCount = 0,
  });

  final String id;
  final String email;
  final UserRole role;
  final String status;
  final String firstName;
  final String lastName;
  final String? phone;
  final AppThemePreference themePreference;
  final int businessCount;

  bool get hasBusinesses => businessCount > 0;

  String get displayName {
    final name = [firstName, lastName].where((part) => part.trim().isNotEmpty).join(' ');
    return name.isNotEmpty ? name : email;
  }

  User copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    AppThemePreference? themePreference,
    int? businessCount,
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
      businessCount: businessCount ?? this.businessCount,
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
        businessCount,
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
