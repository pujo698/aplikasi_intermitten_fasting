import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../controllers/diet_calculator.dart';
import '../controllers/diet_fasting_integrator.dart';
import '../../fasting/controllers/fasting_controller.dart';
import '../../services/storage_service.dart';
import 'diet_result_screen.dart';
import '../../../core/theme/app_colors.dart';

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
  
  bool hasMaag = false; // Medical profiling

  int currentEatingHours = 8; // Default 16:8

  @override
  void initState() {
    super.initState();
    _loadFastingPlan();
  }

  Future<void> _loadFastingPlan() async {
    final data = await StorageService.loadFasting();
    if (data != null) {
      setState(() {
        currentEatingHours = data['eatingHours'];
      });
    }
  }

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
               Container(
                 padding: const EdgeInsets.all(12),
                 margin: const EdgeInsets.only(bottom: 24),
                 decoration: BoxDecoration(
                   color: AppColors.primaryLight.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: AppColors.primaryLight.withOpacity(0.3))
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.timer, color: AppColors.primaryLight),
                     const SizedBox(width: 12),
                     Expanded(child: Text("Estimasi disesuaikan dengan rencana puasa Anda: Jendela makan $currentEatingHours jam.", style: const TextStyle(color: AppColors.primaryDark, fontSize: 13))),
                   ],
                 )
               ),

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
                onChanged: (value) => setState(() => weight = double.tryParse(value) ?? weight),
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
                    child: Text("Fat Loss (Turun Berat Badan)"),
                  ),
                  DropdownMenuItem(
                    value: DietGoal.maintain,
                    child: Text("Maintain (Jaga Berat Badan)"),
                  ),
                  DropdownMenuItem(
                    value: DietGoal.muscleGain,
                    child: Text("Muscle Gain (Tambah Otot)"),
                  ),
                ],
                onChanged: (value) => setState(() => goal = value!),
              ),

              if (goal == DietGoal.fatLoss) ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Target Berat Badan (kg)",
                    border: OutlineInputBorder(),
                    helperText: "Estimasi: Turun 2kg / bulan",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                     if (value == null || double.tryParse(value) == null) {
                       return "Target tidak valid";
                     }
                     final t = double.parse(value);
                     if (t >= weight) {
                       return "Target harus lebih kecil dari berat saat ini";
                     }
                     return null;
                  },
                  onSaved: (value) => targetWeight = double.parse(value!),
                ),
              ],

              const SizedBox(height: 24),
              
              const Divider(),
              
              // 2️⃣ Health Profiling (Maag/GERD Check)
              CheckboxListTile(
                 contentPadding: EdgeInsets.zero,
                 title: const Text("Saya memiliki riwayat Maag / GERD"),
                 value: hasMaag,
                 controlAffinity: ListTileControlAffinity.leading,
                 activeColor: Colors.orange,
                 onChanged: (val) {
                   setState(() {
                     hasMaag = val ?? false;
                   });
                 }
              ),
              
              if (hasMaag)
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: Colors.orange[50],
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: Colors.orange.withOpacity(0.3))
                   ),
                   child: const Text(
                      "⚠️ Disarankan mulai dengan protokol ringan (12:12 atau 14:10). Hindari kopi perut kosong & makanan pedas/asam saat berbuka.",
                      style: TextStyle(fontSize: 12, color: Colors.brown),
                   ),
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

  double? targetWeight;

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final profile = UserProfile(
      gender: gender,
      age: age,
      weight: weight,
      height: height,
      activity: activity,
      goal: goal,
      targetWeight: targetWeight,
    );

    final result = DietCalculator.calculate(profile);

    // Calculate Estimation if Fat Loss
    int? estMonths;
    if (goal == DietGoal.fatLoss && targetWeight != null) {
       estMonths = DietCalculator.calculateWeightLossDurationInMonths(weight, targetWeight!, currentEatingHours);
    }
    
    // Save Profile to Storage
    await StorageService.saveUserProfile(
      age: age,
      weight: weight,
      height: height,
      gender: gender.name,
      activity: activity.name,
      goal: goal.name,
      targetWeight: targetWeight,
      estimatedMonths: estMonths,
    );

    if (!mounted) return;

    String msg = "Data diet berhasil disimpan!";
    if (estMonths != null && estMonths > 0) {
       msg += " Estimasi waktu: $estMonths bulan.";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );

    // Return true to indicate successful save
    Navigator.pop(context, true);
  }
}
