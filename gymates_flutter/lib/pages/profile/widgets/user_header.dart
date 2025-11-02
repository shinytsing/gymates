import 'package:flutter/material.dart';
import '../../../models/user_achievement_data.dart';
import '../../../core/theme/gymates_colors.dart';

/// 👤 用户信息头部组件
/// 
/// 功能：
/// - 展示用户头像、昵称、健身目标、简介
/// - 显示认证标识和会员标识
/// - 社交数据（关注、粉丝、动态数）
/// - 编辑个人资料按钮

class UserHeader extends StatelessWidget {
  final UserAchievementData userData;
  final VoidCallback onEditProfile;
  final VoidCallback? onFollowersClick;
  final VoidCallback? onFollowingClick;
  final VoidCallback? onPostsClick;

  const UserHeader({
    super.key,
    required this.userData,
    required this.onEditProfile,
    this.onFollowersClick,
    this.onFollowingClick,
    this.onPostsClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GyMatesColors.primaryGreen.withOpacity(0.8),
            GyMatesColors.primaryPurple.withOpacity(0.9),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: GyMatesColors.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像和基本信息
              Row(
                children: [
                  // 头像
                  _buildAvatar(),
                  const SizedBox(width: 20),
                  
                  // 名称和目标
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildNameRow(),
                        const SizedBox(height: 8),
                        _buildGoalAndBio(),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // 社交数据
              _buildSocialStats(),
              
              const SizedBox(height: 20),
              
              // 编辑个人资料按钮
              _buildEditButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Stack(
      children: [
        // 头像外圈发光效果
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.1),
              ],
            ),
          ),
        ),
        // 头像
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: userData.avatar.startsWith('http')
                ? Image.network(
                    userData.avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildAvatarPlaceholder();
                    },
                  )
                : _buildAvatarPlaceholder(),
          ),
        ),
        // 会员标识
        if (userData.isPremium)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }

  /// 头像占位符
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: GyMatesColors.primaryPurple.withOpacity(0.3),
      child: Center(
        child: Text(
          userData.avatar,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  /// 构建名称行
  Widget _buildNameRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            userData.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        // 认证标识
        if (userData.isVerified)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: GyMatesColors.primaryPurple,
              size: 16,
            ),
          ),
      ],
    );
  }

  /// 构建目标和简介
  Widget _buildGoalAndBio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 健身目标
        if (userData.fitnessGoal != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '🎯',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  userData.fitnessGoal!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        // 简介
        if (userData.bio != null) ...[
          const SizedBox(height: 6),
          Text(
            userData.bio!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// 构建社交数据
  Widget _buildSocialStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: '粉丝',
            value: _formatNumber(userData.followers),
            onTap: onFollowersClick,
          ),
        ),
        Container(
          width: 1,
          height: 30,
          color: Colors.white.withOpacity(0.3),
        ),
        Expanded(
          child: _buildStatItem(
            label: '关注',
            value: _formatNumber(userData.following),
            onTap: onFollowingClick,
          ),
        ),
        Container(
          width: 1,
          height: 30,
          color: Colors.white.withOpacity(0.3),
        ),
        Expanded(
          child: _buildStatItem(
            label: '动态',
            value: _formatNumber(userData.posts),
            onTap: onPostsClick,
          ),
        ),
      ],
    );
  }

  /// 单个统计项
  Widget _buildStatItem({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建编辑按钮
  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onEditProfile,
        icon: const Icon(Icons.edit, size: 18),
        label: const Text(
          '编辑个人资料',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: GyMatesColors.primaryPurple,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  /// 格式化数字
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}

