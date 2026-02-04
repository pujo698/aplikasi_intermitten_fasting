import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark, // We want light text by default even in "light" theme for this aesthetic
    scaffoldBackgroundColor: AppColors.primaryDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      secondary: AppColors.accent,
      surface: AppColors.primaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent, // For gradient overlap
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textWhite,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: AppColors.textWhite),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textWhite),
      bodyLarge: TextStyle(color: AppColors.textWhite),
      titleLarge: TextStyle(color: AppColors.textWhite),
    ),
  );

  static ThemeData darkTheme = lightTheme; // For now, single theme
}
