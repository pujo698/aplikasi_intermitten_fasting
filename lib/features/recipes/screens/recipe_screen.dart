import 'dart:io';
import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../services/storage_service.dart';
import '../../meal_plan/services/meal_plan_service.dart';
import '../services/recipe_service.dart';
import 'add_recipe_screen.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String selectedFilter = 'All'; // 'All', 'Breakfast', 'Vegan', etc.
  String userGoal = '';
  List<Recipe> filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserGoal();
    final recipes = await RecipeService.getRecipes();
    setState(() {
      filteredRecipes = recipes;
      // Re-apply filter if needed
       if (selectedFilter != 'All') {
         _filterRecipes(selectedFilter);
       }
    });
  }

  Future<void> _loadUserGoal() async {
    final profile = await StorageService.loadUserProfile();
    if (profile != null && profile['goal'] != null) {
      if (mounted) {
        setState(() {
          userGoal = profile['goal']; 
        });
      }
    }
  }

  void _filterRecipes(String filter) async {
    // Always start from full list
    final allRecipes = await RecipeService.getRecipes();
    
    setState(() {
      selectedFilter = filter;
      if (filter == 'All') {
        filteredRecipes = allRecipes;
      } else if (filter == 'Rekomendasi') {
         // Filter match user goal
         filteredRecipes = allRecipes.where((r) => r.dietGoals.contains(userGoal)).toList();
         if (filteredRecipes.isEmpty && userGoal.isNotEmpty) {
            // Fallback if no specific match, maybe show healthy ones
            filteredRecipes = allRecipes; 
         }
      } else {
        // Simple tag/mealType matching
        filteredRecipes = allRecipes.where((r) {
           final lowerFilter = filter.toLowerCase();
           return r.tags.toLowerCase().contains(lowerFilter) || 
                  r.mealTypes.contains(lowerFilter) ||
                  (filter == 'Halal' && r.isHalal) ||
                  (filter == 'Vegan' && r.isVegan);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resep Sehat"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Section
          Container(
            height: 50,
            color: Colors.white,
            child: ListView(
            scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('All'),
                if (userGoal.isNotEmpty) _buildFilterChip('Rekomendasi'),
                _buildFilterChip('Breakfast'),
                _buildFilterChip('Lunch'),
                _buildFilterChip('Dinner'),
                _buildFilterChip('Halal'),
                _buildFilterChip('Vegan'),
                _buildFilterChip('Low Carb'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Recipe List
          Expanded(
            child: filteredRecipes.isEmpty 
              ? Center(child: Text("Tidak ada resep ditemukan untuk '$selectedFilter'", style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = filteredRecipes[index];
                    return _buildRecipeCard(context, recipe);
                  },
                ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const AddRecipeScreen())
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: AppColors.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) _filterRecipes(label);
        },
        selectedColor: AppColors.primaryLight,
        backgroundColor: Colors.grey[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        ),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)),
        );
        if (result == true) {
          _loadData();
        }
      },
      child: Container(
         margin: const EdgeInsets.only(bottom: 16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
           boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
           ]
         ),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Stack(
               children: [
                 ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: recipe.imageUrl.startsWith('http') 
                    ? Image.network(
                        recipe.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_,__,___) => Container(height: 180, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                      )
                    : (recipe.imageUrl.isNotEmpty 
                        ? Image.file(
                            File(recipe.imageUrl),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_,__,___) => Container(height: 180, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                          )
                        : Container(height: 180, color: Colors.grey[300], child: const Icon(Icons.image_not_supported))
                      ),
                ),
                 if (userGoal.isNotEmpty && recipe.dietGoals.contains(userGoal))
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)]
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text("Recommended", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
               ],
             ),
             Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(recipe.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 4),
                   Text(recipe.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                   const SizedBox(height: 12),
                   Wrap(
                     spacing: 8,
                     runSpacing: 8,
                     children: [
                       _buildTag(Icons.local_fire_department, "${recipe.calories} kcal", Colors.orange),
                       _buildTag(Icons.fitness_center, "${recipe.protein}g Pro", Colors.blue),
                       if(recipe.isHalal) _buildTag(Icons.check_circle, "Halal", Colors.green),
                     ],
                   )
                 ],
               ),
             )
           ],
         ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(context),
              )
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(recipe.title, style: const TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
              background: recipe.imageUrl.startsWith('http')
                  ? Image.network(recipe.imageUrl, fit: BoxFit.cover)
                  : (recipe.imageUrl.isNotEmpty
                      ? Image.file(File(recipe.imageUrl), fit: BoxFit.cover)
                      : Container(color: Colors.grey)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Macros
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       _buildMacroItem("Kalori", "${recipe.calories}", Colors.orange),
                       _buildMacroItem("Protein", "${recipe.protein}g", Colors.blue),
                       _buildMacroItem("Lemak", "${recipe.fat}g", Colors.red),
                       _buildMacroItem("Karbo", "${recipe.carbs}g", Colors.green),
                     ],
                   ),
                   const Divider(height: 40),

                   const Text("Bahan-bahan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                   ...recipe.ingredients.map((e) => Padding(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(children: [const Icon(Icons.circle, size: 6, color: AppColors.primaryDark), const SizedBox(width: 8), Expanded(child: Text(e))]),
                   )),
                   
                   const SizedBox(height: 24),
                   
                   const Text("Cara Membuat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 8),
                    ...recipe.instructions.map((e) => Padding(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         const Text("• ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
                         Expanded(child: Text(e))
                       ]
                     ),
                   )),
                   
                   const SizedBox(height: 40),
                   SizedBox(
                     width: double.infinity,
                     child: ElevatedButton.icon(
                       onPressed: () {
                         showModalBottomSheet(
                           context: context, 
                           builder: (context) => _buildMealTypeSelector(context)
                         );
                       }, 
                       icon: const Icon(Icons.add),
                       label: const Text("Tambahkan ke Meal Plan Hari Ini"),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primaryDark,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(vertical: 16),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                       ),
                     ),
                   )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  
  Widget _buildMealTypeSelector(BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),
        height: 300,
        child: Column(
          children: [
            const Text("Pilih Waktu Makan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                   _buildMealOption(context, 'Sarapan', 'breakfast'),
                   _buildMealOption(context, 'Makan Siang', 'lunch'),
                   _buildMealOption(context, 'Makan Malam', 'dinner'),
                   _buildMealOption(context, 'Camilan', 'snack'),
                ],
              ),
            )
          ],
        ),
      );
  }

  Widget _buildMealOption(BuildContext context, String label, String type) {
    return ListTile(
      title: Text(label),
      leading: const Icon(Icons.restaurant),
      onTap: () async {
         // Import MealPlanService locally or at top
         await MealPlanService.addRecipeToPlan(type, recipe.id);
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${recipe.title} ditambahkan ke $label")));
      },
    );
  }

  Widget _buildMacroItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Resep?"),
        content: const Text("Apakah anda yakin ingin menghapus resep ini?"),
        actions: [
          TextButton(
            child: const Text("Batal"), 
            onPressed: () => Navigator.pop(ctx)
          ),
          TextButton(
            child: const Text("Hapus", style: TextStyle(color: Colors.red)), 
            onPressed: () async {
              await RecipeService.deleteRecipe(recipe.id);
              if (context.mounted) {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context, true); // Close screen and return true
              }
            }
          ),
        ]
      )
    );
  }
}
