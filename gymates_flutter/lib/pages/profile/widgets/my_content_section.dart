import 'package:flutter/material.dart';
import '../../../models/user_achievement_data.dart';

/// 📝 我的内容区域组件
/// 
/// 功能：
/// - 展示用户的动态、训练计划、收藏的帖子
/// - 提供快速入口到伙伴列表和会员中心

class MyContentSection extends StatelessWidget {
  final UserAchievementData userData;
  final VoidCallback onMyPosts;
  final VoidCallback onMyPlans;
  final VoidCallback onSavedPosts;
  final VoidCallback onPartners;
  final VoidCallback? onMemberCenter;

  const MyContentSection({
    super.key,
    required this.userData,
    required this.onMyPosts,
    required this.onMyPlans,
    required this.onSavedPosts,
    required this.onPartners,
    this.onMemberCenter,
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
          
          // 内容列表
          _buildContentList(),
          
          // 会员中心入口
          if (userData.isPremium || onMemberCenter != null) ...[
            const Divider(height: 1),
            _buildMemberCenterEntry(),
          ],
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
            Icons.folder_outlined,
            color: Color(0xFF6366F1),
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            '我的内容',
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

  /// 构建内容列表
  Widget _buildContentList() {
    return Column(
      children: [
        _buildContentItem(
          icon: Icons.article_outlined,
          iconColor: const Color(0xFF6366F1),
          iconBgColor: const Color(0xFF6366F1).withOpacity(0.1),
          title: '我的动态',
          subtitle: '${userData.posts} 条动态',
          onTap: onMyPosts,
        ),
        _buildContentItem(
          icon: Icons.fitness_center,
          iconColor: const Color(0xFF8B5CF6),
          iconBgColor: const Color(0xFF8B5CF6).withOpacity(0.1),
          title: '我的训练计划',
          subtitle: '${userData.workoutPlans} 个计划',
          onTap: onMyPlans,
        ),
        _buildContentItem(
          icon: Icons.bookmark_outline,
          iconColor: const Color(0xFFF59E0B),
          iconBgColor: const Color(0xFFF59E0B).withOpacity(0.1),
          title: '收藏的帖子',
          subtitle: '${userData.savedPosts} 条收藏',
          onTap: onSavedPosts,
        ),
        _buildContentItem(
          icon: Icons.people_outline,
          iconColor: const Color(0xFF10B981),
          iconBgColor: const Color(0xFF10B981).withOpacity(0.1),
          title: '我的伙伴',
          subtitle: '${userData.following} 位伙伴',
          onTap: onPartners,
          isLast: onMemberCenter == null && !userData.isPremium,
        ),
      ],
    );
  }

  /// 单个内容项
  Widget _buildContentItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
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
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建会员中心入口
  Widget _buildMemberCenterEntry() {
    if (onMemberCenter == null) return const SizedBox.shrink();

    return InkWell(
      onTap: onMemberCenter,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFD700),
              Color(0xFFFF8C00),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '会员中心',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData.isPremium
                        ? 'AI教练、高级功能尽享'
                        : '解锁更多高级功能',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

