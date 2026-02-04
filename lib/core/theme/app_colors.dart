import 'package:flutter/material.dart';

class AppColors {
  // Serene / Ocean Theme
  static const Color primaryLight = Color(0xFF6B9EA4); // Muted Teal
  static const Color primaryDark = Color(0xFF2C5061);  // Deep Slate Teal
  static const Color accent = Color(0xFFA6D4DE);       // Light Cyan
  static const Color textWhite = Color(0xFFF5F9FA);    // Off-white
  static const Color cardSurface = Color(0x26FFFFFF);  // Glassy white (15% opacity)
  
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryLight,
      primaryDark,
    ],
  );
}
