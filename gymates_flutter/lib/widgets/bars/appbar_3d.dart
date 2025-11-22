import 'package:flutter/material.dart';
import '../../core/theme/apple_fitness_theme.dart';
import '../../core/theme/cartoon_3d_characters.dart';
import '../avatars/fitness_3d_avatar.dart';

/// 📊 AppBar 3D Component
/// 
/// Apple Fitness+ style app bar with 3D avatar support.
/// 
/// Usage:
/// ```dart
/// AppBar3D(
///   title: 'Training',
///   subtitle: 'Start your workout',
///   leading: BackButton(),
///   actions: [IconButton(...)],
/// )
/// ```

class AppBar3D extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final FitnessAction? avatarAction;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final bool showAvatar;
  final double? elevation;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;

  const AppBar3D({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.avatarAction,
    this.avatarUrl,
    this.onAvatarTap,
    this.showAvatar = false,
    this.elevation,
    this.backgroundColor,
    this.backgroundGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: backgroundGradient,
        color: backgroundColor ?? AppleFitnessTheme.backgroundPrimary,
        boxShadow: elevation != null && elevation! > 0
            ? AppleFitnessTheme.softShadow(elevation: elevation!)
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppleFitnessTheme.spacingL,
            vertical: AppleFitnessTheme.spacingM,
          ),
          child: Row(
            children: [
              if (leading != null) leading!,
              if (leading != null) SizedBox(width: AppleFitnessTheme.spacingM),
              if (showAvatar && (avatarAction != null || avatarUrl != null)) ...[
                GestureDetector(
                  onTap: onAvatarTap,
                  child: Fitness3DAvatar(
                    action: avatarAction ?? FitnessAction.idle,
                    avatarUrl: avatarUrl,
                    size: 40,
                    animated: true,
                    showBorder: true,
                  ),
                ),
                SizedBox(width: AppleFitnessTheme.spacingM),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: AppleFitnessTheme.displaySmall,
                      ),
                    if (subtitle != null) ...[
                      SizedBox(height: AppleFitnessTheme.spacingXS / 2),
                      Text(
                        subtitle!,
                        style: AppleFitnessTheme.bodySmall.copyWith(
                          color: AppleFitnessTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + 
        (subtitle != null ? 20 : 0) + 
        AppleFitnessTheme.spacingM * 2,
      );
}

