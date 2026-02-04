import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../fasting/models/fasting_record.dart';
  
class StorageService {
  static const _startEating = 'start_eating';
  static const _eatingHours = 'eating_hours';

  static Future saveFasting({
    required DateTime startEating,
    required int eatingHours,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_startEating, startEating.millisecondsSinceEpoch);
    await prefs.setInt(_eatingHours, eatingHours);
  }

  static Future<Map<String, dynamic>?> loadFasting() async {
    final prefs = await SharedPreferences.getInstance();
    final start = prefs.getInt(_startEating);
    final hours = prefs.getInt(_eatingHours);

    if (start == null || hours == null) return null;

    return {
      'startEating': DateTime.fromMillisecondsSinceEpoch(start),
      'eatingHours': hours,
    };
  }
  static const _records = 'fasting_records';

  static Future saveTodayRecord(int fastingHours) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_records) ?? [];

    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month}-${today.day}";

    // Check if valid record already exists for today
    bool exists = list.any((e) {
      final map = jsonDecode(e);
      final recordDate = DateTime.fromMillisecondsSinceEpoch(map['date']);
      return "${recordDate.year}-${recordDate.month}-${recordDate.day}" == dateStr;
    });

    if (exists) return;

    final record = FastingRecord(
      date: DateTime(today.year, today.month, today.day),
      fastingHours: fastingHours,
    );

    list.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_records, list);
  }

  static Future<List<FastingRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_records) ?? [];

    return list
        .map((e) => FastingRecord.fromJson(jsonDecode(e)))
        .toList();
  }
}
