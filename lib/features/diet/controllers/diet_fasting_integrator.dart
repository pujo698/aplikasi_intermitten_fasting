import '../../fasting/controllers/fasting_controller.dart';
import '../models/diet_result.dart';
import '../models/meal_slot.dart';

class DietFastingIntegrator {

  static List<MealSlot> splitByFasting({
    required FastingController fasting,
    required DietResult diet,
  }) {
    final eatingHours = fasting.eatingHours;

    final meals = eatingHours >= 8 ? 3 : 2;

    final caloriesPerMeal = (diet.calories / meals).round();
    final proteinPerMeal = (diet.protein / meals).round();
    final carbsPerMeal = (diet.carbs / meals).round();
    final fatPerMeal = (diet.fat / meals).round();

    final start = fasting.startEating;

    final interval = eatingHours ~/ meals;

    return List.generate(meals, (i) {
      return MealSlot(
        time: start.add(Duration(hours: i * interval)),
        calories: caloriesPerMeal,
        protein: proteinPerMeal,
        carbs: carbsPerMeal,
        fat: fatPerMeal,
      );
    });
  }
}
