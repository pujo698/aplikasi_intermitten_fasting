import '../models/user_profile.dart';
import '../models/diet_result.dart';

class DietCalculator {

  /// Controller utama diet otomatis (non-medis)
  static DietResult calculate(UserProfile user) {
    final bmr = _calculateBMR(user);
    final tdee = _calculateTDEE(bmr, user.activity);
    var calories = _adjustByGoal(tdee, user.goal);

    // 4️⃣ Calorie Guardrail (Medical Safety)
    // Mencegah defisit ekstrem yang merusak metabolisme & hormon
    double minLimit = (user.gender == Gender.male) ? 1500 : 1200;
    if (calories < minLimit) {
      calories = minLimit;
    }

    final macros = _calculateMacros(calories, user.goal);

    return DietResult(
      calories: calories.round(),
      protein: macros['protein']!,
      carbs: macros['carbs']!,
      fat: macros['fat']!,
    );
  }

  static double _calculateBMR(UserProfile user) {
    if (user.gender == Gender.male) {
      return (10 * user.weight) +
          (6.25 * user.height) -
          (5 * user.age) +
          5;
    } else {
      return (10 * user.weight) +
          (6.25 * user.height) -
          (5 * user.age) -
          161;
    }
  }

  /// Faktor aktivitas
  static double _calculateTDEE(double bmr, ActivityLevel level) {
    final factor = switch (level) {
      ActivityLevel.low => 1.2,
      ActivityLevel.medium => 1.55,
      ActivityLevel.high => 1.75,
    };
    return bmr * factor;
  }

  /// Penyesuaian goal
  static double _adjustByGoal(double tdee, DietGoal goal) {
    return switch (goal) {
      DietGoal.fatLoss => tdee - 300,
      DietGoal.maintain => tdee,
      DietGoal.muscleGain => tdee + 300,
    };
  }

  /// Pembagian makro (realistis & aman)
  static Map<String, int> _calculateMacros(
      double calories, DietGoal goal) {

    double proteinRatio;
    double carbsRatio;
    double fatRatio;

    switch (goal) {
      case DietGoal.fatLoss:
        proteinRatio = 0.30;
        carbsRatio = 0.40;
        fatRatio = 0.30;
        break;
      case DietGoal.maintain:
        proteinRatio = 0.25;
        carbsRatio = 0.45;
        fatRatio = 0.30;
        break;
      case DietGoal.muscleGain:
        proteinRatio = 0.30;
        carbsRatio = 0.45;
        fatRatio = 0.25;
        break;
    }

    final protein = ((calories * proteinRatio) / 4).round();
    final carbs = ((calories * carbsRatio) / 4).round();
    final fat = ((calories * fatRatio) / 9).round();

    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  static int calculateWeightLossDurationInMonths(double currentWeight, double targetWeight, int eatingHours) {
    if (targetWeight >= currentWeight) return 0;
    
    final diff = currentWeight - targetWeight;
    
    // Adjust monthly loss estimation based on Fasting Intensity
    // 16:8 (8h) is standard ~2.5kg
    // OMAD (1h) is faster ~3.5kg
    // 12h+ is slower ~1.5kg
    
    double monthlyLoss = 2.0;

    if (eatingHours <= 1) {
      monthlyLoss = 3.5; // Extreme/OMAD
    } else if (eatingHours <= 6) {
      monthlyLoss = 3.0; // Warrior/20:4
    } else if (eatingHours <= 8) {
      monthlyLoss = 2.5; // 16:8
    } else if (eatingHours <= 10) {
      monthlyLoss = 1.8; // 14:10
    } else {
      monthlyLoss = 1.5; // Normal diet
    }
    
    return (diff / monthlyLoss).ceil();
  }
}
