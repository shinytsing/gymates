import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/apple_fitness_theme.dart';
import '../../core/theme/cartoon_3d_characters.dart';

/// 🎭 Fitness 3D Avatar Component
/// 
/// Unified 3D avatar component for the entire app following Apple Fitness+ style.
/// 
/// Features:
/// - Support for 8 viewing angles (front, front-left, left, back-left, back, back-right, right, front-right)
/// - Dynamic fitness actions (squat, running, weightlifting, etc.)
/// - Smooth angle transitions
/// - Apple Fitness+ minimalist style
/// - Consistent across all pages
/// 
/// Usage:
/// ```dart
/// Fitness3DAvatar(
///   angle: AvatarAngle.front,
///   action: FitnessAction.squat,
///   size: 80,
/// )
/// ```

/// Avatar viewing angles (8 directions)
enum AvatarAngle {
  front,        // 0° - Front view
  frontLeft,    // 45° - Front-left view
  left,         // 90° - Left side view
  backLeft,     // 135° - Back-left view
  back,         // 180° - Back view
  backRight,    // 225° - Back-right view
  right,        // 270° - Right side view
  frontRight,   // 315° - Front-right view
}

class Fitness3DAvatar extends StatefulWidget {
  /// Viewing angle (0-7, representing 8 directions)
  final AvatarAngle angle;
  
  /// Fitness action/pose
  final FitnessAction action;
  
  /// Character emotion
  final CharacterEmotion emotion;
  
  /// Avatar size
  final double size;
  
  /// Enable animation
  final bool animated;
  
  /// Enable angle transition animation
  final bool enableAngleTransition;
  
  /// Custom avatar image URL (optional, falls back to 3D character if null)
  final String? avatarUrl;
  
  /// Border color (for user avatars)
  final Color? borderColor;
  
  /// Show border
  final bool showBorder;

  const Fitness3DAvatar({
    super.key,
    this.angle = AvatarAngle.front,
    this.action = FitnessAction.idle,
    this.emotion = CharacterEmotion.happy,
    this.size = 80.0,
    this.animated = true,
    this.enableAngleTransition = true,
    this.avatarUrl,
    this.borderColor,
    this.showBorder = false,
  });

  @override
  State<Fitness3DAvatar> createState() => _Fitness3DAvatarState();
}

class _Fitness3DAvatarState extends State<Fitness3DAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  AvatarAngle _currentAngle = AvatarAngle.front;

  @override
  void initState() {
    super.initState();
    _currentAngle = widget.angle;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: _angleToRadians(_currentAngle),
      end: _angleToRadians(widget.angle),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
    
    if (widget.enableAngleTransition && _currentAngle != widget.angle) {
      _controller.forward(from: 0.0);
      _currentAngle = widget.angle;
    }
  }

  @override
  void didUpdateWidget(Fitness3DAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.angle != widget.angle && widget.enableAngleTransition) {
      _rotationAnimation = Tween<double>(
        begin: _angleToRadians(_currentAngle),
        end: _angleToRadians(widget.angle),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ));
      _currentAngle = widget.angle;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Convert AvatarAngle to radians for rotation
  double _angleToRadians(AvatarAngle angle) {
    switch (angle) {
      case AvatarAngle.front:
        return 0.0;
      case AvatarAngle.frontLeft:
        return math.pi / 4; // 45°
      case AvatarAngle.left:
        return math.pi / 2; // 90°
      case AvatarAngle.backLeft:
        return 3 * math.pi / 4; // 135°
      case AvatarAngle.back:
        return math.pi; // 180°
      case AvatarAngle.backRight:
        return 5 * math.pi / 4; // 225°
      case AvatarAngle.right:
        return 3 * math.pi / 2; // 270°
      case AvatarAngle.frontRight:
        return 7 * math.pi / 4; // 315°
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enableAngleTransition ? _scaleAnimation.value : 1.0,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // Perspective
              ..rotateY(widget.enableAngleTransition 
                  ? _rotationAnimation.value 
                  : _angleToRadians(widget.angle)),
            child: _buildAvatar(),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    // If custom avatar URL is provided, use it with 3D effect
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      return _buildImageAvatar();
    }
    
    // Otherwise, use 3D character
    return _build3DCharacter();
  }

  Widget _buildImageAvatar() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.showBorder 
            ? AppleFitnessTheme.primaryGradient 
            : null,
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? AppleFitnessTheme.primaryBlue,
                width: 3,
              )
            : null,
        boxShadow: AppleFitnessTheme.softShadow(elevation: 8),
      ),
      padding: widget.showBorder ? const EdgeInsets.all(3) : EdgeInsets.zero,
      child: ClipOval(
        child: Image.network(
          widget.avatarUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _build3DCharacter();
          },
        ),
      ),
    );
  }

  Widget _build3DCharacter() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: widget.showBorder 
            ? AppleFitnessTheme.primaryGradient 
            : null,
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? AppleFitnessTheme.primaryBlue,
                width: 3,
              )
            : null,
        boxShadow: AppleFitnessTheme.softShadow(elevation: 8),
      ),
      padding: widget.showBorder ? const EdgeInsets.all(3) : EdgeInsets.zero,
      child: ClipOval(
        child: Cartoon3DCharacter(
          action: widget.action,
          emotion: widget.emotion,
          size: widget.size,
          animated: widget.animated,
        ),
      ),
    );
  }
}

/// 🎯 Avatar Action Helper
/// 
/// Helper class to map common actions to FitnessAction enum
class AvatarActionHelper {
  static FitnessAction fromString(String action) {
    switch (action.toLowerCase()) {
      case 'squat':
      case '深蹲':
        return FitnessAction.squat;
      case 'running':
      case '跑步':
        return FitnessAction.running;
      case 'weightlifting':
      case '举重':
        return FitnessAction.weightlifting;
      case 'yoga':
      case '瑜伽':
        return FitnessAction.yoga;
      case 'pushup':
      case '俯卧撑':
        return FitnessAction.pushup;
      case 'jumping':
      case '跳跃':
        return FitnessAction.jumping;
      case 'stretching':
      case '拉伸':
        return FitnessAction.stretching;
      case 'celebrating':
      case '庆祝':
        return FitnessAction.celebrating;
      case 'tired':
      case '疲惫':
        return FitnessAction.tired;
      default:
        return FitnessAction.idle;
    }
  }
}

