import 'package:flutter/material.dart';

/// Gymates App Color Palette
/// All colors defined according to Figma design system
class AppColors {
  AppColors._();

  // ==================== Primary Colors ====================
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5142C5);
  static const Color primaryLight = Color(0xFF8B7FE8);
  
  // ==================== Secondary Colors ====================
  static const Color secondary = Color(0xFFFF6B9D);
  static const Color secondaryDark = Color(0xFFE5567C);
  static const Color secondaryLight = Color(0xFFFF8FB5);
  
  // ==================== Accent Colors ====================
  static const Color accent = Color(0xFF00D9C0);
  static const Color accentDark = Color(0xFF00B8A3);
  static const Color accentLight = Color(0xFF33E5D0);
  
  // ==================== Background Colors ====================
  static const Color backgroundLight = Color(0xFFF8F9FD);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D44);
  
  // ==================== Text Colors ====================
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B8C);
  static const Color textTertiary = Color(0xFF9999B3);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textDisabled = Color(0xFFCCCCD9);
  
  // ==================== Gradient Colors ====================
  static const List<Color> primaryGradient = [
    Color(0xFF6C5CE7),
    Color(0xFF8B7FE8),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFFFA06D),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFF00D9C0),
    Color(0xFF00B8F5),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF00D9A5),
    Color(0xFF00C292),
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFFFC107),
    Color(0xFFFF9800),
  ];
  
  static const List<Color> dangerGradient = [
    Color(0xFFFF5252),
    Color(0xFFE53935),
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFFF8F9FD),
    Color(0xFFEEF1FF),
  ];
  
  static const List<Color> darkBackgroundGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
  ];
  
  // ==================== Status Colors ====================
  static const Color success = Color(0xFF00D9A5);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF00B8F5);
  
  // ==================== UI Element Colors ====================
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D44);
  static const Color border = Color(0xFFE5E5F0);
  static const Color divider = Color(0xFFEEEEF5);
  static const Color shadow = Color(0x1A000000);
  
  // ==================== Interactive Colors ====================
  static const Color buttonPrimary = Color(0xFF6C5CE7);
  static const Color buttonSecondary = Color(0xFFFF6B9D);
  static const Color buttonDisabled = Color(0xFFCCCCD9);
  static const Color buttonHover = Color(0xFF5142C5);
  static const Color buttonPressed = Color(0xFF4231A3);
  
  // ==================== Overlay Colors ====================
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  static const Color overlayDark = Color(0xB3000000);
  
  // ==================== Social Media Colors ====================
  static const Color facebook = Color(0xFF1877F2);
  static const Color google = Color(0xFFDB4437);
  static const Color apple = Color(0xFF000000);
  static const Color wechat = Color(0xFF09B83E);
  
  // ==================== Training Colors (by difficulty) ====================
  static const Color beginnerGreen = Color(0xFF00D9A5);
  static const Color intermediateOrange = Color(0xFFFF9800);
  static const Color advancedRed = Color(0xFFE53935);
  
  // ==================== Chart/Data Visualization Colors ====================
  static const Color chartBlue = Color(0xFF00B8F5);
  static const Color chartPurple = Color(0xFF6C5CE7);
  static const Color chartPink = Color(0xFFFF6B9D);
  static const Color chartGreen = Color(0xFF00D9A5);
  static const Color chartOrange = Color(0xFFFF9800);
  static const Color chartRed = Color(0xFFFF5252);
  
  // ==================== Helper Methods ====================
  
  /// Get gradient for primary button
  static LinearGradient getPrimaryGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: primaryGradient,
    );
  }
  
  /// Get gradient for secondary button
  static LinearGradient getSecondaryGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: secondaryGradient,
    );
  }
  
  /// Get gradient for accent elements
  static LinearGradient getAccentGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: accentGradient,
    );
  }
  
  /// Get background gradient based on theme mode
  static LinearGradient getBackgroundGradient({
    required bool isDark,
    AlignmentGeometry begin = Alignment.topCenter,
    AlignmentGeometry end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: isDark ? darkBackgroundGradient : backgroundGradient,
    );
  }
  
  /// Get status color by type
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return success;
      case 'warning':
      case 'pending':
        return warning;
      case 'error':
      case 'failed':
      case 'cancelled':
        return error;
      case 'info':
      case 'ongoing':
        return info;
      default:
        return textSecondary;
    }
  }
  
  /// Get difficulty color
  static Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return beginnerGreen;
      case 'intermediate':
      case 'medium':
        return intermediateOrange;
      case 'advanced':
      case 'hard':
        return advancedRed;
      default:
        return textSecondary;
    }
  }
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}

