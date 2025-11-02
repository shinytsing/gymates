import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/enhanced_theme.dart';
import '../../pages/training/training_page.dart';
import '../../pages/community/community_page.dart';
import '../../pages/mates/mates_page.dart';
import '../../pages/messages/messages_page.dart';
import '../../pages/profile/profile_page.dart';

/// 🧭 Enhanced Main Navigation
/// 
/// 底部导航栏包含 5 个 Tab：
/// 🏋️‍♀️ 训练（TrainingPage）
/// 💬 社区（CommunityPage）
/// 🤝 搭子（PartnerPage）
/// 📩 消息（MessagesPage）
/// 👤 我的（ProfilePage）
/// 
/// 支持 iOS 和 Android 平台的原生风格
/// 点击不同 Tab 时采用淡入过渡动画

class EnhancedMainNavigation extends StatefulWidget {
  const EnhancedMainNavigation({super.key});

  @override
  State<EnhancedMainNavigation> createState() => _EnhancedMainNavigationState();
}

class _EnhancedMainNavigationState extends State<EnhancedMainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;
  
  // 页面列表
  final List<Widget> _pages = [
    const TrainingPage(),
    const CommunityPage(),
    const MatesPage(),
    const MessagesPage(),
    const ProfilePage(),
  ];
  
  // Tab 配置
  final List<NavigationTab> _tabs = [
    NavigationTab(
      icon: Icons.fitness_center,
      activeIcon: Icons.fitness_center,
      label: '训练',
      pageIndex: 0,
    ),
    NavigationTab(
      icon: Icons.people,
      activeIcon: Icons.people,
      label: '社区',
      pageIndex: 1,
    ),
    NavigationTab(
      icon: Icons.favorite,
      activeIcon: Icons.favorite,
      label: '搭子',
      pageIndex: 2,
    ),
    NavigationTab(
      icon: Icons.message,
      activeIcon: Icons.message,
      label: '消息',
      pageIndex: 3,
    ),
    NavigationTab(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: '我的',
      pageIndex: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _tabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.medium,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusL),
          topRight: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70, // 减少高度从80到70
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingS,
            vertical: AppSizes.spacingXS, // 减少垂直间距
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) => _buildTabItem(tab)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(NavigationTab tab) {
    final isSelected = _currentIndex == tab.pageIndex;
    
    return Expanded(
      child: AnimatedBuilder(
        animation: _tabAnimation,
        builder: (context, child) {
          return GestureDetector(
            onTap: () => _onTabTapped(tab.pageIndex),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.spacingXS, // 减少垂直间距
                horizontal: AppSizes.spacingXS,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 图标
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(6), // 减少图标内边距
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      isSelected ? tab.activeIcon : tab.icon,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: isSelected ? 24 : 22, // 减少图标大小
                    ),
                  ),
                  
                  const SizedBox(height: 2), // 减少间距
                  
                  // 标签
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: isSelected ? 11 : 10, // 减少字体大小
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    child: Text(tab.label),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _tabAnimationController.forward().then((_) {
        _tabAnimationController.reset();
      });
    }
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}

/// 🎯 导航 Tab 配置
class NavigationTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int pageIndex;

  NavigationTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.pageIndex,
  });
}

/// 🎨 自定义底部导航栏（iOS 风格）
class CupertinoStyleBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<NavigationTab> tabs;
  final ValueChanged<int> onTap;

  const CupertinoStyleBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 70, // 减少高度从80到70
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingS,
            vertical: AppSizes.spacingXS, // 减少垂直间距
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((tab) => _buildCupertinoTabItem(tab)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoTabItem(NavigationTab tab) {
    final isSelected = currentIndex == tab.pageIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(tab.pageIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.spacingXS, // 减少垂直间距
            horizontal: AppSizes.spacingXS,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                padding: const EdgeInsets.all(6), // 减少图标内边距
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: isSelected ? 24 : 22, // 减少图标大小
                ),
              ),
              
              const SizedBox(height: 2), // 减少间距
              
              // 标签
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10, // 减少字体大小
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎨 自定义底部导航栏（Android Material 3 风格）
class Material3StyleBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<NavigationTab> tabs;
  final ValueChanged<int> onTap;

  const Material3StyleBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.medium,
      ),
      child: SafeArea(
        child: Container(
          height: 70, // 减少高度从80到70
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingS,
            vertical: AppSizes.spacingXS, // 减少垂直间距
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: tabs.map((tab) => _buildMaterial3TabItem(tab)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterial3TabItem(NavigationTab tab) {
    final isSelected = currentIndex == tab.pageIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(tab.pageIndex),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.spacingXS, // 减少垂直间距
            horizontal: AppSizes.spacingXS,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标
              Container(
                padding: const EdgeInsets.all(6), // 减少图标内边距
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: isSelected ? 24 : 22, // 减少图标大小
                ),
              ),
              
              const SizedBox(height: 2), // 减少间距
              
              // 标签
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10, // 减少字体大小
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎯 平台适配的底部导航栏
class PlatformAdaptiveBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final List<NavigationTab> tabs;
  final ValueChanged<int> onTap;

  const PlatformAdaptiveBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    if (isIOS) {
      return CupertinoStyleBottomNavigation(
        currentIndex: currentIndex,
        tabs: tabs,
        onTap: onTap,
      );
    } else {
      return Material3StyleBottomNavigation(
        currentIndex: currentIndex,
        tabs: tabs,
        onTap: onTap,
      );
    }
  }
}
