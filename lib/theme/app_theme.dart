import 'package:flutter/material.dart';

class AppColors {
  static const primary      = Color(0xFFB05A38);
  static const primaryLight = Color(0xFFFDF0EB);
  static const success      = Color(0xFF2E7D32);
  static const successBg    = Color(0xFFE8F5E9);
  static const error        = Color(0xFFC62828);
  static const background   = Color(0xFFFAF9F7);
  static const surface      = Color(0xFFFFFFFF); // ✅ added - used in login_screen
  static const textDark     = Color(0xFF1A1A1A);
  static const textMuted    = Color(0xFF757575);
  static const textLight    = Color(0xFFBDBDBD);
  static const border       = Color(0xFFE0E0E0);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark),
    ),
  );
}
