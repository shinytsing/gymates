import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../services/unified_auth_service.dart';

/// ⚙️ Apple Fitness+ Style Settings Page
/// 
/// Design Features:
/// - 3D section cards with subtle elevation
/// - 3D switch tiles with smooth animations
/// - 3D action tiles with hover effects
/// - Frosted glass modals for selectors
/// - Smooth entry animations
/// - Complete settings functionality

class Settings3DPage extends StatefulWidget {
  const Settings3DPage({super.key});

  @override
  State<Settings3DPage> createState() => _Settings3DPageState();
}

class _Settings3DPageState extends State<Settings3DPage> {
  final UnifiedAuthService _authService = UnifiedAuthService();
  
  // Settings state
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _language = '中文';
  String _theme = '自动';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            cartoon_animations.BounceInAnimation(
              delay: const Duration(milliseconds: 100),
              child: _buildAppBar(),
            ),
            
            // Settings List
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                children: [
                  // Notification Settings
                  cartoon_animations.SlideInAnimation(
                    direction: cartoon_animations.SlideDirection.fromLeft,
                    delay: const Duration(milliseconds: 200),
                    child: _buildSection(
                      '通知设置',
                      Icons.notifications_outlined,
                      AppleFitnessTheme.primaryGradient,
                      [
                        _buildSwitchTile(
                          '推送通知',
                          '接收训练提醒和社交消息',
                          _notificationsEnabled,
                          (value) => setState(() => _notificationsEnabled = value),
                        ),
                        _buildSwitchTile(
                          '声音提示',
                          '播放通知声音',
                          _soundEnabled,
                          (value) => setState(() => _soundEnabled = value),
                        ),
                        _buildSwitchTile(
                          '振动反馈',
                          '启用触觉反馈',
                          _vibrationEnabled,
                          (value) => setState(() => _vibrationEnabled = value),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  
                  // Interface Settings
                  cartoon_animations.SlideInAnimation(
                    direction: cartoon_animations.SlideDirection.fromRight,
                    delay: const Duration(milliseconds: 300),
                    child: _buildSection(
                      '界面设置',
                      Icons.palette_outlined,
                      AppleFitnessTheme.purpleGradient,
                      [
                        _buildSelectTile(
                          '语言',
                          _language,
                          Icons.language_outlined,
                          () => _showLanguageSelector(),
                        ),
                        _buildSelectTile(
                          '主题',
                          _theme,
                          Icons.brightness_6_outlined,
                          () => _showThemeSelector(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  
                  // Account & Security
                  cartoon_animations.SlideInAnimation(
                    direction: cartoon_animations.SlideDirection.fromLeft,
                    delay: const Duration(milliseconds: 400),
                    child: _buildSection(
                      '账号与安全',
                      Icons.security_outlined,
                      AppleFitnessTheme.primaryGradient,
                      [
                        _buildActionTile(
                          '修改密码',
                          Icons.lock_outline,
                          () {
                            // TODO: Navigate to change password
                            _showComingSoon('修改密码');
                          },
                        ),
                        _buildActionTile(
                          '隐私设置',
                          Icons.privacy_tip_outlined,
                          () {
                            // TODO: Navigate to privacy settings
                            _showComingSoon('隐私设置');
                          },
                        ),
                        _buildActionTile(
                          '账号管理',
                          Icons.manage_accounts_outlined,
                          () {
                            // TODO: Navigate to account management
                            _showComingSoon('账号管理');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  
                  // About
                  cartoon_animations.SlideInAnimation(
                    direction: cartoon_animations.SlideDirection.fromBottom,
                    delay: const Duration(milliseconds: 500),
                    child: _buildSection(
                      '关于',
                      Icons.info_outline,
                      AppleFitnessTheme.orangeGradient,
                      [
                        _buildActionTile(
                          '关于我们',
                          Icons.apartment_outlined,
                          () {
                            // TODO: Show about us
                            _showComingSoon('关于我们');
                          },
                        ),
                        _buildActionTile(
                          '用户协议',
                          Icons.description_outlined,
                          () {
                            // TODO: Show user agreement
                            _showComingSoon('用户协议');
                          },
                        ),
                        _buildActionTile(
                          '隐私政策',
                          Icons.policy_outlined,
                          () {
                            // TODO: Show privacy policy
                            _showComingSoon('隐私政策');
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingXL),
                  
                  // Logout Button
                  cartoon_animations.BounceInAnimation(
                    delay: const Duration(milliseconds: 600),
                    child: Button3D.primary(
                      text: '退出登录',
                      icon: Icons.logout,
                      onPressed: _handleLogout,
                      size: Button3DSize.large,
                    ),
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingXL),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      decoration: BoxDecoration(
        color: AppleFitnessTheme.backgroundPrimary,
        boxShadow: AppleFitnessTheme.softShadow(elevation: 2),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
            color: AppleFitnessTheme.textPrimary,
          ),
          SizedBox(width: AppleFitnessTheme.spacingM),
          Text(
            '设置',
            style: AppleFitnessTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    IconData icon,
    LinearGradient gradient,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppleFitnessTheme.spacingM,
            bottom: AppleFitnessTheme.spacingS,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingS),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: AppleFitnessTheme.radiusSmall,
                  boxShadow: AppleFitnessTheme.softShadow(elevation: 4),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(width: AppleFitnessTheme.spacingS),
              Text(
                title,
                style: AppleFitnessTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Card3D(
          elevation: 8,
          borderRadius: AppleFitnessTheme.radiusMedium,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppleFitnessTheme.textQuaternary,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppleFitnessTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: AppleFitnessTheme.bodySmall.copyWith(
            color: AppleFitnessTheme.textSecondary,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: (newValue) {
            HapticFeedback.lightImpact();
            onChanged(newValue);
          },
          activeThumbColor: AppleFitnessTheme.primaryBlue,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppleFitnessTheme.spacingL,
          vertical: AppleFitnessTheme.spacingS,
        ),
      ),
    );
  }

  Widget _buildSelectTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppleFitnessTheme.textQuaternary,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppleFitnessTheme.primaryBlue,
          size: 24,
        ),
        title: Text(
          title,
          style: AppleFitnessTheme.titleMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
            SizedBox(width: AppleFitnessTheme.spacingS),
            Icon(
              Icons.chevron_right,
              color: AppleFitnessTheme.textTertiary,
            ),
          ],
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppleFitnessTheme.spacingL,
          vertical: AppleFitnessTheme.spacingS,
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppleFitnessTheme.textQuaternary,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppleFitnessTheme.primaryBlue,
          size: 24,
        ),
        title: Text(
          title,
          style: AppleFitnessTheme.titleMedium,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppleFitnessTheme.textTertiary,
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppleFitnessTheme.spacingL,
          vertical: AppleFitnessTheme.spacingS,
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    HapticFeedback.mediumImpact();
    showModal3D(
      context: context,
      child: Container(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        decoration: BoxDecoration(
          color: AppleFitnessTheme.backgroundPrimary,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingL),
              decoration: BoxDecoration(
                color: AppleFitnessTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '选择语言',
              style: AppleFitnessTheme.titleLarge,
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            _buildLanguageOption('中文'),
            _buildLanguageOption('English'),
            _buildLanguageOption('日本語'),
            SizedBox(height: AppleFitnessTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _language == language;
    return Card3D(
      elevation: isSelected ? 12 : 4,
      borderRadius: AppleFitnessTheme.radiusMedium,
      onTap: () {
        setState(() => _language = language);
        Navigator.pop(context);
        HapticFeedback.mediumImpact();
      },
      child: ListTile(
        title: Text(
          language,
          style: AppleFitnessTheme.titleMedium.copyWith(
            color: isSelected
                ? AppleFitnessTheme.primaryBlue
                : AppleFitnessTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppleFitnessTheme.primaryBlue,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppleFitnessTheme.spacingL,
          vertical: AppleFitnessTheme.spacingS,
        ),
      ),
    );
  }

  void _showThemeSelector() {
    HapticFeedback.mediumImpact();
    showModal3D(
      context: context,
      child: Container(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        decoration: BoxDecoration(
          color: AppleFitnessTheme.backgroundPrimary,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingL),
              decoration: BoxDecoration(
                color: AppleFitnessTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '选择主题',
              style: AppleFitnessTheme.titleLarge,
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            _buildThemeOption('自动', Icons.brightness_auto),
            _buildThemeOption('浅色', Icons.light_mode),
            _buildThemeOption('深色', Icons.dark_mode),
            SizedBox(height: AppleFitnessTheme.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon) {
    final isSelected = _theme == theme;
    return Card3D(
      elevation: isSelected ? 12 : 4,
      borderRadius: AppleFitnessTheme.radiusMedium,
      onTap: () {
        setState(() => _theme = theme);
        Navigator.pop(context);
        HapticFeedback.mediumImpact();
      },
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? AppleFitnessTheme.primaryBlue
              : AppleFitnessTheme.textSecondary,
        ),
        title: Text(
          theme,
          style: AppleFitnessTheme.titleMedium.copyWith(
            color: isSelected
                ? AppleFitnessTheme.primaryBlue
                : AppleFitnessTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: AppleFitnessTheme.primaryBlue,
              )
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppleFitnessTheme.spacingL,
          vertical: AppleFitnessTheme.spacingS,
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature 功能即将推出'),
        backgroundColor: AppleFitnessTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppleFitnessTheme.radiusMedium,
        ),
      ),
    );
  }

  void _handleLogout() {
    HapticFeedback.mediumImpact();
    showAlertDialog3D(
      context: context,
      title: '确认退出',
      message: '确定要退出登录吗？',
      confirmText: '退出',
      cancelText: '取消',
      onConfirm: () async {
        try {
          await _authService.logout();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('退出登录失败: $e'),
                backgroundColor: AppleFitnessTheme.error,
              ),
            );
          }
        }
      },
    );
  }
}

