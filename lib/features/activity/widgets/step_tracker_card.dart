import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import 'dart:async';

class StepTrackerCard extends StatefulWidget {
  const StepTrackerCard({super.key});

  @override
  State<StepTrackerCard> createState() => _StepTrackerCardState();
}

class _StepTrackerCardState extends State<StepTrackerCard> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  
  String _status = 'Unknown';
  int _steps = 0;
  int _dailySteps = 0; 
  int _offset = 0;     

  bool _isError = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Request Permission
    if (await Permission.activityRecognition.request().isGranted) {
      _initPedometer();
    } else {
       setState(() {
         _isError = true;
         _status = "Izin Ditolak";
       });
    }
  }

  void _initPedometer() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream
        .listen(onStepCount)
        .onError(onStepCountError);
  }

  void onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString('step_date');
    
    int savedOffset = prefs.getInt('step_offset') ?? -1;

    // New Day or First Run
    if (lastDate != today || savedOffset == -1) {
       savedOffset = event.steps;
       await prefs.setString('step_date', today);
       await prefs.setInt('step_offset', savedOffset);
    }

    if (mounted) {
      setState(() {
        _steps = event.steps;
        _offset = savedOffset;
        _dailySteps = _steps - _offset;
        if (_dailySteps < 0) _dailySteps = 0; 
      });
    }
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    if (mounted) {
      setState(() {
        _status = event.status;
      });
    }
  }

  void onPedestrianStatusError(error) {
    if (mounted) {
      setState(() {
        _status = 'Sensor Error';
        _isError = true;
      });
    }
  }

  void onStepCountError(error) {
    if (mounted) {
      setState(() {
        _status = 'Step Count Error'; 
        _isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calc Distance (approx 0.7m per step) & Calories (approx 0.04 kcal per step)
    double km = (_dailySteps * 0.7) / 1000;
    int kcal = (_dailySteps * 0.04).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6dd5ed), Color(0xFF2193b0)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2193b0).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Langkah Hari Ini", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    _isError ? "Unavailable" : "$_dailySteps",
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Icon(_status == 'walking' ? Icons.directions_walk : Icons.accessibility_new, color: Colors.white.withOpacity(0.8), size: 40),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfo(Icons.local_fire_department, "$kcal kcal"),
              _buildInfo(Icons.map, "${km.toStringAsFixed(2)} km"),
            ],
          ),
          if (_isError)
            Padding(
               padding: const EdgeInsets.only(top: 8),
               child: Text("Sensor tidak terdeteksi di perangkat ini.", style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
            )
        ],
      ),
    );
  }

  Widget _buildInfo(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
