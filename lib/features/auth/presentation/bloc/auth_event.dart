part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthAppStarted extends AuthEvent {
  const AuthAppStarted();
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.role,
    this.firstName,
    this.lastName,
  });

  final String email;
  final String password;
  final String role;
  final String? firstName;
  final String? lastName;

  @override
  List<Object?> get props => [email, password, role, firstName, lastName];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
