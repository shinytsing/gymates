import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🔘 3D Button Component - Universal 3D Button System
/// 
/// Features:
/// - Press depth animation
/// - Hover lift animation
/// - Gradient backgrounds with 3D effect
/// - Ripple and glow effects
/// - Loading state with 3D spinner
/// - Haptic feedback
/// - Icon + Text combinations
/// 
/// Button Types:
/// - Primary: Main action buttons
/// - Secondary: Secondary action buttons
/// - Outline: Border-only buttons
/// - Icon: Icon-only buttons
/// - Floating: Floating action buttons

enum Button3DType {
  primary,
  secondary,
  outline,
  icon,
  floating,
}

enum Button3DSize {
  small,
  medium,
  large,
  extraLarge,
}

class Button3D extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  
  // Button Properties
  final Button3DType type;
  final Button3DSize size;
  final bool isLoading;
  final bool isDisabled;
  
  // Visual Properties
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final double? width;
  final double? height;
  
  // 3D Properties
  final double elevation;
  final bool enableHaptic;
  final bool enableGlow;
  final bool enablePulse;
  
  // Animation Properties
  final Duration animationDuration;
  final Curve animationCurve;
  
  const Button3D({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.onLongPress,
    this.type = Button3DType.primary,
    this.size = Button3DSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.gradient,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.width,
    this.height,
    this.elevation = 8,
    this.enableHaptic = true,
    this.enableGlow = false,
    this.enablePulse = false,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOut,
  });

  // Factory constructors for common button types
  factory Button3D.primary({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    Button3DSize size = Button3DSize.medium,
  }) {
    return Button3D(
      text: text,
      icon: icon,
      onPressed: onPressed,
      type: Button3DType.primary,
      size: size,
      isLoading: isLoading,
      enableGlow: true,
    );
  }
  
  factory Button3D.secondary({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Button3DSize size = Button3DSize.medium,
  }) {
    return Button3D(
      text: text,
      icon: icon,
      onPressed: onPressed,
      type: Button3DType.secondary,
      size: size,
    );
  }
  
  factory Button3D.outline({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Button3DSize size = Button3DSize.medium,
  }) {
    return Button3D(
      text: text,
      icon: icon,
      onPressed: onPressed,
      type: Button3DType.outline,
      size: size,
      elevation: 4,
    );
  }
  
  factory Button3D.icon({
    required IconData icon,
    required VoidCallback onPressed,
    Button3DSize size = Button3DSize.medium,
  }) {
    return Button3D(
      icon: icon,
      onPressed: onPressed,
      type: Button3DType.icon,
      size: size,
    );
  }
  
  factory Button3D.floating({
    required IconData icon,
    required VoidCallback onPressed,
    bool enablePulse = true,
  }) {
    return Button3D(
      icon: icon,
      onPressed: onPressed,
      type: Button3DType.floating,
      size: Button3DSize.large,
      elevation: 12,
      enableGlow: true,
      enablePulse: enablePulse,
    );
  }

  @override
  State<Button3D> createState() => _Button3DState();
}

class _Button3DState extends State<Button3D> with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isPressed = false;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    
    // Press animation
    _pressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: widget.animationCurve,
    ));
    
    _elevationAnimation = Tween<double>(
      begin: widget.elevation,
      end: widget.elevation * 0.3,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: widget.animationCurve,
    ));
    
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.enablePulse && !widget.isDisabled) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  @override
  void didUpdateWidget(Button3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enablePulse != oldWidget.enablePulse) {
      if (widget.enablePulse && !widget.isDisabled) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }
  
  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = true);
      _pressController.forward();
      if (widget.enableHaptic) {
        HapticFeedback.lightImpact();
      }
    }
  }
  
  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }
  
  void _handleTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      _pressController.reverse();
    }
  }
  
  void _handleTap() {
    if (!widget.isDisabled && !widget.isLoading) {
      if (widget.enableHaptic) {
        HapticFeedback.mediumImpact();
      }
      widget.onPressed?.call();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !widget.isDisabled && !widget.isLoading;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pressController, _pulseController]),
      builder: (context, child) {
        return GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          onLongPress: widget.onLongPress,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: AnimatedOpacity(
              opacity: widget.isDisabled ? 0.5 : 1.0,
              duration: widget.animationDuration,
              child: Transform.scale(
                scale: widget.enablePulse 
                    ? _pulseAnimation.value 
                    : (_isPressed ? _scaleAnimation.value : (_isHovered ? 1.05 : 1.0)),
                child: AnimatedContainer(
                  duration: widget.animationDuration,
                  curve: widget.animationCurve,
                  width: widget.width ?? _getWidth(),
                  height: widget.height ?? _getHeight(),
                  decoration: BoxDecoration(
                    gradient: _getGradient(theme),
                    color: _getBackgroundColor(theme),
                    border: widget.type == Button3DType.outline 
                        ? Border.all(
                            color: widget.foregroundColor ?? theme.colorScheme.primary,
                            width: 2,
                          )
                        : null,
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(_getBorderRadius()),
                    boxShadow: _buildShadows(theme),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: isEnabled ? _handleTap : null,
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(_getBorderRadius()),
                      child: Container(
                        padding: _getPadding(),
                        child: _buildContent(theme),
                      ),
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
  
  Widget _buildContent(ThemeData theme) {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _getIconSize() * 1.2,
          height: _getIconSize() * 1.2,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(
              widget.foregroundColor ?? _getForegroundColor(theme),
            ),
          ),
        ),
      );
    }
    
    if (widget.type == Button3DType.icon || widget.type == Button3DType.floating) {
      return Center(
        child: Icon(
          widget.icon,
          size: _getIconSize(),
          color: widget.foregroundColor ?? _getForegroundColor(theme),
        ),
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            size: _getIconSize(),
            color: widget.foregroundColor ?? _getForegroundColor(theme),
          ),
          const SizedBox(width: 8),
        ],
        if (widget.text != null)
          Text(
            widget.text!,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
              color: widget.foregroundColor ?? _getForegroundColor(theme),
            ),
          ),
      ],
    );
  }
  
  double _getWidth() {
    if (widget.type == Button3DType.icon || widget.type == Button3DType.floating) {
      return _getHeight();
    }
    return double.infinity;
  }
  
  double _getHeight() {
    return switch (widget.size) {
      Button3DSize.small => 40,
      Button3DSize.medium => 50,
      Button3DSize.large => 60,
      Button3DSize.extraLarge => 70,
    };
  }
  
  double _getBorderRadius() {
    return switch (widget.size) {
      Button3DSize.small => 12,
      Button3DSize.medium => 16,
      Button3DSize.large => 20,
      Button3DSize.extraLarge => 24,
    };
  }
  
  double _getFontSize() {
    return switch (widget.size) {
      Button3DSize.small => 14,
      Button3DSize.medium => 16,
      Button3DSize.large => 18,
      Button3DSize.extraLarge => 20,
    };
  }
  
  double _getIconSize() {
    return switch (widget.size) {
      Button3DSize.small => 18,
      Button3DSize.medium => 22,
      Button3DSize.large => 26,
      Button3DSize.extraLarge => 30,
    };
  }
  
  EdgeInsets _getPadding() {
    if (widget.type == Button3DType.icon || widget.type == Button3DType.floating) {
      return EdgeInsets.zero;
    }
    return switch (widget.size) {
      Button3DSize.small => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      Button3DSize.medium => const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      Button3DSize.large => const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      Button3DSize.extraLarge => const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
    };
  }
  
  Gradient? _getGradient(ThemeData theme) {
    if (widget.gradient != null) return widget.gradient;
    if (widget.type == Button3DType.outline) return null;
    if (widget.type == Button3DType.primary || widget.type == Button3DType.floating) {
      final color = widget.backgroundColor ?? theme.colorScheme.primary;
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color,
          Color.lerp(color, Colors.black, 0.2)!,
        ],
      );
    }
    return null;
  }
  
  Color? _getBackgroundColor(ThemeData theme) {
    if (widget.gradient != null) return null;
    if (widget.type == Button3DType.outline) return Colors.transparent;
    return widget.backgroundColor ?? (
      widget.type == Button3DType.secondary 
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.primary
    );
  }
  
  Color _getForegroundColor(ThemeData theme) {
    if (widget.type == Button3DType.outline || widget.type == Button3DType.secondary) {
      return theme.colorScheme.primary;
    }
    return Colors.white;
  }
  
  List<BoxShadow> _buildShadows(ThemeData theme) {
    final currentElevation = _isPressed 
        ? _elevationAnimation.value 
        : (_isHovered ? widget.elevation * 1.5 : widget.elevation);
    
    final shadows = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: currentElevation,
        offset: Offset(0, currentElevation * 0.5),
      ),
    ];
    
    // Add glow effect
    if (widget.enableGlow && !widget.isDisabled) {
      final glowColor = widget.backgroundColor ?? theme.colorScheme.primary;
      shadows.addAll([
        BoxShadow(
          color: glowColor.withValues(alpha: 0.3),
          blurRadius: currentElevation * 1.5,
          offset: Offset.zero,
        ),
      ]);
    }
    
    return shadows;
  }
}

/// 🔘 3D Icon Button - Circular icon button with 3D effect
class IconButton3D extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  
  const IconButton3D({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Button3D.icon(
      icon: icon,
      onPressed: onPressed ?? () {},
      size: Button3DSize.medium,
    );
  }
}

