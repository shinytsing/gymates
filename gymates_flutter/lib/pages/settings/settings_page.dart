import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';

/// ⚙️ 设置页面 - SettingsPage
/// 
/// 基于Figma设计的设置页面
/// 包含主题切换、隐私设置、安全设置、关于等

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _dataSyncEnabled = true;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 头部动画控制器
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 内容动画控制器
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // 内容动画
    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始头部动画
    _headerAnimationController.forward();
    
    // 延迟开始内容动画
    await Future.delayed(const Duration(milliseconds: 200));
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域
            _buildHeader(),
            
            // 内容区域
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // 返回按钮
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 标题
                  const Expanded(
                    child: Text(
                      '设置',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
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

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 外观设置
                  _buildAppearanceSection(),
                  
                  const SizedBox(height: 16),
                  
                  // 通知设置
                  _buildNotificationSection(),
                  
                  const SizedBox(height: 16),
                  
                  // 隐私设置
                  _buildPrivacySection(),
                  
                  const SizedBox(height: 16),
                  
                  // 安全设置
                  _buildSecuritySection(),
                  
                  const SizedBox(height: 16),
                  
                  // 数据设置
                  _buildDataSection(),
                  
                  const SizedBox(height: 16),
                  
                  // 关于设置
                  _buildAboutSection(),
                  
                  const SizedBox(height: 16),
                  
                  // 退出登录
                  _buildLogoutSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSection(
      title: '外观',
      children: [
        _buildSwitchItem(
          icon: Icons.dark_mode,
          title: '深色模式',
          subtitle: '切换到深色主题',
          value: _isDarkMode,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() {
              _isDarkMode = value;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(value ? '已开启深色模式' : '已关闭深色模式'),
                backgroundColor: const Color(0xFF6366F1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: '通知',
      children: [
        _buildSwitchItem(
          icon: Icons.notifications,
          title: '推送通知',
          subtitle: '接收训练提醒和消息通知',
          value: _notificationsEnabled,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
        _buildActionItem(
          icon: Icons.schedule,
          title: '通知时间',
          subtitle: '设置通知接收时间',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('通知时间设置功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: '隐私',
      children: [
        _buildSwitchItem(
          icon: Icons.location_on,
          title: '位置服务',
          subtitle: '允许应用访问位置信息',
          value: _locationEnabled,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() {
              _locationEnabled = value;
            });
          },
        ),
        _buildActionItem(
          icon: Icons.visibility,
          title: '隐私设置',
          subtitle: '管理个人信息可见性',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('隐私设置功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.block,
          title: '屏蔽管理',
          subtitle: '管理屏蔽的用户和内容',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('屏蔽管理功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: '安全',
      children: [
        _buildSwitchItem(
          icon: Icons.fingerprint,
          title: '生物识别',
          subtitle: '使用指纹或面部识别登录',
          value: _biometricEnabled,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() {
              _biometricEnabled = value;
            });
          },
        ),
        _buildActionItem(
          icon: Icons.lock,
          title: '修改密码',
          subtitle: '更改登录密码',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('修改密码功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.security,
          title: '安全中心',
          subtitle: '查看账户安全状态',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('安全中心功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: '数据',
      children: [
        _buildSwitchItem(
          icon: Icons.sync,
          title: '数据同步',
          subtitle: '自动同步训练数据',
          value: _dataSyncEnabled,
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() {
              _dataSyncEnabled = value;
            });
          },
        ),
        _buildActionItem(
          icon: Icons.download,
          title: '数据导出',
          subtitle: '导出训练数据',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('数据导出功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.delete,
          title: '清除缓存',
          subtitle: '清理应用缓存数据',
          onTap: () {
            HapticFeedback.lightImpact();
            _showClearCacheDialog();
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: '关于',
      children: [
        _buildActionItem(
          icon: Icons.info,
          title: '关于我们',
          subtitle: '了解Gymates',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('关于我们页面待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.help,
          title: '帮助中心',
          subtitle: '常见问题解答',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('帮助中心功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.feedback,
          title: '意见反馈',
          subtitle: '告诉我们你的想法',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('意见反馈功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
        _buildActionItem(
          icon: Icons.star,
          title: '评价应用',
          subtitle: '在应用商店评价',
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('评价应用功能待实现'),
                backgroundColor: Color(0xFF6366F1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionItem(
            icon: Icons.logout,
            title: '退出登录',
            subtitle: '退出当前账户',
            iconColor: const Color(0xFFEF4444),
            textColor: const Color(0xFFEF4444),
            onTap: () {
              HapticFeedback.lightImpact();
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6366F1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (iconColor ?? const Color(0xFF6366F1)).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? const Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor ?? const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '清除缓存',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '确定要清除应用缓存吗？这将删除所有临时数据，但不会影响你的训练记录。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('缓存清除成功'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '确定要退出登录吗？退出后需要重新登录才能使用应用。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已退出登录'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}
