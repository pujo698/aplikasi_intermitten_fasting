import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../services/storage_service.dart';
import '../../fasting/models/fasting_model.dart'; // Reuse model if needed or pass raw data

class PlanConfigurationScreen extends StatefulWidget {
  final String planName;
  final int eatingHours;

  const PlanConfigurationScreen({
    super.key,
    required this.planName,
    required this.eatingHours,
  });

  @override
  State<PlanConfigurationScreen> createState() => _PlanConfigurationScreenState();
}

class _PlanConfigurationScreenState extends State<PlanConfigurationScreen> {
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _savePlan() async {
    final now = DateTime.now();
    // Start Eating Today at the selected time
    // If the time has already passed today, usually apps still set it for today (so the current status is Eating or Fasting depending on duration)
    // Or users might mean "Start Tomorrow". For simplicity, let's assume Today.
    
    final startEating = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime.hour,
      _startTime.minute,
    );
    
    // Logic to determine if "startEating" implies we are currently eating or fasting is handled by the Controller usually.
    // We strictly save the "Start Time Reference" and "Duration".
    
    final eatingHours = widget.eatingHours;
    final startFasting = startEating.add(Duration(hours: eatingHours));

    // Clear old notifications
    await NotificationService.cancelAll();

    // Schedule Notifications (Eating Window Start) (Repeat Daily)
    await NotificationService.scheduleDaily(
      id: 1,
      title: "🍽️ Waktu Makan",
      body: "Jendela makan ${widget.planName} dimulai sekarang!",
      time: startEating,
    );

    // Schedule Notifications (Fasting Window Start) (Repeat Daily)
    await NotificationService.scheduleDaily(
      id: 2,
      title: "⏳ Mulai Puasa",
      body: "Waktunya puasa (${24 - eatingHours} jam) dimulai!",
      time: startFasting,
    );

    // Save to Storage
    await StorageService.saveFasting(
      startEating: startEating,
      eatingHours: eatingHours,
    );

    if (!mounted) return;

    // Show confirmation and navigate back/home
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Rencana ${widget.planName} telah diaktifkan!")),
    );
    
    // Navigate back to Home (pop until first route usually, or switch tab)
    // Since we are in a tab (Rencana), we might want to switch the tab to Home.
    // However, since we don't have direct access to the parent TabController's state easily without provider/callback,
    // We will just Pop. The user can manually switch to "Puasa" tab to see the updated timer.
    // Alternatively, we can assume the user wants to go back to the list.
    Navigator.pop(context, true); 
  }

  @override
  Widget build(BuildContext context) {
    // Calculate End Time for display
    final startDt = DateTime(2022, 1, 1, _startTime.hour, _startTime.minute);
    final endDt = startDt.add(Duration(hours: widget.eatingHours));
    final endTime = TimeOfDay.fromDateTime(endDt);

    final fastingHours = 24 - widget.eatingHours;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Atur ${widget.planName}"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              "Kapan Anda ingin mulai makan?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
            ),
            const SizedBox(height: 8),
            Text(
              "Kami akan mengatur notifikasi puasa berdasarkan waktu makan Anda.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Time Picker Card
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mulai Makan", style: TextStyle(color: Colors.blueGrey)),
                        Text(
                          _startTime.format(context),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ],
                    ),
                    const Icon(Icons.edit, color: Colors.blue),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Info Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context, 
                    "Jendela Makan", 
                    "${widget.eatingHours} Jam", 
                    "${_startTime.format(context)} - ${endTime.format(context)}",
                    Icons.restaurant,
                    Colors.orange
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context, 
                    "Jendela Puasa", 
                    "$fastingHours Jam", 
                    "${endTime.format(context)} - ${_startTime.format(context)}",
                    Icons.bolt,
                    Colors.green
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePlan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Mulai Rencana Ini",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, String subValue, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subValue, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
