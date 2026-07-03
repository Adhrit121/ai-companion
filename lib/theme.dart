import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF090909);
  static const card = Color(0xFF181818);
  static const purple = Color(0xFF9D4EDD);
  static const crimson = Color(0xFFFF3D71);
  static const cyan = Color(0xFF56E1E9);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFAAAAAA);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.purple,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple,
        secondary: AppColors.crimson,
        surface: AppColors.card,
      ),
      cardColor: AppColors.card,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary),
        bodySmall: TextStyle(color: AppColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.purple,
        unselectedItemColor: AppColors.textSecondary,
      ),
      useMaterial3: true,
    );
  }

  static BoxDecoration cardDecoration({Color? accent}) {
    return BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: (accent ?? AppColors.purple).withOpacity(0.25)),
    );
  }

  static LinearGradient accentGradient() {
    return const LinearGradient(
      colors: [AppColors.purple, AppColors.crimson],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
