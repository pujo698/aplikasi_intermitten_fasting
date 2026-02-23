import 'package:flutter/material.dart';
import '../../diet/screens/diet_input_screen.dart';
import '../../meal_plan/services/meal_plan_service.dart';
import '../../recipes/data/recipe_data.dart';
import 'plan_configuration_screen.dart';
import '../../../core/theme/app_colors.dart';

class PlanScreen extends StatefulWidget {
  final VoidCallback? onPlanUpdate;
  final VoidCallback? goToProfile;

  const PlanScreen({super.key, this.onPlanUpdate, this.goToProfile});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  Map<String, List<Recipe>> dailyMeals = {};
  int totalCalories = 0;
  int calorieTarget = 2000; // Default

  @override
  void initState() {
    super.initState();
    _loadMealPlan();
  }

  Future<void> _loadMealPlan() async {
    final plan = await MealPlanService.loadDailyPlan();
    Map<String, List<Recipe>> mapped = {};
    int cal = 0;

    plan.forEach((type, ids) {
       mapped[type] = [];
       for (var id in ids) {
          final recipe = dummyRecipes.firstWhere((r) => r.id == id, orElse: () => dummyRecipes[0]);
          if (recipe.id == id) {
            mapped[type]!.add(recipe);
            cal += recipe.calories;
          }
       }
    });

    if (mounted) {
      setState(() {
        dailyMeals = mapped;
        totalCalories = cal;
      });
    }
  }

  Future<void> _removeMeal(String type, String id) async {
    await MealPlanService.removeRecipeFromPlan(type, id);
    _loadMealPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: AppBar(
        title: Text("Rencana & Makan", style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
        actions: [
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)), onPressed: _loadMealPlan)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0,4))]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Text("Kalori Harian", style: TextStyle(color: AppColors.textWhite)),
                         const SizedBox(height: 4),
                         Text("$totalCalories kcal", style: const TextStyle(color: AppColors.textWhite, fontSize: 28, fontWeight: FontWeight.bold)),
                         Text("Target: ~$calorieTarget kcal", style: const TextStyle(color: AppColors.textWhite, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: AppColors.textWhite.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.restaurant_menu, color: AppColors.textWhite, size: 30),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Meal Plan Hari Ini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (dailyMeals.isEmpty)
              Center(
                 child: Padding(
                   padding: const EdgeInsets.symmetric(vertical: 20),
                   child: Text("Belum ada rencana makan hari ini.\nTambahkan dari menu Resep!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
                 ),
              )
            else ...[
               _buildMealSection("Sarapan", "breakfast"),
               _buildMealSection("Makan Siang", "lunch"),
               _buildMealSection("Makan Malam", "dinner"),
               _buildMealSection("Camilan", "snack"),
            ],

            const SizedBox(height: 32),
            const Text(
              "Jadwal Puasa",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Fasting Plans Grid (Existing code)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildPlanCard(
                  context: context,
                  title: "16:8",
                  subtitle: "16h puasa\n8h makan",
                  eatingHours: 8,
                  tag: "Paling populer",
                  tagColor: Colors.pink[100],
                  tagText: Colors.pink,
                  color: const Color(0xFFE8EFFD),
                  icon: Icons.restaurant_menu,
                  iconColor: Colors.green,
                ),
                _buildPlanCard(
                  context: context,
                  title: "23:1",
                  subtitle: "23h puasa\n1h makan",
                  eatingHours: 1,
                  tag: "OMAD",
                  tagColor: Colors.orange[100],
                  tagText: Colors.orange,
                  color: const Color(0xFFFFF6E4),
                  icon: Icons.bolt,
                  iconColor: Colors.orange,
                ),
                 _buildPlanCard(
                  context: context,
                  title: "20:4",
                  subtitle: "20h puasa\n4h makan",
                  eatingHours: 4,
                  tag: "Diet Pejuang",
                  tagColor: Colors.purple[100],
                  tagText: Colors.purple,
                  color: const Color(0xFFFFF4E8),
                  icon: Icons.timer,
                  iconColor: Colors.green,
                ),
                _buildPlanCard(
                  context: context,
                  title: "14:10",
                  subtitle: "14h puasa\n10h makan",
                  eatingHours: 10,
                  tag: "Mudah dimulai",
                  tagColor: Colors.green[100],
                  tagText: Colors.green,
                  color: const Color(0xFFE0F7EF),
                  icon: Icons.check_circle,
                  iconColor: Colors.white,
                  fullColor: true, 
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, String type) {
     final meals = dailyMeals[type];
     if (meals == null || meals.isEmpty) return const SizedBox.shrink();

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(title, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
          ),
          ...meals.map((recipe) => Container(
             margin: const EdgeInsets.only(bottom: 8),
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: Colors.white,
               borderRadius: BorderRadius.circular(12),
               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0,2))]
             ),
             child: Row(
               children: [
                 ClipRRect(
                   borderRadius: BorderRadius.circular(8),
                   child: Image.network(recipe.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                       Text("${recipe.calories} kcal", style: TextStyle(color: Colors.orange[700], fontSize: 12)),
                     ],
                   ),
                 ),
                 IconButton(
                   icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                   onPressed: () => _removeMeal(type, recipe.id),
                 )
               ],
             ),
          )),
       ],
     );
  }

  // Helper method for Plan Card (Existing)
  Widget _buildPlanCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String tag,
    Color? tagColor,
    Color? tagText,
    required Color color,
    required IconData icon,
    required Color iconColor,
    required int eatingHours,
    bool isPro = false,
    bool fullColor = false,
  }) {
    // ... Copy implementation details from previous file or simplify
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlanConfigurationScreen(
              planName: title,
              eatingHours: eatingHours,
            ),
          ),
        );
        
        if (result == true) {
           widget.onPlanUpdate?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fullColor ? AppColors.mealCardFull : color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: fullColor ? Colors.white : Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                 if (fullColor)
                  const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Icon(icon, size: 16, color: fullColor ? Colors.white : iconColor),
                const SizedBox(width: 4),
                Text(
                  subtitle.split('\n')[0],
                  style: TextStyle(
                    color: fullColor ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 12, 
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
             Row(
              children: [
                Icon(Icons.restaurant, size: 16, color: fullColor ? Colors.white : Colors.orange),
                const SizedBox(width: 4),
                Text(
                  subtitle.split('\n')[1],
                  style: TextStyle(
                    color: fullColor ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 12, 
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: fullColor ? Colors.white.withOpacity(0.2) : tagColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 10,
                  color: fullColor ? Colors.white : tagText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
