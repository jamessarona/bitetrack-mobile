import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitetrack/core/theme/theme_cubit.dart';
import 'package:bitetrack/core/theme/theme_preference.dart';

void main() {
  group('ThemeCubit', () {
    late ThemeCubit cubit;

    setUp(() {
      cubit = ThemeCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('starts with system theme', () {
      expect(cubit.state, ThemeMode.system);
    });

    test('syncFromPreference maps light and dark modes', () {
      cubit.syncFromPreference(AppThemePreference.dark);
      expect(cubit.state, ThemeMode.dark);

      cubit.syncFromPreference(AppThemePreference.light);
      expect(cubit.state, ThemeMode.light);
    });

    test('reset returns to system theme', () {
      cubit.syncFromPreference(AppThemePreference.dark);
      cubit.reset();
      expect(cubit.state, ThemeMode.system);
    });
  });
}
