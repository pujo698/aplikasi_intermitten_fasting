import '../../../core/constants/fasting_type.dart';

class FastingModel {
  final FastingType type;
  final DateTime startEating;
  final int eatingHours;

  FastingModel({
    required this.type,
    required this.startEating,
    required this.eatingHours,
  });
}


