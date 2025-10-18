import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';
import '../../../animations/gymates_animations.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/models/mock_data.dart';
import '../../../pages/training/training_detail_page.dart';
import '../../../pages/training/training_page.dart';
import 'exercise_completion_animation.dart';

/// 🏋️‍♀️ 今日训练计划卡片 - TodayPlanCard
/// 
/// 基于Figma设计的今日训练计划展示组件
/// 包含训练计划信息、进度显示、开始训练按钮

class TodayPlanCard extends StatefulWidget {
  const TodayPlanCard({super.key});

  @override
  State<TodayPlanCard> createState() => _TodayPlanCardState();
}

class _TodayPlanCardState extends State<TodayPlanCard>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _progressController;
  
  late Animation<double> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 卡片动画控制器
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 进度动画控制器
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 卡片动画
    _cardSlideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    // 进度动画
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 0.68, // 68% 进度
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始卡片动画
    _cardAnimationController.forward();
    
    // 延迟开始进度动画
    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trainingPlan = MockDataProvider.trainingPlans.first;
    
    return AnimatedBuilder(
      animation: _cardAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _cardSlideAnimation.value),
          child: Opacity(
            opacity: _cardFadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                  // 训练计划图片
                  _buildPlanImage(trainingPlan),
                  
                  // 训练计划信息
                  _buildPlanInfo(trainingPlan),
                  
                  // 进度条
                  _buildProgressSection(),
                  
                  // 开始训练按钮
                  _buildStartButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanImage(MockTrainingPlan plan) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        image: DecorationImage(
          image: NetworkImage(plan.image),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // 渐变遮罩
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // 难度标签
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                plan.difficulty,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ),
          
          // 时长标签
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    plan.duration,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfo(MockTrainingPlan plan) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            plan.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 描述
          Text(
            plan.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 训练项目
          _buildExerciseList(plan.exercises),
          
          const SizedBox(height: 12),
          
          // 卡路里消耗
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 16,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 4),
              Text(
                '${plan.calories} 卡路里',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(List<String> exercises) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: exercises.map((exercise) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            exercise,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6366F1),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日进度',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 进度条
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 8),
          
          // 进度文字
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Text(
                '${(_progressAnimation.value * 100).toInt()}% 完成',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6366F1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _startTraining();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '开始训练',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 开始训练
  void _startTraining() {
    if (MockDataProvider.trainingPlans.isNotEmpty) {
      final plan = MockDataProvider.trainingPlans.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainingSessionPage(trainingPlan: plan),
        ),
      );
    }
  }

  void _showExerciseDemo() {
    // 显示动作完成动画演示
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '动作完成演示',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            
            // 动作完成动画
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: MockDataProvider.exercises.take(3).map((exercise) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ExerciseCompletionAnimation(
                        exercise: exercise,
                        onCompleted: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${exercise.name} 完成！'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 导航到训练详情页
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainingDetailPage(
                          trainingPlan: MockDataProvider.trainingPlans.first,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '开始正式训练',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
