import 'dart:async';

enum FastingStatus { eating, fasting }

class FastingController {
  final DateTime startEating;
  final int eatingHours;



  late Stream<DateTime> timerStream;

  FastingController({
    required this.startEating,
    required this.eatingHours,
  }) {
    timerStream =
        Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
  }

  FastingStatus getStatus(DateTime now) {
    // Check Today's window
    if (_isInEatingWindow(now, now)) return FastingStatus.eating;
    
    // Check Yesterday's window (in case it spills over to today)
    if (_isInEatingWindow(now, now.subtract(const Duration(days: 1)))) {
      return FastingStatus.eating;
    }

    return FastingStatus.fasting;
  }

  bool _isInEatingWindow(DateTime now, DateTime baseDate) {
    final start = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      startEating.hour,
      startEating.minute,
    );
    final end = start.add(Duration(hours: eatingHours));
    return now.isAfter(start) && now.isBefore(end);
  }

  Duration getRemaining(DateTime now) {
    // Find the relevant window boundaries
    final todayStart = DateTime(
      now.year, now.month, now.day, startEating.hour, startEating.minute);
    
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    // If currently eating (owing to Today's start)
    if (_isInEatingWindow(now, now)) {
        final end = todayStart.add(Duration(hours: eatingHours));
        return end.difference(now);
    }

    // If currently eating (owing to Yesterday's start)
    if (_isInEatingWindow(now, yesterdayStart)) {
        final end = yesterdayStart.add(Duration(hours: eatingHours));
        return end.difference(now);
    }

    // If Fasting.
    // Next eating window could be Today's (if we are before it) or Tomorrow's (if we are after it)
    if (now.isBefore(todayStart)) {
        return todayStart.difference(now);
    } else {
        return tomorrowStart.difference(now);
    }
  }
}
