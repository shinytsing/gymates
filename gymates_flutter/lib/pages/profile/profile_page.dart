import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';
import '../achievements/achievements_page.dart';

/// 👤 我的页 ProfilePage - 现代化用户个人中心
/// 
/// 设计规范：
/// - 主色调：#6366F1
/// - 背景色：#F9FAFB
/// - 卡片圆角：12px
/// - 页面边距：16px
/// - 个人信息头部 + 功能卡片区 + 统计组件

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _statsAnimationController;
  late AnimationController _cardsAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _cardsAnimation;

  // 模拟用户数据
  final UserProfile _userProfile = UserProfile(
    name: '健身达人',
    avatar: '👨‍💼',
    bio: '热爱健身，追求健康生活',
    followers: 1280,
    following: 456,
    posts: 89,
    isVerified: true,
    joinDate: '2023年1月',
    location: '北京市',
    workoutDays: 156,
    caloriesBurned: 125000,
    achievements: 12,
  );

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 头部动画控制器
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 统计动画控制器
    _statsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // 卡片动画控制器
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 头部动画
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 统计动画
    _statsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _statsAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 卡片动画
    _cardsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    _headerAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _statsAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _cardsAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _statsAnimationController.dispose();
    _cardsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 个人信息头部
              _buildProfileHeader(),
              
              const SizedBox(height: GymatesTheme.spacing16),
              
              // 统计组件
              _buildStatsSection(),
              
              const SizedBox(height: GymatesTheme.spacing16),
              
              // 功能卡片区
              _buildFunctionCards(),
              
              const SizedBox(height: GymatesTheme.spacing16),
              
              // 设置选项
              _buildSettingsSection(),
              
              const SizedBox(height: GymatesTheme.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(GymatesTheme.spacing20),
              decoration: BoxDecoration(
                gradient: GymatesTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(GymatesTheme.radius16),
                  bottomRight: Radius.circular(GymatesTheme.radius16),
                ),
              ),
              child: Column(
                children: [
                  // 头像和基本信息
                  Row(
                    children: [
                      // 头像
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _userProfile.avatar,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: GymatesTheme.spacing16),
                      
                      // 用户信息
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _userProfile.name,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_userProfile.isVerified) ...[
                                  const SizedBox(width: GymatesTheme.spacing4),
                                  Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: GymatesTheme.spacing4),
                            Text(
                              _userProfile.bio,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: GymatesTheme.spacing8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: GymatesTheme.spacing4),
                                Text(
                                  _userProfile.location,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(width: GymatesTheme.spacing16),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: GymatesTheme.spacing4),
                                Text(
                                  _userProfile.joinDate,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: GymatesTheme.spacing20),
                  
                  // 关注数据
                  Row(
                    children: [
                      Expanded(
                        child: _buildFollowStat('粉丝', _userProfile.followers),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildFollowStat('关注', _userProfile.following),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      Expanded(
                        child: _buildFollowStat('动态', _userProfile.posts),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: GymatesTheme.spacing20),
                  
                  // 编辑资料按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _editProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: GymatesTheme.primaryColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          vertical: GymatesTheme.spacing16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
                        ),
                      ),
                      child: Text(
                        '编辑资料',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowStat(String label, int count) {
    return Column(
      children: [
        Text(
          _formatNumber(count),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: GymatesTheme.spacing4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _statsAnimation.value)),
          child: Opacity(
            opacity: _statsAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GymatesTheme.spacing16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '训练天数',
                      _userProfile.workoutDays.toString(),
                      Icons.fitness_center,
                      GymatesTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: GymatesTheme.spacing12),
                  Expanded(
                    child: _buildStatCard(
                      '消耗卡路里',
                      _formatNumber(_userProfile.caloriesBurned),
                      Icons.local_fire_department,
                      GymatesTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: GymatesTheme.spacing12),
                  Expanded(
                    child: _buildStatCard(
                      '成就徽章',
                      _userProfile.achievements.toString(),
                      Icons.emoji_events,
                      GymatesTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: GymatesTheme.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: GymatesTheme.spacing4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: GymatesTheme.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionCards() {
    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: GymatesTheme.spacing16),
              child: Column(
                children: [
                  _buildFunctionCard(
                    '我的训练数据',
                    '查看详细的训练记录和进度',
                    Icons.analytics_outlined,
                    () => _openTrainingData(),
                  ),
                  const SizedBox(height: GymatesTheme.spacing12),
                  _buildFunctionCard(
                    '我的成就',
                    '查看你的成就和徽章',
                    Icons.emoji_events,
                    () => _openAchievements(),
                  ),
                  const SizedBox(height: GymatesTheme.spacing12),
                  _buildFunctionCard(
                    '我的社区',
                    '管理你的帖子和互动',
                    Icons.people_outline,
                    () => _openMyCommunity(),
                  ),
                  const SizedBox(height: GymatesTheme.spacing12),
                  _buildFunctionCard(
                    '消息中心',
                    '查看系统通知和消息',
                    Icons.notifications_outlined,
                    () => _openMessageCenter(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFunctionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        child: Container(
          padding: const EdgeInsets.all(GymatesTheme.spacing16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GymatesTheme.radius12),
            boxShadow: GymatesTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(GymatesTheme.spacing12),
                decoration: BoxDecoration(
                  color: GymatesTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                ),
                child: Icon(
                  icon,
                  color: GymatesTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: GymatesTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: GymatesTheme.spacing4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: GymatesTheme.lightTextSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GymatesTheme.spacing16),
      child: Column(
        children: [
          _buildSettingsItem(
            '设置',
            Icons.settings_outlined,
            () => _openSettings(),
          ),
          _buildSettingsItem(
            '帮助与反馈',
            Icons.help_outline,
            () => _openHelp(),
          ),
          _buildSettingsItem(
            '关于我们',
            Icons.info_outline,
            () => _openAbout(),
          ),
          _buildSettingsItem(
            '退出登录',
            Icons.logout,
            () => _logout(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        child: Container(
          padding: const EdgeInsets.all(GymatesTheme.spacing16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(GymatesTheme.radius12),
            boxShadow: GymatesTheme.softShadow,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive 
                    ? GymatesTheme.errorColor 
                    : GymatesTheme.lightTextSecondary,
                size: 24,
              ),
              const SizedBox(width: GymatesTheme.spacing16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDestructive 
                        ? GymatesTheme.errorColor 
                        : GymatesTheme.lightTextPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: GymatesTheme.lightTextSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _editProfile() {
    // TODO: 打开编辑资料页面
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑资料'),
        content: Text('编辑个人资料功能'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  void _openTrainingData() {
    // TODO: 打开训练数据页面
  }

  void _openAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AchievementsPage(),
      ),
    );
  }

  void _openMyCommunity() {
    // TODO: 打开我的社区页面
  }

  void _openMessageCenter() {
    // TODO: 打开消息中心页面
  }

  void _openSettings() {
    // TODO: 打开设置页面
  }

  void _openHelp() {
    // TODO: 打开帮助页面
  }

  void _openAbout() {
    // TODO: 打开关于页面
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('退出登录'),
        content: Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 执行退出登录
            },
            child: Text(
              '确定',
              style: TextStyle(color: GymatesTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// 用户资料数据模型
class UserProfile {
  final String name;
  final String avatar;
  final String bio;
  final int followers;
  final int following;
  final int posts;
  final bool isVerified;
  final String joinDate;
  final String location;
  final int workoutDays;
  final int caloriesBurned;
  final int achievements;

  UserProfile({
    required this.name,
    required this.avatar,
    required this.bio,
    required this.followers,
    required this.following,
    required this.posts,
    required this.isVerified,
    required this.joinDate,
    required this.location,
    required this.workoutDays,
    required this.caloriesBurned,
    required this.achievements,
  });
}