import 'package:flutter/material.dart';
import '../../../core/constants/fasting_type.dart';
import '../models/fasting_model.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  FastingType selectedType = FastingType.fasting16_8;
  TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 0);

  void pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }
  void saveSetting() async {
    final now = DateTime.now();
    final startEating = DateTime(
      now.year,
      now.month,
      now.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final eatingHours = getEatingHours(selectedType);
    final startFasting = startEating.add(Duration(hours: eatingHours));

    // hapus notif lama
    await NotificationService.cancelAll();

    // notif makan
    await NotificationService.scheduleDaily(
      id: 1,
      title: "🍽️ Waktu Makan",
      body: "Silakan mulai makan sekarang",
      time: startEating,
    );

    // notif puasa
    await NotificationService.scheduleDaily(
      id: 2,
      title: "⏳ Mulai Puasa",
      body: "Waktunya mulai puasa",
      time: startFasting,
    );

    await StorageService.saveFasting(
      startEating: startEating,
      eatingHours: eatingHours,
    );

    if (mounted) {
      Navigator.pop(
        context,
        FastingModel(
          type: selectedType,
          startEating: startEating,
          eatingHours: eatingHours,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pengaturan Fasting")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Metode Fasting", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButton<FastingType>(
              value: selectedType,
              isExpanded: true,
              items: FastingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.replaceAll('_', ':')),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedType = value);
                }
              },
            ),

            const SizedBox(height: 24),
            const Text("Jam Mulai Makan", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),

            Row(
              children: [
                Text(
                  selectedTime.format(context),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: pickTime,
                  child: const Text("Pilih Jam"),
                ),
              ],
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveSetting,
                child: const Text("Simpan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
