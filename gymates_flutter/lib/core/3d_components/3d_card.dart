import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

/// 🎴 Apple Fitness+ Style 3D Card Component
/// 
/// Design Principles:
/// - Minimalist design with subtle 3D depth
/// - Soft gradients and frosted glass effects
/// - Smooth, natural animations
/// - Large rounded corners
/// - Light shadows, not dramatic
/// - Clean typography and spacing
/// 
/// Usage:
/// ```dart
/// Card3D(
///   child: YourContent(),
///   onTap: () {},
///   elevation: 8,  // Subtle elevation
///   useFrostedGlass: true,
/// )
/// ```

class Card3D extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  
  // 3D Properties (Apple style - subtle)
  final double elevation;
  final double rotateX;
  final double rotateY;
  final double rotateZ;
  final double perspective;
  final bool enableHover;
  final bool enablePress;
  final bool enableFlip;
  
  // Visual Properties (Apple style)
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool useFrostedGlass; // Frosted glass effect
  final double glassOpacity;
  
  // Animation Properties (Apple style - smooth)
  final Duration animationDuration;
  final Curve animationCurve;
  
  const Card3D({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.elevation = 8, // Apple style - subtle
    this.rotateX = 0,
    this.rotateY = 0,
    this.rotateZ = 0,
    this.perspective = 0.002, // More subtle
    this.enableHover = true,
    this.enablePress = true,
    this.enableFlip = false,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.useFrostedGlass = false,
    this.glassOpacity = 0.7,
    this.animationDuration = const Duration(milliseconds: 400), // Smoother
    this.animationCurve = Curves.easeInOutCubic, // Apple's preferred curve
  });

  @override
  State<Card3D> createState() => _Card3DState();
}

class _Card3DState extends State<Card3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFlipped = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation * 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (widget.enablePress) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }
  
  void _handleTapUp(TapUpDetails details) {
    if (widget.enablePress) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }
  
  void _handleTapCancel() {
    if (widget.enablePress) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }
  
  void _handleTap() {
    if (widget.enableFlip) {
      setState(() => _isFlipped = !_isFlipped);
    }
    widget.onTap?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          onLongPress: widget.onLongPress,
          child: MouseRegion(
            onEnter: (_) {
              if (widget.enableHover) setState(() => _isHovered = true);
            },
            onExit: (_) {
              if (widget.enableHover) setState(() => _isHovered = false);
            },
            child: AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              width: widget.width,
              height: widget.height,
              margin: widget.margin,
              child: Transform(
                alignment: Alignment.center,
                transform: _build3DTransform(),
                child: ClipRRect(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(28), // Apple style - larger radius
                  child: BackdropFilter(
                    filter: widget.useFrostedGlass 
                        ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: AnimatedContainer(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      padding: widget.padding ?? const EdgeInsets.all(20), // Generous padding
                      decoration: BoxDecoration(
                        gradient: widget.gradient ?? (widget.useFrostedGlass 
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: widget.glassOpacity),
                                  Colors.white.withValues(alpha: widget.glassOpacity * 0.8),
                                ],
                              )
                            : null),
                        color: widget.useFrostedGlass 
                            ? null 
                            : (widget.backgroundColor ?? Colors.white),
                        borderRadius: widget.borderRadius ?? BorderRadius.circular(28),
                        border: widget.useFrostedGlass 
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.5,
                              )
                            : null,
                        boxShadow: _buildShadows(),
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Matrix4 _build3DTransform() {
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, widget.perspective);
    
    // Apply base rotation
    if (widget.rotateX != 0) matrix.rotateX(widget.rotateX);
    if (widget.rotateY != 0) matrix.rotateY(widget.rotateY);
    if (widget.rotateZ != 0) matrix.rotateZ(widget.rotateZ);
    
    // Apply hover effect (Apple style - subtle)
    if (_isHovered && widget.enableHover) {
      matrix
        ..scale(1.02) // More subtle
        ..rotateX(-0.02) // Gentler tilt
        ..rotateY(0.01);
    }
    
    // Apply press effect (Apple style - gentle bounce)
    if (_isPressed && widget.enablePress) {
      matrix.scale(_scaleAnimation.value);
    }
    
    // Apply flip effect
    if (_isFlipped && widget.enableFlip) {
      matrix.rotateY(math.pi);
    }
    
    return matrix;
  }
  
  List<BoxShadow> _buildShadows() {
    final currentElevation = _isPressed 
        ? _elevationAnimation.value 
        : (_isHovered ? widget.elevation * 1.3 : widget.elevation);
    
    // Apple Fitness+ style - soft, diffused shadows
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08), // Lighter shadow
        blurRadius: currentElevation * 1.5, // More blur for softness
        offset: Offset(0, currentElevation * 0.4),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04), // Very light ambient shadow
        blurRadius: currentElevation * 0.8,
        offset: Offset(0, currentElevation * 0.2),
        spreadRadius: -currentElevation * 0.1,
      ),
    ];
  }
}

/// 🎴 3D Flip Card - Card with front and back sides
class FlipCard3D extends StatefulWidget {
  final Widget front;
  final Widget back;
  final Duration flipDuration;
  final Curve flipCurve;
  final VoidCallback? onFlip;
  
  const FlipCard3D({
    super.key,
    required this.front,
    required this.back,
    this.flipDuration = const Duration(milliseconds: 600),
    this.flipCurve = Curves.easeInOut,
    this.onFlip,
  });

  @override
  State<FlipCard3D> createState() => _FlipCard3DState();
}

class _FlipCard3DState extends State<FlipCard3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.flipDuration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.flipCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
    widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);
          
          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle < math.pi / 2 ? widget.front : Transform(
              transform: Matrix4.identity()..rotateY(math.pi),
              alignment: Alignment.center,
              child: widget.back,
            ),
          );
        },
      ),
    );
  }
}

/// 🎴 3D Stack Card - Cards stacked with depth
class StackCard3D extends StatelessWidget {
  final List<Widget> cards;
  final double depthOffset;
  final double scaleOffset;
  
  const StackCard3D({
    super.key,
    required this.cards,
    this.depthOffset = 8,
    this.scaleOffset = 0.95,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(cards.length, (index) {
        final scale = math.pow(scaleOffset, cards.length - index - 1).toDouble();
        final offset = (cards.length - index - 1) * depthOffset;
        
        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(0, offset),
            child: cards[index],
          ),
        );
      }),
    );
  }
}

/// 🎴 3D Tilt Card - Card that tilts based on pointer position
class TiltCard3D extends StatefulWidget {
  final Widget child;
  final double tiltAmount;
  final Duration tiltDuration;
  
  const TiltCard3D({
    super.key,
    required this.child,
    this.tiltAmount = 0.01,
    this.tiltDuration = const Duration(milliseconds: 100),
  });

  @override
  State<TiltCard3D> createState() => _TiltCard3DState();
}

class _TiltCard3DState extends State<TiltCard3D> {
  double _rotateX = 0;
  double _rotateY = 0;

  void _onPointerMove(PointerEvent details, Size size) {
    final x = details.localPosition.dx / size.width - 0.5;
    final y = details.localPosition.dy / size.height - 0.5;
    
    setState(() {
      _rotateY = x * widget.tiltAmount;
      _rotateX = -y * widget.tiltAmount;
    });
  }

  void _onPointerExit(PointerEvent details) {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        _onPointerMove(event, box.size);
      },
      onExit: _onPointerExit,
      child: AnimatedContainer(
        duration: widget.tiltDuration,
        curve: Curves.easeOut,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotateX)
            ..rotateY(_rotateY),
          child: widget.child,
        ),
      ),
    );
  }
}

