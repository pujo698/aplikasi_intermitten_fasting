import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../../../core/theme/app_colors.dart';

class WaterTrackerCard extends StatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  State<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends State<WaterTrackerCard> {
  int waterIntake = 0;
  final int waterGoal = 2500; // Standard goal

  @override
  void initState() {
    super.initState();
    _loadWater();
  }

  Future<void> _loadWater() async {
    final w = await StorageService.loadWater();
    if (mounted) {
      setState(() {
        waterIntake = w;
      });
    }
  }

  Future<void> _updateWater(int delta) async {
    int newValue = waterIntake + delta;
    if (newValue < 0) newValue = 0;

    setState(() {
      waterIntake = newValue;
    });

    await StorageService.saveWater(newValue);
  }

  @override
  Widget build(BuildContext context) {
    double progress = (waterIntake / waterGoal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: Colors.blue),
              const SizedBox(width: 8),
              const Text("Air Minum", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Text("$waterIntake / $waterGoal ml", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.blue[50],
              color: Colors.blue,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               _buildButton(Icons.remove, () => _updateWater(-250)),
               const Text("250ml", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
               _buildButton(Icons.add, () => _updateWater(250)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue),
      ),
    );
  }
}
