import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../../core/theme/gymates_theme.dart';
import '../../core/animations/gymates_animations.dart';
import '../training/screens/training_screen.dart';
import '../community/screens/community_screen.dart';
import '../mates/screens/mates_screen.dart';
import '../messages/screens/messages_screen.dart';
import '../profile/screens/profile_screen.dart';

/// 🧭 Gymates Main Navigation - Platform-Adaptive Bottom Navigation
/// 
/// Features:
/// - iOS Cupertino tab bar with blur effects
/// - Android Material 3 navigation with dynamic colors
/// - Smooth tab transitions with custom animations
/// - Platform-specific icons and styling
/// - Haptic feedback and visual indicators

class GymatesMainNavigation extends StatefulWidget {
  const GymatesMainNavigation({super.key});

  @override
  State<GymatesMainNavigation> createState() => _GymatesMainNavigationState();
}

class _GymatesMainNavigationState extends State<GymatesMainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _tabAnimationController;
  late Animation<double> _tabScaleAnimation;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.fitness_center,
      activeIcon: Icons.fitness_center,
      label: 'Training',
      page: const TrainingScreen(),
    ),
    NavigationItem(
      icon: Icons.people,
      activeIcon: Icons.people,
      label: 'Community',
      page: const CommunityScreen(),
    ),
    NavigationItem(
      icon: Icons.favorite,
      activeIcon: Icons.favorite,
      label: 'Mates',
      page: const MatesScreen(),
    ),
    NavigationItem(
      icon: Icons.message,
      activeIcon: Icons.message,
      label: 'Messages',
      page: const MessagesScreen(),
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: 'Profile',
      page: const ProfileScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _tabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _tabAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      HapticFeedback.lightImpact();
      _tabAnimationController.forward().then((_) {
        _tabAnimationController.reverse();
      });
      
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return PlatformNavBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      itemChanged: (index) => _onTabTapped(index),
      items: _navigationItems.map((item) => _buildNavBarItem(item)).toList(),
      backgroundColor: Platform.isIOS 
          ? CupertinoColors.systemBackground.withOpacity(0.8)
          : Theme.of(context).colorScheme.surface,
      // iOS specific styling
      ios: (context, platform) => CupertinoTabBarData(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.8),
        activeColor: GymatesTheme.primaryColor,
        inactiveColor: CupertinoColors.inactiveGray,
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      // Android specific styling
      android: (context, platform) => MaterialNavBarData(
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: GymatesTheme.primaryColor,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  PlatformNavBarItem _buildNavBarItem(NavigationItem item) {
    return PlatformNavBarItem(
      cupertino: (context, platform) => CupertinoTabBarItemData(
        icon: Icon(item.icon),
        activeIcon: Icon(item.activeIcon),
        title: Text(item.label),
      ),
      material: (context, platform) => MaterialNavBarItemData(
        icon: Icon(item.icon),
        activeIcon: Icon(item.activeIcon),
        label: item.label,
      ),
    );
  }
}

/// 🎯 Navigation Item Model
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.page,
  });
}

/// 🎨 Enhanced Bottom Navigation with Custom Animations
class EnhancedBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onTap;

  const EnhancedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  State<EnhancedBottomNavigation> createState() => _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends State<EnhancedBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
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

  void _handleTap(int index) {
    if (index != widget.currentIndex) {
      HapticFeedback.lightImpact();
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.onTap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Platform.isIOS 
            ? CupertinoColors.systemBackground.withOpacity(0.8)
            : Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleTap(index),
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isSelected ? _scaleAnimation.value : 1.0,
                        child: _buildNavItem(item, isSelected),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(NavigationItem item, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? GymatesTheme.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 24,
              color: isSelected 
                  ? GymatesTheme.primaryColor
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Label with animation
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected 
                  ? GymatesTheme.primaryColor
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

/// 🎭 Floating Action Button for Quick Actions
class GymatesFloatingActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;

  const GymatesFloatingActionButton({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    this.tooltip,
  });

  @override
  State<GymatesFloatingActionButton> createState() => _GymatesFloatingActionButtonState();
}

class _GymatesFloatingActionButtonState extends State<GymatesFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
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
    HapticFeedback.mediumImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: FloatingActionButton(
              onPressed: _handleTap,
              backgroundColor: GymatesTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 8,
              tooltip: widget.tooltip,
              child: Icon(widget.icon),
            ),
          ),
        );
      },
    );
  }
}
