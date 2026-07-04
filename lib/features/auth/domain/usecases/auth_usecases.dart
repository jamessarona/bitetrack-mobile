import 'package:injectable/injectable.dart';
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
