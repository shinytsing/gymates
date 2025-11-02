import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gymates App Typography System
/// Font styles based on Figma design specifications
class AppTypography {
  AppTypography._();

  // ==================== Font Families ====================
  static const String primaryFont = 'SF Pro Display';
  static const String secondaryFont = 'Inter';
  static const String monospaceFont = 'SF Mono';

  // ==================== Display Styles (Extra Large) ====================
  static const TextStyle displayLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ==================== Headline Styles ====================
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ==================== Title Styles ====================
  static const TextStyle titleLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  // ==================== Body Styles ====================
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  // ==================== Label Styles ====================
  static const TextStyle labelLarge = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  // ==================== Caption Styles ====================
  static const TextStyle caption = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
    letterSpacing: 0.4,
    color: AppColors.textTertiary,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
  );

  // ==================== Button Styles ====================
  static const TextStyle button = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
    color: AppColors.textInverse,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.textInverse,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
    color: AppColors.textInverse,
  );

  // ==================== Overline / Metadata ====================
  static const TextStyle overline = TextStyle(
    fontFamily: secondaryFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 1.5,
    color: AppColors.textTertiary,
  );

  // ==================== Number / Stats ====================
  static const TextStyle numberLarge = TextStyle(
    fontFamily: primaryFont,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1,
    color: AppColors.textPrimary,
  );

  static const TextStyle numberMedium = TextStyle(
    fontFamily: primaryFont,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle numberSmall = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  // ==================== Helper Methods ====================

  /// Get text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Get text style with custom weight
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Get text style with custom size
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Get gradient text style (requires ShaderMask wrapper)
  static TextStyle withGradient(TextStyle style) {
    return style.copyWith(
      foreground: Paint()
        ..shader = AppColors.getPrimaryGradient().createShader(
          const Rect.fromLTWH(0, 0, 200, 70),
        ),
    );
  }

  /// Get text style for dark theme
  static TextStyle forDarkTheme(TextStyle style) {
    if (style.color == AppColors.textPrimary) {
      return style.copyWith(color: AppColors.textInverse);
    } else if (style.color == AppColors.textSecondary) {
      return style.copyWith(color: AppColors.textTertiary);
    }
    return style;
  }

  /// Get responsive text style based on screen width
  static TextStyle responsive(
    TextStyle style,
    double screenWidth, {
    double baseWidth = 375,
  }) {
    final scaleFactor = screenWidth / baseWidth;
    final clampedScale = scaleFactor.clamp(0.8, 1.2);
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * clampedScale,
    );
  }
}

