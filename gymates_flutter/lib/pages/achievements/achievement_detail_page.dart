import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';
import '../../shared/models/mock_data.dart';

/// 🏆 成就详情页 - AchievementDetailPage
/// 
/// 基于Figma设计的成就详情页面
/// 包含成就列表、进度跟踪、成就解锁

class AchievementDetailPage extends StatefulWidget {
  const AchievementDetailPage({super.key});

  @override
  State<AchievementDetailPage> createState() => _AchievementDetailPageState();
}

class _AchievementDetailPageState extends State<AchievementDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _achievementAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _achievementAnimation;

  String _selectedCategory = 'all';
  
  final List<String> _categories = ['all', 'training', 'social', 'streak', 'special'];
  
  final Map<String, String> _categoryNames = {
    'all': '全部',
    'training': '训练',
    'social': '社交',
    'streak': '连续',
    'special': '特殊',
  };

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
    
    // 成就动画控制器
    _achievementAnimationController = AnimationController(
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

    // 内容动画
    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 成就动画
    _achievementAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _achievementAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始头部动画
    _headerAnimationController.forward();
    
    // 延迟开始内容动画
    await Future.delayed(const Duration(milliseconds: 200));
    _contentAnimationController.forward();
    
    // 延迟开始成就动画
    await Future.delayed(const Duration(milliseconds: 400));
    _achievementAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    _achievementAnimationController.dispose();
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
                      '我的成就',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  
                  // 统计信息
                  _buildStatsInfo(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsInfo() {
    final unlockedCount = MockDataProvider.achievements.where((a) => a.isUnlocked).length;
    final totalCount = MockDataProvider.achievements.length;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$unlockedCount/$totalCount',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
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
            child: Column(
              children: [
                // 分类标签
                _buildCategoryTabs(),
                
                // 成就列表
                Expanded(
                  child: _buildAchievementList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  _categoryNames[category]!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAchievementList() {
    final filteredAchievements = _selectedCategory == 'all'
        ? MockDataProvider.achievements
        : MockDataProvider.achievements.where((achievement) {
            // 这里可以根据成就类型过滤
            return true; // 简化处理，实际应该根据category过滤
          }).toList();

    return AnimatedBuilder(
      animation: _achievementAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _achievementAnimation.value,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredAchievements.length,
            itemBuilder: (context, index) {
              final achievement = filteredAchievements[index];
              final animationDelay = index * 0.1;
              
              return Transform.translate(
                offset: Offset(0, 20 * (1 - _achievementAnimation.value)),
                child: Opacity(
                  opacity: _achievementAnimation.value,
                  child: _buildAchievementItem(achievement, index),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAchievementItem(MockAchievement achievement, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: achievement.isUnlocked ? Border.all(
          color: const Color(0xFF10B981),
          width: 2,
        ) : null,
      ),
      child: Row(
        children: [
          // 成就图标
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement.isUnlocked 
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: achievement.isUnlocked 
                    ? const Color(0xFF10B981)
                    : const Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 24,
                  color: achievement.isUnlocked 
                      ? const Color(0xFF10B981)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 成就信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: achievement.isUnlocked 
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    if (achievement.isUnlocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '已解锁',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: achievement.isUnlocked 
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
                    height: 1.4,
                  ),
                ),
                
                if (achievement.isUnlocked) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${achievement.points} 积分',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (achievement.date.isNotEmpty) ...[
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          achievement.date,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // 进度指示器
          if (!achievement.isUnlocked)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock,
                size: 12,
                color: Color(0xFF6B7280),
              ),
            ),
        ],
      ),
    );
  }
}
