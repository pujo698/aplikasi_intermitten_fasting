import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CircularTimer extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final String time;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer faint ring
          SizedBox(
            width: 280,
            height: 280,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 2,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          
          // Progress Ring
          // Progress Ring
          SizedBox(
            width: 280,
            height: 280,
            child: Transform.rotate(
              angle: -1.5708, // -90 degrees (start from top)
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    color: AppColors.accent,
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
            ),
          ),

          // Inner Content
          Container(
             width: 240,
             height: 240,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               gradient: LinearGradient(
                 begin: Alignment.topLeft,
                 end: Alignment.bottomRight,
                 colors: [
                   AppColors.accent.withValues(alpha: 0.15),
                   Colors.transparent,
                 ],
               ),
               boxShadow: [
                 BoxShadow(
                   color: AppColors.primaryDark.withValues(alpha: 0.3),
                   blurRadius: 20,
                   offset: const Offset(0, 10),
                 )
               ]
             ),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(
                   label.toUpperCase(),
                   style: TextStyle(
                     letterSpacing: 1.5,
                     fontSize: 14,
                     color: AppColors.textWhite.withValues(alpha: 0.7),
                   ),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   time,
                   style: const TextStyle(
                     fontSize: 48,
                     fontWeight: FontWeight.w300, 
                     color: AppColors.textWhite,
                     fontFeatures: [FontFeature.tabularFigures()],
                   ),
                 ),
               ],
             ),
          ),
          
          // Decorative dot at the end of progress (optional, simple for now)
        ],
      ),
    );
  }
}
