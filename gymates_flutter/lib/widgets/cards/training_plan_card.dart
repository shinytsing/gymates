import 'package:flutter/material.dart';
import '../../core/theme/apple_fitness_theme.dart';
import '../../core/theme/cartoon_3d_characters.dart';
import '../../core/3d_components/3d_card.dart';
import '../avatars/fitness_3d_avatar.dart';

/// 🏋️ Training Plan Card Component
/// 
/// Apple Fitness+ style training plan card.
/// 
/// Usage:
/// ```dart
/// TrainingPlanCard(
///   title: 'Upper Body Strength',
///   duration: '45 min',
///   difficulty: 'Intermediate',
///   gradient: AppleFitnessTheme.workoutGradients['strength']!,
///   onTap: () {},
/// )
/// ```

class TrainingPlanCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? duration;
  final String? difficulty;
  final String? calories;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final FitnessAction? action;
  final String? imageUrl;

  const TrainingPlanCard({
    super.key,
    required this.title,
    this.subtitle,
    this.duration,
    this.difficulty,
    this.calories,
    this.gradient,
    this.onTap,
    this.action,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cardGradient = gradient ?? AppleFitnessTheme.primaryGradient;
    
    return Card3D(
      onTap: onTap,
      elevation: 12,
      borderRadius: AppleFitnessTheme.radiusLarge,
      gradient: cardGradient,
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
      enableHover: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppleFitnessTheme.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: AppleFitnessTheme.spacingXS),
                      Text(
                        subtitle!,
                        style: AppleFitnessTheme.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null)
                Fitness3DAvatar(
                  action: action!,
                  size: 60,
                  animated: true,
                ),
            ],
          ),
          if (duration != null || difficulty != null || calories != null) ...[
            SizedBox(height: AppleFitnessTheme.spacingM),
            Wrap(
              spacing: AppleFitnessTheme.spacingM,
              runSpacing: AppleFitnessTheme.spacingS,
              children: [
                if (duration != null)
                  _buildInfoChip(
                    icon: Icons.timer_outlined,
                    label: duration!,
                  ),
                if (difficulty != null)
                  _buildInfoChip(
                    icon: Icons.trending_up_outlined,
                    label: difficulty!,
                  ),
                if (calories != null)
                  _buildInfoChip(
                    icon: Icons.local_fire_department_outlined,
                    label: calories!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppleFitnessTheme.spacingM,
        vertical: AppleFitnessTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppleFitnessTheme.radiusMedium,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          SizedBox(width: AppleFitnessTheme.spacingXS),
          Text(
            label,
            style: AppleFitnessTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

