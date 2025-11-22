import 'package:flutter/material.dart';
import '../theme/cartoon_3d_theme.dart';
import '../animations/cartoon_3d_animations.dart';

/// 🎨 3D页面包装器
/// 
/// 用于快速将现有页面转换为3D卡通风格
/// 
/// 使用方法:
/// ```dart
/// Cartoon3DPageWrapper(
///   title: '页面标题',
///   child: YourExistingPage(),
/// )
/// ```
class Cartoon3DPageWrapper extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool hasAppBar;
  final List<Color>? gradientColors;
  final Widget? floatingActionButton;
  final bool enableAnimation;

  const Cartoon3DPageWrapper({
    super.key,
    required this.child,
    this.title,
    this.hasAppBar = false,
    this.gradientColors,
    this.floatingActionButton,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // 添加入场动画
    if (enableAnimation) {
      content = SlideInAnimation(
        direction: SlideDirection.fromBottom,
        child: content,
      );
    }

    // 添加渐变背景
    content = AnimatedGradientBackground(
      colors: gradientColors ??
          [
            Cartoon3DTheme.lightBg,
            Cartoon3DTheme.cardBg,
          ],
      child: content,
    );

    return Scaffold(
      appBar: hasAppBar && title != null
          ? AppBar(
              title: Text(
                title!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: Cartoon3DTheme.primary3DGradient,
                ),
              ),
              elevation: 0,
            )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// 🎯 快速3D转换辅助类
/// 
/// 提供便捷的方法将现有组件转换为3D样式
class Cartoon3DConverter {
  /// 转换按钮样式
  static ButtonStyle convertButtonStyle(ButtonStyle? original) {
    return ElevatedButton.styleFrom(
      backgroundColor: Cartoon3DTheme.primaryVibrant,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: Cartoon3DTheme.space24,
        vertical: Cartoon3DTheme.space16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusM),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    );
  }

  /// 转换卡片装饰
  static BoxDecoration convertCardDecoration(BoxDecoration? original) {
    return BoxDecoration(
      color: Cartoon3DTheme.cardBg,
      borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusM),
      boxShadow: Cartoon3DTheme.cartoon3DShadow,
    );
  }

  /// 转换输入框装饰
  static InputDecoration convertInputDecoration(InputDecoration? original) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
        borderSide: BorderSide(
          color: Cartoon3DTheme.mediumBg,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
        borderSide: BorderSide(
          color: Cartoon3DTheme.primaryVibrant,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.all(Cartoon3DTheme.space16),
    );
  }

  /// 转换文本样式
  static TextStyle convertTextStyle(TextStyle? original, {bool isTitle = false}) {
    if (isTitle) {
      return const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2B2D42),
      );
    }
    return const TextStyle(
      fontSize: 16,
      color: Color(0xFF495057),
    );
  }

  /// 添加弹跳动画包装
  static Widget wrapWithBounce(Widget child, {Duration? delay}) {
    return BounceInAnimation(
      delay: delay ?? Duration.zero,
      child: child,
    );
  }

  /// 添加滑动动画包装
  static Widget wrapWithSlide(
    Widget child, {
    SlideDirection direction = SlideDirection.fromBottom,
    Duration? delay,
  }) {
    return SlideInAnimation(
      direction: direction,
      delay: delay ?? Duration.zero,
      child: child,
    );
  }

  /// 添加脉冲动画包装
  static Widget wrapWithPulse(Widget child) {
    return PulseAnimation(child: child);
  }

  /// 添加交互动画包装
  static Widget wrapWithBouncyPress(Widget child, VoidCallback? onPressed) {
    if (onPressed == null) return child;
    return BouncyPress(
      onPressed: onPressed,
      child: child,
    );
  }
}

/// 🎨 主题适配器
/// 
/// 自动将Material组件适配为3D卡通风格
class Cartoon3DThemeAdapter extends StatelessWidget {
  final Widget child;

  const Cartoon3DThemeAdapter({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        // 主色调
        primaryColor: Cartoon3DTheme.primaryVibrant,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Cartoon3DTheme.primaryVibrant,
          secondary: Cartoon3DTheme.secondaryPurple,
          tertiary: Cartoon3DTheme.accentTeal,
        ),
        
        // 按钮主题
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Cartoon3DTheme.primaryVibrant,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: Cartoon3DTheme.space24,
              vertical: Cartoon3DTheme.space16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusM),
            ),
            elevation: 0,
          ),
        ),
        
        // 卡片主题
        cardTheme: CardThemeData(
          color: Cartoon3DTheme.cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusM),
          ),
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
        
        // 输入框主题
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
            borderSide: BorderSide(
              color: Cartoon3DTheme.mediumBg,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
            borderSide: BorderSide(
              color: Cartoon3DTheme.primaryVibrant,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(Cartoon3DTheme.space16),
        ),
        
        // AppBar主题
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        // 文本主题
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2D42),
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2D42),
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2B2D42),
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B2D42),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF495057),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF6C757D),
          ),
        ),
        
        // 使用Material 3
        useMaterial3: true,
      ),
      child: child,
    );
  }
}

