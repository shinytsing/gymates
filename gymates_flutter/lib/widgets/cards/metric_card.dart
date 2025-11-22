import 'package:flutter/material.dart';
import '../../core/theme/apple_fitness_theme.dart';
import '../../core/3d_components/3d_card.dart';

/// 📊 Metric Card Component
/// 
/// Apple Fitness+ style metric card for displaying stats.
/// 
/// Usage:
/// ```dart
/// MetricCard(
///   title: 'Calories',
///   value: '1,234',
///   unit: 'kcal',
///   icon: Icons.local_fire_department,
///   gradient: AppleFitnessTheme.orangeGradient,
/// )
/// ```

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData? icon;
  final Gradient? gradient;
  final Color? iconColor;
  final VoidCallback? onTap;
  final String? subtitle;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.unit,
    this.icon,
    this.gradient,
    this.iconColor,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card3D(
      onTap: onTap,
      elevation: 8,
      borderRadius: AppleFitnessTheme.radiusLarge,
      gradient: gradient,
      backgroundColor: gradient == null 
          ? AppleFitnessTheme.backgroundPrimary 
          : null,
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      enableHover: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppleFitnessTheme.bodyMedium.copyWith(
                    color: gradient != null 
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppleFitnessTheme.textSecondary,
                  ),
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor ?? 
                      (gradient != null 
                          ? Colors.white 
                          : AppleFitnessTheme.primaryBlue),
                  size: 24,
                ),
            ],
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppleFitnessTheme.headlineLarge.copyWith(
                  color: gradient != null 
                      ? Colors.white 
                      : AppleFitnessTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: AppleFitnessTheme.spacingXS),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit!,
                    style: AppleFitnessTheme.bodyMedium.copyWith(
                      color: gradient != null 
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppleFitnessTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppleFitnessTheme.spacingXS),
            Text(
              subtitle!,
              style: AppleFitnessTheme.bodySmall.copyWith(
                color: gradient != null 
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppleFitnessTheme.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

