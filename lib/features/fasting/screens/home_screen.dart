import 'package:flutter/material.dart';
import '../controllers/fasting_controller.dart';
import '../models/fasting_model.dart';
import '../widgets/circular_timer.dart';
import '../widgets/ocean_background.dart';
import 'setting_screen.dart';
import 'statistic_screen.dart'; 
import '../../diet/screens/diet_input_screen.dart'; 
import '../../profile/screens/profile_screen.dart'; 
import '../../plan/screens/plan_screen.dart';
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
  int _currentIndex = 0; // 0: Puasa, 1: Rencana, 2: Mempelajari, 3: Resep, 4: Saya

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
    
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            /// [0] PUASA (With Ocean Background)
            OceanBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent, 
                appBar: AppBar(
                  title: const Text("Puasa Mas"),
                  backgroundColor: Colors.transparent, 
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
                body: StreamBuilder<DateTime>(
                  stream: controller!.timerStream,
                  builder: (context, snapshot) {
                    final now = snapshot.data ?? DateTime.now();
                    final status = controller!.getStatus(now);
                    final remaining = controller!.getRemaining(now);
                    
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
            ),

            /// [1] RENCANA
            PlanScreen(
              onPlanUpdate: loadSavedData, 
              goToProfile: () {
                setState(() {
                  _currentIndex = 4; // Switch to Profile tab
                });
              }
            ),

            /// [2] MEMPELAJARI
            const Scaffold(body: Center(child: Text("Fitur Mempelajari segera hadir"))),

            /// [3] RESEP
            const Scaffold(body: Center(child: Text("Fitur Resep segera hadir"))),

            /// [4] SAYA (Profile)
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
           backgroundColor: Colors.white,
           selectedItemColor: AppColors.primaryDark,
           unselectedItemColor: Colors.grey,
           showSelectedLabels: true,
           showUnselectedLabels: true,
           type: BottomNavigationBarType.fixed,
           currentIndex: _currentIndex,
           items: const [
             BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Puasa'),
             BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Rencana'), // Updated icon
             BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Mempelajari'),
             BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Resep'),
             BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Saya'),
           ],
           onTap: (idx) {
               setState(() {
                 _currentIndex = idx;
               });
           },
        ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required String value}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface, // Adjusted for OceanBackground visibility
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardSurface),
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
