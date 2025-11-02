import 'package:flutter/material.dart';
import '../../../models/user_achievement_data.dart';
import '../../../core/theme/gymates_colors.dart';

/// 🏆 成就面板组件
/// 
/// 功能：
/// - 展示训练统计数据（训练次数、时长、卡路里、体重变化）
/// - 显示成就徽章
/// - 生成可分享的成就卡片

class AchievementPanel extends StatefulWidget {
  final UserAchievementData userData;
  final VoidCallback onShareAchievement;
  final VoidCallback onViewAllBadges;

  const AchievementPanel({
    super.key,
    required this.userData,
    required this.onShareAchievement,
    required this.onViewAllBadges,
  });

  @override
  State<AchievementPanel> createState() => _AchievementPanelState();
}

class _AchievementPanelState extends State<AchievementPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
          // 标题栏
          _buildHeader(),
          
          const Divider(height: 1),
          
          // 统计数据
          _buildStatsGrid(),
          
          const Divider(height: 1),
          
          // 成就徽章
          _buildBadgesSection(),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: GyMatesColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '我的成就',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '记录每一次突破',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          // 分享按钮
          IconButton(
            onPressed: widget.onShareAchievement,
            icon: const Icon(Icons.share),
            style: IconButton.styleFrom(
              backgroundColor: GyMatesColors.primaryPurple.withOpacity(0.1),
              foregroundColor: GyMatesColors.primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计数据网格
  Widget _buildStatsGrid() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 第一行
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: '💪',
                      label: '训练次数',
                      value: widget.userData.totalSessions.toString(),
                      unit: '次',
                      color: const Color(0xFF6366F1),
                      delay: 0,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: '⏱️',
                      label: '训练时长',
                      value: widget.userData.totalHours.toStringAsFixed(1),
                      unit: '小时',
                      color: const Color(0xFF8B5CF6),
                      delay: 0.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 第二行
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: '🔥',
                      label: '消耗卡路里',
                      value: _formatCalories(widget.userData.totalCalories),
                      unit: '',
                      color: const Color(0xFFF59E0B),
                      delay: 0.2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: widget.userData.weightChange < 0 ? '📉' : '📈',
                      label: '体重变化',
                      value: widget.userData.weightChange.abs().toStringAsFixed(1),
                      unit: 'kg',
                      color: widget.userData.weightChange < 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      delay: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// 单个统计卡片
  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
    required double delay,
  }) {
    final animationValue = Curves.easeOutCubic.transform(
      (_animation.value - delay).clamp(0.0, 1.0),
    );

    return Transform.scale(
      scale: 0.8 + (animationValue * 0.2),
      child: Opacity(
        opacity: animationValue,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        unit,
                        style: TextStyle(
                          fontSize: 12,
                          color: color.withOpacity(0.7),
                        ),
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

  /// 构建徽章区域
  Widget _buildBadgesSection() {
    final unlockedBadges = widget.userData.badges
        .where((badge) => badge.isUnlocked)
        .take(5)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '成就徽章',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已解锁 ${widget.userData.unlockedBadges}/${widget.userData.totalBadges}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: widget.onViewAllBadges,
                child: const Text('查看全部 →'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 进度条
          _buildProgressBar(),
          
          const SizedBox(height: 16),
          
          // 徽章列表
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: unlockedBadges.length,
              itemBuilder: (context, index) {
                return _buildBadgeItem(unlockedBadges[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建进度条
  Widget _buildProgressBar() {
    final progress = widget.userData.unlockedBadges / widget.userData.totalBadges;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress * _animation.value,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  GyMatesColors.primaryGreen,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 单个徽章项
  Widget _buildBadgeItem(AchievementBadge badge, int index) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final delay = 0.4 + (index * 0.1);
        final animationValue = Curves.easeOutCubic.transform(
          (_animation.value - delay).clamp(0.0, 1.0),
        );

        return Transform.scale(
          scale: 0.8 + (animationValue * 0.2),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: GyMatesColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GyMatesColors.primaryPurple.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        badge.icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    badge.title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 格式化卡路里
  String _formatCalories(int calories) {
    if (calories >= 1000) {
      return '${(calories / 1000).toStringAsFixed(1)}K';
    }
    return calories.toString();
  }
}

