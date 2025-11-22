import 'package:flutter/material.dart';
import '../../core/theme/apple_fitness_theme.dart';
import '../../core/3d_components/3d_card.dart';

/// 📦 Section Card Component
/// 
/// Apple Fitness+ style section card for grouping content.
/// 
/// Usage:
/// ```dart
/// SectionCard(
///   title: 'Today\'s Workout',
///   child: YourContent(),
/// )
/// ```

class SectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final Color? backgroundColor;
  final bool useFrostedGlass;

  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.gradient,
    this.backgroundColor,
    this.useFrostedGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card3D(
      onTap: onTap,
      elevation: 8,
      borderRadius: AppleFitnessTheme.radiusLarge,
      gradient: gradient,
      backgroundColor: backgroundColor ?? AppleFitnessTheme.backgroundPrimary,
      padding: padding ?? EdgeInsets.all(AppleFitnessTheme.spacingL),
      margin: margin ?? EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
      useFrostedGlass: useFrostedGlass,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || subtitle != null) ...[
            if (title != null)
              Text(
                title!,
                style: AppleFitnessTheme.headlineSmall,
              ),
            if (subtitle != null) ...[
              SizedBox(height: AppleFitnessTheme.spacingXS),
              Text(
                subtitle!,
                style: AppleFitnessTheme.bodySmall,
              ),
            ],
            SizedBox(height: AppleFitnessTheme.spacingM),
          ],
          child,
        ],
      ),
    );
  }
}

