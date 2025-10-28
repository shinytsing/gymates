import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/navigation/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: '我的',
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: null, // TODO: Implement settings
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(user),
            
            // Stats
            _buildStats(),
            
            // Menu Items
            _buildMenuItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return CustomCard(
      margin: const EdgeInsets.all(AppSizes.paddingM),
      child: Column(
        children: [
          CircleAvatar(
            radius: AppSizes.avatarXL / 2,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            user?.name ?? '用户',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            user?.email ?? 'user@example.com',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingL),
          ElevatedButton(
            onPressed: () {
              AppNavigation.goToEditProfile(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
            ),
            child: const Text('编辑资料'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem('训练次数', '12'),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildStatItem('关注', '8'),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildStatItem('粉丝', '24'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h5.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingXS),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      MenuItem(
        icon: Icons.fitness_center,
        title: '我的训练',
        subtitle: '查看训练记录',
        onTap: () {
          // TODO: Implement my training
        },
      ),
      MenuItem(
        icon: Icons.people,
        title: '我的搭子',
        subtitle: '管理健身伙伴',
        onTap: () {
          // TODO: Implement my mates
        },
      ),
      MenuItem(
        icon: Icons.bookmark,
        title: '收藏',
        subtitle: '收藏的帖子',
        onTap: () {
          // TODO: Implement bookmarks
        },
      ),
      MenuItem(
        icon: Icons.emoji_events,
        title: '成就',
        subtitle: '获得的徽章',
        onTap: () {
          // TODO: Implement achievements
        },
      ),
      MenuItem(
        icon: Icons.settings,
        title: '设置',
        subtitle: '应用设置',
        onTap: () {
          // TODO: Implement settings
        },
      ),
      MenuItem(
        icon: Icons.logout,
        title: '退出登录',
        subtitle: '安全退出',
        onTap: () {
          _showLogoutDialog();
        },
      ),
    ];

    return Column(
      children: menuItems.map((item) => _buildMenuItem(item)).toList(),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return CustomCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
      onTap: item.onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusS),
            ),
            child: Icon(
              item.icon,
              color: AppColors.primary,
              size: AppSizes.iconM,
            ),
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingXS),
                Text(
                  item.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
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
              ref.read(authNotifierProvider.notifier).logout();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}
