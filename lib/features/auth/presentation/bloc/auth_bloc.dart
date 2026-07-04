import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';
import 'package:bitetrack/features/auth/domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required GetCurrentUserUseCase getCurrentUser,
    required LoginUseCase login,
    required RegisterUseCase register,
    required LogoutUseCase logout,
  })  : _getCurrentUser = getCurrentUser,
        _login = login,
        _register = register,
        _logout = logout,
        super(const AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;

  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final session = await _login(email: event.email, password: event.password);
      emit(AuthAuthenticated(session.user));
    } on Failure catch (e) {
      emit(AuthUnauthenticated(message: e.message));
    } catch (_) {
      emit(const AuthUnauthenticated(message: 'Login failed'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final session = await _register(
        email: event.email,
        password: event.password,
        role: event.role,
        firstName: event.firstName,
        lastName: event.lastName,
      );
      emit(AuthAuthenticated(session.user));
    } on Failure catch (e) {
      emit(AuthUnauthenticated(message: e.message));
    } catch (_) {
      emit(const AuthUnauthenticated(message: 'Registration failed'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _logout();
    emit(const AuthUnauthenticated());
  }
}
