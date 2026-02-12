enum Gender { male, female }
enum ActivityLevel { low, medium, high }
enum DietGoal { fatLoss, maintain, muscleGain }

class UserProfile {
  final Gender gender;
  final int age;
  final double weight;
  final double height;
  final ActivityLevel activity;
  final DietGoal goal;
  final double? targetWeight;

  UserProfile({
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.activity,
    required this.goal,
    this.targetWeight,
  });
}
