import 'package:flutter/material.dart';

enum AppThemePreference {
  light,
  dark,
  system,
}

extension AppThemePreferenceX on AppThemePreference {
  String get apiValue {
    switch (this) {
      case AppThemePreference.light:
        return 'LIGHT';
      case AppThemePreference.dark:
        return 'DARK';
      case AppThemePreference.system:
        return 'SYSTEM';
    }
  }

  String get label {
    switch (this) {
      case AppThemePreference.light:
        return 'Light';
      case AppThemePreference.dark:
        return 'Dark';
      case AppThemePreference.system:
        return 'Match device';
    }
  }

  String get description {
    switch (this) {
      case AppThemePreference.light:
        return 'Always use the light theme';
      case AppThemePreference.dark:
        return 'Always use the dark theme';
      case AppThemePreference.system:
        return 'Follow your phone\'s light or dark setting';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemePreference.light:
        return Icons.light_mode_outlined;
      case AppThemePreference.dark:
        return Icons.dark_mode_outlined;
      case AppThemePreference.system:
        return Icons.brightness_auto_outlined;
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.system:
        return ThemeMode.system;
    }
  }

  static AppThemePreference fromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'LIGHT':
        return AppThemePreference.light;
      case 'DARK':
        return AppThemePreference.dark;
      default:
        return AppThemePreference.system;
    }
  }
}
