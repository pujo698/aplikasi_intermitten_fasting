import 'package:flutter/material.dart';

class AppColors {
  // === Futuristic Pastel Palette ===
  static const Color pastelCyan = Color(0xFF80FFDB);   // Aqua/Mint
  static const Color pastelBlue = Color(0xFF64DFDF);   // Electric Blue pastel
  static const Color deepTeal = Color(0xFF5390D9);     // Deeper Blue for contrast
  static const Color futuristicGreen = Color(0xFF6930C3); // (Placeholder replacement -> actually need Green)
  
  // Correction for "Pastel Blue Green Futuristic":
  static const Color mintGreen = Color(0xFFccffcc); // Pastel Mint
  static const Color electricBlue = Color(0xFFe0f7fa); // Very light cyan
  
  // Cohesive set:
  static const Color primary = Color(0xFF48CAE4);      // Vibrant Pastel Blue
  static const Color primaryLight = Color(0xFF90E0EF); // Softer Blue
  static const Color primaryDark = Color(0xFF0077B6);  // Deeper Blue
  static const Color secondary = Color(0xFF90E0EF);    // Softer Blue
  static const Color tertiary = Color(0xFFADE8F4);     // Very pale blue
  static const Color accentGreen = Color(0xFFcaf0f8);  // Icy blue-white
  static const Color accentNeon = Color(0xFF00B4D8);   // Stronger blue for accents
  static const Color accent = Color(0xFF00B4D8);       // Main accent color

  // === Text ===
  static const Color textPrimary = Color(0xFF023E8A);  // Deep Blue-Black for readability on pastel
  static const Color textSecondary = Color(0xFF0077B6);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // === Surface / Background ===
  static const Color background = Color(0xFFCAF0F8);   // Very light blueish white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0x26FFFFFF);  // Glassy white

  // === Semantic / Status ===
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // === Macro nutrient tags ===
  static const Color calorieTag = Color(0xFFFF9800);
  static const Color proteinTag = Color(0xFF2196F3);
  static const Color fatTag = Color(0xFFF44336);
  static const Color carbTag = Color(0xFF4CAF50);

  // === Meal plan card backgrounds ===
  static const Color mealCardProtein = Color(0xFFE8EFFD);
  static const Color mealCardFat = Color(0xFFFFF6E4);
  static const Color mealCardSnack = Color(0xFFFFF4E8);
  static const Color mealCardFiber = Color(0xFFE0F7EF);
  static const Color mealCardFull = Color(0xFF00C896);

  // === Meal plan tag colors ===
  static const Color tagPinkBg = Color(0xFFF8BBD0);
  static const Color tagPink = Color(0xFFE91E63);
  static const Color tagOrangeBg = Color(0xFFFFE0B2);
  static const Color tagPurpleBg = Color(0xFFE1BEE7);
  static const Color tagPurple = Color(0xFF9C27B0);
  static const Color tagGreenBg = Color(0xFFC8E6C9);

  // === Chart colors ===
  static const Color chartBorder = Color(0xFF37434D);
  
  // === Gradients ===
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primary,
      secondary,
    ],
  );
  
  static const LinearGradient stepGradient = LinearGradient(
    colors: [pastelCyan, pastelBlue],
  );
}
