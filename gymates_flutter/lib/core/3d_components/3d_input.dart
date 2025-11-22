import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 📝 3D Input Components - 3D input fields with depth
/// 
/// Features:
/// - Floating label with 3D effect
/// - Focus state with elevation
/// - Error state with shake animation
/// - Prefix/suffix icons with 3D depth
/// - Character counter with 3D style

class Input3D extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  
  // Visual Properties
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorColor;
  final double elevation;
  final BorderRadius? borderRadius;
  
  const Input3D({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.inputFormatters,
    this.validator,
    this.backgroundColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorColor,
    this.elevation = 8,
    this.borderRadius,
  });

  @override
  State<Input3D> createState() => _Input3DState();
}

class _Input3DState extends State<Input3D> with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isFocused = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(_shakeController);
    
    _currentError = widget.errorText;
  }

  @override
  void didUpdateWidget(Input3D oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText && widget.errorText != null) {
      _currentError = widget.errorText;
      _shakeController.forward(from: 0);
      HapticFeedback.vibrate();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = _currentError != null;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? theme.colorScheme.surface,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              border: Border.all(
                color: hasError 
                    ? (widget.errorColor ?? theme.colorScheme.error)
                    : _isFocused
                        ? (widget.focusedBorderColor ?? theme.colorScheme.primary)
                        : (widget.borderColor ?? theme.colorScheme.outline),
                width: _isFocused ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasError
                      ? (widget.errorColor ?? theme.colorScheme.error).withValues(alpha: 0.2)
                      : _isFocused
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.05),
                  blurRadius: _isFocused ? widget.elevation * 1.5 : widget.elevation,
                  offset: Offset(0, _isFocused ? widget.elevation * 0.8 : widget.elevation * 0.5),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
              inputFormatters: widget.inputFormatters,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                labelText: widget.label,
                labelStyle: TextStyle(
                  color: _isFocused 
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
                ),
                floatingLabelStyle: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      )
                    : null,
                suffixIcon: widget.suffixIcon != null
                    ? GestureDetector(
                        onTap: widget.onSuffixTap,
                        child: Icon(
                          widget.suffixIcon,
                          color: _isFocused 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                counterText: '', // Hide default counter
              ),
            ),
          ),
          if (widget.maxLength != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: widget.errorColor ?? theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _currentError!,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.errorColor ?? theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (widget.helperText != null && !hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Text(
                widget.helperText!,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 🔍 3D Search Input - Search field with 3D effect
class SearchInput3D extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  
  const SearchInput3D({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<SearchInput3D> createState() => _SearchInput3DState();
}

class _SearchInput3DState extends State<SearchInput3D> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Input3D(
      controller: _controller,
      hint: widget.hint ?? '搜索...',
      prefixIcon: Icons.search,
      suffixIcon: _hasText ? Icons.clear : null,
      onSuffixTap: _hasText ? _clear : null,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      autofocus: widget.autofocus,
      elevation: 12,
    );
  }
}

/// 🔐 3D Password Input - Password field with visibility toggle
class PasswordInput3D extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool showStrengthIndicator;
  
  const PasswordInput3D({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.showStrengthIndicator = false,
  });

  @override
  State<PasswordInput3D> createState() => _PasswordInput3DState();
}

class _PasswordInput3DState extends State<PasswordInput3D> {
  bool _obscureText = true;
  double _strength = 0;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
    HapticFeedback.lightImpact();
  }

  void _calculateStrength(String password) {
    if (!widget.showStrengthIndicator) return;
    
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    
    setState(() {
      _strength = strength;
    });
  }

  Color _getStrengthColor() {
    if (_strength < 0.25) return Colors.red;
    if (_strength < 0.5) return Colors.orange;
    if (_strength < 0.75) return Colors.yellow;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_strength < 0.25) return '弱';
    if (_strength < 0.5) return '中等';
    if (_strength < 0.75) return '良好';
    return '强';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Input3D(
          controller: widget.controller,
          label: widget.label ?? '密码',
          hint: widget.hint,
          errorText: widget.errorText,
          prefixIcon: Icons.lock_outline,
          suffixIcon: _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          onSuffixTap: _toggleVisibility,
          obscureText: _obscureText,
          onChanged: (value) {
            _calculateStrength(value);
            widget.onChanged?.call(value);
          },
          onSubmitted: widget.onSubmitted,
        ),
        if (widget.showStrengthIndicator && widget.controller != null && widget.controller!.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _strength,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getStrengthColor(),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStrengthText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStrengthColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

