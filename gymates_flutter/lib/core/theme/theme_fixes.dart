import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'gymates_theme.dart';

/// 🎨 全局主题修复工具
/// 
/// 确保所有页面都使用精确的 Figma 设计规范：
/// - 颜色系统：使用 GymatesTheme 中的精确颜色值
/// - 间距系统：使用 8dp 网格系统
/// - 圆角系统：平台特定的圆角半径
/// - 阴影系统：多层阴影叠加
/// - 字体系统：精确的行高和字重

class ThemeFixes {
  /// 修复 Scaffold 背景色
  static Widget fixScaffoldBackground({
    required Widget child,
    bool isDark = false,
  }) {
    return Scaffold(
      backgroundColor: isDark ? GymatesTheme.darkBackground : GymatesTheme.lightBackground,
      body: child,
    );
  }

  /// 修复卡片样式
  static BoxDecoration fixCardDecoration({
    bool isDark = false,
    bool isIOS = false,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: isDark ? GymatesTheme.darkCardBackground : GymatesTheme.cardBackground,
      borderRadius: BorderRadius.circular(isIOS ? GymatesTheme.radius16 : GymatesTheme.radius12),
      boxShadow: hasShadow ? GymatesTheme.getCardShadow(isDark) : null,
    );
  }

  /// 修复按钮样式
  static BoxDecoration fixButtonDecoration({
    required Color backgroundColor,
    required Color borderColor,
    bool isIOS = false,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(isIOS ? GymatesTheme.radius12 : GymatesTheme.radius8),
      border: Border.all(color: borderColor, width: 1),
      boxShadow: hasShadow ? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ] : null,
    );
  }

  /// 修复文本样式
  static TextStyle fixTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    bool isIOS = false,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.2,
      letterSpacing: letterSpacing ?? (isIOS ? -0.2 : 0.0),
    );
  }

  /// 修复间距
  static EdgeInsets fixPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top ?? vertical ?? all ?? 0,
      bottom: bottom ?? vertical ?? all ?? 0,
      left: left ?? horizontal ?? all ?? 0,
      right: right ?? horizontal ?? all ?? 0,
    );
  }

  /// 修复渐变背景
  static BoxDecoration fixGradientDecoration({
    required Gradient gradient,
    bool isIOS = false,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(isIOS ? GymatesTheme.radius16 : GymatesTheme.radius12),
    );
  }

  /// 修复输入框样式
  static InputDecoration fixInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    bool isDark = false,
    bool isIOS = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: isDark ? GymatesTheme.darkTextSecondary : GymatesTheme.lightTextSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: isDark ? GymatesTheme.darkTextSecondary : GymatesTheme.lightTextSecondary,
        size: 20,
      ),
      filled: true,
      fillColor: isDark ? GymatesTheme.darkCardBackground : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isIOS ? GymatesTheme.radius12 : GymatesTheme.radius8),
        borderSide: BorderSide(
          color: GymatesTheme.borderColor,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isIOS ? GymatesTheme.radius12 : GymatesTheme.radius8),
        borderSide: BorderSide(
          color: GymatesTheme.borderColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(isIOS ? GymatesTheme.radius12 : GymatesTheme.radius8),
        borderSide: BorderSide(
          color: GymatesTheme.primaryColor,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: GymatesTheme.spacing16,
        vertical: GymatesTheme.spacing12,
      ),
    );
  }

  /// 修复标签页样式
  static BoxDecoration fixTabDecoration({
    required bool isActive,
    bool isDark = false,
    bool isIOS = false,
  }) {
    return BoxDecoration(
      color: isActive 
        ? (isDark ? GymatesTheme.darkCardBackground : Colors.white)
        : Colors.transparent,
      borderRadius: BorderRadius.circular(isIOS ? 6 : 4),
      boxShadow: isActive ? [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
      ] : null,
    );
  }

  /// 修复头像样式
  static BoxDecoration fixAvatarDecoration({
    bool isIOS = false,
    bool hasBorder = false,
    Color? borderColor,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: hasBorder ? Border.all(
        color: borderColor ?? GymatesTheme.borderColor,
        width: 2,
      ) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 修复加载指示器
  static Widget fixLoadingIndicator({
    Color? color,
    double size = 24.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? GymatesTheme.primaryColor,
        ),
      ),
    );
  }

  /// 修复分隔线
  static Widget fixDivider({
    bool isDark = false,
    double height = 1.0,
    double? indent,
    double? endIndent,
  }) {
    return Divider(
      height: height,
      thickness: height,
      indent: indent,
      endIndent: endIndent,
      color: isDark 
        ? GymatesTheme.darkTextSecondary.withValues(alpha: 0.2)
        : GymatesTheme.lightTextSecondary.withValues(alpha: 0.2),
    );
  }

  /// 修复徽章样式
  static BoxDecoration fixBadgeDecoration({
    required Color backgroundColor,
    bool isIOS = false,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(isIOS ? 12 : 8),
      boxShadow: [
        BoxShadow(
          color: backgroundColor.withValues(alpha: 0.3),
          blurRadius: 4,
          spreadRadius: 1,
        ),
      ],
    );
  }

  /// 修复模态底部表单
  static Widget fixModalBottomSheet({
    required BuildContext context,
    required Widget child,
    bool isIOS = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isIOS ? 16 : 12),
          topRight: Radius.circular(isIOS ? 16 : 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// 修复手势检测器
  static Widget fixGestureDetector({
    required Widget child,
    required VoidCallback onTap,
    bool enableHaptic = true,
  }) {
    return GestureDetector(
      onTap: () {
        if (enableHaptic) {
          HapticFeedback.lightImpact();
        }
        onTap();
      },
      child: child,
    );
  }

  /// 修复动画容器
  static Widget fixAnimatedContainer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeInOut,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      decoration: decoration,
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}

/// 🎯 平台特定样式工具
class PlatformStyles {
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  static double getCardRadius(BuildContext context) {
    return isIOS(context) ? GymatesTheme.radius16 : GymatesTheme.radius12;
  }

  static double getButtonRadius(BuildContext context) {
    return isIOS(context) ? GymatesTheme.radius12 : GymatesTheme.radius8;
  }

  static double getInputRadius(BuildContext context) {
    return isIOS(context) ? GymatesTheme.radius12 : GymatesTheme.radius8;
  }

  static FontWeight getTitleWeight(BuildContext context) {
    return isIOS(context) ? FontWeight.w600 : FontWeight.w500;
  }

  static FontWeight getBodyWeight(BuildContext context) {
    return isIOS(context) ? FontWeight.w400 : FontWeight.w400;
  }

  static double getLetterSpacing(BuildContext context, double baseSpacing) {
    return isIOS(context) ? baseSpacing - 0.2 : baseSpacing;
  }
}
