import 'package:flutter/material.dart';
import '../models/diet_result.dart';
import '../models/meal_slot.dart';

class DietResultScreen extends StatelessWidget {
  final DietResult result;
  final List<MealSlot> meals;

  const DietResultScreen({
    super.key,
    required this.result,
    required this.meals,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasil Diet Kamu"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔥 TOTAL KALORI
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Kalori Harian",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${result.calories} kcal",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🍽️ MAKRO NUTRISI
            const Text(
              "Pembagian Makro Nutrisi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _MacroTile(
              label: "Protein",
              value: result.protein,
              unit: "gram",
              icon: Icons.fitness_center,
              color: Colors.red,
            ),

            _MacroTile(
              label: "Karbohidrat",
              value: result.carbs,
              unit: "gram",
              icon: Icons.rice_bowl,
              color: Colors.orange,
            ),

            _MacroTile(
              label: "Lemak",
              value: result.fat,
              unit: "gram",
              icon: Icons.opacity,
              color: Colors.blue,
            ),

            const SizedBox(height: 24),

            /// ⚠️ DISCLAIMER
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Hasil ini merupakan estimasi berdasarkan data yang kamu input. "
                      "Bukan pengganti saran medis atau ahli gizi profesional.",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// ⏰ MEAL SCHEDULE
            if (meals.isNotEmpty) ...[
              const Text(
                "Rekomendasi Jam Makan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...meals.map((m) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.schedule, color: Colors.green),
                      ),
                      title: Text(
                        "${m.time.hour.toString().padLeft(2, '0')}:${m.time.minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${m.calories} kcal | P ${m.protein}g | C ${m.carbs}g | F ${m.fat}g",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
            ],
            /// 🥗 LOCAL MENU GUIDE
            const Text(
              "Panduan Makanan Lokal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                   _FoodItem(icon: "🍚", title: "Karbohidrat", desc: "Nasi Merah, Ubi, Jagung"),
                   Divider(),
                   _FoodItem(icon: "🍗", title: "Protein", desc: "Tempe, Tahu, Dada Ayam, Ikan"),
                   Divider(),
                   _FoodItem(icon: "🥦", title: "Serat", desc: "Sayur Bayam, Kangkung, Brokoli"),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// 💧 HYDRATION GUIDE
            const Text(
              "Aturan Minum Saat Puasa",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                   _FoodItem(icon: "💧", title: "Air Putih", desc: "Wajib! Minum 2-3 liter/hari"),
                   Divider(),
                   _FoodItem(icon: "☕", title: "Kopi & Teh", desc: "Boleh (Tanpa Gula & Susu)"),
                   Divider(),
                   _FoodItem(icon: "❌", title: "Hindari", desc: "Minuman manis, Soda, Susu"),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FoodItem extends StatelessWidget {
  final String icon;
  final String title;
  final String desc;

  const _FoodItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final IconData icon;
  final Color color;

  const _MacroTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: "$value ",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextSpan(
                text: unit,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

