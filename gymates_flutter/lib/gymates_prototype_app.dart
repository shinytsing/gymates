import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'theme/gymates_theme.dart';
import 'animations/gymates_animations.dart';
import 'pages/training/training_page.dart';
import 'pages/community/community_page.dart';
import 'pages/partner/partner_page.dart';
import 'pages/messages/messages_page.dart';
import 'pages/profile/profile_page.dart';

/// 🏗️ Gymates 健身社交应用完整原型
/// 
/// 这是一个现代化健身社交 App「Gymates」的完整交互原型
/// 支持 iOS (375x812) 与 Android (360x800) 双端
/// 自动适配两种系统视觉语言（iOS Human Interface Guidelines / Material Design 3.0）
/// 
/// 🎨 整体设计规范：
/// - 主色调：#6366F1 (Indigo-500)
/// - 背景色：浅色模式 #F9FAFB / 深色模式 #111827
/// - 文字主色：#1F2937
/// - 次要文字：#6B7280
/// - 圆角：卡片 12px，按钮 8px，头像 50%
/// - 阴影：统一柔和投影 (0px 4px 8px rgba(0,0,0,0.1))
/// - 间距：页面边距 16px，组件间距 8/12/16px
/// - 字体：标题 18px，副标题 16px，正文 14px，说明 12px
/// 
/// 🧭 导航结构：
/// 底部导航栏 (BottomNavigationBar) 共 5 个 Tab：
/// 🏋️‍♀️ 训练（TrainingPage）
/// 💬 社区（CommunityPage）
/// 🤝 搭子（PartnerPage）
/// 📩 消息（MessagesPage）
/// 👤 我的（ProfilePage）

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置系统 UI 覆盖样式以获得沉浸式体验
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 设置首选方向
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const ProviderScope(
      child: GymatesPrototypeApp(),
    ),
  );
}

class GymatesPrototypeApp extends ConsumerWidget {
  const GymatesPrototypeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlatformApp(
      title: 'Gymates - 健身社交应用',
      debugShowCheckedModeBanner: false,
      
      // iOS 主题
      cupertino: (context, platform) => CupertinoAppData(
        theme: CupertinoGymatesTheme.buildTheme(),
        localizationsDelegates: const [],
      ),
      
      // Android 主题
      material: (context, platform) => MaterialAppData(
        theme: MaterialGymatesTheme.buildTheme(),
        darkTheme: MaterialGymatesTheme.buildDarkTheme(),
        themeMode: ThemeMode.system,
      ),
      
      // 高级配置
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // 防止文字缩放
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: GymatesTheme.getBackgroundGradient(
                Theme.of(context).brightness == Brightness.dark
              ),
            ),
            child: child!,
          ),
        );
      },
      
      // 主应用入口
      home: const GymatesMainApp(),
    );
  }
}

class GymatesMainApp extends StatefulWidget {
  const GymatesMainApp({super.key});

  @override
  State<GymatesMainApp> createState() => _GymatesMainAppState();
}

class _GymatesMainAppState extends State<GymatesMainApp>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _tabAnimationController;
  late Animation<double> _tabAnimation;
  
  // 页面列表
  final List<Widget> _pages = [
    const TrainingPage(),
    const CommunityPage(),
    const PartnerPage(),
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
      duration: AnimationConstants.fastAnimation,
      vsync: this,
    );
    _tabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabAnimationController,
      curve: AnimationConstants.easeInOutCubic,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? GymatesTheme.darkBackground : GymatesTheme.lightBackground,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isDark),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
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
          height: 80,
          padding: const EdgeInsets.symmetric(
            horizontal: GymatesTheme.spacing16,
            vertical: GymatesTheme.spacing8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) => _buildTabItem(tab, isDark)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(NavigationTab tab, bool isDark) {
    final isSelected = _currentIndex == tab.pageIndex;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(tab.pageIndex),
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
                padding: const EdgeInsets.all(GymatesTheme.spacing8),
                decoration: BoxDecoration(
                  gradient: isSelected 
                    ? GymatesTheme.primaryGradient
                    : null,
                  color: isSelected 
                    ? null
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                  boxShadow: isSelected 
                    ? GymatesTheme.glowShadow
                    : null,
                ),
                child: Icon(
                  isSelected ? tab.activeIcon : tab.icon,
                  size: 24,
                  color: isSelected 
                    ? Colors.white
                    : (isDark 
                      ? GymatesTheme.darkTextSecondary 
                      : GymatesTheme.lightTextSecondary),
                ),
              ),
              
              const SizedBox(height: GymatesTheme.spacing4),
              
              // 标签文字
              Text(
                tab.label,
                style: TextStyle(
                  fontSize: 12,
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
              ),
            ],
          ),
        ),
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
        duration: AnimationConstants.normalAnimation,
        curve: AnimationConstants.easeInOutCubic,
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

/// 🎨 iOS 风格主题
class CupertinoGymatesTheme {
  static CupertinoThemeData buildTheme() {
    return CupertinoThemeData(
      primaryColor: GymatesTheme.primaryColor,
      scaffoldBackgroundColor: GymatesTheme.lightBackground,
      barBackgroundColor: Colors.white,
      textTheme: CupertinoTextThemeData(
        primaryColor: GymatesTheme.lightTextPrimary,
        textStyle: TextStyle(
          color: GymatesTheme.lightTextPrimary,
          fontSize: 16,
        ),
        actionTextStyle: TextStyle(
          color: GymatesTheme.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        tabLabelTextStyle: TextStyle(
          color: GymatesTheme.lightTextSecondary,
          fontSize: 12,
        ),
        navTitleTextStyle: TextStyle(
          color: GymatesTheme.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: GymatesTheme.lightTextPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        navActionTextStyle: TextStyle(
          color: GymatesTheme.primaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        pickerTextStyle: TextStyle(
          color: GymatesTheme.lightTextPrimary,
          fontSize: 20,
        ),
        dateTimePickerTextStyle: TextStyle(
          color: GymatesTheme.lightTextPrimary,
          fontSize: 20,
        ),
      ),
    );
  }
}

/// 🎨 Android Material 3 风格主题
class MaterialGymatesTheme {
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GymatesTheme.primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: GymatesTheme.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: GymatesTheme.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: GymatesTheme.lightTextPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: GymatesTheme.lightTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: GymatesTheme.lightTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: GymatesTheme.lightTextPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.lightTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.lightTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.lightTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.lightTextPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.lightTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: GymatesTheme.lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: GymatesTheme.lightTextPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: GymatesTheme.lightTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.lightTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.lightTextPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: GymatesTheme.lightTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GymatesTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: GymatesTheme.primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: GymatesTheme.spacing24,
            vertical: GymatesTheme.spacing12,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GymatesTheme.primaryColor,
          side: BorderSide(color: GymatesTheme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: GymatesTheme.spacing24,
            vertical: GymatesTheme.spacing12,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GymatesTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: GymatesTheme.spacing16,
            vertical: GymatesTheme.spacing8,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          borderSide: BorderSide(color: GymatesTheme.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          borderSide: BorderSide(color: GymatesTheme.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          borderSide: BorderSide(color: GymatesTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          borderSide: BorderSide(color: GymatesTheme.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GymatesTheme.spacing16,
          vertical: GymatesTheme.spacing12,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: GymatesTheme.primaryColor,
        unselectedItemColor: GymatesTheme.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  
  static ThemeData buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: GymatesTheme.primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: GymatesTheme.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: GymatesTheme.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: GymatesTheme.darkTextPrimary),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: GymatesTheme.darkTextPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: GymatesTheme.darkTextPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: GymatesTheme.darkTextPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.darkTextPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.darkTextPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GymatesTheme.darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.darkTextPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.darkTextPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: GymatesTheme.darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: GymatesTheme.darkTextPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: GymatesTheme.darkTextSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.darkTextPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: GymatesTheme.darkTextPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: GymatesTheme.darkTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GymatesTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: GymatesTheme.spacing24,
            vertical: GymatesTheme.spacing12,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GymatesTheme.primaryColor,
          side: BorderSide(color: GymatesTheme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: GymatesTheme.spacing24,
            vertical: GymatesTheme.spacing12,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GymatesTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: GymatesTheme.spacing16,
            vertical: GymatesTheme.spacing8,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1F2937),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2937),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          borderSide: BorderSide(color: GymatesTheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          borderSide: BorderSide(color: GymatesTheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          borderSide: BorderSide(color: GymatesTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          borderSide: BorderSide(color: GymatesTheme.errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GymatesTheme.spacing16,
          vertical: GymatesTheme.spacing12,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1F2937),
        selectedItemColor: GymatesTheme.primaryColor,
        unselectedItemColor: GymatesTheme.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
