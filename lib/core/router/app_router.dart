import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bitetrack/core/presentation/app_shell.dart';
import 'package:bitetrack/core/presentation/splash_page.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bitetrack/features/auth/presentation/pages/login_page.dart';
import 'package:bitetrack/features/auth/presentation/pages/register_page.dart';
import 'package:bitetrack/features/home/presentation/pages/home_page.dart';
import 'package:bitetrack/features/settings/presentation/pages/settings_page.dart';
import 'package:bitetrack/features/settings/presentation/pages/theme_settings_page.dart';
import 'package:bitetrack/features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshListenable(_authBloc),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final location = state.matchedLocation;
      final isSplash = location == '/splash';
      final isAuthRoute = location == '/login' || location == '/register';

      if (authState is AuthInitial || authState is AuthLoading) {
        return isSplash ? null : '/splash';
      }

      if (authState is AuthAuthenticated) {
        if (isAuthRoute || isSplash) return '/home';
        return null;
      }

      if (authState is AuthUnauthenticated) {
        if (isAuthRoute) return null;
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: '/settings/theme',
            builder: (context, state) => const ThemeSettingsPage(),
          ),
        ],
      ),
    ],
  );
}

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._bloc) {
    _subscription = _bloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _bloc;
  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

GoRouter createAppRouter() => AppRouter(getIt<AuthBloc>()).router;
