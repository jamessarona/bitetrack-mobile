import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitetrack/core/constants/app_branding.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/core/router/app_router.dart';
import 'package:bitetrack/core/theme/app_theme.dart';
import 'package:bitetrack/core/theme/theme_cubit.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';

class BiteTrackApp extends StatefulWidget {
  const BiteTrackApp({super.key});

  @override
  State<BiteTrackApp> createState() => _BiteTrackAppState();
}

class _BiteTrackAppState extends State<BiteTrackApp> {
  late final AuthBloc _authBloc;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(const AuthAppStarted());
    _themeCubit = getIt<ThemeCubit>();
    _router = AppRouter(_authBloc).router;
  }

  @override
  void dispose() {
    _authBloc.close();
    _themeCubit.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _themeCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _themeCubit.syncFromPreference(state.user.themePreference);
          } else {
            _themeCubit.reset();
          }
        },
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: AppBranding.displayName,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: _router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
