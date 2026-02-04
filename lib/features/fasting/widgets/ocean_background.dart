import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class OceanBackground extends StatelessWidget {
  final Widget child;

  const OceanBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.mainGradient,
      ),
      child: child,
    );
  }
}
