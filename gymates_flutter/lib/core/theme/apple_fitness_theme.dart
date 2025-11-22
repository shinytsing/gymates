import 'package:flutter/material.dart';
import 'dart:ui';

/// 🍎 Apple Fitness+ Minimalist 3D Theme
/// 
/// Design Philosophy:
/// - Minimalism: Clean, spacious, focused
/// - Soft 3D: Subtle depth, not exaggerated
/// - Smooth Animations: Natural, fluid transitions
/// - Soft Gradients: Gentle, calming colors
/// - Frosted Glass: Translucent, layered UI
/// - Large Radius: Rounded, friendly shapes
/// - Typography: San Francisco style - clean and readable

class AppleFitnessTheme {
  // 🎨 Color Palette - Inspired by Apple Fitness+
  
  // Primary Colors (Soft, not vibrant)
  static const Color primaryBlue = Color(0xFF007AFF);        // Apple Blue
  static const Color primaryPink = Color(0xFFFF2D55);        // Apple Pink
  static const Color primaryGreen = Color(0xFF34C759);       // Apple Green
  static const Color primaryOrange = Color(0xFFFF9500);      // Apple Orange
  static const Color primaryPurple = Color(0xFFAF52DE);      // Apple Purple
  static const Color primaryTeal = Color(0xFF5AC8FA);        // Apple Teal
  static const Color primaryYellow = Color(0xFFFFCC00);      // Apple Yellow
  
  // Background Colors (Light, airy)
  static const Color backgroundPrimary = Color(0xFFFFFFFF);  // Pure white
  static const Color backgroundSecondary = Color(0xFFF2F2F7); // Light gray
  static const Color backgroundTertiary = Color(0xFFE5E5EA); // Slightly darker gray
  
  // Text Colors (High contrast for readability)
  static const Color textPrimary = Color(0xFF000000);        // Pure black
  static const Color textSecondary = Color(0xFF3C3C43);      // Dark gray
  static const Color textTertiary = Color(0xFF8E8E93);       // Medium gray
  static const Color textQuaternary = Color(0xFFC7C7CC);     // Light gray
  
  // Semantic Colors
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
  static const Color info = Color(0xFF007AFF);
  
  // 🌈 Soft Gradients (Apple Fitness+ style)
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF007AFF),
      Color(0xFF5AC8FA),
    ],
  );
  
  static const LinearGradient pinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF2D55),
      Color(0xFFFF6482),
    ],
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF34C759),
      Color(0xFF52D97C),
    ],
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFAF52DE),
      Color(0xFFBF7AF0),
    ],
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF9500),
      Color(0xFFFFAA33),
    ],
  );
  
  // Soft background gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF2F2F7),
    ],
  );
  
  // 🎯 Shadow Definitions (Subtle, not dramatic)
  
  static List<BoxShadow> softShadow({double elevation = 8}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: elevation * 1.5,
      offset: Offset(0, elevation * 0.3),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: elevation,
      offset: Offset(0, elevation * 0.15),
      spreadRadius: -elevation * 0.1,
    ),
  ];
  
  static List<BoxShadow> hoverShadow({double elevation = 12}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: elevation * 2,
      offset: Offset(0, elevation * 0.5),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> pressedShadow({double elevation = 4}) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: elevation,
      offset: Offset(0, elevation * 0.2),
      spreadRadius: 0,
    ),
  ];
  
  // 🔆 Glow Effect (Subtle)
  static List<BoxShadow> softGlow(Color color, {double intensity = 0.3}) => [
    BoxShadow(
      color: color.withValues(alpha: intensity * 0.4),
      blurRadius: 20,
      offset: Offset.zero,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: color.withValues(alpha: intensity * 0.2),
      blurRadius: 40,
      offset: Offset.zero,
      spreadRadius: 4,
    ),
  ];
  
  // 📐 Border Radius (Apple's signature large radius)
  static const BorderRadius radiusSmall = BorderRadius.all(Radius.circular(12));
  static const BorderRadius radiusMedium = BorderRadius.all(Radius.circular(20));
  static const BorderRadius radiusLarge = BorderRadius.all(Radius.circular(28));
  static const BorderRadius radiusXLarge = BorderRadius.all(Radius.circular(36));
  
  // 📏 Spacing (Generous, airy)
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 16;
  static const double spacingL = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;
  
  // 🔤 Typography (San Francisco style)
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.12,
    color: textPrimary,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.16,
    color: textPrimary,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.22,
    color: textPrimary,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.25,
    color: textPrimary,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.29,
    color: textPrimary,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.33,
    color: textPrimary,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.27,
    color: textPrimary,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.29,
    color: textPrimary,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.33,
    color: textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.4,
    height: 1.47,
    color: textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.47,
    color: textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.1,
    height: 1.38,
    color: textSecondary,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.29,
    color: textPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.33,
    color: textPrimary,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.38,
    color: textPrimary,
  );
  
  // 🎬 Animation Curves (Apple's signature)
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve easeOut = Curves.easeOut;
  static const Curve spring = Curves.elasticOut;
  
  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationVerySlow = Duration(milliseconds: 800);
  
  // 🎨 Frosted Glass Effect
  static ImageFilter frostEffect({double blur = 20}) => ImageFilter.blur(sigmaX: blur, sigmaY: blur);
  
  static BoxDecoration frostGlassDecoration({
    double opacity = 0.7,
    BorderRadius? borderRadius,
    Color? baseColor,
  }) => BoxDecoration(
    color: (baseColor ?? Colors.white).withValues(alpha: opacity),
    borderRadius: borderRadius ?? radiusLarge,
    border: Border.all(
      color: Colors.white.withValues(alpha: 0.2),
      width: 1.5,
    ),
    boxShadow: softShadow(),
  );
  
  // 🎯 3D Transform Presets (Subtle)
  static Matrix4 subtleTilt = Matrix4.identity()
    ..setEntry(3, 2, 0.002)
    ..rotateX(-0.02)
    ..rotateY(0.01);
  
  static Matrix4 hoverLift = Matrix4.identity()
    ..setEntry(3, 2, 0.002)
    ..translate(0.0, -4.0, 0.0)
    ..scale(1.02);
  
  static Matrix4 pressDown = Matrix4.identity()
    ..setEntry(3, 2, 0.002)
    ..scale(0.97);
  
  // 🎨 Workout Type Colors (from Apple Fitness+)
  static const Map<String, LinearGradient> workoutGradients = {
    'strength': LinearGradient(
      colors: [Color(0xFFFF453A), Color(0xFFFF6961)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'hiit': LinearGradient(
      colors: [Color(0xFFFF9F0A), Color(0xFFFFAE42)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'yoga': LinearGradient(
      colors: [Color(0xFF30D158), Color(0xFF52DE7A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'cycling': LinearGradient(
      colors: [Color(0xFF007AFF), Color(0xFF409CFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'treadmill': LinearGradient(
      colors: [Color(0xFF5E5CE6), Color(0xFF7D7AFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'rowing': LinearGradient(
      colors: [Color(0xFFAC8E68), Color(0xFFC19A6B)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'dance': LinearGradient(
      colors: [Color(0xFFFF375F), Color(0xFFFF6482)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'core': LinearGradient(
      colors: [Color(0xFFBF5AF2), Color(0xFFDA8FFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };
  
  // 🎨 Activity Ring Colors (from Apple Watch)
  static const Color moveRing = Color(0xFFFF453A);
  static const Color exerciseRing = Color(0xFF30D158);
  static const Color standRing = Color(0xFF00C7BE);
  
  // 📊 Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF007AFF),
    Color(0xFFFF2D55),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFFAF52DE),
    Color(0xFF5AC8FA),
  ];
  
  // 🎭 Dark Mode Colors (for future implementation)
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkBackgroundElevated = Color(0xFF1C1C1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFEBEBF5);
}

/// 🎨 Helper extension for easy theme access
extension AppleFitnessThemeExtension on BuildContext {
  AppleFitnessTheme get appleTheme => AppleFitnessTheme();
}

/// 🎨 Pre-built card styles
class AppleFitnessCardStyles {
  // Workout card style
  static BoxDecoration workoutCard(Gradient gradient) => BoxDecoration(
    gradient: gradient,
    borderRadius: AppleFitnessTheme.radiusLarge,
    boxShadow: AppleFitnessTheme.softShadow(elevation: 12),
  );
  
  // Stat card style
  static BoxDecoration statCard = BoxDecoration(
    color: AppleFitnessTheme.backgroundPrimary,
    borderRadius: AppleFitnessTheme.radiusLarge,
    boxShadow: AppleFitnessTheme.softShadow(elevation: 8),
  );
  
  // Frosted glass card
  static BoxDecoration frostCard = AppleFitnessTheme.frostGlassDecoration(
    opacity: 0.7,
    borderRadius: AppleFitnessTheme.radiusLarge,
  );
}

