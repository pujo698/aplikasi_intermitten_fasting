import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'storage_service.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  static Future scheduleDaily({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    if (kIsWeb) return; // Web does not support zonedSchedule easily
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _nextInstance(time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fasting_channel',
            'Fasting Reminder',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("Notification Error: $e");
    }
  }

  static tz.TZDateTime _nextInstance(DateTime time) {
    // ... (rest of _nextInstance logic is fine, but it is helper)
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  static Future cancelAll() async {
    if (kIsWeb) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint("Cancel Notification Error: $e");
    }
  }

  static Future rescheduleFromStorage() async {
    final data = await StorageService.loadFasting();
    if (data == null) return;

    final startEating = data['startEating'] as DateTime;
    final eatingHours = data['eatingHours'] as int;
    final startFasting = startEating.add(Duration(hours: eatingHours));

    await cancelAll();

    await scheduleDaily(
      id: 1,
      title: "🍽️ Waktu Makan",
      body: "Silakan mulai makan sekarang",
      time: startEating,
    );

    await scheduleDaily(
      id: 2,
      title: "⏳ Mulai Puasa",
      body: "Waktunya mulai puasa",
      time: startFasting,
    );
  }
}
