import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/theme/theme_preference.dart';
import 'package:bitetrack/core/storage/token_storage.dart';
import 'package:bitetrack/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bitetrack/features/auth/data/services/google_sign_in_service.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';
import 'package:bitetrack/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._tokenStorage, this._googleSignIn);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  final GoogleSignInService _googleSignIn;

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
    String? firstName,
    String? lastName,
  }) async {
    final response = await _remote.register(
      email: email,
      password: password,
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
  Future<AuthSession> googleSignIn({required String idToken}) async {
    final response = await _remote.googleSignIn(idToken: idToken);
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
  Future<User> updateThemePreference(AppThemePreference preference) async {
    final model = await _remote.updateThemePreference(themePreference: preference);
    return model.toEntity();
  }

  @override
  Future<User> updateProfile(UpdateProfileInput input) async {
    final model = await _remote.updateProfile(
      firstName: input.firstName,
      lastName: input.lastName,
      phone: input.phone,
    );
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    final refresh = _tokenStorage.refreshToken;
    if (refresh != null) {
      try {
        await _remote.logout(refreshToken: refresh);
      } catch (_) {}
    }
    await _googleSignIn.signOut();
    await _tokenStorage.clear();
  }
}
