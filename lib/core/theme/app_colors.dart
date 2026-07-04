import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF7C3AED);
  static const primaryDark = Color(0xFF5B21B6);
  static const primaryDeep = Color(0xFF4C1D95);
  static const primaryLight = Color(0xFFA78BFA);
  static const primarySurface = Color(0xFFEDE9FE);

  static const secondary = Color(0xFFF59E0B);
  static const secondaryLight = Color(0xFFFDE68A);

  static const background = Color(0xFFF8F7FC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF1EEF9);

  static const textPrimary = Color(0xFF1E1B2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF059669);
  static const border = Color(0xFFE5E7EB);

  static const gradientStart = Color(0xFF7C3AED);
  static const gradientMid = Color(0xFF6D28D9);
  static const gradientEnd = Color(0xFF4338CA);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMid, gradientEnd],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F3FF), background],
  );

  static LinearGradient softGradientFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? AppDarkColors.softGradient
        : softGradient;
  }
}

abstract final class AppDarkColors {
  static const primary = Color(0xFFA78BFA);
  static const primaryDark = Color(0xFF7C3AED);
  static const primaryDeep = Color(0xFF5B21B6);
  static const primaryLight = Color(0xFFC4B5FD);
  static const primarySurface = Color(0xFF2E1065);

  static const secondary = Color(0xFFFBBF24);
  static const secondaryLight = Color(0xFF78350F);

  static const background = Color(0xFF0F0D14);
  static const surface = Color(0xFF1A1724);
  static const surfaceMuted = Color(0xFF252131);

  static const textPrimary = Color(0xFFF5F3FF);
  static const textSecondary = Color(0xFFA1A1AA);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const error = Color(0xFFF87171);
  static const success = Color(0xFF34D399);
  static const border = Color(0xFF2E2A3A);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), Color(0xFF5B21B6), Color(0xFF312E81)],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1724), background],
  );
}
