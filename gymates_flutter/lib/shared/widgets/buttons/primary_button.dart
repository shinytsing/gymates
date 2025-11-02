import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Primary button with gradient background
/// Matches Figma design specifications
class GymatesPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final List<Color>? gradientColors;

  const GymatesPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 56,
    this.padding,
    this.icon,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool isButtonDisabled = isDisabled || isLoading || onPressed == null;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isButtonDisabled
            ? null
            : LinearGradient(
                colors: gradientColors ?? AppColors.primaryGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isButtonDisabled ? AppColors.buttonDisabled : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isButtonDisabled
            ? null
            : [
                BoxShadow(
                  color: (gradientColors ?? AppColors.primaryGradient).first.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isButtonDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null && !isLoading) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.textInverse,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Text(
                    text,
                    style: AppTypography.button.copyWith(
                      color: isButtonDisabled
                          ? AppColors.textDisabled
                          : AppColors.textInverse,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

