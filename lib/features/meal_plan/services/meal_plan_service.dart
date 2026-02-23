import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../recipes/data/recipe_data.dart';

class MealPlanService {
  static const String _keyMealPlan = 'daily_meal_plan';
  static const String _keyMealDate = 'meal_plan_date';

  // Structure: { 'breakfast': [recipeId1, recipeId2], 'lunch': [], ... }
  
  static Future<Map<String, List<String>>> loadDailyPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(_keyMealDate);

    if (lastDate != today) {
      // Reset if new day
      await prefs.setString(_keyMealDate, today);
      await prefs.remove(_keyMealPlan);
      return {};
    }

    final String? data = prefs.getString(_keyMealPlan);
    if (data == null) return {};

    try {
      Map<String, dynamic> decoded = jsonDecode(data);
      // Convert dynamic to List<String>
      Map<String, List<String>> result = {};
      decoded.forEach((key, value) {
        result[key] = List<String>.from(value);
      });
      return result;
    } catch (e) {
      return {};
    }
  }

  static Future<void> addRecipeToPlan(String mealType, String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<String>> plan = await loadDailyPlan();

    if (!plan.containsKey(mealType)) {
      plan[mealType] = [];
    }
    
    // Avoid duplicates
    if (!plan[mealType]!.contains(recipeId)) {
      plan[mealType]!.add(recipeId);
    }

    await prefs.setString(_keyMealPlan, jsonEncode(plan));
  }

  static Future<void> removeRecipeFromPlan(String mealType, String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<String>> plan = await loadDailyPlan();

    if (plan.containsKey(mealType)) {
      plan[mealType]!.remove(recipeId);
      await prefs.setString(_keyMealPlan, jsonEncode(plan));
    }
  }

  static Future<int> calculateTotalCalories() async {
    Map<String, List<String>> plan = await loadDailyPlan();
    int total = 0;

    plan.forEach((key, recipeIds) {
      for (var id in recipeIds) {
        final recipe = dummyRecipes.firstWhere((r) => r.id == id, orElse: () => dummyRecipes[0]);
        // Ideally handle 'not found' better, but dummy implementation sufficient
        if (recipe.id == id) {
           total += recipe.calories;
        }
      }
    });

    return total;
  }
}
