import 'package:bitetrack/features/auth/domain/entities/user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final User user;
  final String accessToken;
  final String refreshToken;
}

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<AuthSession> register({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  });
  Future<AuthSession> googleSignIn({required String idToken});
  Future<User?> getCurrentUser();
  Future<void> logout();
}
