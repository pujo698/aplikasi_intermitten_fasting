import 'package:flutter/material.dart';

import '../../services/storage_service.dart';
import '../../diet/screens/diet_input_screen.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Stats
  int totalFasts = 0;
  String currentWeight = "-";
  String currentHeight = "-";
  String dietGoal = "Belum diset";
  String goalEstimation = ""; // Instance variable
  String averageFasting = "0h";
  String longestFasting = "0h";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // Load Records for Stats
    final records = await StorageService.loadRecords();
    int count = records.length;
    int maxDuration = 0;
    int totalDuration = 0;

    for (var r in records) {
      if (r.fastingHours > maxDuration) maxDuration = r.fastingHours;
      totalDuration += r.fastingHours;
    }
  
  // ...

    // Load User Profile
    final profile = await StorageService.loadUserProfile();
    String weight = "-";
    String height = "-";
    String goal = "Belum diset";
    String estimation = " ";

    if (profile != null) {
      weight = "${profile['weight']}kg";
      height = "${profile['height']}cm";
      
      // Format Goal Name
      final rawGoal = profile['goal'];
      if (rawGoal == 'fatLoss') {
         goal = "Turun Berat Badan";
         final target = profile['targetWeight'];
         final months = profile['estimatedMonths'];
         
         if (target != null && months != null) {
            final finishDate = DateTime.now().add(Duration(days: (months as int) * 30));
            // Simple month mapper
            const monthsNames = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"];
            estimation = "Target: ${target}kg\nEstimasi: ${monthsNames[finishDate.month - 1]} ${finishDate.year}";
         }
      }
      else if (rawGoal == 'maintain') goal = "Jaga Berat Badan";
      else if (rawGoal == 'muscleGain') goal = "Tambah Otot";
    }

    if (mounted) {
      setState(() {
        totalFasts = count;
        longestFasting = "${maxDuration}h";
        averageFasting = count > 0 ? "${(totalDuration / count).toStringAsFixed(1)}h" : "0h";
        currentWeight = weight;
        currentHeight = height;
        dietGoal = goal;
        goalEstimation = estimation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[50], // Removed to use theme background (AppColors.primaryDark)
 // Keep light background for now, or change to white/AppColors.accent.withOpacity(0.1)

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, size: 30, color: AppColors.primaryDark),
                ),
                Text(
                  "Profil Saya",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.settings, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 24),
            
             // Goal Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: AppColors.mainGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryLight.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0,4))
                ]
              ),
              child: Column(
                children: [
                   const Text("🎯 Tujuan Saat Ini", style: TextStyle(color: Colors.white70)),
                   const SizedBox(height: 8),
                   Text(dietGoal, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                   if (goalEstimation.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        goalEstimation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic)
                      ),
                   ],
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: () {
                        // Navigate to Diet Input for editing
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DietInputScreen())).then((_) => loadData());
                     },
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.white,
                       foregroundColor: AppColors.primaryDark,
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                     ),
                     child: const Text("Ubah Data / Diet Plan")
                   )
                ],
              ),
            ),

            // Stats Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(Icons.calendar_today, "Total Puasa", "$totalFasts hari", AppColors.primaryDark),
                      _buildStatItem(Icons.monitor_weight, "Berat Badan", currentWeight, Colors.green),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(Icons.height, "Tinggi Badan", currentHeight, Colors.purple), // Updated Icon
                      _buildStatItem(Icons.history, "Puasa Terlama", longestFasting, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Prestasi / Badges

            
            const SizedBox(height: 24),
            
            // 🚨 Disclaimer Medis
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PENTING",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[900], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Intermittent fasting bukan untuk semua orang. Jika Anda memiliki kondisi medis (Maag, Diabetes, Hipotensi), konsultasikan dengan dokter sebelum memulai.",
                          style: TextStyle(color: Colors.red[900], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }


}
