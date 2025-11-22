import 'package:flutter/material.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../models/user_achievement_data.dart';
import '../../services/profile_api_service.dart';
import '../../services/unified_auth_service.dart';
import '../../../pages/profile/widgets/user_header.dart';
import '../../../pages/profile/widgets/achievement_panel.dart';
import '../../../pages/profile/widgets/my_content_section.dart';
import '../../../pages/profile/widgets/settings_section.dart';
import '../../pages/profile/edit_3d_profile_page.dart';
import '../achievements/achievements_page.dart';
import '../settings/settings_3d_page.dart';
import '../community/main_page_3d.dart';
import '../training/main_page_3d.dart';
import '../mates/main_page_3d.dart';
import '../about/about_page.dart';
import '../help/help_page.dart';
import '../auth/modern_login_page.dart';

/// 👤 Apple Fitness+ Style Profile Page
/// 
/// Design Features:
/// - 3D user header (avatar, stats)
/// - 3D achievement cards
/// - 3D content sections
/// - 3D settings list
/// - Smooth scroll animations

class ProfileMainPage3D extends StatefulWidget {
  const ProfileMainPage3D({super.key});

  @override
  State<ProfileMainPage3D> createState() => _ProfileMainPage3DState();
}

class _ProfileMainPage3DState extends State<ProfileMainPage3D> {
  final ProfileApiService _apiService = ProfileApiService();
  final UnifiedAuthService _authService = UnifiedAuthService();
  UserAchievementData? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      const String userId = '1';
      UserAchievementData? userData;
      
      try {
        userData = await _apiService.fetchCompleteUserData(userId);
      } catch (e) {
        debugPrint('⚠️ 用户数据不存在，创建默认用户: $e');
        // 如果用户不存在，创建默认用户数据
        userData = _createDefaultUserData(userId);
      }
      
      if (mounted) {
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载用户数据失败: $e');
      if (mounted) {
        // 即使出错也创建默认用户，避免显示错误页面
        setState(() {
          _userData = _createDefaultUserData('1');
          _isLoading = false;
        });
        _showErrorSnackBar('使用默认用户数据，请检查网络连接');
      }
    }
  }

  UserAchievementData _createDefaultUserData(String userId) {
    return UserAchievementData(
      id: userId,
      name: '健身达人',
      username: 'user_$userId',
      avatar: '👨‍💼',
      bio: '开始你的健身之旅吧！',
      fitnessGoal: '增肌',
      isVerified: false,
      isPremium: false,
      followers: 0,
      following: 0,
      posts: 0,
      totalSessions: 0,
      totalHours: 0.0,
      totalCalories: 0,
      weightChange: 0.0,
      consecutiveDays: 0,
      monthlyGoal: 12,
      monthlyProgress: 0,
      badges: [],
      totalBadges: 0,
      unlockedBadges: 0,
      personalRecords: [],
      workoutPlans: 0,
      completedWorkouts: 0,
      savedPosts: 0,
      membershipExpiry: null,
      membershipTier: 'free',
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppleFitnessTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppleFitnessTheme.radiusMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: _isLoading
            ? Center(
                child: CircularProgress3D(
                  value: 0.0,
                  size: 60,
                  progressColor: AppleFitnessTheme.primaryBlue,
                  showPercentage: false,
                ),
              )
            : _userData == null
                ? _buildErrorView()
                : RefreshIndicator(
                    onRefresh: _loadUserData,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // UserHeader (from old design)
                          cartoon_animations.BounceInAnimation(
                            delay: const Duration(milliseconds: 100),
                            child: UserHeader(
                              userData: _userData!,
                              onEditProfile: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Edit3DProfilePage(user: _userData!),
                                  ),
                                ).then((_) => _loadUserData());
                              },
                              onFollowersClick: () {
                                // 跳转到搭子页面，显示粉丝列表
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MatesMainPage3D(),
                                  ),
                                );
                              },
                              onFollowingClick: () {
                                // 跳转到搭子页面，显示关注列表
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MatesMainPage3D(),
                                  ),
                                );
                              },
                              onPostsClick: () {
                                // 跳转到社区页面，显示我的动态
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CommunityMainPage3D(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: AppleFitnessTheme.spacingL),
                          // AchievementPanel (from old design)
                          cartoon_animations.SlideInAnimation(
                            direction: cartoon_animations.SlideDirection.fromLeft,
                            delay: const Duration(milliseconds: 200),
                            child: AchievementPanel(
                              userData: _userData!,
                              onShareAchievement: () {
                                // 分享成就到社区
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CommunityMainPage3D(),
                                  ),
                                );
                              },
                              onViewAllBadges: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AchievementsPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: AppleFitnessTheme.spacingL),
                          // MyContentSection (from old design)
                          cartoon_animations.SlideInAnimation(
                            direction: cartoon_animations.SlideDirection.fromRight,
                            delay: const Duration(milliseconds: 300),
                            child: MyContentSection(
                              userData: _userData!,
                              onMyPosts: () {
                                // 跳转到社区页面，显示我的动态
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CommunityMainPage3D(),
                                  ),
                                );
                              },
                              onMyPlans: () {
                                // 跳转到训练页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TrainingMainPage3D(),
                                  ),
                                );
                              },
                              onSavedPosts: () {
                                // 跳转到社区页面，显示收藏的帖子
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CommunityMainPage3D(),
                                  ),
                                );
                              },
                              onPartners: () {
                                // 跳转到搭子页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MatesMainPage3D(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: AppleFitnessTheme.spacingL),
                          // SettingsSection (from old design)
                          cartoon_animations.BounceInAnimation(
                            delay: const Duration(milliseconds: 400),
                            child: SettingsSection(
                              onNotifications: () {
                                // 跳转到设置页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Settings3DPage(),
                                  ),
                                );
                              },
                              onPrivacy: () {
                                // 跳转到设置页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Settings3DPage(),
                                  ),
                                );
                              },
                              onLanguage: () {
                                // 跳转到设置页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Settings3DPage(),
                                  ),
                                );
                              },
                              onDeviceBinding: () {
                                // 跳转到设置页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Settings3DPage(),
                                  ),
                                );
                              },
                              onPermissions: () {
                                // 跳转到设置页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const Settings3DPage(),
                                  ),
                                );
                              },
                              onFeedback: () {
                                // 跳转到帮助页面（包含反馈功能）
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HelpPage(),
                                  ),
                                );
                              },
                              onHelp: () {
                                // 跳转到帮助页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HelpPage(),
                                  ),
                                );
                              },
                              onAbout: () {
                                // 跳转到关于页面
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AboutPage(),
                                  ),
                                );
                              },
                              onLogout: () async {
                                // 退出登录并跳转到登录页
                                await _authService.logout();
                                if (mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const ModernLoginPage(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ),
                          SizedBox(height: AppleFitnessTheme.spacingXXL),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }


  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppleFitnessTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              _errorMessage ?? '加载失败',
              style: AppleFitnessTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Button3D.primary(
              text: '重试',
              icon: Icons.refresh,
              onPressed: _loadUserData,
            ),
          ],
        ),
      ),
    );
  }
}

