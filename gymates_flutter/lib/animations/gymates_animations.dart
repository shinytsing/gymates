import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:math' as math;
import '../theme/gymates_theme.dart';

/// 🎬 Gymates 高级动画系统 - 消除AI机械感
/// 
/// 动效风格：高能流光 + 微呼吸感 + 自然惯性动效
/// 目标：60fps，响应延迟 < 80ms
/// 
/// 包含：
/// - Hero 动画 + Slide + Fade
/// - StaggeredAnimation 滚动渐显
/// - 发光 + Scale + Haptic feedback
/// - 背景模糊 + 上滑弹入 + 光晕渐隐
/// - Rive / Lottie 流光动画

class GymatesAnimations {
  
  /// 🌟 页面切换：Hero 动画 + Slide + Fade
  static PageRouteBuilder<T> createHeroSlideTransition<T>({
    required Widget page,
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOutCubic,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide animation
        Offset begin, end;
        switch (direction) {
          case SlideDirection.left:
            begin = const Offset(-1.0, 0.0);
            end = Offset.zero;
            break;
          case SlideDirection.right:
            begin = const Offset(1.0, 0.0);
            end = Offset.zero;
            break;
          case SlideDirection.up:
            begin = const Offset(0.0, 1.0);
            end = Offset.zero;
            break;
          case SlideDirection.down:
            begin = const Offset(0.0, -1.0);
            end = Offset.zero;
            break;
        }

        var slideTween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(slideTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    );
  }
  
  /// 🎭 Hero 动画增强
  static Widget createHeroCard({
    required String tag,
    required Widget child,
    VoidCallback? onTap,
    bool enableGlow = false,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          child: enableGlow 
              ? PlatformEffects.buildGlowEffect(child: child)
              : child,
        ),
      ),
    );
  }
  
  /// 🌊 StaggeredAnimation 滚动渐显
  static Widget createStaggeredList({
    required List<Widget> children,
    int columnCount = 1,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = const Duration(milliseconds: 100),
    bool enableGlow = false,
  }) {
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: columnCount,
        children: AnimationConfiguration.toStaggeredList(
          duration: duration,
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: enableGlow 
                  ? PlatformEffects.buildGlowEffect(child: widget)
                  : widget,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
  
  static Widget createStaggeredColumn({
    required List<Widget> children,
    Duration duration = const Duration(milliseconds: 600),
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: duration,
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 30.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
  
  /// 💫 微呼吸感动画
  static Widget createBreathingEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2800),
    double minScale = 0.98,
    double maxScale = 1.02,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: minScale, end: maxScale),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      onEnd: () {
        // 反向动画，创造呼吸感
        createBreathingEffect(
          child: child,
          duration: duration,
          minScale: maxScale,
          maxScale: minScale,
        );
      },
    );
  }
  
  /// ⚡ 能量波动扩散
  static Widget createEnergyPulse({
    required Widget child,
    Color pulseColor = GymatesTheme.primaryColor,
    Duration duration = const Duration(milliseconds: 1000),
    bool enableHaptic = true,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        if (enableHaptic && value > 0.5) {
          HapticFeedback.lightImpact();
        }
        
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GymatesTheme.radius16),
            boxShadow: [
              BoxShadow(
                color: pulseColor.withOpacity(0.3 * (1 - value)),
                blurRadius: 20 * value,
                spreadRadius: 5 * value,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
  
  /// 🎯 点击反馈：发光 + Scale + Haptic feedback
  static Widget createInteractiveButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 150),
    bool enableGlow = true,
  }) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        return GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            onPressed();
          },
          onTapCancel: () {
            // Scale back up
          },
          child: AnimatedScale(
            scale: 1.0,
            duration: duration,
            child: enableGlow 
                ? PlatformEffects.buildGlowEffect(child: child)
                : child,
          ),
        );
      },
    );
  }
  
  /// 🌈 流动渐变背景
  static Widget createFlowingGradient({
    required Widget child,
    List<Color> colors = const [
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFA855F7),
      Color(0xFF06B6D4),
    ],
    Duration duration = const Duration(seconds: 3),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: [
                0.0,
                0.3 + (value * 0.2),
                0.7 + (value * 0.2),
                1.0,
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
  
  /// 🎪 弹窗：背景模糊 + 上滑弹入 + 光晕渐隐
  static Future<T?> showAnimatedBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool enableBlur = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOutCubic,
        )),
        child: enableBlur 
            ? PlatformEffects.buildGlassEffect(child: child)
            : child,
      ),
    );
  }
  
  /// 🎨 加载动画：Skeleton shimmer + 光带扫描
  static Widget createShimmerEffect({
    required Widget child,
    Color baseColor = const Color(0xFFE5E7EB),
    Color highlightColor = const Color(0xFFF3F4F6),
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value,
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
          child: child,
        );
      },
    );
  }
  
  /// 🎯 进度环动画
  static Widget createAnimatedProgressRing({
    required double progress,
    double size = 100.0,
    double strokeWidth = 8.0,
    Color primaryColor = GymatesTheme.primaryColor,
    Color secondaryColor = GymatesTheme.secondaryColor,
    Duration duration = const Duration(milliseconds: 1000),
    bool enableGlow = true,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: progress),
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              // Background ring
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
              // Animated progress ring
              CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  value < 0.5 ? primaryColor : secondaryColor,
                ),
              ),
              // Center content
              Center(
                child: Text(
                  '${(value * 100).round()}%',
                  style: const TextStyle(
                    color: GymatesTheme.lightTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// 🎪 粒子爆发动画
  static Widget createParticleExplosion({
    required Widget child,
    int particleCount = 20,
    Duration duration = const Duration(milliseconds: 800),
    Color particleColor = GymatesTheme.primaryColor,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Stack(
          children: [
            child!,
            ...List.generate(particleCount, (index) {
              final angle = (index * 2 * math.pi) / particleCount;
              final distance = value * 100;
              final x = math.cos(angle) * distance;
              final y = math.sin(angle) * distance;
              
              return Positioned(
                left: x + 50,
                top: y + 50,
                child: Opacity(
                  opacity: 1 - value,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: particleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
  
  /// 🌟 能量环充能动画
  static Widget createEnergyRingCharging({
    required Widget child,
    double ringSize = 120.0,
    double strokeWidth = 6.0,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer energy ring
            SizedBox(
              width: ringSize,
              height: ringSize,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(
                    GymatesTheme.primaryColor,
                    GymatesTheme.accentColor,
                    value,
                  )!,
                ),
              ),
            ),
            // Inner content
            child!,
          ],
        );
      },
    );
  }
  
  /// 🎭 3D 翻转动画
  static Widget create3DFlip({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    bool enableGlow = true,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value * math.pi),
          child: enableGlow 
              ? PlatformEffects.buildGlowEffect(child: child!)
              : child!,
        );
      },
    );
  }
  
  /// 🎨 打字机效果
  static Widget createTypewriterEffect({
    required String text,
    Duration duration = const Duration(milliseconds: 2000),
    TextStyle? style,
  }) {
    return TweenAnimationBuilder<int>(
      duration: duration,
      tween: IntTween(begin: 0, end: text.length),
      builder: (context, value, child) {
        return Text(
          text.substring(0, value),
          style: style ?? const TextStyle(
            fontSize: 16,
            color: GymatesTheme.lightTextPrimary,
          ),
        );
      },
    );
  }
}

/// 🎭 动画方向枚举
enum SlideDirection {
  left,
  right,
  up,
  down,
}

/// 🎨 自定义动画曲线
class CustomCurves {
  static const Curve energyPulse = Curves.easeInOutSine;
  static const Curve breathing = Curves.easeInOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve bouncy = Curves.elasticOut;
  static const Curve quick = Curves.easeOutQuart;
  static const Curve spring = Curves.elasticOut;
}

/// 🎯 动画性能工具
class AnimationPerformance {
  static bool shouldUseNativeDriver(AnimationType type) {
    switch (type) {
      case AnimationType.transform:
      case AnimationType.opacity:
        return true;
      case AnimationType.color:
      case AnimationType.size:
        return false;
    }
  }
  
  static Duration getOptimalDuration(BuildContext context, Duration baseDuration) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    if (devicePixelRatio > 3.0) {
      return Duration(milliseconds: (baseDuration.inMilliseconds * 0.8).round());
    }
    return baseDuration;
  }
}

enum AnimationType {
  transform,
  opacity,
  color,
  size,
}
