import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎬 Enhanced Gymates Animations
/// 
/// 提供流畅的页面切换、组件动画和交互反馈
/// 支持 iOS 和 Android 平台的原生动画风格

class EnhancedGymatesAnimations {
  // 动画持续时间
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 300);
  static const Duration slowDuration = Duration(milliseconds: 500);
  static const Duration verySlowDuration = Duration(milliseconds: 800);
  
  // 动画曲线
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  
  /// 页面切换动画
  static Route<T> createSlideRoute<T extends Object?>(
    Widget page, {
    Duration duration = normalDuration,
    Offset beginOffset = const Offset(1.0, 0.0),
    Curve curve = easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));
        
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
  
  /// 淡入淡出动画
  static Route<T> createFadeRoute<T extends Object?>(
    Widget page, {
    Duration duration = normalDuration,
    Curve curve = easeInOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }
  
  /// 缩放动画
  static Route<T> createScaleRoute<T extends Object?>(
    Widget page, {
    Duration duration = normalDuration,
    Curve curve = elasticOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));
        
        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }
  
  /// 底部弹窗动画
  static Route<T> createBottomSheetRoute<T extends Object?>(
    Widget page, {
    Duration duration = normalDuration,
    Curve curve = easeOut,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: curve,
        ));
        
        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }
}

/// 🎯 动画控制器管理
class AnimationControllerManager {
  final Map<String, AnimationController> _controllers = {};
  
  AnimationController? getController(String key) => _controllers[key];
  
  void addController(String key, AnimationController controller) {
    _controllers[key] = controller;
  }
  
  void removeController(String key) {
    _controllers[key]?.dispose();
    _controllers.remove(key);
  }
  
  void disposeAll() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

/// 🎨 动画组件
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTap;
  final bool enableHapticFeedback;
  
  const AnimatedCard({
    super.key,
    required this.child,
    this.duration = EnhancedGymatesAnimations.fastDuration,
    this.curve = EnhancedGymatesAnimations.easeInOut,
    this.onTap,
    this.enableHapticFeedback = true,
  });
  
  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// 🎭 淡入动画组件
class FadeInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset offset;
  
  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = EnhancedGymatesAnimations.normalDuration,
    this.delay = Duration.zero,
    this.curve = EnhancedGymatesAnimations.easeOut,
    this.offset = Offset.zero,
  });
  
  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// 🎪 弹跳动画组件
class BounceInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  
  const BounceInWidget({
    super.key,
    required this.child,
    this.duration = EnhancedGymatesAnimations.normalDuration,
    this.delay = Duration.zero,
  });
  
  @override
  State<BounceInWidget> createState() => _BounceInWidgetState();
}

class _BounceInWidgetState extends State<BounceInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedGymatesAnimations.bounceOut,
    ));
    
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// 🌊 波浪动画组件
class WaveAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;
  
  const WaveAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.amplitude = 10.0,
  });
  
  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(_controller);
    
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_animation.value) * widget.amplitude),
          child: widget.child,
        );
      },
    );
  }
}

/// 🎯 加载动画组件
class LoadingAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  
  const LoadingAnimation({
    super.key,
    this.size = 24.0,
    this.color = const Color(0xFF6366F1),
    this.duration = const Duration(milliseconds: 1000),
  });
  
  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
    
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            value: _animation.value,
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          ),
        );
      },
    );
  }
}

/// 🎨 呼吸动画组件
class BreathingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  
  const BreathingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.minScale = 0.98,
    this.maxScale = 1.02,
  });
  
  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: EnhancedGymatesAnimations.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// 🎭 动画工具类
class AnimationUtils {
  /// 创建页面切换动画
  static Widget buildPageTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child, {
    String transitionType = 'slide',
  }) {
    switch (transitionType) {
      case 'slide':
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: EnhancedGymatesAnimations.easeInOut,
          )),
          child: child,
        );
      case 'fade':
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case 'scale':
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      default:
        return child;
    }
  }
  
  /// 创建按钮点击动画
  static void animateButtonPress(AnimationController controller) {
    HapticFeedback.lightImpact();
    controller.forward().then((_) {
      controller.reverse();
    });
  }
  
  /// 创建列表项动画
  static Widget buildStaggeredAnimation(
    BuildContext context,
    int index,
    Widget child, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return FadeInWidget(
      delay: Duration(milliseconds: delay.inMilliseconds * index),
      child: child,
    );
  }
}

// 导入数学库
import 'dart:math' as math;
