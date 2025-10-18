import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';

/// 🎨 Enhanced UI Components - Premium Design System
/// 
/// Features:
/// - Platform-specific styling
/// - Advanced animations and interactions
/// - Haptic feedback integration
/// - Accessibility support
/// - Performance optimized

/// 🌟 Enhanced Button Component
class EnhancedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const EnhancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  State<EnhancedButton> createState() => _EnhancedButtonState();
}

class _EnhancedButtonState extends State<EnhancedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      HapticFeedback.lightImpact();
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              height: _getButtonHeight(),
              padding: EdgeInsets.symmetric(
                horizontal: _getHorizontalPadding(),
                vertical: _getVerticalPadding(),
              ),
              decoration: BoxDecoration(
                gradient: _getGradient(),
                color: _getSolidColor(),
                borderRadius: BorderRadius.circular(GymatesTheme.buttonRadius),
                boxShadow: _getShadow(),
                border: _getBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: _getTextColor(),
                      size: _getIconSize(),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      color: _getTextColor(),
                      fontSize: _getFontSize(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double _getButtonHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getHorizontalPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 24;
      case ButtonSize.large:
        return 32;
    }
  }

  double _getVerticalPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return 8;
      case ButtonSize.medium:
        return 12;
      case ButtonSize.large:
        return 16;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }

  Gradient? _getGradient() {
    switch (widget.type) {
      case ButtonType.primary:
        return GymatesTheme.primaryGradient;
      case ButtonType.secondary:
        return null;
      case ButtonType.outline:
        return null;
      case ButtonType.ghost:
        return null;
    }
  }

  Color? _getSolidColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return null;
      case ButtonType.secondary:
        return GymatesTheme.primaryColor.withOpacity(0.1);
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.ghost:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return GymatesTheme.primaryColor;
      case ButtonType.outline:
        return GymatesTheme.primaryColor;
      case ButtonType.ghost:
        return GymatesTheme.lightTextPrimary;
    }
  }

  List<BoxShadow>? _getShadow() {
    switch (widget.type) {
      case ButtonType.primary:
        return GymatesTheme.glowShadow;
      case ButtonType.secondary:
        return GymatesTheme.softShadow;
      case ButtonType.outline:
        return null;
      case ButtonType.ghost:
        return null;
    }
  }

  Border? _getBorder() {
    switch (widget.type) {
      case ButtonType.primary:
        return null;
      case ButtonType.secondary:
        return null;
      case ButtonType.outline:
        return Border.all(
          color: GymatesTheme.primaryColor,
          width: 1,
        );
      case ButtonType.ghost:
        return null;
    }
  }
}

/// 🎯 Button Types
enum ButtonType {
  primary,
  secondary,
  outline,
  ghost,
}

enum ButtonSize {
  small,
  medium,
  large,
}

/// 🎨 Enhanced Card Component
class EnhancedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final CardType type;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool enableGlow;
  final bool enableBreathing;

  const EnhancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.type = CardType.elevated,
    this.padding,
    this.margin,
    this.enableGlow = false,
    this.enableBreathing = false,
  });

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.enableBreathing) {
      _breathingController = AnimationController(
        duration: const Duration(milliseconds: 2800),
        vsync: this,
      );
      _breathingAnimation = Tween<double>(
        begin: 0.95,
        end: 1.05,
      ).animate(CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ));
      _breathingController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.enableBreathing) {
      _breathingController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(GymatesTheme.cardRadius),
        boxShadow: _getShadow(),
        border: _getBorder(),
        gradient: _getGradient(),
      ),
      child: widget.child,
    );

    if (widget.enableBreathing) {
      card = AnimatedBuilder(
        animation: _breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _breathingAnimation.value,
            child: child,
          );
        },
        child: card,
      );
    }

    if (widget.onTap != null) {
      card = GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap!();
        },
        child: card,
      );
    }

    return card;
  }

  Color? _getBackgroundColor() {
    switch (widget.type) {
      case CardType.elevated:
        return Colors.white;
      case CardType.outlined:
        return Colors.white;
      case CardType.filled:
        return GymatesTheme.lightBackground;
      case CardType.glass:
        return Colors.white.withOpacity(0.1);
    }
  }

  List<BoxShadow>? _getShadow() {
    switch (widget.type) {
      case CardType.elevated:
        return widget.enableGlow 
            ? GymatesTheme.glowShadow
            : GymatesTheme.softShadow;
      case CardType.outlined:
        return null;
      case CardType.filled:
        return null;
      case CardType.glass:
        return GymatesTheme.platformShadow;
    }
  }

  Border? _getBorder() {
    switch (widget.type) {
      case CardType.elevated:
        return null;
      case CardType.outlined:
        return Border.all(
          color: GymatesTheme.lightTextSecondary.withOpacity(0.2),
          width: 1,
        );
      case CardType.filled:
        return null;
      case CardType.glass:
        return Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        );
    }
  }

  Gradient? _getGradient() {
    switch (widget.type) {
      case CardType.elevated:
        return null;
      case CardType.outlined:
        return null;
      case CardType.filled:
        return null;
      case CardType.glass:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        );
    }
  }
}

/// 🎯 Card Types
enum CardType {
  elevated,
  outlined,
  filled,
  glass,
}

/// 🎨 Enhanced Text Field Component
class EnhancedTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final bool enabled;

  const EnhancedTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<EnhancedTextField> createState() => _EnhancedTextFieldState();
}

class _EnhancedTextFieldState extends State<EnhancedTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GymatesTheme.inputRadius),
            boxShadow: _isFocused 
                ? [
                    BoxShadow(
                      color: GymatesTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: widget.hintText,
              labelText: widget.labelText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GymatesTheme.inputRadius),
                borderSide: BorderSide(
                  color: _isFocused 
                      ? GymatesTheme.primaryColor
                      : Colors.grey.withOpacity(0.3),
                  width: _isFocused ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GymatesTheme.inputRadius),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GymatesTheme.inputRadius),
                borderSide: BorderSide(
                  color: GymatesTheme.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GymatesTheme.inputRadius),
                borderSide: const BorderSide(
                  color: GymatesTheme.errorColor,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GymatesTheme.inputRadius),
                borderSide: const BorderSide(
                  color: GymatesTheme.errorColor,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎨 Enhanced Loading Indicator
class EnhancedLoadingIndicator extends StatefulWidget {
  final LoadingType type;
  final Color? color;
  final double? size;
  final String? message;

  const EnhancedLoadingIndicator({
    super.key,
    this.type = LoadingType.circular,
    this.color,
    this.size,
    this.message,
  });

  @override
  State<EnhancedLoadingIndicator> createState() => _EnhancedLoadingIndicatorState();
}

class _EnhancedLoadingIndicatorState extends State<EnhancedLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? GymatesTheme.primaryColor;
    final size = widget.size ?? 24.0;

    Widget indicator;
    
    switch (widget.type) {
      case LoadingType.circular:
        indicator = CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
          strokeWidth: 3,
        );
        break;
      case LoadingType.linear:
        indicator = LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color),
        );
        break;
      case LoadingType.dots:
        indicator = _buildDotsIndicator(color, size);
        break;
      case LoadingType.pulse:
        indicator = _buildPulseIndicator(color, size);
        break;
    }

    if (widget.message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: indicator,
          ),
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: indicator,
    );
  }

  Widget _buildDotsIndicator(Color color, double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * animationValue);
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: size / 3,
                  height: size / 3,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulseIndicator(Color color, double size) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.3 * (1 - _animation.value)),
          ),
          child: Center(
            child: Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🎯 Loading Types
enum LoadingType {
  circular,
  linear,
  dots,
  pulse,
}
