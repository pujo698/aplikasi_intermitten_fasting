import '../models/fasting_record.dart';

class StatisticController {
  /// Hitung streak hari berturut-turut
  static int calculateStreak(List<FastingRecord> records) {
    if (records.isEmpty) return 0;

    records.sort((a, b) => b.date.compareTo(a.date));

    int streak = 1;

    for (int i = 1; i < records.length; i++) {
      final diff =
          records[i - 1].date.difference(records[i].date).inDays;

      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
