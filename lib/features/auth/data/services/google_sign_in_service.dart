import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/config/env_config.dart';

@lazySingleton
class GoogleSignInService {
  GoogleSignIn? _client;

  GoogleSignIn get _googleSignIn {
    _client ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: EnvConfig.instance.googleClientId.isEmpty
          ? null
          : EnvConfig.instance.googleClientId,
    );
    return _client!;
  }

  Future<String?> signInAndGetIdToken() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;

    final auth = await account.authentication;
    return auth.idToken;
  }

  Future<void> signOut() async {
    if (_client != null) {
      await _client!.signOut();
    }
  }
}
