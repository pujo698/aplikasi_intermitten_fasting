import 'package:flutter/material.dart';

class AppColors {
  // Bright Sea Blue Theme
  static const Color primaryLight = Color(0xFF00B4D8); // Bright Cerulean
  static const Color primaryDark = Color(0xFF0077B6);  // Deep Ocean Blue
  static const Color accent = Color(0xFF90E0EF);       // Light Cyan
  static const Color textWhite = Color(0xFFFFFFFF);    // Pure White
  static const Color cardSurface = Color(0x26FFFFFF);  // Glassy white
  
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryLight,
      primaryDark,
    ],
  );
}
