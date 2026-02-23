import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../fasting/models/fasting_record.dart';
  
class StorageService {
  static const String _keyFasting = 'fasting_data';
  static const String _keyRecords = 'fasting_records';
  static const String _keyProfile = 'user_profile';
  static const String _keyWater = 'water_daily'; // NEW

  // ... (Existing methods)

  /// Water Tracker
  static Future<void> saveWater(int ml) async {
    final prefs = await SharedPreferences.getInstance();
    // Reset if new day (simple check)
    final lastDate = prefs.getString('${_keyWater}_date');
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastDate != today) {
       await prefs.setString('${_keyWater}_date', today);
       await prefs.setInt(_keyWater, ml);
    } else {
       await prefs.setInt(_keyWater, ml);
    }
  }

  static Future<int> loadWater() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('${_keyWater}_date');
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastDate != today) {
      return 0; // New day, reset
    }
    return prefs.getInt(_keyWater) ?? 0;
  }
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

  static const _userProfile = 'user_profile';

  static Future saveUserProfile({
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activity,
    required String goal,
    double? targetWeight,
    int? estimatedMonths,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'activity': activity,
      'goal': goal,
      'targetWeight': targetWeight,
      'estimatedMonths': estimatedMonths,
    };
    await prefs.setString(_userProfile, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userProfile);
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr);
  }

  static Future<List<FastingRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_records) ?? [];

    return list
        .map((e) => FastingRecord.fromJson(jsonDecode(e)))
        .toList();
  }
}
