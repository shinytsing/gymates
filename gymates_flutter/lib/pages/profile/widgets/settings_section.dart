import 'package:flutter/material.dart';

/// ⚙️ 设置和工具区域组件
/// 
/// 功能：
/// - 通知设置
/// - 隐私设置
/// - 语言设置
/// - 设备绑定
/// - 权限控制
/// - 反馈与帮助中心
/// - 退出登录

class SettingsSection extends StatelessWidget {
  final VoidCallback? onNotifications;
  final VoidCallback? onPrivacy;
  final VoidCallback? onLanguage;
  final VoidCallback? onDeviceBinding;
  final VoidCallback? onPermissions;
  final VoidCallback? onFeedback;
  final VoidCallback? onHelp;
  final VoidCallback? onAbout;
  final VoidCallback onLogout;

  const SettingsSection({
    super.key,
    this.onNotifications,
    this.onPrivacy,
    this.onLanguage,
    this.onDeviceBinding,
    this.onPermissions,
    this.onFeedback,
    this.onHelp,
    this.onAbout,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          _buildHeader(),
          
          const Divider(height: 1),
          
          // 设置列表
          _buildSettingsList(context),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.settings_outlined,
            color: Color(0xFF6366F1),
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            '设置与工具',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建设置列表
  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        // 通知设置
        if (onNotifications != null)
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFF6366F1),
            iconBgColor: const Color(0xFF6366F1).withOpacity(0.1),
            title: '通知设置',
            subtitle: '管理推送通知',
            onTap: onNotifications!,
          ),
        
        // 隐私设置
        if (onPrivacy != null)
          _buildSettingItem(
            icon: Icons.lock_outline,
            iconColor: const Color(0xFF8B5CF6),
            iconBgColor: const Color(0xFF8B5CF6).withOpacity(0.1),
            title: '隐私设置',
            subtitle: '谁可以看到我的内容',
            onTap: onPrivacy!,
          ),
        
        // 语言设置
        if (onLanguage != null)
          _buildSettingItem(
            icon: Icons.language_outlined,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFF10B981).withOpacity(0.1),
            title: '语言',
            subtitle: '简体中文',
            onTap: onLanguage!,
          ),
        
        // 设备绑定
        if (onDeviceBinding != null)
          _buildSettingItem(
            icon: Icons.devices_outlined,
            iconColor: const Color(0xFF06B6D4),
            iconBgColor: const Color(0xFF06B6D4).withOpacity(0.1),
            title: '设备绑定',
            subtitle: '管理已绑定的设备',
            onTap: onDeviceBinding!,
          ),
        
        // 权限控制
        if (onPermissions != null)
          _buildSettingItem(
            icon: Icons.security_outlined,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFF59E0B).withOpacity(0.1),
            title: '权限控制',
            subtitle: '相机、位置等权限',
            onTap: onPermissions!,
          ),
        
        // 分隔线
        if (onFeedback != null || onHelp != null || onAbout != null)
          Container(
            height: 8,
            color: Colors.grey[100],
          ),
        
        // 反馈
        if (onFeedback != null)
          _buildSettingItem(
            icon: Icons.feedback_outlined,
            iconColor: const Color(0xFFEC4899),
            iconBgColor: const Color(0xFFEC4899).withOpacity(0.1),
            title: '意见反馈',
            subtitle: '帮助我们做得更好',
            onTap: onFeedback!,
          ),
        
        // 帮助中心
        if (onHelp != null)
          _buildSettingItem(
            icon: Icons.help_outline,
            iconColor: const Color(0xFF3B82F6),
            iconBgColor: const Color(0xFF3B82F6).withOpacity(0.1),
            title: '帮助中心',
            subtitle: '常见问题与使用指南',
            onTap: onHelp!,
          ),
        
        // 关于
        if (onAbout != null)
          _buildSettingItem(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF9CA3AF),
            iconBgColor: const Color(0xFF9CA3AF).withOpacity(0.1),
            title: '关于Gymates',
            subtitle: '版本信息',
            onTap: onAbout!,
          ),
        
        // 分隔线
        Container(
          height: 8,
          color: Colors.grey[100],
        ),
        
        // 退出登录
        _buildLogoutButton(context),
      ],
    );
  }

  /// 单个设置项
  Widget _buildSettingItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            
            // 标题和副标题
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 3),
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
            
            // 箭头
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  /// 退出登录按钮
  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: Colors.red[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '退出登录',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示退出登录对话框
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '退出登录',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '确定要退出登录吗？',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            child: Text(
              '确定',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

