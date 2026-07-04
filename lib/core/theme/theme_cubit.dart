import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:bitetrack/core/theme/theme_preference.dart';

@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void syncFromPreference(AppThemePreference preference) {
    emit(preference.themeMode);
  }

  void reset() {
    emit(ThemeMode.system);
  }
}
