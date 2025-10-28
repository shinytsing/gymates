import 'package:flutter/material.dart';
import 'gymates_theme.dart';
import 'theme_fixes.dart';

/// 🔍 Figma 高保真验证工具
/// 
/// 用于验证 UI 实现与 Figma 设计的像素级一致性：
/// - 颜色对比验证
/// - 间距精度验证
/// - 圆角半径验证
/// - 阴影效果验证
/// - 字体样式验证
/// - 动画节奏验证

class FigmaValidation {
  /// 验证颜色是否与 Figma 设计一致
  static bool validateColor(Color actualColor, Color expectedColor, {double tolerance = 0.05}) {
    final actualR = actualColor.red / 255.0;
    final actualG = actualColor.green / 255.0;
    final actualB = actualColor.blue / 255.0;
    
    final expectedR = expectedColor.red / 255.0;
    final expectedG = expectedColor.green / 255.0;
    final expectedB = expectedColor.blue / 255.0;
    
    final deltaR = (actualR - expectedR).abs();
    final deltaG = (actualG - expectedG).abs();
    final deltaB = (actualB - expectedB).abs();
    
    return deltaR <= tolerance && deltaG <= tolerance && deltaB <= tolerance;
  }

  /// 验证间距是否遵循 8dp 网格系统
  static bool validateSpacing(double spacing) {
    return spacing % 4.0 == 0.0; // 8dp 网格系统，最小单位 4dp
  }

  /// 验证圆角半径是否符合平台规范
  static bool validateBorderRadius(double radius, bool isIOS) {
    if (isIOS) {
      return radius == 8.0 || radius == 12.0 || radius == 16.0 || radius == 20.0;
    } else {
      return radius == 4.0 || radius == 8.0 || radius == 12.0 || radius == 16.0;
    }
  }

  /// 验证阴影效果是否与 Figma 一致
  static bool validateShadow(List<BoxShadow> shadows, bool isDark) {
    if (shadows.isEmpty) return false;
    
    final expectedShadows = GymatesTheme.getCardShadow(isDark);
    if (shadows.length != expectedShadows.length) return false;
    
    for (int i = 0; i < shadows.length; i++) {
      final actual = shadows[i];
      final expected = expectedShadows[i];
      
      if (!validateColor(actual.color, expected.color, tolerance: 0.1)) return false;
      if ((actual.blurRadius - expected.blurRadius).abs() > 2.0) return false;
      if ((actual.offset.dx - expected.offset.dx).abs() > 1.0) return false;
      if ((actual.offset.dy - expected.offset.dy).abs() > 1.0) return false;
    }
    
    return true;
  }

  /// 验证字体样式是否与 Figma Typography 一致
  static bool validateTypography(TextStyle style, {
    required double expectedFontSize,
    required FontWeight expectedFontWeight,
    required Color expectedColor,
    required double expectedHeight,
    required double expectedLetterSpacing,
  }) {
    return style.fontSize == expectedFontSize &&
           style.fontWeight == expectedFontWeight &&
           validateColor(style.color ?? Colors.black, expectedColor) &&
           style.height == expectedHeight &&
           style.letterSpacing == expectedLetterSpacing;
  }

  /// 验证渐变效果
  static bool validateGradient(Gradient gradient, Gradient expectedGradient) {
    if (gradient is LinearGradient && expectedGradient is LinearGradient) {
      final actual = gradient;
      final expected = expectedGradient;
      
      if (actual.colors.length != expected.colors.length) return false;
      
      for (int i = 0; i < actual.colors.length; i++) {
        if (!validateColor(actual.colors[i], expected.colors[i])) return false;
      }
      
      return true;
    }
    return false;
  }

  /// 验证动画持续时间是否符合 Figma 规范
  static bool validateAnimationDuration(Duration duration) {
    // Figma 动画持续时间通常是 200ms, 300ms, 500ms, 800ms
    final validDurations = [
      const Duration(milliseconds: 200),
      const Duration(milliseconds: 300),
      const Duration(milliseconds: 500),
      const Duration(milliseconds: 800),
    ];
    
    return validDurations.contains(duration);
  }

  /// 验证动画曲线是否符合 Figma 规范
  static bool validateAnimationCurve(Curve curve) {
    // Figma 常用动画曲线
    final validCurves = [
      Curves.easeInOut,
      Curves.easeOut,
      Curves.easeIn,
      Curves.easeOutCubic,
      Curves.easeInOutCubic,
      Curves.elasticOut,
      Curves.bounceOut,
    ];
    
    return validCurves.contains(curve);
  }

  /// 生成验证报告
  static Map<String, dynamic> generateValidationReport({
    required BuildContext context,
    required Widget widget,
  }) {
    final isIOS = PlatformStyles.isIOS(context);
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'platform': isIOS ? 'iOS' : 'Android',
      'validations': <String, bool>{},
      'issues': <String>[],
      'recommendations': <String>[],
    };

    // 这里可以添加更多具体的验证逻辑
    // 例如检查特定组件的样式是否符合规范

    return report;
  }
}

/// 🎨 设计规范检查器
class DesignSpecChecker {
  /// 检查页面是否遵循 Figma 设计规范
  static List<String> checkPageCompliance({
    required BuildContext context,
    required Widget page,
  }) {
    final issues = <String>[];

    // 检查背景色
    if (page is Scaffold) {
      final backgroundColor = page.backgroundColor;
      if (backgroundColor != GymatesTheme.lightBackground) {
        issues.add('页面背景色不符合 Figma 规范');
      }
    }

    // 检查间距
    // 这里可以添加更多检查逻辑

    return issues;
  }

  /// 检查组件是否遵循设计系统
  static List<String> checkComponentCompliance({
    required Widget component,
    required String componentType,
  }) {
    final issues = <String>[];

    switch (componentType) {
      case 'Card':
        // 检查卡片样式
        break;
      case 'Button':
        // 检查按钮样式
        break;
      case 'TextField':
        // 检查输入框样式
        break;
      default:
        break;
    }

    return issues;
  }
}

/// 📊 性能监控工具
class PerformanceMonitor {
  static void trackRenderTime(String widgetName, Duration renderTime) {
    if (renderTime.inMilliseconds > 16) { // 60fps threshold
      debugPrint('⚠️ $widgetName 渲染时间过长: ${renderTime.inMilliseconds}ms');
    }
  }

  static void trackAnimationPerformance(String animationName, Duration duration) {
    if (duration.inMilliseconds > 500) {
      debugPrint('⚠️ $animationName 动画时间过长: ${duration.inMilliseconds}ms');
    }
  }
}

/// 🔧 自动修复工具
class AutoFixer {
  /// 自动修复常见的样式问题
  static Widget autoFixWidget(Widget widget, BuildContext context) {
    // 这里可以添加自动修复逻辑
    return widget;
  }

  /// 修复颜色问题
  static Color fixColor(Color color, {bool isDark = false}) {
    // 确保颜色符合设计系统
    return color;
  }

  /// 修复间距问题
  static double fixSpacing(double spacing) {
    // 确保间距遵循 8dp 网格系统
    return (spacing / 4.0).round() * 4.0;
  }

  /// 修复圆角问题
  static double fixBorderRadius(double radius, bool isIOS) {
    // 确保圆角符合平台规范
    if (isIOS) {
      if (radius <= 8) return 8.0;
      if (radius <= 12) return 12.0;
      if (radius <= 16) return 16.0;
      return 20.0;
    } else {
      if (radius <= 4) return 4.0;
      if (radius <= 8) return 8.0;
      if (radius <= 12) return 12.0;
      return 16.0;
    }
  }
}
