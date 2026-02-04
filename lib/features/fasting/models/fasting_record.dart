class FastingRecord {
  final DateTime date;
  final int fastingHours;

  FastingRecord({
    required this.date,
    required this.fastingHours,
  });

  Map<String, dynamic> toJson() => {
        'date': date.millisecondsSinceEpoch,
        'hours': fastingHours,
      };

  factory FastingRecord.fromJson(Map<String, dynamic> json) {
    return FastingRecord(
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      fastingHours: json['hours'],
    );
  }
}
