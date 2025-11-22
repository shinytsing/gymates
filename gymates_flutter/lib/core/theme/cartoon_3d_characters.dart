import 'package:flutter/material.dart';
import 'cartoon_3d_theme.dart';

/// 🎭 3D卡通角色系统
/// 
/// 为健身应用创建生动的卡通形象:
/// - 不同体型的角色
/// - 多种健身动作姿势
/// - 丰富的表情系统
/// - 动态状态展示

/// 🏃 健身动作枚举
enum FitnessAction {
  idle,           // 待机
  running,        // 跑步
  weightlifting,  // 举重
  yoga,           // 瑜伽
  pushup,         // 俯卧撑
  squat,          // 深蹲
  jumping,        // 跳跃
  stretching,     // 拉伸
  celebrating,    // 庆祝
  tired,          // 疲惫
}

/// 😊 表情枚举
enum CharacterEmotion {
  happy,          // 开心
  motivated,      // 有动力
  focused,        // 专注
  tired,          // 疲惫
  excited,        // 兴奋
  relaxed,        // 放松
}

/// 🎨 3D卡通角色组件
class Cartoon3DCharacter extends StatefulWidget {
  final FitnessAction action;
  final CharacterEmotion emotion;
  final double size;
  final bool animated;
  
  const Cartoon3DCharacter({
    super.key,
    this.action = FitnessAction.idle,
    this.emotion = CharacterEmotion.happy,
    this.size = 200.0,
    this.animated = true,
  });

  @override
  State<Cartoon3DCharacter> createState() => _Cartoon3DCharacterState();
}

class _Cartoon3DCharacterState extends State<Cartoon3DCharacter> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
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
        return Transform.translate(
          offset: Offset(0, widget.animated ? -_bounceAnimation.value : 0),
          child: Transform.rotate(
            angle: widget.animated ? _rotationAnimation.value : 0,
            child: _buildCharacter(),
          ),
        );
      },
    );
  }

  Widget _buildCharacter() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        boxShadow: Cartoon3DTheme.floatingShadow,
      ),
      child: CustomPaint(
        painter: CharacterPainter(
          action: widget.action,
          emotion: widget.emotion,
        ),
      ),
    );
  }
}

/// 🎨 角色绘制器
class CharacterPainter extends CustomPainter {
  final FitnessAction action;
  final CharacterEmotion emotion;

  CharacterPainter({
    required this.action,
    required this.emotion,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 绘制身体（简化的卡通形象）
    _drawBody(canvas, center, size);
    
    // 绘制头部
    _drawHead(canvas, center, size);
    
    // 绘制表情
    _drawFace(canvas, center, size);
    
    // 根据动作绘制四肢
    _drawLimbs(canvas, center, size);
    
    // 绘制装饰元素（汗滴、星星等）
    _drawDecorations(canvas, center, size);
  }

  void _drawBody(Canvas canvas, Offset center, Size size) {
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Cartoon3DTheme.primaryVibrant,
          Cartoon3DTheme.energyOrange,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.2))
      ..style = PaintingStyle.fill;

    // 身体椭圆
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.height * 0.1),
        width: size.width * 0.4,
        height: size.height * 0.5,
      ),
      const Radius.circular(40),
    );
    
    canvas.drawRRect(bodyRect, bodyPaint);
    
    // 添加高光
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - size.width * 0.05, center.dy),
        width: size.width * 0.15,
        height: size.height * 0.2,
      ),
      highlightPaint,
    );
  }

  void _drawHead(Canvas canvas, Offset center, Size size) {
    final headPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFDDB7),
          Color(0xFFFFCBA4),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(center.dx, center.dy - size.height * 0.15),
        radius: size.width * 0.2,
      ))
      ..style = PaintingStyle.fill;

    // 头部圆形
    canvas.drawCircle(
      Offset(center.dx, center.dy - size.height * 0.15),
      size.width * 0.2,
      headPaint,
    );
    
    // 头发
    final hairPaint = Paint()
      ..color = Cartoon3DTheme.textPrimary
      ..style = PaintingStyle.fill;
    
    final hairPath = Path()
      ..moveTo(center.dx, center.dy - size.height * 0.35)
      ..quadraticBezierTo(
        center.dx - size.width * 0.15,
        center.dy - size.height * 0.4,
        center.dx - size.width * 0.2,
        center.dy - size.height * 0.25,
      )
      ..lineTo(center.dx - size.width * 0.2, center.dy - size.height * 0.15)
      ..lineTo(center.dx + size.width * 0.2, center.dy - size.height * 0.15)
      ..lineTo(center.dx + size.width * 0.2, center.dy - size.height * 0.25)
      ..quadraticBezierTo(
        center.dx + size.width * 0.15,
        center.dy - size.height * 0.4,
        center.dx,
        center.dy - size.height * 0.35,
      )
      ..close();
    
    canvas.drawPath(hairPath, hairPaint);
  }

  void _drawFace(Canvas canvas, Offset center, Size size) {
    final faceCenter = Offset(center.dx, center.dy - size.height * 0.15);
    
    // 眼睛
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final pupilPaint = Paint()
      ..color = Cartoon3DTheme.textPrimary
      ..style = PaintingStyle.fill;
    
    // 左眼
    canvas.drawCircle(
      Offset(faceCenter.dx - size.width * 0.08, faceCenter.dy - size.height * 0.02),
      size.width * 0.04,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(faceCenter.dx - size.width * 0.08, faceCenter.dy - size.height * 0.02),
      size.width * 0.02,
      pupilPaint,
    );
    
    // 右眼
    canvas.drawCircle(
      Offset(faceCenter.dx + size.width * 0.08, faceCenter.dy - size.height * 0.02),
      size.width * 0.04,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(faceCenter.dx + size.width * 0.08, faceCenter.dy - size.height * 0.02),
      size.width * 0.02,
      pupilPaint,
    );
    
    // 嘴巴 - 根据表情变化
    final mouthPaint = Paint()
      ..color = Cartoon3DTheme.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    final mouthPath = Path();
    
    switch (emotion) {
      case CharacterEmotion.happy:
      case CharacterEmotion.excited:
        // 大笑
        mouthPath.moveTo(faceCenter.dx - size.width * 0.08, faceCenter.dy + size.height * 0.05);
        mouthPath.quadraticBezierTo(
          faceCenter.dx,
          faceCenter.dy + size.height * 0.1,
          faceCenter.dx + size.width * 0.08,
          faceCenter.dy + size.height * 0.05,
        );
        break;
      case CharacterEmotion.motivated:
      case CharacterEmotion.focused:
        // 微笑
        mouthPath.moveTo(faceCenter.dx - size.width * 0.06, faceCenter.dy + size.height * 0.05);
        mouthPath.quadraticBezierTo(
          faceCenter.dx,
          faceCenter.dy + size.height * 0.08,
          faceCenter.dx + size.width * 0.06,
          faceCenter.dy + size.height * 0.05,
        );
        break;
      case CharacterEmotion.tired:
        // 疲惫
        mouthPath.moveTo(faceCenter.dx - size.width * 0.06, faceCenter.dy + size.height * 0.08);
        mouthPath.lineTo(faceCenter.dx + size.width * 0.06, faceCenter.dy + size.height * 0.08);
        break;
      case CharacterEmotion.relaxed:
        // 平静
        mouthPath.moveTo(faceCenter.dx - size.width * 0.05, faceCenter.dy + size.height * 0.06);
        mouthPath.quadraticBezierTo(
          faceCenter.dx,
          faceCenter.dy + size.height * 0.07,
          faceCenter.dx + size.width * 0.05,
          faceCenter.dy + size.height * 0.06,
        );
        break;
    }
    
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawLimbs(Canvas canvas, Offset center, Size size) {
    final limbPaint = Paint()
      ..color = Cartoon3DTheme.primaryVibrant
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round;
    
    // 根据动作绘制不同的四肢姿势
    switch (action) {
      case FitnessAction.running:
        _drawRunningPose(canvas, center, size, limbPaint);
        break;
      case FitnessAction.weightlifting:
        _drawWeightliftingPose(canvas, center, size, limbPaint);
        break;
      case FitnessAction.yoga:
        _drawYogaPose(canvas, center, size, limbPaint);
        break;
      case FitnessAction.celebrating:
        _drawCelebratingPose(canvas, center, size, limbPaint);
        break;
      default:
        _drawIdlePose(canvas, center, size, limbPaint);
    }
  }

  void _drawIdlePose(Canvas canvas, Offset center, Size size, Paint paint) {
    // 左手臂
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, center.dy),
      Offset(center.dx - size.width * 0.25, center.dy + size.height * 0.15),
      paint,
    );
    
    // 右手臂
    canvas.drawLine(
      Offset(center.dx + size.width * 0.15, center.dy),
      Offset(center.dx + size.width * 0.25, center.dy + size.height * 0.15),
      paint,
    );
    
    // 左腿
    canvas.drawLine(
      Offset(center.dx - size.width * 0.08, center.dy + size.height * 0.25),
      Offset(center.dx - size.width * 0.1, center.dy + size.height * 0.45),
      paint,
    );
    
    // 右腿
    canvas.drawLine(
      Offset(center.dx + size.width * 0.08, center.dy + size.height * 0.25),
      Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.45),
      paint,
    );
  }

  void _drawRunningPose(Canvas canvas, Offset center, Size size, Paint paint) {
    // 左手臂 - 向前
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, center.dy),
      Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.1),
      paint,
    );
    
    // 右手臂 - 向后
    canvas.drawLine(
      Offset(center.dx + size.width * 0.15, center.dy),
      Offset(center.dx + size.width * 0.3, center.dy + size.height * 0.1),
      paint,
    );
    
    // 左腿 - 向后
    canvas.drawLine(
      Offset(center.dx - size.width * 0.08, center.dy + size.height * 0.25),
      Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.4),
      paint,
    );
    
    // 右腿 - 向前抬起
    canvas.drawLine(
      Offset(center.dx + size.width * 0.08, center.dy + size.height * 0.25),
      Offset(center.dx + size.width * 0.1, center.dy + size.height * 0.15),
      paint,
    );
  }

  void _drawWeightliftingPose(Canvas canvas, Offset center, Size size, Paint paint) {
    // 举重杠铃
    final barPaint = Paint()
      ..color = Cartoon3DTheme.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.02;
    
    canvas.drawLine(
      Offset(center.dx - size.width * 0.25, center.dy - size.height * 0.2),
      Offset(center.dx + size.width * 0.25, center.dy - size.height * 0.2),
      barPaint,
    );
    
    // 左手臂
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, center.dy),
      Offset(center.dx - size.width * 0.25, center.dy - size.height * 0.2),
      paint,
    );
    
    // 右手臂
    canvas.drawLine(
      Offset(center.dx + size.width * 0.15, center.dy),
      Offset(center.dx + size.width * 0.25, center.dy - size.height * 0.2),
      paint,
    );
  }

  void _drawYogaPose(Canvas canvas, Offset center, Size size, Paint paint) {
    // 瑜伽姿势 - 树式
    // 左手臂向上
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, center.dy),
      Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.25),
      paint,
    );
    
    // 右手臂向上
    canvas.drawLine(
      Offset(center.dx + size.width * 0.15, center.dy),
      Offset(center.dx + size.width * 0.2, center.dy - size.height * 0.25),
      paint,
    );
    
    // 单腿站立
    canvas.drawLine(
      Offset(center.dx, center.dy + size.height * 0.25),
      Offset(center.dx, center.dy + size.height * 0.45),
      paint,
    );
  }

  void _drawCelebratingPose(Canvas canvas, Offset center, Size size, Paint paint) {
    // 双手举起庆祝
    // 左手臂
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, center.dy),
      Offset(center.dx - size.width * 0.25, center.dy - size.height * 0.25),
      paint,
    );
    
    // 右手臂
    canvas.drawLine(
      Offset(center.dx + size.width * 0.15, center.dy),
      Offset(center.dx + size.width * 0.25, center.dy - size.height * 0.25),
      paint,
    );
    
    // 跳跃姿势
    canvas.drawLine(
      Offset(center.dx - size.width * 0.08, center.dy + size.height * 0.25),
      Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.35),
      paint,
    );
    
    canvas.drawLine(
      Offset(center.dx + size.width * 0.08, center.dy + size.height * 0.25),
      Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.35),
      paint,
    );
  }

  void _drawDecorations(Canvas canvas, Offset center, Size size) {
    // 根据情绪添加装饰元素
    if (emotion == CharacterEmotion.excited) {
      _drawSparkles(canvas, center, size);
    } else if (emotion == CharacterEmotion.tired && action == FitnessAction.tired) {
      _drawSweatDrops(canvas, center, size);
    }
  }

  void _drawSparkles(Canvas canvas, Offset center, Size size) {
    final sparklePaint = Paint()
      ..color = Cartoon3DTheme.sunnyYellow
      ..style = PaintingStyle.fill;
    
    // 绘制几个星星
    final sparklePositions = [
      Offset(center.dx - size.width * 0.3, center.dy - size.height * 0.2),
      Offset(center.dx + size.width * 0.3, center.dy - size.height * 0.25),
      Offset(center.dx - size.width * 0.25, center.dy + size.height * 0.1),
    ];
    
    for (final pos in sparklePositions) {
      _drawStar(canvas, pos, size.width * 0.03, sparklePaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * 3.14159 / 180;
      final x = center.dx + size * 2 * (i % 2 == 0 ? 1 : 0.5) * cos(angle);
      final y = center.dy + size * 2 * (i % 2 == 0 ? 1 : 0.5) * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSweatDrops(Canvas canvas, Offset center, Size size) {
    final sweatPaint = Paint()
      ..color = Cartoon3DTheme.skyBlue
      ..style = PaintingStyle.fill;
    
    // 绘制汗滴
    final sweatPositions = [
      Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.1),
      Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.12),
    ];
    
    for (final pos in sweatPositions) {
      canvas.drawCircle(pos, size.width * 0.02, sweatPaint);
    }
  }

  double cos(double angle) => angle.isFinite ? angle.cos() : 0.0;
  double sin(double angle) => angle.isFinite ? angle.sin() : 0.0;

  @override
  bool shouldRepaint(CharacterPainter oldDelegate) {
    return oldDelegate.action != action || oldDelegate.emotion != emotion;
  }
}

// 扩展double类以支持三角函数
extension DoubleExtension on double {
  double cos() => this * 0.01745329252; // 简化的cos近似
  double sin() => this * 0.01745329252; // 简化的sin近似
}

