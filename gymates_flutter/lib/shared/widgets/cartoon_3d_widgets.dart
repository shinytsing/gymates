import 'package:flutter/material.dart';
import '../../core/theme/cartoon_3d_theme.dart';

/// 🎨 3D卡通风格UI组件库
/// 
/// 包含所有常用的UI组件,统一使用3D卡通风格

/// 🎨 3D卡通输入框
class Cartoon3DTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  
  const Cartoon3DTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
  });

  @override
  State<Cartoon3DTextField> createState() => _Cartoon3DTextFieldState();
}

class _Cartoon3DTextFieldState extends State<Cartoon3DTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Cartoon3DTheme.cardBg,
        borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusM),
        boxShadow: _isFocused 
            ? Cartoon3DTheme.glowingShadow(Cartoon3DTheme.primaryVibrant)
            : Cartoon3DTheme.cartoon3DShadow,
        border: Border.all(
          color: _isFocused 
              ? Cartoon3DTheme.primaryVibrant 
              : Colors.white,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        onChanged: widget.onChanged,
        style: const TextStyle(
          color: Cartoon3DTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Cartoon3DTheme.space20,
            vertical: Cartoon3DTheme.space16,
          ),
          hintStyle: TextStyle(
            color: Cartoon3DTheme.textSecondary.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          labelStyle: const TextStyle(
            color: Cartoon3DTheme.primaryVibrant,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () => setState(() => _isFocused = true),
        onTapOutside: (_) => setState(() => _isFocused = false),
      ),
    );
  }
}

/// 🎨 3D卡通标签
class Cartoon3DChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool selected;
  
  const Cartoon3DChip({
    super.key,
    required this.label,
    this.color,
    this.gradient,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Cartoon3DTheme.space16,
          vertical: Cartoon3DTheme.space8,
        ),
        decoration: BoxDecoration(
          gradient: selected 
              ? (gradient ?? Cartoon3DTheme.primary3DGradient)
              : null,
          color: selected ? null : (color ?? Cartoon3DTheme.mediumBg),
          borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusFull),
          boxShadow: selected 
              ? Cartoon3DTheme.glowingShadow(
                  color ?? Cartoon3DTheme.primaryVibrant,
                )
              : Cartoon3DTheme.cartoon3DShadow,
          border: Border.all(
            color: selected 
                ? Colors.white 
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected 
                ? Cartoon3DTheme.textLight 
                : Cartoon3DTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// 🎨 3D卡通统计卡片
class Cartoon3DStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;
  
  const Cartoon3DStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.gradient = Cartoon3DTheme.primary3DGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Cartoon3DCard(
      gradient: gradient,
      onTap: onTap,
      padding: const EdgeInsets.all(Cartoon3DTheme.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标
          Container(
            padding: const EdgeInsets.all(Cartoon3DTheme.space12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
            ),
            child: Icon(
              icon,
              color: Cartoon3DTheme.textLight,
              size: 24,
            ),
          ),
          const SizedBox(height: Cartoon3DTheme.space16),
          
          // 标题
          Text(
            title,
            style: const TextStyle(
              color: Cartoon3DTheme.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Cartoon3DTheme.space8),
          
          // 数值
          Text(
            value,
            style: const TextStyle(
              color: Cartoon3DTheme.textLight,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          
          // 副标题
          if (subtitle != null) ...[
            const SizedBox(height: Cartoon3DTheme.space8),
            Text(
              subtitle!,
              style: TextStyle(
                color: Cartoon3DTheme.textLight.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 🎨 3D卡通动作按钮
class Cartoon3DActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final Color? color;
  final bool large;
  
  const Cartoon3DActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.gradient,
    this.color,
    this.large = false,
  });

  @override
  State<Cartoon3DActionButton> createState() => _Cartoon3DActionButtonState();
}

class _Cartoon3DActionButtonState extends State<Cartoon3DActionButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Cartoon3DTheme.space24,
            vertical: widget.large 
                ? Cartoon3DTheme.space20 
                : Cartoon3DTheme.space16,
          ),
          decoration: BoxDecoration(
            gradient: widget.gradient ?? Cartoon3DTheme.primary3DGradient,
            color: widget.color,
            borderRadius: BorderRadius.circular(
              widget.large 
                  ? Cartoon3DTheme.radiusL 
                  : Cartoon3DTheme.radiusM,
            ),
            boxShadow: Cartoon3DTheme.glowingShadow(
              widget.color ?? Cartoon3DTheme.primaryVibrant,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Cartoon3DTheme.textLight,
                size: widget.large ? 28 : 24,
              ),
              const SizedBox(width: Cartoon3DTheme.space12),
              Text(
                widget.label,
                style: TextStyle(
                  color: Cartoon3DTheme.textLight,
                  fontSize: widget.large ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎨 3D卡通列表项
class Cartoon3DListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Gradient? gradient;
  
  const Cartoon3DListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Cartoon3DCard(
      onTap: onTap,
      gradient: gradient,
      padding: const EdgeInsets.all(Cartoon3DTheme.space16),
      child: Row(
        children: [
          // Leading
          if (leading != null) ...[
            leading!,
            const SizedBox(width: Cartoon3DTheme.space16),
          ],
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: gradient != null 
                        ? Cartoon3DTheme.textLight 
                        : Cartoon3DTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: Cartoon3DTheme.space4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: gradient != null 
                          ? Cartoon3DTheme.textLight.withValues(alpha: 0.8)
                          : Cartoon3DTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Trailing
          if (trailing != null) ...[
            const SizedBox(width: Cartoon3DTheme.space16),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// 🎨 3D卡通开关
class Cartoon3DSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  
  const Cartoon3DSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 56,
        height: 32,
        decoration: BoxDecoration(
          gradient: value 
              ? LinearGradient(
                  colors: [
                    activeColor ?? Cartoon3DTheme.primaryVibrant,
                    (activeColor ?? Cartoon3DTheme.primaryVibrant)
                        .withValues(alpha: 0.8),
                  ],
                )
              : null,
          color: value ? null : Cartoon3DTheme.mediumBg,
          borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusFull),
          boxShadow: value 
              ? Cartoon3DTheme.glowingShadow(
                  activeColor ?? Cartoon3DTheme.primaryVibrant,
                )
              : Cartoon3DTheme.cartoon3DShadow,
        ),
        child: AnimatedAlign(
          duration: Cartoon3DAnimations.normal,
          curve: Cartoon3DAnimations.spring,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Cartoon3DTheme.cardBg,
              shape: BoxShape.circle,
              boxShadow: Cartoon3DTheme.floatingShadow,
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎨 3D卡通底部导航栏
class Cartoon3DBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<Cartoon3DBottomNavItem> items;
  
  const Cartoon3DBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Cartoon3DTheme.cardBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Cartoon3DTheme.radiusL),
          topRight: Radius.circular(Cartoon3DTheme.radiusL),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x20000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) => _buildNavItem(items[index], index == currentIndex, index),
        ),
      ),
    );
  }

  Widget _buildNavItem(Cartoon3DBottomNavItem item, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Cartoon3DTheme.space20,
          vertical: Cartoon3DTheme.space12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标容器
            AnimatedContainer(
              duration: Cartoon3DAnimations.normal,
              curve: Cartoon3DAnimations.spring,
              padding: const EdgeInsets.all(Cartoon3DTheme.space8),
              decoration: isSelected
                  ? BoxDecoration(
                      gradient: item.gradient ?? Cartoon3DTheme.primary3DGradient,
                      borderRadius: BorderRadius.circular(Cartoon3DTheme.radiusS),
                      boxShadow: Cartoon3DTheme.glowingShadow(
                        Cartoon3DTheme.primaryVibrant,
                      ),
                    )
                  : null,
              child: Icon(
                item.icon,
                color: isSelected 
                    ? Cartoon3DTheme.textLight 
                    : Cartoon3DTheme.textSecondary,
                size: 24,
              ),
            ),
            
            const SizedBox(height: Cartoon3DTheme.space4),
            
            // 标签
            Text(
              item.label,
              style: TextStyle(
                color: isSelected 
                    ? Cartoon3DTheme.primaryVibrant 
                    : Cartoon3DTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部导航项数据类
class Cartoon3DBottomNavItem {
  final IconData icon;
  final String label;
  final Gradient? gradient;
  
  const Cartoon3DBottomNavItem({
    required this.icon,
    required this.label,
    this.gradient,
  });
}

/// 🎨 3D卡通浮动动作按钮
class Cartoon3DFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final bool mini;
  
  const Cartoon3DFAB({
    super.key,
    required this.icon,
    required this.onPressed,
    this.gradient,
    this.mini = false,
  });

  @override
  State<Cartoon3DFAB> createState() => _Cartoon3DFABState();
}

class _Cartoon3DFABState extends State<Cartoon3DFAB> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.mini ? 48.0 : 64.0;
    final iconSize = widget.mini ? 24.0 : 32.0;
    
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: widget.gradient ?? Cartoon3DTheme.rainbow3DGradient,
                  shape: BoxShape.circle,
                  boxShadow: Cartoon3DTheme.glowingShadow(
                    Cartoon3DTheme.primaryVibrant,
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  color: Cartoon3DTheme.textLight,
                  size: iconSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

