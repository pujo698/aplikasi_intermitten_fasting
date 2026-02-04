import 'package:flutter/material.dart';

class FastingStatusCard extends StatelessWidget {
  final bool isEating;

  const FastingStatusCard({super.key, required this.isEating});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isEating
          ? Colors.green.withValues(alpha: 0.9)
          : Colors.orange.withValues(alpha: 0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
        child: Column(
          children: [
            Icon(
              isEating ? Icons.restaurant : Icons.timer,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              isEating ? "WAKTU MAKAN" : "WAKTU PUASA",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
