import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/features/auth/data/services/google_sign_in_service.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';
import 'package:bitetrack/features/auth/domain/repositories/auth_repository.dart';

@injectable
class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({required String email, required String password}) {
    return _repository.login(email: email, password: password);
  }
}

@injectable
class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  }) {
    return _repository.register(
      email: email,
      password: password,
      role: role,
      firstName: firstName,
      lastName: lastName,
    );
  }
}

@injectable
class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<User?> call() => _repository.getCurrentUser();
}

@injectable
class LogoutUseCase {
  LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.logout();
}

@injectable
class GoogleSignInUseCase {
  GoogleSignInUseCase(this._repository, this._googleSignIn);

  final AuthRepository _repository;
  final GoogleSignInService _googleSignIn;

  Future<AuthSession> call() async {
    final idToken = await _googleSignIn.signInAndGetIdToken();
    if (idToken == null) {
      throw const AuthFailure('Google sign-in was cancelled');
    }
    return _repository.googleSignIn(idToken: idToken);
  }
}
