import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/storage/token_storage.dart';
import 'package:bitetrack/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';
import 'package:bitetrack/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(email: email, password: password);
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    return AuthSession(
      user: response.user.toEntity(),
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  }) async {
    final response = await _remote.register(
      email: email,
      password: password,
      role: role,
      firstName: firstName,
      lastName: lastName,
    );
    await _tokenStorage.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
    return AuthSession(
      user: response.user.toEntity(),
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    if (!_tokenStorage.hasTokens) return null;
    try {
      final model = await _remote.me();
      return model.toEntity();
    } catch (_) {
      await _tokenStorage.clear();
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final refresh = _tokenStorage.refreshToken;
    if (refresh != null) {
      try {
        await _remote.logout(refreshToken: refresh);
      } catch (_) {}
    }
    await _tokenStorage.clear();
  }
}
