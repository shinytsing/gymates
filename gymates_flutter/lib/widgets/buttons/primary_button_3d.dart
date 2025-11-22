import 'package:flutter/material.dart';
import '../../core/theme/apple_fitness_theme.dart';
import '../../core/3d_components/3d_button.dart';

/// 🔘 Primary Button 3D Component
/// 
/// Apple Fitness+ style primary button wrapper.
/// 
/// Usage:
/// ```dart
/// PrimaryButton3D(
///   text: 'Start Workout',
///   onPressed: () {},
///   icon: Icons.play_arrow,
/// )
/// ```

class PrimaryButton3D extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final Button3DSize size;
  final Gradient? gradient;
  final bool fullWidth;

  const PrimaryButton3D({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = Button3DSize.large,
    this.gradient,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = Button3D(
      text: text,
      icon: icon,
      onPressed: isDisabled ? null : onPressed,
      type: Button3DType.primary,
      size: size,
      isLoading: isLoading,
      gradient: gradient ?? AppleFitnessTheme.primaryGradient,
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

