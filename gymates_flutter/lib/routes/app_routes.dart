import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../pages/auth/modern_login_page.dart';
import '../pages/training/training_page.dart';
import '../pages/training/training_detail_page.dart';
import '../pages/training/ai_training_detail_page.dart';
import '../pages/ai_training/ai_training_page.dart';
import '../pages/community/community_page.dart';
import '../pages/community/post_detail_page.dart';
import '../pages/mates/mates_page.dart';
import '../pages/messages/messages_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/profile/edit_profile_page.dart';
import '../pages/achievements/achievements_page.dart';
import '../pages/achievements/achievement_detail_page.dart';
import '../pages/settings/settings_page.dart';
import '../animations/gymates_animations.dart';
import '../theme/gymates_theme.dart';

/// 🧭 Gymates 路由系统 - 平台自适应导航
/// 
/// 特性：
/// - Hero 动画 + Slide + Fade 页面切换
/// - 平台特定过渡效果
/// - 深度链接支持
/// - 路由守卫和权限控制

class AppRoutes {
  // 路由名称常量
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String training = '/training';
  static const String trainingDetail = '/training-detail';
  static const String aiTraining = '/ai-training';
  static const String aiTrainingDetail = '/ai-training-detail';
  static const String community = '/community';
  static const String postDetail = '/post-detail';
  static const String mates = '/mates';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String achievements = '/achievements';
  static const String achievementDetail = '/achievement-detail';
  static const String settings = '/settings';
  
  // 路由配置
  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const ModernLoginPage(),
    main: (context) => const MainNavigationScreen(),
    training: (context) => const TrainingPage(),
    trainingDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['trainingPlan'] != null) {
        return TrainingDetailPage(trainingPlan: args['trainingPlan']);
      }
      return const Scaffold(
        body: Center(child: Text('训练计划参数错误')),
      );
    },
    aiTraining: (context) => const AITrainingPage(),
    aiTrainingDetail: (context) => const AITrainingDetailPage(),
    community: (context) => const CommunityPage(),
    postDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['post'] != null) {
        return PostDetailPage(post: args['post']);
      }
      return const Scaffold(
        body: Center(child: Text('帖子参数错误')),
      );
    },
    mates: (context) => const MatesPage(),
    messages: (context) => const MessagesPage(),
    profile: (context) => const ProfilePage(),
    editProfile: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args['user'] != null) {
        return EditProfilePage(user: args['user']);
      }
      return const Scaffold(
        body: Center(child: Text('用户参数错误')),
      );
    },
    achievements: (context) => const AchievementsPage(),
    achievementDetail: (context) => const AchievementDetailPage(),
    settings: (context) => const SettingsPage(),
  };
  
  // 页面切换方法
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool useHeroAnimation = true,
  }) {
    if (useHeroAnimation) {
      return Navigator.of(context).push<T>(
        MaterialPageRoute(
          builder: (context) => routes[routeName]!(context),
          settings: RouteSettings(
            name: routeName,
            arguments: arguments,
          ),
        ),
      );
    } else {
      return Navigator.of(context).pushNamed(routeName, arguments: arguments);
    }
  }
  
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
    bool useHeroAnimation = true,
  }) {
    if (useHeroAnimation) {
      return Navigator.of(context).pushReplacement<T, TO>(
        GymatesAnimations.createHeroSlideTransition(
          page: routes[routeName]!(context),
        ),
        result: result,
      );
    } else {
      return Navigator.of(context).pushReplacementNamed(
        routeName,
        arguments: arguments,
        result: result,
      );
    }
  }
  
  static void popUntil(BuildContext context, String routeName) {
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }
  
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.of(context).pop(result);
  }
}

/// 🎬 启动屏幕
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _gradientController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _particleAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Logo 动画控制器
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // 粒子动画控制器
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    // 渐变动画控制器
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Logo 动画
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // 粒子动画
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    // 渐变动画
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // 开始渐变动画
    _gradientController.forward();
    
    // 开始粒子动画
    _particleController.repeat();
    
    // 开始 Logo 动画
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    // 等待完成并导航
    await Future.delayed(const Duration(milliseconds: 1200));
    _navigateToMain();
  }

  void _navigateToMain() {
    if (mounted) {
      // TODO: 检查用户登录状态，这里暂时跳转到登录页
      AppRoutes.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // 动态渐变背景
            _buildGradientBackground(),
            
            // 粒子系统
            _buildParticleSystem(),
            
            // 主内容
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
                const Color(0xFFA855F7),
                const Color(0xFF06B6D4),
              ],
              stops: [
                0.0,
                0.3 + (_gradientAnimation.value * 0.2),
                0.7 + (_gradientAnimation.value * 0.2),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleSystem() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo 动画
          _buildAnimatedLogo(),
          
          const SizedBox(height: 40),
          
          // 应用名称
          _buildAppName(),
          
          const SizedBox(height: 20),
          
          // 标语
          _buildTagline(),
          
          const SizedBox(height: 60),
          
          // 加载指示器
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF3F4F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 60,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return const Text(
      'Gymates',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTagline() {
    return const Text(
      'Train. Connect. Grow.',
      style: TextStyle(
        fontSize: 16,
        color: Colors.white70,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

/// 🧭 主导航屏幕
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _tabAnimationController;
  // late Animation<double> _tabScaleAnimation; // Commented out - unused

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.fitness_center,
      activeIcon: Icons.fitness_center,
      label: '训练',
      page: const TrainingPage(),
    ),
    NavigationItem(
      icon: Icons.people,
      activeIcon: Icons.people,
      label: '社区',
      page: const CommunityPage(),
    ),
    NavigationItem(
      icon: Icons.people_alt,
      activeIcon: Icons.people_alt,
      label: '搭子',
      page: const MatesPage(),
    ),
    NavigationItem(
      icon: Icons.message,
      activeIcon: Icons.message,
      label: '消息',
      page: const MessagesPage(),
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: '我的',
      page: const ProfilePage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    // _tabScaleAnimation = Tween<double>(
    //   begin: 1.0,
    //   end: 0.95,
    // ).animate(CurvedAnimation(
    //   parent: _tabAnimationController,
    //   curve: Curves.easeInOut,
    // )); // Commented out - unused
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(GymatesTheme.radius20),
          boxShadow: GymatesTheme.softShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GymatesTheme.radius20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(GymatesTheme.radius20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: SafeArea(
                child: Container(
                  height: 65,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _navigationItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = _currentIndex == index;
                      
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onTabTapped(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected 
                                  ? GymatesTheme.primaryGradient
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: GymatesTheme.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  color: isSelected 
                                      ? Colors.white
                                      : GymatesTheme.lightTextSecondary,
                                  size: 24,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected 
                                        ? Colors.white
                                        : GymatesTheme.lightTextSecondary,
                                    fontWeight: isSelected 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                    fontSize: 11,
                                  ),
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
          ),
        ),
      ),
    );
  }

}

/// 🎯 导航项目模型
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

/// 🎨 粒子系统绘制器
class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    
    for (int i = 0; i < 20; i++) {
      final x = (random.nextDouble() * size.width);
      final y = (random.nextDouble() * size.height);
      final radius = 2 + (random.nextDouble() * 3);
      
      final offsetY = math.sin(animationValue * 2 * math.pi + i) * 20;
      final opacity = 0.1 + (math.sin(animationValue * 2 * math.pi + i) * 0.1);
      
      paint.color = Colors.white.withValues(alpha: opacity.clamp(0.0, 0.2));
      
      canvas.drawCircle(
        Offset(x, y + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
