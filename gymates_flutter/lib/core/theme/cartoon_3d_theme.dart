import 'package:flutter/material.dart';
import 'dart:ui';

/// 🎨 Gymates 3D Cartoon Theme System
/// 
/// 设计灵感来自主流app的3D卡通风格:
/// - Nike Training Club (运动风格)
/// - Apple Fitness+ (简洁现代)
/// - Duolingo (趣味卡通)
/// - Headspace (柔和舒适)
/// 
/// 核心特点:
/// - 鲜明的渐变色彩
/// - 夸张的3D阴影效果
/// - 圆润的卡通边角
/// - 生动的动画效果
/// - 可爱的角色形象

class Cartoon3DTheme {
  // 🎨 主色调 - 活力健康风格
  static const Color primaryVibrant = Color(0xFFFF6B6B);      // 活力红
  static const Color secondaryPurple = Color(0xFF845EC2);     // 神秘紫
  static const Color accentTeal = Color(0xFF4ECDC4);         // 清新青
  static const Color energyOrange = Color(0xFFFFBE0B);       // 能量橙
  static const Color successGreen = Color(0xFF4CD964);       // 成功绿
  
  // 🌈 辅助色调 - 丰富的色彩层次
  static const Color softPink = Color(0xFFFFC6FF);           // 柔粉色
  static const Color skyBlue = Color(0xFF7EC8E3);            // 天空蓝
  static const Color sunnyYellow = Color(0xFFFFF75E);        // 阳光黄
  static const Color mintGreen = Color(0xFFB4F8C8);          // 薄荷绿
  static const Color lavender = Color(0xFFD4A5A5);           // 薰衣草
  static const Color errorOrange = Color(0xFFFF6B35);        // 错误橙
  
  // 🎭 中性色调 - 柔和背景
  static const Color lightBg = Color(0xFFF8F9FA);            // 浅灰背景
  static const Color mediumBg = Color(0xFFE9ECEF);           // 中灰背景
  static const Color darkBg = Color(0xFF2B2D42);             // 深色背景
  static const Color cardBg = Color(0xFFFFFFFF);             // 卡片背景
  
  // 📝 文字色彩
  static const Color textPrimary = Color(0xFF2B2D42);        // 主要文字
  static const Color textSecondary = Color(0xFF8D99AE);      // 次要文字
  static const Color textLight = Color(0xFFFFFFFF);          // 浅色文字
  
  // 🌟 3D效果渐变定义
  static const LinearGradient primary3DGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFFF8E53),
    ],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient purple3DGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF845EC2),
      Color(0xFFB39CD0),
    ],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient teal3DGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4ECDC4),
      Color(0xFF44A08D),
    ],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient rainbow3DGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),  // 红
      Color(0xFFFFBE0B),  // 橙
      Color(0xFF4CD964),  // 绿
      Color(0xFF4ECDC4),  // 青
      Color(0xFF845EC2),  // 紫
    ],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8F9FA),
      Color(0xFFE9ECEF),
    ],
  );
  
  // 🎯 3D阴影效果 - 卡通风格
  static const List<BoxShadow> cartoon3DShadow = [
    // 主阴影 - 创建深度感
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 20,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
    // 内阴影 - 增强立体感
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 10,
      offset: Offset(0, 5),
      spreadRadius: -5,
    ),
  ];
  
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x30000000),
      blurRadius: 30,
      offset: Offset(0, 15),
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> pressedShadow = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 10,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  // 发光效果 - 用于按钮和重要元素
  static List<BoxShadow> glowingShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.5),
      blurRadius: 25,
      offset: const Offset(0, 0),
      spreadRadius: 5,
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 40,
      offset: const Offset(0, 0),
      spreadRadius: 10,
    ),
  ];
  
  // 🎯 圆角规范 - 卡通圆润风格
  static const double radiusXS = 12.0;   // 超小圆角
  static const double radiusS = 16.0;    // 小圆角
  static const double radiusM = 24.0;    // 中圆角
  static const double radiusL = 32.0;    // 大圆角
  static const double radiusXL = 40.0;   // 超大圆角
  static const double radiusFull = 999.0; // 完全圆形
  
  // 📐 间距系统 - 8dp网格
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space80 = 80.0;
  
  // 🎨 卡通3D卡片效果
  static BoxDecoration cartoon3DCard({
    required Gradient gradient,
    double radius = radiusM,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: isPressed ? pressedShadow : cartoon3DShadow,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.3),
        width: 2,
      ),
    );
  }
  
  // 🌟 悬浮卡片效果
  static BoxDecoration floatingCard({
    Color color = cardBg,
    double radius = radiusM,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: floatingShadow,
      border: Border.all(
        color: Colors.white,
        width: 3,
      ),
    );
  }
  
  // 🎭 毛玻璃效果 - 现代感
  static Widget glassCard({
    required Widget child,
    double radius = radiusM,
    double blur = 20.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: cartoon3DShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 🎭 3D卡通动画配置
class Cartoon3DAnimations {
  // 动画时长
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration bounce = Duration(milliseconds: 800);
  
  // 动画曲线
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve spring = Curves.easeInOutBack;
  static const Curve smooth = Curves.easeInOutCubic;
  
  // 弹跳效果
  static Curve bouncyCurve = Curves.elasticOut;
  
  // 缩放效果
  static const double scaleSmall = 0.95;
  static const double scaleNormal = 1.0;
  static const double scaleLarge = 1.05;
}

/// 🎨 3D卡通按钮组件
class Cartoon3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  
  const Cartoon3DButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.gradient,
    this.color,
    this.radius = Cartoon3DTheme.radiusM,
    this.padding,
    this.elevation = 10.0,
  });

  @override
  State<Cartoon3DButton> createState() => _Cartoon3DButtonState();
}

class _Cartoon3DButtonState extends State<Cartoon3DButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Cartoon3DAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Cartoon3DAnimations.smooth,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.symmetric(
            horizontal: Cartoon3DTheme.space24,
            vertical: Cartoon3DTheme.space16,
          ),
          decoration: widget.gradient != null
              ? Cartoon3DTheme.cartoon3DCard(
                  gradient: widget.gradient!,
                  radius: widget.radius,
                  isPressed: _isPressed,
                )
              : BoxDecoration(
                  color: widget.color ?? Cartoon3DTheme.primaryVibrant,
                  borderRadius: BorderRadius.circular(widget.radius),
                  boxShadow: _isPressed 
                      ? Cartoon3DTheme.pressedShadow 
                      : Cartoon3DTheme.cartoon3DShadow,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// 🎨 3D卡通卡片组件
class Cartoon3DCard extends StatefulWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? color;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool floating;
  
  const Cartoon3DCard({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.radius = Cartoon3DTheme.radiusM,
    this.padding,
    this.onTap,
    this.floating = false,
  });

  @override
  State<Cartoon3DCard> createState() => _Cartoon3DCardState();
}

class _Cartoon3DCardState extends State<Cartoon3DCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Cartoon3DAnimations.normal,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Cartoon3DAnimations.elastic,
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
      onTap: widget.onTap,
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(Cartoon3DTheme.space16),
          decoration: widget.gradient != null
              ? Cartoon3DTheme.cartoon3DCard(
                  gradient: widget.gradient!,
                  radius: widget.radius,
                )
              : widget.floating
                  ? Cartoon3DTheme.floatingCard(
                      color: widget.color ?? Cartoon3DTheme.cardBg,
                      radius: widget.radius,
                    )
                  : BoxDecoration(
                      color: widget.color ?? Cartoon3DTheme.cardBg,
                      borderRadius: BorderRadius.circular(widget.radius),
                      boxShadow: Cartoon3DTheme.cartoon3DShadow,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// 🎨 3D卡通头像组件
class Cartoon3DAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double size;
  final Gradient? gradient;
  final bool hasGlow;
  
  const Cartoon3DAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 60.0,
    this.gradient,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient ?? Cartoon3DTheme.primary3DGradient,
        boxShadow: hasGlow 
            ? Cartoon3DTheme.glowingShadow(Cartoon3DTheme.primaryVibrant)
            : Cartoon3DTheme.cartoon3DShadow,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitials(),
              )
            : _buildInitials(),
      ),
    );
  }
  
  Widget _buildInitials() {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? Cartoon3DTheme.rainbow3DGradient,
      ),
      child: Center(
        child: Text(
          initials ?? '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 🎨 3D卡通进度条
class Cartoon3DProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final double radius;
  final Gradient? gradient;
  final Color? backgroundColor;
  
  const Cartoon3DProgressBar({
    super.key,
    required this.progress,
    this.height = 12.0,
    this.radius = Cartoon3DTheme.radiusFull,
    this.gradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Cartoon3DTheme.mediumBg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 背景轨道
          Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? Cartoon3DTheme.mediumBg,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          // 进度条
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient ?? Cartoon3DTheme.primary3DGradient,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: Cartoon3DTheme.glowingShadow(
                  Cartoon3DTheme.primaryVibrant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 3D卡通徽章
class Cartoon3DBadge extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final Color? color;
  final double size;
  
  const Cartoon3DBadge({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        color: color,
        shape: BoxShape.circle,
        boxShadow: Cartoon3DTheme.cartoon3DShadow,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Center(child: child),
    );
  }
}

