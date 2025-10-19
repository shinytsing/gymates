import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/enhanced_theme.dart';
import '../../core/navigation/app_router.dart';
import '../../core/animations/page_animations.dart';

/// Enhanced Main Navigation with better animations and styling
class EnhancedMainNavigation extends StatefulWidget {
  final Widget child;

  const EnhancedMainNavigation({
    super.key,
    required this.child,
  });

  @override
  State<EnhancedMainNavigation> createState() => _EnhancedMainNavigationState();
}

class _EnhancedMainNavigationState extends State<EnhancedMainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.fitness_center_outlined,
      activeIcon: Icons.fitness_center,
      label: '训练',
      route: AppRoutes.training,
      color: AppColors.primary,
    ),
    NavigationItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: '社区',
      route: AppRoutes.community,
      color: AppColors.secondary,
    ),
    NavigationItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: '搭子',
      route: AppRoutes.mates,
      color: AppColors.success,
    ),
    NavigationItem(
      icon: Icons.message_outlined,
      activeIcon: Icons.message,
      label: '消息',
      route: AppRoutes.messages,
      color: AppColors.warning,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: '我的',
      route: AppRoutes.profile,
      color: AppColors.info,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: AppCurves.easeOut,
    ));
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _indicatorController.forward().then((_) {
        _indicatorController.reset();
      });
      context.go(_navigationItems[index].route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppShadows.large,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusXL),
            topRight: Radius.circular(AppSizes.radiusXL),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: AppSizes.bottomNavHeight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: AppSizes.spacingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                
                return Expanded(
                  child: AnimatedScaleContainer(
                    scale: 0.9,
                    onTap: () => _onTabTapped(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.spacingS,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: AppDurations.fast,
                            padding: const EdgeInsets.all(AppSizes.spacingS),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? item.color.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSizes.radiusM),
                            ),
                            child: AnimatedSwitcher(
                              duration: AppDurations.fast,
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                key: ValueKey(isSelected),
                                size: AppSizes.iconM,
                                color: isSelected 
                                    ? item.color 
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSizes.spacingXS),
                          AnimatedDefaultTextStyle(
                            duration: AppDurations.fast,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isSelected 
                                  ? item.color 
                                  : AppColors.textSecondary,
                              fontWeight: isSelected 
                                  ? FontWeight.w600 
                                  : FontWeight.normal,
                            ),
                            child: Text(item.label),
                          ),
                          if (isSelected)
                            AnimatedBuilder(
                              animation: _indicatorAnimation,
                              builder: (context, child) {
                                return Container(
                                  margin: const EdgeInsets.only(top: AppSizes.spacingXS),
                                  height: 2,
                                  width: 20 * _indicatorAnimation.value,
                                  decoration: BoxDecoration(
                                    color: item.color,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enhanced App Bar with better styling
class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool enableBackButton;
  final VoidCallback? onBackPressed;

  const EnhancedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.enableBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          color: foregroundColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surface,
      foregroundColor: foregroundColor ?? AppColors.textPrimary,
      elevation: elevation ?? 0,
      shadowColor: AppColors.shadow,
      surfaceTintColor: Colors.transparent,
      leading: leading ??
          (enableBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: onBackPressed ?? () => context.pop(),
                )
              : null),
      actions: actions?.map((action) {
        return AnimatedScaleContainer(
          scale: 0.9,
          child: action,
        );
      }).toList(),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (backgroundColor ?? AppColors.surface).withOpacity(0.95),
              (backgroundColor ?? AppColors.surface).withOpacity(0.8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);
}

/// Enhanced Tab Bar with animated indicator
class EnhancedTabBar extends StatefulWidget {
  final List<String> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;

  const EnhancedTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  });

  @override
  State<EnhancedTabBar> createState() => _EnhancedTabBarState();
}

class _EnhancedTabBarState extends State<EnhancedTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = widget.controller ??
        TabController(length: widget.tabs.length, vsync: this);
    _indicatorController = AnimationController(
      duration: AppDurations.normal,
      vsync: this,
    );
    _indicatorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _indicatorController,
      curve: AppCurves.easeOut,
    ));

    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _tabController.dispose();
    }
    _indicatorController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    _indicatorController.forward().then((_) {
      _indicatorController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.small,
      ),
      child: TabBar(
        controller: _tabController,
        onTap: widget.onTap,
        isScrollable: widget.isScrollable,
        indicatorColor: widget.indicatorColor ?? AppColors.primary,
        labelColor: widget.labelColor ?? AppColors.primary,
        unselectedLabelColor: widget.unselectedLabelColor ?? AppColors.textSecondary,
        labelStyle: AppTextStyles.buttonMedium,
        unselectedLabelStyle: AppTextStyles.bodyMedium,
        indicator: AnimatedBuilder(
          animation: _indicatorAnimation,
          builder: (context, child) {
            return UnderlineTabIndicator(
              borderSide: BorderSide(
                color: widget.indicatorColor ?? AppColors.primary,
                width: 3,
              ),
              insets: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
            );
          },
        ),
        tabs: widget.tabs.map((tab) {
          return Tab(
            child: AnimatedScaleContainer(
              scale: 0.95,
              child: Text(tab),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Enhanced Floating Action Button
class EnhancedFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;
  final bool enableHapticFeedback;

  const EnhancedFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
    this.enableHapticFeedback = true,
  });

  @override
  State<EnhancedFloatingActionButton> createState() =>
      _EnhancedFloatingActionButtonState();
}

class _EnhancedFloatingActionButtonState
    extends State<EnhancedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.easeInOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: AppCurves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: FloatingActionButton(
              onPressed: widget.onPressed != null ? _handleTap : null,
              backgroundColor: widget.backgroundColor ?? AppColors.primary,
              foregroundColor: widget.foregroundColor ?? AppColors.textOnPrimary,
              tooltip: widget.tooltip,
              mini: widget.mini,
              elevation: 8,
              child: Icon(widget.icon),
            ),
          ),
        );
      },
    );
  }
}

/// Navigation Item Model
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final Color color;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.color,
  });
}
