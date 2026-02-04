import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../controllers/diet_calculator.dart';
import 'diet_result_screen.dart';

class DietInputScreen extends StatefulWidget {
  const DietInputScreen({super.key});

  @override
  State<DietInputScreen> createState() => _DietInputScreenState();
}

class _DietInputScreenState extends State<DietInputScreen> {
  final _formKey = GlobalKey<FormState>();

  Gender gender = Gender.male;
  ActivityLevel activity = ActivityLevel.medium;
  DietGoal goal = DietGoal.fatLoss;

  int age = 25;
  double weight = 60;
  double height = 170;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diet Otomatis"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// GENDER
              const Text("Jenis Kelamin"),
              DropdownButtonFormField<Gender>(
                value: gender,
                items: const [
                  DropdownMenuItem(
                    value: Gender.male,
                    child: Text("Pria"),
                  ),
                  DropdownMenuItem(
                    value: Gender.female,
                    child: Text("Wanita"),
                  ),
                ],
                onChanged: (value) => setState(() => gender = value!),
              ),

              const SizedBox(height: 16),

              /// AGE
              TextFormField(
                initialValue: age.toString(),
                decoration: const InputDecoration(
                  labelText: "Umur (tahun)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                        ? "Umur tidak valid"
                        : null,
                onSaved: (value) => age = int.parse(value!),
              ),

              const SizedBox(height: 16),

              /// WEIGHT
              TextFormField(
                initialValue: weight.toString(),
                decoration: const InputDecoration(
                  labelText: "Berat Badan (kg)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? "Berat tidak valid"
                        : null,
                onSaved: (value) => weight = double.parse(value!),
              ),

              const SizedBox(height: 16),

              /// HEIGHT
              TextFormField(
                initialValue: height.toString(),
                decoration: const InputDecoration(
                  labelText: "Tinggi Badan (cm)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? "Tinggi tidak valid"
                        : null,
                onSaved: (value) => height = double.parse(value!),
              ),

              const SizedBox(height: 16),

              /// ACTIVITY
              const Text("Aktivitas Harian"),
              DropdownButtonFormField<ActivityLevel>(
                value: activity,
                items: const [
                  DropdownMenuItem(
                    value: ActivityLevel.low,
                    child: Text("Rendah"),
                  ),
                  DropdownMenuItem(
                    value: ActivityLevel.medium,
                    child: Text("Sedang"),
                  ),
                  DropdownMenuItem(
                    value: ActivityLevel.high,
                    child: Text("Tinggi"),
                  ),
                ],
                onChanged: (value) => setState(() => activity = value!),
              ),

              const SizedBox(height: 16),

              /// GOAL
              const Text("Tujuan Diet"),
              DropdownButtonFormField<DietGoal>(
                value: goal,
                items: const [
                  DropdownMenuItem(
                    value: DietGoal.fatLoss,
                    child: Text("Fat Loss"),
                  ),
                  DropdownMenuItem(
                    value: DietGoal.maintain,
                    child: Text("Maintain"),
                  ),
                  DropdownMenuItem(
                    value: DietGoal.muscleGain,
                    child: Text("Muscle Gain"),
                  ),
                ],
                onChanged: (value) => setState(() => goal = value!),
              ),

              const SizedBox(height: 32),

              /// SUBMIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submit,
                  child: const Text("Hitung Diet Plan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final profile = UserProfile(
      gender: gender,
      age: age,
      weight: weight,
      height: height,
      activity: activity,
      goal: goal,
    );

    final result = DietCalculator.calculate(profile);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DietResultScreen(result: result),
      ),
    );
  }
}
