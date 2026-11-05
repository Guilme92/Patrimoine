import 'package:flutter/material.dart';

/// Palette sombre inspirée des dashboards fintech (type Finary).
class AppColors {
  static const background = Color(0xFF0B0F14);
  static const surface = Color(0xFF141A22);
  static const surfaceAlt = Color(0xFF1B232E);
  static const primary = Color(0xFF16C784); // vert émeraude
  static const positive = Color(0xFF16C784);
  static const negative = Color(0xFFEA3943);
  static const textPrimary = Color(0xFFF2F5F8);
  static const textSecondary = Color(0xFF8A93A5);
  static const divider = Color(0xFF232B36);
}

ThemeData buildDarkTheme() {
  final base = ThemeData(brightness: Brightness.dark);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onPrimary: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      bodySmall: TextStyle(color: AppColors.textSecondary),
    ),
    dividerColor: AppColors.divider,
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
  );
}

/// Carte arrondie standard de l'app.
BoxDecoration cardDecoration() => BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
    );
