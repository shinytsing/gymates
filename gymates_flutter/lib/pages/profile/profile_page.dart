import 'package:flutter/material.dart';
import '../../models/user_achievement_data.dart';
import '../../core/theme/gymates_colors.dart';
import '../../services/profile_api_service.dart';
import 'widgets/user_header.dart';
import 'widgets/achievement_panel.dart';
import 'widgets/my_content_section.dart';
import 'widgets/settings_section.dart';
import 'widgets/achievement_share_card.dart';
import 'edit_profile_page.dart';
import '../achievements/achievements_page.dart';
import '../help/help_page.dart';
import '../about/about_page.dart';

/// 👤 个人中心页面 - ProfilePage
/// 
/// 完全重构的个人中心页面，包含：
/// - 用户信息头部（头像、昵称、目标、社交数据）
/// - 成就面板（训练统计、徽章展示）
/// - 我的内容（动态、计划、收藏、伙伴）
/// - 设置与工具（通知、隐私、语言等）
/// - 成就卡片分享功能
/// 
/// 设计特点：
/// - 渐变色头部，现代化卡片设计
/// - 流畅的动画效果
/// - 清晰的层次结构
/// - 支持深色模式

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ProfileApiService _apiService = ProfileApiService();
  
  // 用户数据
  UserAchievementData? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: 从本地存储或认证服务获取当前用户ID
      // 这里暂时使用默认ID，实际应用中需要从登录状态获取
      const String userId = '1';
      
      print('🔄 开始加载用户数据...');
      
      // 尝试从API获取完整数据
      final userData = await _apiService.fetchCompleteUserData(userId);
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
        
        print('✅ 用户数据加载成功');
        
        // 数据加载完成后启动动画
        _startAnimations();
      }
    } catch (e) {
      print('❌ 加载用户数据失败: $e');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '无法加载用户数据: $e';
        });
        
        // 显示错误提示
        _showErrorSnackBar('无法加载用户数据，请检查网络连接');
      }
    }
  }

  /// 刷新数据
  Future<void> _refreshUserData() async {
    await _loadUserData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _isLoading
          ? _buildLoadingView()
          : _userData == null
              ? _buildErrorView()
              : _buildContentView(),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误视图
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '加载失败',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshUserData,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GyMatesColors.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建内容视图
  Widget _buildContentView() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: RefreshIndicator(
        onRefresh: _refreshUserData,
        child: CustomScrollView(
          slivers: [
            // 用户信息头部
            SliverToBoxAdapter(
              child: UserHeader(
                userData: _userData!,
                onEditProfile: _handleEditProfile,
                onFollowersClick: _handleFollowersClick,
                onFollowingClick: _handleFollowingClick,
                onPostsClick: _handlePostsClick,
              ),
            ),

            // 间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            // 成就面板
            SliverToBoxAdapter(
              child: AchievementPanel(
                userData: _userData!,
                onShareAchievement: _handleShareAchievement,
                onViewAllBadges: _handleViewAllBadges,
              ),
            ),

            // 间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // 我的内容
            SliverToBoxAdapter(
              child: MyContentSection(
                userData: _userData!,
                onMyPosts: _handleMyPosts,
                onMyPlans: _handleMyPlans,
                onSavedPosts: _handleSavedPosts,
                onPartners: _handlePartners,
                onMemberCenter: _handleMemberCenter,
              ),
            ),

            // 间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // 设置与工具
            SliverToBoxAdapter(
              child: SettingsSection(
                onNotifications: _handleNotifications,
                onPrivacy: _handlePrivacy,
                onLanguage: _handleLanguage,
                onDeviceBinding: _handleDeviceBinding,
                onPermissions: _handlePermissions,
                onFeedback: _handleFeedback,
                onHelp: _handleHelp,
                onAbout: _handleAbout,
                onLogout: _handleLogout,
              ),
            ),

            // 底部间距
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  // ========== 辅助方法 ==========

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: GyMatesColors.warningYellow,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ========== 事件处理方法 ==========

  /// 编辑个人资料
  void _handleEditProfile() {
    if (_userData == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(user: _userData!),
      ),
    );
  }

  /// 查看粉丝
  void _handleFollowersClick() {
    _showSnackBar('查看粉丝列表');
  }

  /// 查看关注
  void _handleFollowingClick() {
    _showSnackBar('查看关注列表');
  }

  /// 查看动态
  void _handlePostsClick() {
    _showSnackBar('查看我的动态');
  }

  /// 分享成就
  void _handleShareAchievement() {
    if (_userData == null) return;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => AchievementShareCard(
        userData: _userData!,
      ),
    );
  }

  /// 查看所有徽章
  void _handleViewAllBadges() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AchievementsPage(),
      ),
    );
  }

  /// 我的动态
  void _handleMyPosts() {
    _showSnackBar('查看我的动态');
  }

  /// 我的训练计划
  void _handleMyPlans() {
    _showSnackBar('查看我的训练计划');
  }

  /// 收藏的帖子
  void _handleSavedPosts() {
    _showSnackBar('查看收藏的帖子');
  }

  /// 我的伙伴
  void _handlePartners() {
    _showSnackBar('查看我的伙伴');
  }

  /// 会员中心
  void _handleMemberCenter() {
    _showMemberCenterDialog();
  }

  /// 通知设置
  void _handleNotifications() {
    _showSnackBar('通知设置');
  }

  /// 隐私设置
  void _handlePrivacy() {
    _showSnackBar('隐私设置');
  }

  /// 语言设置
  void _handleLanguage() {
    _showLanguageDialog();
  }

  /// 设备绑定
  void _handleDeviceBinding() {
    _showSnackBar('设备绑定管理');
  }

  /// 权限控制
  void _handlePermissions() {
    _showSnackBar('权限控制');
  }

  /// 意见反馈
  void _handleFeedback() {
    _showSnackBar('意见反馈');
  }

  /// 帮助中心
  void _handleHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpPage(),
      ),
    );
  }

  /// 关于
  void _handleAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutPage(),
      ),
    );
  }

  /// 退出登录
  void _handleLogout() {
    // 显示确认对话框
    _showSnackBar('退出登录');
  }

  // ========== 辅助方法 ==========

  /// 显示提示
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// 显示会员中心对话框
  void _showMemberCenterDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 会员图标
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              
              // 标题
              const Text(
                '会员中心',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // 描述
              Text(
                _userData?.isPremium == true
                    ? '您已是尊贵的高级会员\n尽享AI教练和全部高级功能'
                    : '升级为高级会员\n解锁AI教练和更多高级功能',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // 功能列表
              _buildMemberFeature('AI智能教练', '24/7在线指导'),
              _buildMemberFeature('个性化训练计划', '科学定制方案'),
              _buildMemberFeature('高级数据分析', '深度运动洞察'),
              _buildMemberFeature('优先客服支持', '快速响应服务'),
              
              const SizedBox(height: 24),
              
              // 按钮
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('关闭'),
                    ),
                  ),
                  if (_userData?.isPremium != true) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSnackBar('开通会员功能开发中...');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GyMatesColors.primaryPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('立即开通'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 会员功能项
  Widget _buildMemberFeature(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: GyMatesColors.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '选择语言',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('简体中文', true),
            _buildLanguageOption('English', false),
            _buildLanguageOption('繁體中文', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('语言已切换');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 语言选项
  Widget _buildLanguageOption(String language, bool isSelected) {
    return InkWell(
      onTap: () {
        // 切换语言逻辑
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? GyMatesColors.primaryPurple.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? GyMatesColors.primaryPurple
                : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? GyMatesColors.primaryPurple
                      : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: GyMatesColors.primaryPurple,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

