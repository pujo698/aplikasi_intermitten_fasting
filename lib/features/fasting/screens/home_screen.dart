import 'package:flutter/material.dart';
import '../controllers/fasting_controller.dart';
import '../models/fasting_model.dart';
import '../widgets/circular_timer.dart';
import '../widgets/ocean_background.dart';
import 'setting_screen.dart';
import 'statistic_screen.dart'; 
import '../../services/storage_service.dart';
import '../../services/notification_service.dart';
import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FastingController? controller;
  FastingStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    final data = await StorageService.loadFasting();

    if (data != null) {
      setState(() {
        controller = FastingController(
          startEating: data['startEating'],
          eatingHours: data['eatingHours'],
        );
      });

      NotificationService.rescheduleFromStorage();
    } else {
      setState(() {
       controller = FastingController(
        startEating: DateTime.now(),
        eatingHours: 8,
      );  
      });
    }
  }

  Future<void> openSetting() async {
    final result = await Navigator.push<FastingModel>(
      context,
      MaterialPageRoute(builder: (_) => const SettingScreen()),
    );

    if (result != null) {
      setState(() {
        controller = FastingController(
          startEating: result.startEating,
          eatingHours: result.eatingHours,
        );
        _lastStatus = null; // Reset status tracking on setting change
      });
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String hours = twoDigits(d.inHours);
    String minutes = twoDigits(d.inMinutes.remainder(60));
    String seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return OceanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // Important for OceanBackground
        appBar: AppBar(
          title: const Text("Puasa Mas"),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticScreen()),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: openSetting,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
           backgroundColor: AppColors.primaryDark,
           selectedItemColor: AppColors.accent,
           unselectedItemColor: AppColors.textWhite.withValues(alpha: 0.5),
           showSelectedLabels: false,
           showUnselectedLabels: false,
           type: BottomNavigationBarType.fixed,
           elevation: 0,
           items: const [
             BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
             BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jurnal'),
             BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Mind'),
             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
           ],
           onTap: (idx) {
               // Placeholder for now
               if (idx == 1) {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticScreen()));
               }
           },
        ),
        body: StreamBuilder<DateTime>(
          stream: controller!.timerStream,
          builder: (context, snapshot) {
            final now = snapshot.data ?? DateTime.now();
            final status = controller!.getStatus(now);
            final remaining = controller!.getRemaining(now);
            
            // Calc progress (1.0 to 0.0) -> Depleting
            double totalSeconds = status == FastingStatus.eating 
                ? controller!.eatingHours * 3600.0
                : (24 - controller!.eatingHours) * 3600.0;
            
            double remainingSeconds = remaining.inSeconds.toDouble();
            double progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);


            // Logic to detect transition to Fasting and save record
            if (_lastStatus != null && _lastStatus != status) {
               if (_lastStatus == FastingStatus.eating && status == FastingStatus.fasting) {
                   StorageService.saveTodayRecord(24 - controller!.eatingHours);
               }
            }
            
            // Update last status safely
            if (_lastStatus != status) {
               WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) { 
                     setState(() {
                        _lastStatus = status;
                     });
                  }
               });
            }

            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        status == FastingStatus.eating 
                           ? "Waktu untuk menutrisi tubuh."
                           : "Tubuh sedang beristirahat.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 48),

                    CircularTimer(
                      progress: progress,
                      label: status == FastingStatus.eating ? "WAKTU MAKAN" : "SEDANG PUASA",
                      time: formatDuration(remaining),
                    ),

                    const SizedBox(height: 48),

                    // Bottom Cards / Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip(
                           icon: Icons.wb_sunny_outlined, 
                           label: "Start", 
                           value: "${controller!.startEating.hour}:${controller!.startEating.minute.toString().padLeft(2, '0')}"
                        ),
                         const SizedBox(width: 16),
                        _buildInfoChip(
                           icon: Icons.nightlight_outlined, 
                           label: "Goal", 
                           value: "${controller!.eatingHours} : ${24 - controller!.eatingHours}"
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required String value}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.white60)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            )
          ],
        ),
      );
  }
}
