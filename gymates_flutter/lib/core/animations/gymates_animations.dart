import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// 🎬 Gymates Animation System - High-Performance Visual Effects
/// 
/// Features:
/// - Platform-specific animations (iOS smooth, Android dynamic)
/// - Hero transitions with custom curves
/// - Staggered animations for lists
/// - Breathing effects and energy pulses
/// - Performance-optimized with native drivers

class GymatesAnimations {
  
  /// 🌟 Page Transition Animations
  static PageRouteBuilder createSlideTransition({
    required Widget page,
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
  static PageRouteBuilder createFadeTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
  
  static PageRouteBuilder createScaleTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: child,
        );
      },
    );
  }
  
  /// 🎭 Hero Animation with Custom Effects
  static Widget createHeroCard({
    required String tag,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Hero(
      tag: tag,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
      ),
    );
  }
  
  /// 🌊 Staggered List Animations
  static Widget createStaggeredList({
    required List<Widget> children,
    int columnCount = 1,
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: columnCount,
        children: AnimationConfiguration.toStaggeredList(
          duration: duration,
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
  
  static Widget createStaggeredColumn({
    required List<Widget> children,
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: duration,
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: children,
        ),
      ),
    );
  }
  
  /// 💫 Breathing Animation Controller
  static Widget createBreathingEffect({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2800),
    double minScale = 0.95,
    double maxScale = 1.05,
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
        // Reverse the animation
        createBreathingEffect(
          child: child,
          duration: duration,
          minScale: maxScale,
          maxScale: minScale,
        );
      },
    );
  }
  
  /// ⚡ Energy Pulse Animation
  static Widget createEnergyPulse({
    required Widget child,
    Color pulseColor = const Color(0xFF6366F1),
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
  
  /// 🎯 Button Interaction Animations
  static Widget createInteractiveButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return AnimatedBuilder(
      animation: AlwaysStoppedAnimation(0.0),
      builder: (context, _) {
        return GestureDetector(
          onTapDown: (_) {
            // Scale down effect
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
            child: child,
          ),
        );
      },
    );
  }
  
  /// 🌈 Gradient Flow Animation
  static Widget createGradientFlow({
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
  
  /// 🎪 Modal Bottom Sheet Animation
  static Future<T?> showAnimatedBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
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
        child: child,
      ),
    );
  }
  
  /// 🎨 Loading Shimmer Animation
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
  
  /// 🎯 Progress Ring Animation
  static Widget createAnimatedProgressRing({
    required double progress,
    double size = 100.0,
    double strokeWidth = 8.0,
    Color primaryColor = const Color(0xFF6366F1),
    Color secondaryColor = const Color(0xFFA855F7),
    Duration duration = const Duration(milliseconds: 1000),
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
            ],
          ),
        );
      },
    );
  }
  
  /// 🎪 Particle Explosion Animation
  static Widget createParticleExplosion({
    required Widget child,
    int particleCount = 20,
    Duration duration = const Duration(milliseconds: 800),
    Color particleColor = const Color(0xFF6366F1),
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Stack(
          children: [
            child,
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
}

/// 🎭 Animation Direction Enum
enum SlideDirection {
  left,
  right,
  up,
  down,
}

/// 🎨 Custom Animation Curves
class CustomCurves {
  static const Curve energyPulse = Curves.easeInOutSine;
  static const Curve breathing = Curves.easeInOut;
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve bouncy = Curves.elasticOut;
  static const Curve quick = Curves.easeOutQuart;
}

/// 🎯 Animation Performance Utilities
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
