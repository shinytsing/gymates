import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/gymates_theme.dart';
import '../../core/navigation/app_router.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.fitness_center,
      activeIcon: Icons.fitness_center,
      label: '训练',
      route: AppRoutes.training,
    ),
    NavigationItem(
      icon: Icons.people,
      activeIcon: Icons.people,
      label: '社区',
      route: AppRoutes.community,
    ),
    NavigationItem(
      icon: Icons.people_alt,
      activeIcon: Icons.people_alt,
      label: '搭子',
      route: AppRoutes.partner,
    ),
    NavigationItem(
      icon: Icons.message,
      activeIcon: Icons.message,
      label: '消息',
      route: AppRoutes.messages,
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: '我的',
      route: AppRoutes.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? GymatesTheme.cardGradientDark 
            : GymatesTheme.cardGradient,
          boxShadow: GymatesTheme.getCardShadow(isDark),
          border: const Border(
            top: BorderSide(
              color: GymatesTheme.borderColor,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 65, // 增加高度以提供更好的触摸体验
            padding: const EdgeInsets.symmetric(
              horizontal: GymatesTheme.spacing8,
              vertical: GymatesTheme.spacing2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                      context.go(item.route);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: GymatesTheme.spacing8,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 高级动画图标容器
                          AnimatedContainer(
                            duration: AnimationConstants.normalAnimation,
                            curve: AnimationConstants.easeInOutCubic,
                            padding: const EdgeInsets.all(GymatesTheme.spacing4),
                            decoration: BoxDecoration(
                              gradient: isSelected 
                                ? GymatesTheme.primaryGradient
                                : null,
                              color: isSelected 
                                ? null
                                : Colors.transparent,
                              borderRadius: BorderRadius.circular(GymatesTheme.radius8),
                              boxShadow: isSelected 
                                ? GymatesTheme.glowShadow
                                : null,
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 20,
                              color: isSelected 
                                ? Colors.white
                                : (isDark 
                                  ? GymatesTheme.darkTextSecondary 
                                  : GymatesTheme.lightTextSecondary),
                            ),
                          )
                          .animate(target: isSelected ? 1 : 0)
                          .scale(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.1, 1.1),
                            duration: AnimationConstants.fastAnimation,
                            curve: AnimationConstants.springCurve,
                          )
                          .shimmer(
                            duration: const Duration(milliseconds: 1500),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          
                          const SizedBox(height: 0),
                          
                          // 标签文字
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                              color: isSelected 
                                ? (isDark 
                                  ? GymatesTheme.darkTextPrimary 
                                  : GymatesTheme.lightTextPrimary)
                                : (isDark 
                                  ? GymatesTheme.darkTextSecondary 
                                  : GymatesTheme.lightTextSecondary),
                              letterSpacing: 0.5,
                            ),
                          )
                          .animate(target: isSelected ? 1 : 0)
                          .fadeIn(
                            duration: AnimationConstants.fastAnimation,
                            curve: AnimationConstants.easeInOutCubic,
                          )
                          .slideY(
                            begin: 0.2,
                            end: 0.0,
                            duration: AnimationConstants.fastAnimation,
                            curve: AnimationConstants.easeInOutCubic,
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

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
