import 'package:equatable/equatable.dart';

enum UserRole { customer, vendor, admin }

/// Domain entity — no JSON/serialization concerns here.
class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.firstName,
    this.lastName,
  });

  final String id;
  final String email;
  final UserRole role;
  final String status;
  final String? firstName;
  final String? lastName;

  String get displayName {
    final name = [firstName, lastName].where((p) => p != null && p.isNotEmpty).join(' ');
    return name.isNotEmpty ? name : email;
  }

  @override
  List<Object?> get props => [id, email, role, status, firstName, lastName];
}
