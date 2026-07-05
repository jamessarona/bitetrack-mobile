import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/features/auth/domain/entities/user.dart';
import 'package:bitetrack/features/auth/domain/repositories/auth_repository.dart';
import 'package:bitetrack/features/auth/domain/usecases/auth_usecases.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGoogleSignInUseCase extends Mock implements GoogleSignInUseCase {}

const testUser = User(
  id: '11111111-1111-1111-1111-111111111111',
  email: 'user@test.com',
  role: UserRole.customer,
  status: 'ACTIVE',
  firstName: 'Test',
  lastName: 'User',
);

const testSession = AuthSession(
  user: testUser,
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
);

void main() {
  late MockGetCurrentUserUseCase getCurrentUser;
  late MockLoginUseCase login;
  late MockRegisterUseCase register;
  late MockLogoutUseCase logout;
  late MockGoogleSignInUseCase googleSignIn;
  late AuthBloc bloc;

  setUp(() {
    getCurrentUser = MockGetCurrentUserUseCase();
    login = MockLoginUseCase();
    register = MockRegisterUseCase();
    logout = MockLogoutUseCase();
    googleSignIn = MockGoogleSignInUseCase();

    bloc = AuthBloc(
      getCurrentUser: getCurrentUser,
      login: login,
      register: register,
      logout: logout,
      googleSignIn: googleSignIn,
    );
  });

  tearDown(() => bloc.close());

  blocTest<AuthBloc, AuthState>(
    'emits authenticated when app starts with stored session',
    build: () {
      when(() => getCurrentUser()).thenAnswer((_) async => testUser);
      return bloc;
    },
    act: (bloc) => bloc.add(const AuthAppStarted()),
    expect: () => [
      const AuthLoading(),
      const AuthAuthenticated(testUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits unauthenticated when app starts without session',
    build: () {
      when(() => getCurrentUser()).thenAnswer((_) async => null);
      return bloc;
    },
    act: (bloc) => bloc.add(const AuthAppStarted()),
    expect: () => [
      const AuthLoading(),
      const AuthUnauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits authenticated on successful login',
    build: () {
      when(() => login(email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => testSession);
      return bloc;
    },
    act: (bloc) => bloc.add(
      const AuthLoginRequested(email: 'user@test.com', password: 'password123'),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthAuthenticated(testUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits unauthenticated with message on login failure',
    build: () {
      when(() => login(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const AuthFailure('Invalid credentials'));
      return bloc;
    },
    act: (bloc) => bloc.add(
      const AuthLoginRequested(email: 'user@test.com', password: 'wrong'),
    ),
    expect: () => [
      const AuthLoading(),
      const AuthUnauthenticated(message: 'Invalid credentials'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits authenticated on successful Google sign-in',
    build: () {
      when(() => googleSignIn()).thenAnswer((_) async => testSession);
      return bloc;
    },
    act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
    expect: () => [
      const AuthLoading(),
      const AuthAuthenticated(testUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits unauthenticated on logout',
    build: () {
      when(() => logout()).thenAnswer((_) async {});
      return bloc;
    },
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [
      const AuthLoading(),
      const AuthUnauthenticated(),
    ],
  );
}
