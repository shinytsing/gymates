import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/apple_fitness_theme.dart';

/// 🎭 Apple Fitness+ Style 3D Modal Components
/// 
/// Features:
/// - Frosted glass modals
/// - Smooth slide-up animations
/// - Gentle backdrop blur
/// - Large radius corners
/// - Minimal, clean design

/// 🎭 Show 3D Bottom Sheet (Apple style)
Future<T?> showModal3D<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
  double? height,
  bool useFrostedGlass = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (context) => Modal3D(
      height: height,
      useFrostedGlass: useFrostedGlass,
      backgroundColor: backgroundColor,
      child: child,
    ),
  );
}

/// 🎭 3D Modal Container
class Modal3D extends StatefulWidget {
  final Widget child;
  final double? height;
  final bool useFrostedGlass;
  final Color? backgroundColor;
  
  const Modal3D({
    super.key,
    required this.child,
    this.height,
    this.useFrostedGlass = true,
    this.backgroundColor,
  });

  @override
  State<Modal3D> createState() => _Modal3DState();
}

class _Modal3DState extends State<Modal3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleFitnessTheme.durationNormal,
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppleFitnessTheme.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final modalHeight = widget.height ?? screenHeight * 0.9;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, modalHeight * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        height: modalHeight,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(36), // Extra large radius
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(36),
          ),
          child: BackdropFilter(
            filter: widget.useFrostedGlass
                ? AppleFitnessTheme.frostEffect(blur: 30)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              decoration: BoxDecoration(
                color: widget.useFrostedGlass
                    ? AppleFitnessTheme.backgroundPrimary.withValues(alpha: 0.85)
                    : (widget.backgroundColor ?? AppleFitnessTheme.backgroundPrimary),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Container(
                        width: 36,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppleFitnessTheme.textQuaternary,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎭 Full Screen 3D Dialog (Apple style)
Future<T?> showDialog3D<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  bool useFrostedGlass = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => Dialog3D(
      useFrostedGlass: useFrostedGlass,
      child: child,
    ),
  );
}

/// 🎭 3D Dialog Container
class Dialog3D extends StatefulWidget {
  final Widget child;
  final bool useFrostedGlass;
  
  const Dialog3D({
    super.key,
    required this.child,
    this.useFrostedGlass = true,
  });

  @override
  State<Dialog3D> createState() => _Dialog3DState();
}

class _Dialog3DState extends State<Dialog3D> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppleFitnessTheme.durationNormal,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppleFitnessTheme.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _controller.forward();
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
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: AppleFitnessTheme.radiusLarge,
          child: BackdropFilter(
            filter: widget.useFrostedGlass
                ? AppleFitnessTheme.frostEffect(blur: 30)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              decoration: BoxDecoration(
                color: widget.useFrostedGlass
                    ? AppleFitnessTheme.backgroundPrimary.withValues(alpha: 0.9)
                    : AppleFitnessTheme.backgroundPrimary,
                borderRadius: AppleFitnessTheme.radiusLarge,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: AppleFitnessTheme.softShadow(elevation: 20),
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎭 Alert Dialog 3D (Apple style)
Future<bool?> showAlertDialog3D({
  required BuildContext context,
  String? title,
  String? message,
  String confirmText = '确定',
  String? cancelText,
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
}) {
  return showDialog3D<bool>(
    context: context,
    child: AlertDialog3D(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      onConfirm: () {
        onConfirm?.call();
        Navigator.of(context).pop(true);
      },
      onCancel: cancelText != null
          ? () {
              onCancel?.call();
              Navigator.of(context).pop(false);
            }
          : null,
    ),
  );
}

/// 🎭 Alert Dialog 3D Content
class AlertDialog3D extends StatelessWidget {
  final String? title;
  final String? message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  
  const AlertDialog3D({
    super.key,
    this.title,
    this.message,
    required this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: AppleFitnessTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          if (message != null) ...[
            Text(
              message!,
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
          Row(
            children: [
              if (cancelText != null) ...[
                Expanded(
                  child: _DialogButton(
                    text: cancelText!,
                    onPressed: onCancel,
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _DialogButton(
                  text: confirmText,
                  onPressed: onConfirm,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  
  const _DialogButton({
    required this.text,
    this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppleFitnessTheme.primaryGradient : null,
          color: isPrimary ? null : AppleFitnessTheme.backgroundSecondary,
          borderRadius: AppleFitnessTheme.radiusMedium,
          boxShadow: isPrimary ? AppleFitnessTheme.softShadow(elevation: 6) : null,
        ),
        child: Center(
          child: Text(
            text,
            style: AppleFitnessTheme.labelMedium.copyWith(
              color: isPrimary ? Colors.white : AppleFitnessTheme.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎭 Action Sheet 3D (iOS style)
Future<T?> showActionSheet3D<T>({
  required BuildContext context,
  String? title,
  String? message,
  required List<ActionSheetOption<T>> options,
  ActionSheetOption<T>? cancelOption,
}) {
  return showModal3D<T>(
    context: context,
    height: null,
    child: ActionSheet3D(
      title: title,
      message: message,
      options: options,
      cancelOption: cancelOption,
    ),
  );
}

class ActionSheetOption<T> {
  final String text;
  final T value;
  final bool isDestructive;
  final IconData? icon;
  
  ActionSheetOption({
    required this.text,
    required this.value,
    this.isDestructive = false,
    this.icon,
  });
}

class ActionSheet3D<T> extends StatelessWidget {
  final String? title;
  final String? message;
  final List<ActionSheetOption<T>> options;
  final ActionSheetOption<T>? cancelOption;
  
  const ActionSheet3D({
    super.key,
    this.title,
    this.message,
    required this.options,
    this.cancelOption,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || message != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppleFitnessTheme.backgroundSecondary,
                  borderRadius: AppleFitnessTheme.radiusMedium,
                ),
                child: Column(
                  children: [
                    if (title != null) ...[
                      Text(
                        title!,
                        style: AppleFitnessTheme.titleMedium.copyWith(
                          color: AppleFitnessTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (message != null) const SizedBox(height: 8),
                    ],
                    if (message != null)
                      Text(
                        message!,
                        style: AppleFitnessTheme.bodySmall.copyWith(
                          color: AppleFitnessTheme.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              decoration: BoxDecoration(
                color: AppleFitnessTheme.backgroundSecondary,
                borderRadius: AppleFitnessTheme.radiusMedium,
              ),
              child: Column(
                children: List.generate(
                  options.length,
                  (index) => _ActionSheetItem(
                    option: options[index],
                    isFirst: index == 0,
                    isLast: index == options.length - 1,
                    onTap: () => Navigator.of(context).pop(options[index].value),
                  ),
                ),
              ),
            ),
            if (cancelOption != null) ...[
              const SizedBox(height: 12),
              _ActionSheetItem(
                option: cancelOption!,
                isFirst: true,
                isLast: true,
                isBold: true,
                onTap: () => Navigator.of(context).pop(cancelOption!.value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionSheetItem<T> extends StatelessWidget {
  final ActionSheetOption<T> option;
  final bool isFirst;
  final bool isLast;
  final bool isBold;
  final VoidCallback onTap;
  
  const _ActionSheetItem({
    required this.option,
    required this.isFirst,
    required this.isLast,
    this.isBold = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: AppleFitnessTheme.textQuaternary.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                )
              : null,
          borderRadius: isFirst && isLast
              ? AppleFitnessTheme.radiusMedium
              : isFirst
                  ? const BorderRadius.vertical(top: Radius.circular(20))
                  : isLast
                      ? const BorderRadius.vertical(bottom: Radius.circular(20))
                      : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 20,
                color: option.isDestructive
                    ? AppleFitnessTheme.error
                    : AppleFitnessTheme.primaryBlue,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              option.text,
              style: (isBold ? AppleFitnessTheme.labelLarge : AppleFitnessTheme.bodyLarge).copyWith(
                color: option.isDestructive
                    ? AppleFitnessTheme.error
                    : AppleFitnessTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

