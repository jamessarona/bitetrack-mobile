import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bitetrack/core/config/env_config.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/core/router/app_router.dart';
import 'package:bitetrack/core/theme/app_theme.dart';
import 'package:bitetrack/features/auth/presentation/bloc/auth_bloc.dart';

class BiteTrackApp extends StatefulWidget {
  const BiteTrackApp({super.key});

  @override
  State<BiteTrackApp> createState() => _BiteTrackAppState();
}

class _BiteTrackAppState extends State<BiteTrackApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>()..add(const AuthAppStarted());
    _router = AppRouter(_authBloc).router;
  }

  @override
  void dispose() {
    _authBloc.close();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: EnvConfig.instance.appName,
        theme: AppTheme.light,
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
