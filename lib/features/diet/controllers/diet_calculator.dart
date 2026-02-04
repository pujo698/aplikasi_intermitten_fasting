import '../models/user_profile.dart';
import '../models/diet_result.dart';

class DietCalculator {

  /// Controller utama diet otomatis (non-medis)
  static DietResult calculate(UserProfile user) {
    final bmr = _calculateBMR(user);
    final tdee = _calculateTDEE(bmr, user.activity);
    final calories = _adjustByGoal(tdee, user.goal);

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
}
