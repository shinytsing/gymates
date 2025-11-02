import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';

/// 🎨 Gymates 完整主题系统 - 自然风格健身社交应用
/// 
/// 设计理念：
/// - 自然灵感配色：柔和绿色、粉蓝色、温暖橙色
/// - Neumorphism + Glassmorphism 风格
/// - 圆润边角，柔和阴影，毛玻璃效果
/// - 字体：Poppins (标题)，Open Sans (正文)
/// - 卡片圆角：12-16dp，柔光阴影
/// - 页面内间距统一 16dp，遵循 8dp 网格系统

class GymatesTheme {
  // 🌿 自然风格色彩系统 (Nature-inspired Palette)
  // Primary Colors - 健康与活力
  static const Color primaryGreen = Color(0xFF8BC34A);      // 柔和绿色 - 健康
  static const Color primaryBlue = Color(0xFF64B5F6);       // 粉蓝色 - 平静
  static const Color primaryOrange = Color(0xFFFFC107);     // 温暖橙色 - 能量
  
  // Accent Colors - 社交与放松
  static const Color accentLavender = Color(0xFFA78DF0);   // 薰衣草紫 - 放松
  static const Color accentCoral = Color(0xFFFF6F61);      // 珊瑚粉 - 社交互动
  
  // 主色保持兼容
  static const Color primaryColor = primaryGreen;
  static const Color secondaryColor = accentLavender;
  static const Color accentColor = primaryBlue;
  
  // 🌈 自然风格渐变定义
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, primaryBlue, accentLavender],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryGreen,      // 柔和绿色
      primaryBlue,       // 粉蓝色
      accentLavender,    // 薰衣草紫
      primaryOrange,     // 温暖橙色
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  static const LinearGradient socialGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCoral, accentLavender],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF6F7FB),  // 更柔和的背景
      Color(0xFFEAEAEA),
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF7F7F7)],
  );
  
  static const LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F2937), Color(0xFF111827)],
  );
  
  // 🎨 背景色彩 (柔和中性色)
  static const Color lightBackground = Color(0xFFF6F7FB);    // 更柔和的背景
  static const Color darkBackground = Color(0xFF111827);
  static const Color cardBackground = Colors.white;
  static const Color darkCardBackground = Color(0xFF1F2937);
  static const Color neutralGray = Color(0xFFEAEAEA);        // 柔和灰色
  
  // 📝 文本色彩
  static const Color lightTextPrimary = Color(0xFF212121);   // 更深的标题色
  static const Color lightTextSecondary = Color(0xFF666666); // 正文色
  static const Color lightTextMuted = Color(0xFFA9A9A9);     // 元数据色
  static const Color darkTextPrimary = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFFD1D5DB);
  
  // 🔥 交互色彩
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // 📐 精确尺寸规范 (8dp 网格系统)
  static const double spacing1 = 1.0;
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  
  // 🎯 圆角规范 (Neumorphism风格 - 圆润边角)
  static const double radius8 = 8.0;    // 小组件
  static const double radius12 = 12.0;  // 按钮、标签
  static const double radius16 = 16.0;  // 卡片
  static const double radius20 = 20.0;  // 大卡片
  static const double radius24 = 24.0;  // 模态框
  
  // 兼容性别名
  static const double cardRadius = radius16;
  static const double buttonRadius = radius12;
  static const double inputRadius = radius8;
  static const double modalRadius = radius24;
  
  // 🌟 阴影定义 (Neumorphism柔和阴影)
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x1A000000),  // 透明黑色阴影
      blurRadius: 15,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> neumorphismShadow = [
    BoxShadow(
      color: Color(0x40000000),  // 深色阴影
      blurRadius: 10,
      offset: Offset(4, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0xFFFFFFFF),  // 高光
      blurRadius: 10,
      offset: Offset(-4, -4),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x338BC34A),  // 绿色光晕
      blurRadius: 20,
      offset: Offset(0, 0),
      spreadRadius: 2,
    ),
  ];
  
  static const List<BoxShadow> platformShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  // 🎭 边框颜色 (透明灰 #E0E0E0, opacity 0.3)
  static const Color borderColor = Color(0x4DE0E0E0);
  
  /// 获取阴影效果
  static List<BoxShadow> getCardShadow(bool isDark) {
    return [
      BoxShadow(
        color: isDark 
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.08),
        blurRadius: 15,
        offset: const Offset(0, 4),
        spreadRadius: 0,
      ),
    ];
  }

  /// 获取渐变背景
  static LinearGradient getBackgroundGradient(bool isDark) {
    if (isDark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF111827), Color(0xFF1F2937)],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF9FAFB), Color(0xFFFFFFFF)],
      );
    }
  }
}

/// 🍎 iOS Cupertino 主题配置
class CupertinoGymatesTheme {
  static CupertinoThemeData buildTheme() {
    return CupertinoThemeData(
      primaryColor: GymatesTheme.primaryColor,
      scaffoldBackgroundColor: GymatesTheme.lightBackground,
      barBackgroundColor: GymatesTheme.cardBackground.withValues(alpha: 0.8),
      textTheme: CupertinoTextThemeData(
        primaryColor: GymatesTheme.lightTextPrimary,
        textStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: GymatesTheme.lightTextPrimary,
        ),
      ),
    );
  }
  
  static CupertinoThemeData buildDarkTheme() {
    return CupertinoThemeData(
      primaryColor: GymatesTheme.primaryColor,
      scaffoldBackgroundColor: GymatesTheme.darkBackground,
      barBackgroundColor: GymatesTheme.darkCardBackground.withValues(alpha: 0.8),
      textTheme: CupertinoTextThemeData(
        primaryColor: GymatesTheme.darkTextPrimary,
        textStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: GymatesTheme.darkTextPrimary,
        ),
      ),
    );
  }
}

/// 🤖 Android Material 3 主题配置
class MaterialGymatesTheme {
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GymatesTheme.primaryColor,
        brightness: Brightness.light,
        primary: GymatesTheme.primaryColor,
        secondary: GymatesTheme.secondaryColor,
        tertiary: GymatesTheme.accentColor,
        surface: GymatesTheme.cardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: GymatesTheme.lightTextPrimary,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: GymatesTheme.lightTextPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.lightTextPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: GymatesTheme.lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: GymatesTheme.lightTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GymatesTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GymatesTheme.radius12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: GymatesTheme.spacing24,
            vertical: GymatesTheme.spacing16,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: GymatesTheme.cardBackground,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        ),
      ),
    );
  }
  
  static ThemeData buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GymatesTheme.primaryColor,
        brightness: Brightness.dark,
        primary: GymatesTheme.primaryColor,
        secondary: GymatesTheme.secondaryColor,
        tertiary: GymatesTheme.accentColor,
        surface: GymatesTheme.darkCardBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: GymatesTheme.darkTextPrimary,
      ),
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: GymatesTheme.darkTextPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.darkTextPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: GymatesTheme.darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: GymatesTheme.darkTextSecondary,
        ),
      ),
    );
  }
}

/// 🌟 平台特定视觉特效 (Glassmorphism + Neumorphism)
class PlatformEffects {
  /// 毛玻璃效果 (Glassmorphism)
  static Widget buildGlassEffect({
    required Widget child,
    double sigmaX = 20.0,
    double sigmaY = 20.0,
    Color tintColor = Colors.white,
    double tintOpacity = 0.1,
    double borderRadius = 16.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: tintColor.withValues(alpha: tintOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: GymatesTheme.softShadow,
          ),
          child: child,
        ),
      ),
    );
  }
  
  /// Neumorphism 卡片效果
  static Widget buildNeumorphismCard({
    required Widget child,
    double borderRadius = 16.0,
    Color backgroundColor = const Color(0xFFF6F7FB),
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: GymatesTheme.neumorphismShadow,
      ),
      child: child,
    );
  }
  
  /// Android 动态光晕卡片
  static Widget buildGlowEffect({
    required Widget child,
    Color glowColor = GymatesTheme.primaryColor,
    double blurRadius = 20.0,
    double spreadRadius = 2.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
  
  /// 通用渐变背景 + 视差滚动
  static Widget buildGradientBackground({
    required Widget child,
    Gradient gradient = GymatesTheme.primaryGradient,
    BlendMode blendMode = BlendMode.overlay,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: child,
    );
  }
  
  /// 动态模糊渐变导航
  static Widget buildAnimatedBlurNavigation({
    required Widget child,
    double sigmaX = 15.0,
    double sigmaY = 15.0,
  }) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: GymatesTheme.borderColor,
                width: 0.5,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
  
  /// 运动波纹反馈
  static Widget buildRippleEffect({
    required Widget child,
    required VoidCallback onTap,
    Color rippleColor = GymatesTheme.primaryColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        splashColor: rippleColor.withValues(alpha: 0.1),
        highlightColor: rippleColor.withValues(alpha: 0.05),
        child: child,
      ),
    );
  }
}

/// 🎭 动画常量
class AnimationConstants {
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration breathingAnimation = Duration(milliseconds: 2800);
  
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve breathingCurve = Curves.easeInOut;
  static const Curve springCurve = Curves.elasticOut;
}

/// 📱 响应式设计工具
class ResponsiveDesign {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }
  
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return GymatesTheme.spacing16;
    if (isTablet(context)) return GymatesTheme.spacing24;
    return GymatesTheme.spacing32;
  }
  
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 375.0; // Base iPhone width
    return baseSize * scaleFactor.clamp(0.8, 1.2);
  }
}

/// 🎨 全局主题控制器
class ThemeController extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isIOSPlatform = false;
  
  bool get isDarkMode => _isDarkMode;
  bool get isIOSPlatform => _isIOSPlatform;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  void setPlatform(bool isIOS) {
    _isIOSPlatform = isIOS;
    notifyListeners();
  }
  
  void detectSystemTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    _isDarkMode = brightness == Brightness.dark;
    notifyListeners();
  }
}
