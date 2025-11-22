import 'package:flutter/material.dart';
import '../../core/theme/apple_fitness_theme.dart';

/// 📊 Progress Ring 3D Component
/// 
/// Apple Fitness+ style circular progress ring (like Apple Watch activity rings).
/// 
/// Usage:
/// ```dart
/// ProgressRing3D(
///   progress: 0.75,
///   color: AppleFitnessTheme.moveRing,
///   size: 100,
/// )
/// ```

class ProgressRing3D extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final double size;
  final double strokeWidth;
  final String? label;
  final String? value;
  final Color? backgroundColor;
  final bool showPercentage;

  const ProgressRing3D({
    super.key,
    required this.progress,
    required this.color,
    this.size = 100.0,
    this.strokeWidth = 8.0,
    this.label,
    this.value,
    this.backgroundColor,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                backgroundColor ?? AppleFitnessTheme.backgroundTertiary,
              ),
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(
                  value!,
                  style: AppleFitnessTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (label != null) ...[
                SizedBox(height: AppleFitnessTheme.spacingXS / 2),
                Text(
                  label!,
                  style: AppleFitnessTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              if (showPercentage && value == null)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppleFitnessTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

