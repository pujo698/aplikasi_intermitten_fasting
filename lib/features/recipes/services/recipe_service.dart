import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/recipe_data.dart';

class RecipeService {
  static const String _recipesKey = 'user_recipes_v1';

  // Load recipes from storage, if empty, save and return default recipes
  static Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recipesJson = prefs.getString(_recipesKey);

    if (recipesJson == null) {
      // First time load: save default dummy recipes and return them
      await saveRecipes(dummyRecipes);
      return dummyRecipes;
    }

    try {
      final List<dynamic> decoded = jsonDecode(recipesJson);
      return decoded.map((item) => Recipe.fromJson(item)).toList();
    } catch (e) {
      // If error (e.g. format change), return defaults
      return dummyRecipes;
    }
  }

  static Future<void> saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await prefs.setString(_recipesKey, encoded);
  }

  static Future<void> addRecipe(Recipe newRecipe) async {
    final recipes = await getRecipes();
    recipes.add(newRecipe);
    await saveRecipes(recipes);
  }

  static Future<void> deleteRecipe(String id) async {
    final recipes = await getRecipes();
    recipes.removeWhere((r) => r.id == id);
    await saveRecipes(recipes);
  }
}
