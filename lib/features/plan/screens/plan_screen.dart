import 'package:flutter/material.dart';
import '../../diet/screens/diet_input_screen.dart';
import 'plan_configuration_screen.dart';

class PlanScreen extends StatelessWidget {
  final VoidCallback? onPlanUpdate;
  final VoidCallback? goToProfile;

  const PlanScreen({super.key, this.onPlanUpdate, this.goToProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      appBar: AppBar(
        title: const Text("Rencana", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Diet Calculator (Previous Feature)
            _buildCustomPlanCard(context),
            const SizedBox(height: 24),
            
            const Text(
              "Rencana panas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Grid Plans
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

  Widget _buildCustomPlanCard(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const DietInputScreen()));
        if (result == true) {
           goToProfile?.call();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF6DD),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rencana yang Disesuaikan",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E5E32)
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hitung kalori & makro harianmu di sini",
                    style: TextStyle(color: Color(0xFF4A7A4E)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Cek Sekarang",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            // Placeholder for illustration
            const Icon(Icons.calculate, size: 60, color: Color(0xFF4CAF50)),
          ],
        ),
      ),
    );
  }

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
           onPlanUpdate?.call();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fullColor ? const Color(0xFF00C896) : color,
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
                    color: fullColor ? Colors.white : Colors.black87,
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
                    color: fullColor ? Colors.white : Colors.black87,
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
                    color: fullColor ? Colors.white : Colors.black87,
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

