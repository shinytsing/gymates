import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/enhanced_gymates_theme.dart';
import '../../core/animations/enhanced_gymates_animations.dart';

/// 🏋️‍♀️ Enhanced Training Page
/// 
/// 训练页包含以下模块：
/// 1. 今日训练计划卡片 (TodayPlanCard)
/// 2. AI智能推荐 (AIPlanGenerator)
/// 3. 训练历史 (TrainingHistoryList)
/// 4. 数据统计区
/// 5. 打卡日历 (CheckinCalendar)
/// 6. 成就徽章网格 (AchievementGrid)
/// 7. 进度图表 (ProgressChart)

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _refreshController;
  late AnimationController _cardAnimationController;
  
  // 模拟数据
  final List<TrainingPlan> _trainingPlans = [
    TrainingPlan(
      title: '上肢力量训练',
      duration: 45,
      exercises: 5,
      difficulty: '中级',
      calories: 320,
      description: '专注于胸肌、背肌和手臂的力量训练',
    ),
    TrainingPlan(
      title: '有氧燃脂训练',
      duration: 30,
      exercises: 3,
      difficulty: '初级',
      calories: 280,
      description: '高效燃脂的有氧运动组合',
    ),
    TrainingPlan(
      title: '全身综合训练',
      duration: 60,
      exercises: 8,
      difficulty: '高级',
      calories: 450,
      description: '全身肌肉群的综合训练计划',
    ),
  ];
  
  final List<Achievement> _achievements = [
    Achievement(
      title: '坚持一周',
      description: '连续训练7天',
      icon: '🏆',
      isUnlocked: true,
    ),
    Achievement(
      title: '力量达人',
      description: '完成100次力量训练',
      icon: '💪',
      isUnlocked: true,
    ),
    Achievement(
      title: '有氧专家',
      description: '完成50次有氧训练',
      icon: '🏃‍♂️',
      isUnlocked: false,
    ),
    Achievement(
      title: '完美身材',
      description: '达到目标体重',
      icon: '✨',
      isUnlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // 启动卡片动画
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedGymatesTheme.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 页面标题
              _buildSliverAppBar(),
              
              // 今日训练计划
              _buildTodayPlanCard(),
              
              // AI智能推荐
              _buildAIPlanGenerator(),
              
              // 数据统计区
              _buildStatsSection(),
              
              // 训练历史
              _buildTrainingHistory(),
              
              // 打卡日历
              _buildCheckinCalendar(),
              
              // 成就徽章
              _buildAchievementGrid(),
              
              // 进度图表
              _buildProgressChart(),
              
              // 底部间距
              const SliverToBoxAdapter(
                child: SizedBox(height: EnhancedGymatesTheme.spacing32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: EnhancedGymatesTheme.lightBackground,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '训练',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: EnhancedGymatesTheme.lightTextPrimary,
              ),
            ),
            Text(
              '开始你的健身之旅',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: EnhancedGymatesTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: 打开设置
          },
          icon: Icon(
            Icons.settings,
            color: EnhancedGymatesTheme.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayPlanCard() {
    return SliverToBoxAdapter(
      child: FadeInWidget(
        delay: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.all(EnhancedGymatesTheme.spacing16),
          decoration: BoxDecoration(
            gradient: EnhancedGymatesTheme.primaryGradient,
            borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius16),
            boxShadow: EnhancedGymatesTheme.mediumShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius8),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: EnhancedGymatesTheme.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日训练计划',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '上肢力量训练',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: EnhancedGymatesTheme.spacing16),
                
                Row(
                  children: [
                    _buildPlanInfo('45分钟', Icons.access_time),
                    const SizedBox(width: EnhancedGymatesTheme.spacing16),
                    _buildPlanInfo('5个动作', Icons.list),
                    const SizedBox(width: EnhancedGymatesTheme.spacing16),
                    _buildPlanInfo('320卡路里', Icons.local_fire_department),
                  ],
                ),
                
                const SizedBox(height: EnhancedGymatesTheme.spacing20),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: 开始训练
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: EnhancedGymatesTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: EnhancedGymatesTheme.spacing16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius8),
                      ),
                    ),
                    child: Text(
                      '开始训练',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanInfo(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(width: EnhancedGymatesTheme.spacing4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAIPlanGenerator() {
    return SliverToBoxAdapter(
      child: FadeInWidget(
        delay: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: EnhancedGymatesTheme.spacing16),
          padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius16),
            boxShadow: EnhancedGymatesTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing8),
                    decoration: BoxDecoration(
                      color: EnhancedGymatesTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius8),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: EnhancedGymatesTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: EnhancedGymatesTheme.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI智能推荐',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: EnhancedGymatesTheme.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '根据您的数据生成个性化训练计划',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: EnhancedGymatesTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: EnhancedGymatesTheme.spacing16),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // TODO: 生成AI训练计划
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('生成训练计划'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: EnhancedGymatesTheme.primaryColor,
                    side: BorderSide(color: EnhancedGymatesTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: EnhancedGymatesTheme.spacing12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: FadeInWidget(
        delay: const Duration(milliseconds: 300),
        child: Container(
          margin: const EdgeInsets.all(EnhancedGymatesTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '本周数据',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: EnhancedGymatesTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: EnhancedGymatesTheme.spacing12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '训练次数',
                      '5',
                      '次',
                      Icons.fitness_center,
                      EnhancedGymatesTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: EnhancedGymatesTheme.spacing12),
                  Expanded(
                    child: _buildStatCard(
                      '消耗卡路里',
                      '1,250',
                      'kcal',
                      Icons.local_fire_department,
                      EnhancedGymatesTheme.warningColor,
                    ),
                  ),
                  const SizedBox(width: EnhancedGymatesTheme.spacing12),
                  Expanded(
                    child: _buildStatCard(
                      '目标完成率',
                      '85',
                      '%',
                      Icons.trending_up,
                      EnhancedGymatesTheme.successColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius12),
        boxShadow: EnhancedGymatesTheme.softShadow,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: EnhancedGymatesTheme.spacing8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: EnhancedGymatesTheme.lightTextPrimary,
            ),
          ),
          Text(
            unit,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: EnhancedGymatesTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: EnhancedGymatesTheme.spacing4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: EnhancedGymatesTheme.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingHistory() {
    return SliverToBoxAdapter(
      child: FadeInWidget(
        delay: const Duration(milliseconds: 400),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: EnhancedGymatesTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '训练历史',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: EnhancedGymatesTheme.lightTextPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // TODO: 查看全部历史
                    },
                    child: Text(
                      '查看全部',
                      style: TextStyle(
                        color: EnhancedGymatesTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: EnhancedGymatesTheme.spacing12),
              ...(_trainingPlans.take(3).map((plan) => _buildTrainingHistoryItem(plan))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingHistoryItem(TrainingPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: EnhancedGymatesTheme.spacing12),
      padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius12),
        boxShadow: EnhancedGymatesTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing8),
            decoration: BoxDecoration(
              color: EnhancedGymatesTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius8),
            ),
            child: Icon(
              Icons.fitness_center,
              color: EnhancedGymatesTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: EnhancedGymatesTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: EnhancedGymatesTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: EnhancedGymatesTheme.spacing4),
                Text(
                  plan.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: EnhancedGymatesTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${plan.duration}分钟',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: EnhancedGymatesTheme.lightTextPrimary,
                ),
              ),
              Text(
                '${plan.calories}卡路里',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: EnhancedGymatesTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinCalendar() {
    return SliverToBoxAdapter(
      child: FadeInWidget(
        delay: const Duration(milliseconds: 500),
        child: Container(
          margin: const EdgeInsets.all(EnhancedGymatesTheme.spacing16),
          padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius16),
            boxShadow: EnhancedGymatesTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '打卡日历',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: EnhancedGymatesTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: EnhancedGymatesTheme.spacing16),
              _buildCalendarGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: firstWeekday - 1 + daysInMonth,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return const SizedBox();
        }
        
        final day = index - firstWeekday + 2;
        final isToday = day == now.day;
        final isChecked = day <= now.day && day % 3 == 0; // 模拟打卡数据
        
        return Container(
          decoration: BoxDecoration(
            color: isChecked
                ? EnhancedGymatesTheme.successColor.withOpacity(0.1)
                : isToday
                    ? EnhancedGymatesTheme.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius8),
            border: isToday
                ? Border.all(color: EnhancedGymatesTheme.primaryColor, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isChecked
                    ? EnhancedGymatesTheme.successColor
                    : isToday
                        ? EnhancedGymatesTheme.primaryColor
                        : EnhancedGymatesTheme.lightTextPrimary,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementGrid() {
    return SliverToBoxAdapter(
      child: FadeInWidget(
        delay: const Duration(milliseconds: 600),
        child: Container(
          margin: const EdgeInsets.all(EnhancedGymatesTheme.spacing16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '成就徽章',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: EnhancedGymatesTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: EnhancedGymatesTheme.spacing12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: EnhancedGymatesTheme.spacing12,
                  mainAxisSpacing: EnhancedGymatesTheme.spacing12,
                ),
                itemCount: _achievements.length,
                itemBuilder: (context, index) {
                  final achievement = _achievements[index];
                  return _buildAchievementCard(achievement);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius12),
        boxShadow: achievement.isUnlocked ? EnhancedGymatesTheme.softShadow : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.icon,
            style: TextStyle(
              fontSize: achievement.isUnlocked ? 32 : 24,
              color: achievement.isUnlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(height: EnhancedGymatesTheme.spacing8),
          Text(
            achievement.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: achievement.isUnlocked
                  ? EnhancedGymatesTheme.lightTextPrimary
                  : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EnhancedGymatesTheme.spacing4),
          Text(
            achievement.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: achievement.isUnlocked
                  ? EnhancedGymatesTheme.lightTextSecondary
                  : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return SliverToBoxAdapter(
      child: FadeInWidget(
        delay: const Duration(milliseconds: 700),
        child: Container(
          margin: const EdgeInsets.all(EnhancedGymatesTheme.spacing16),
          padding: const EdgeInsets.all(EnhancedGymatesTheme.spacing20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius16),
            boxShadow: EnhancedGymatesTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '进度图表',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: EnhancedGymatesTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: EnhancedGymatesTheme.spacing16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: EnhancedGymatesTheme.lightBackground,
                  borderRadius: BorderRadius.circular(EnhancedGymatesTheme.radius8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.show_chart,
                        size: 48,
                        color: EnhancedGymatesTheme.lightTextSecondary.withOpacity(0.5),
                      ),
                      const SizedBox(height: EnhancedGymatesTheme.spacing8),
                      Text(
                        '图表功能开发中',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: EnhancedGymatesTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    _refreshController.forward().then((_) {
      _refreshController.reset();
    });
    await Future.delayed(const Duration(milliseconds: 1000));
  }
}

/// 🏋️‍♀️ 训练计划数据模型
class TrainingPlan {
  final String title;
  final int duration;
  final int exercises;
  final String difficulty;
  final int calories;
  final String description;

  TrainingPlan({
    required this.title,
    required this.duration,
    required this.exercises,
    required this.difficulty,
    required this.calories,
    required this.description,
  });
}

/// 🏆 成就数据模型
class Achievement {
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
  });
}
