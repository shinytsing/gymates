import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 📊 3D Progress Components - Various 3D progress indicators
/// 
/// Features:
/// - 3D Circular Progress with depth
/// - 3D Linear Progress with pipeline effect
/// - 3D Ring Progress with glow
/// - 3D Step Progress with elevation
/// - Animated progress transitions

/// 🔄 3D Circular Progress - Circular progress with 3D depth
class CircularProgress3D extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final bool showPercentage;
  final bool animate;
  final Widget? centerWidget;
  
  const CircularProgress3D({
    super.key,
    required this.value,
    this.size = 120,
    this.strokeWidth = 12,
    this.progressColor,
    this.backgroundColor,
    this.showPercentage = true,
    this.animate = true,
    this.centerWidget,
  });

  @override
  State<CircularProgress3D> createState() => _CircularProgress3DState();
}

class _CircularProgress3DState extends State<CircularProgress3D> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(CircularProgress3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = widget.progressColor ?? theme.colorScheme.primary;
    final bgColor = widget.backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: widget.animate ? _animation : AlwaysStoppedAnimation(widget.value),
        builder: (context, child) {
          final currentValue = widget.animate ? _animation.value : widget.value;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // Background shadow
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              // Background circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircleProgressPainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: bgColor,
                  isBackground: true,
                ),
              ),
              // Progress circle with glow
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CircleProgressPainter(
                  progress: currentValue,
                  strokeWidth: widget.strokeWidth,
                  color: progressColor,
                  glowColor: progressColor.withValues(alpha: 0.3),
                ),
              ),
              // Center content
              if (widget.centerWidget != null)
                widget.centerWidget!
              else if (widget.showPercentage)
                Text(
                  '${(currentValue * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: widget.size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color? glowColor;
  final bool isBackground;

  _CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    this.glowColor,
    this.isBackground = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (!isBackground && glowColor != null) {
      // Draw glow
      final glowPaint = Paint()
        ..color = glowColor!
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    // Draw main arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      isBackground ? 2 * math.pi : 2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 📏 3D Linear Progress - Pipeline style progress bar
class LinearProgress3D extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color? progressColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showPercentage;
  final Gradient? gradient;
  
  const LinearProgress3D({
    super.key,
    required this.value,
    this.height = 20,
    this.progressColor,
    this.backgroundColor,
    this.borderRadius,
    this.showPercentage = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = this.progressColor ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Progress bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: height,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient ?? LinearGradient(
                    colors: [
                      progressColor,
                      Color.lerp(progressColor, Colors.white, 0.3)!,
                    ],
                  ),
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: progressColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: Offset.zero,
                    ),
                  ],
                ),
                // Shimmer effect
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: radius,
                        child: CustomPaint(
                          painter: _ShimmerPainter(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Percentage text
          if (showPercentage)
            Center(
              child: Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: height * 0.6,
                  fontWeight: FontWeight.bold,
                  color: value > 0.5 ? Colors.white : progressColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 💍 3D Ring Progress - Ring with multiple layers
class RingProgress3D extends StatelessWidget {
  final List<double> values;
  final List<Color> colors;
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;
  
  const RingProgress3D({
    super.key,
    required this.values,
    required this.colors,
    this.size = 150,
    this.strokeWidth = 10,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Multiple ring layers
          ...List.generate(values.length, (index) {
            final layerSize = size - (index * (strokeWidth + 8));
            return CircularProgress3D(
              value: values[index],
              size: layerSize,
              strokeWidth: strokeWidth,
              progressColor: colors[index],
              showPercentage: false,
            );
          }),
          // Center content
          if (centerWidget != null)
            centerWidget!,
        ],
      ),
    );
  }
}

/// 📍 3D Step Progress - Multi-step progress indicator
class StepProgress3D extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;
  final double stepSize;
  
  const StepProgress3D({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.stepSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = this.activeColor ?? theme.colorScheme.primary;
    final inactiveColor = this.inactiveColor ?? theme.colorScheme.surfaceContainerHighest;

    return Column(
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isEven) {
              // Step circle
              final stepIndex = index ~/ 2;
              final isActive = stepIndex <= currentStep;
              final isCompleted = stepIndex < currentStep;
              
              return _buildStepCircle(
                stepIndex + 1,
                isActive,
                isCompleted,
                activeColor,
                inactiveColor,
              );
            } else {
              // Connector line
              final stepIndex = index ~/ 2;
              final isActive = stepIndex < currentStep;
              
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : inactiveColor,
                    boxShadow: isActive ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ] : null,
                  ),
                ),
              );
            }
          }),
        ),
        if (stepLabels != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Text(
                  stepLabels![index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildStepCircle(
    int stepNumber,
    bool isActive,
    bool isCompleted,
    Color activeColor,
    Color inactiveColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: stepSize,
      height: stepSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? activeColor : inactiveColor,
        boxShadow: isActive ? [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : Text(
                '$stepNumber',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

