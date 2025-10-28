import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../achievements/achievements_page.dart';
import 'edit_profile_page.dart';
import '../settings/settings_page.dart';
import '../../shared/models/mock_data.dart';
import '../help/help_page.dart';
import '../about/about_page.dart';

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
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
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
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: GymatesTheme.spacing8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: GymatesTheme.spacing4),
                                Text(
                                  _userProfile.location,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                const SizedBox(width: GymatesTheme.spacing16),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: 16,
                                ),
                                const SizedBox(width: GymatesTheme.spacing4),
                                Text(
                                  _userProfile.joinDate,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
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
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: _buildFollowStat('关注', _userProfile.following),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3),
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
            color: Colors.white.withValues(alpha: 0.9),
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
                  _buildAchievementsShowcase(),
                  const SizedBox(height: GymatesTheme.spacing16),
                  _buildFunctionCard(
                    '设置',
                    '应用设置和账户管理',
                    Icons.settings_outlined,
                    () => _openSettings(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementsShowcase() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _openAchievements();
      },
      child: Container(
        padding: const EdgeInsets.all(GymatesTheme.spacing20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GymatesTheme.radius16),
          boxShadow: GymatesTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withValues(alpha: 0.8),
                        Colors.amber.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(GymatesTheme.radius8),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: GymatesTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '我的成就',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: GymatesTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: GymatesTheme.spacing4),
                      Text(
                        '查看你的成就和徽章',
                        style: TextStyle(
                          fontSize: 14,
                          color: GymatesTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: GymatesTheme.lightTextSecondary,
                ),
              ],
            ),
            const SizedBox(height: GymatesTheme.spacing16),
            // 成就展示
            Row(
              children: [
                Expanded(
                  child: _buildAchievementItem('连续训练7天', Icons.local_fire_department, Colors.orange, true),
                ),
                const SizedBox(width: GymatesTheme.spacing12),
                Expanded(
                  child: _buildAchievementItem('力量提升', Icons.fitness_center, Colors.blue, true),
                ),
                const SizedBox(width: GymatesTheme.spacing12),
                Expanded(
                  child: _buildAchievementItem('有氧达人', Icons.directions_run, Colors.green, false),
                ),
              ],
            ),
          ],
        ),
      ),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GymatesTheme.radius8),
                ),
                child: Icon(
                  icon,
                  color: GymatesTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: GymatesTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: GymatesTheme.spacing4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: GymatesTheme.lightTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: _convertToMockUser(_userProfile)),
      ),
    );
  }

  MockUser _convertToMockUser(UserProfile profile) {
    return MockUser(
      id: '1',
      name: profile.name,
      username: profile.name.toLowerCase().replaceAll(' ', ''),
      avatar: profile.avatar,
      bio: profile.bio,
      age: 25,
      location: profile.location,
      isVerified: profile.isVerified,
      followers: profile.followers,
      following: profile.following,
      posts: profile.posts,
      joinDate: profile.joinDate,
      workoutDays: profile.workoutDays,
      caloriesBurned: profile.caloriesBurned,
      achievements: profile.achievements,
      rating: 4.8,
      preferences: ['力量训练', '有氧运动'],
      goal: '增肌',
      experience: '中级',
      workoutTime: '60分钟',
      distance: '5公里',
      isOnline: true,
    );
  }

  void _openTrainingData() {
    // 移除训练数据页面
  }

  void _openAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementsPage(),
      ),
    );
  }

  void _openMyCommunity() {
    // 移除社区页面
  }

  void _openMessageCenter() {
    // 移除消息中心页面
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    );
  }

  void _openHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpPage(),
      ),
    );
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutPage(),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 执行退出登录
            },
            child: const Text(
              '确定',
              style: TextStyle(color: GymatesTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem(String title, IconData icon, Color color, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing12),
      decoration: BoxDecoration(
        color: isUnlocked ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(GymatesTheme.radius8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isUnlocked ? color : Colors.grey,
            size: 20,
          ),
          const SizedBox(height: GymatesTheme.spacing8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? color : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GymatesTheme.spacing16),
      child: Column(
        children: [
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
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
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
                color: GymatesTheme.lightTextSecondary,
                size: 24,
              ),
              const SizedBox(width: GymatesTheme.spacing16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: GymatesTheme.lightTextPrimary,
                  ),
                ),
              ),
              const Icon(
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

  const UserProfile({
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