import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

/// Persists auth tokens securely in platform shared preferences.
/// For production, consider flutter_secure_storage.
@lazySingleton
class TokenStorage {
  TokenStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);
  }

  String? get accessToken => _prefs.getString(_accessTokenKey);
  String? get refreshToken => _prefs.getString(_refreshTokenKey);

  Future<void> clear() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
  }

  bool get hasTokens => accessToken != null && refreshToken != null;
}
