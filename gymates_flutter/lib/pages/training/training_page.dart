import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';
import '../../shared/widgets/training/today_plan_card.dart';
import '../../shared/widgets/training/ai_plan_generator.dart';
import '../../shared/widgets/training/progress_chart.dart';
import '../../shared/widgets/training/checkin_calendar.dart';
import '../../shared/widgets/training/training_history_list.dart';

/// 🏋️‍♀️ 训练页 TrainingPage - 基于Figma设计的现代化健身训练界面
/// 
/// 设计规范：
/// - 主色调：#6366F1
/// - 背景色：#F9FAFB
/// - 卡片圆角：12px
/// - 页面边距：16px
/// - 组件间距：8/12/16px

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  String _activeTab = 'today';

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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域 with precise Figma styling
            _buildHeader(isIOS),
            
            // 内容区域
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isIOS) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '训练',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: GymatesTheme.lightTextPrimary,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: GymatesTheme.spacing4),
                          Text(
                            '让我们开始今天的训练吧！',
                            style: TextStyle(
                              fontSize: 14,
                              color: GymatesTheme.lightTextSecondary,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // 移除搜索和通知按钮
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 进度统计
                  _buildProgressStats(),
                  
                  const SizedBox(height: 16),
                  
                  // 标签页
                  _buildTabs(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap, {bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                size: 20,
                color: GymatesTheme.lightTextSecondary,
              ),
            ),
            if (hasBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('12', '本周训练'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('2.3k', '消耗卡路里'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('85%', '目标完成'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: GymatesTheme.lightBackground,
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: GymatesTheme.lightTextPrimary,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: GymatesTheme.spacing4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: GymatesTheme.lightTextSecondary,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(GymatesTheme.radius8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('today', '今日训练'),
          ),
          Expanded(
            child: _buildTabButton('history', '历史'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    final isSelected = _activeTab == tab;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: GymatesTheme.spacing8, 
          horizontal: GymatesTheme.spacing16
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? GymatesTheme.primaryColor : GymatesTheme.lightTextSecondary,
            height: 1.2,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // 增加底部边距以避免与导航栏重叠
              child: Column(
                children: [
                  if (_activeTab == 'today') ...[
                    // 今日训练内容
                    const TodayPlanCard(),
                    const SizedBox(height: 16),
                    const AIPlanGenerator(),
                  ] else ...[
                    // 历史内容
                    const ProgressChart(),
                    const SizedBox(height: 16),
                    const CheckinCalendar(),
                    const SizedBox(height: 16),
                    const TrainingHistoryList(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}