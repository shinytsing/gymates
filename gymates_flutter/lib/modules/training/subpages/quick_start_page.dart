import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../pages/training_detail_page.dart';
import '../../../shared/models/mock_data.dart';

/// 🚀 快速开始训练页面 - QuickStartPage
/// 
/// 允许用户快速选择预设训练计划并开始训练

class QuickStartPage extends StatefulWidget {
  const QuickStartPage({super.key});

  @override
  State<QuickStartPage> createState() => _QuickStartPageState();
}

class _QuickStartPageState extends State<QuickStartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: GymatesTheme.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '快速开始',
          style: TextStyle(
            color: GymatesTheme.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildPresetPlans(),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '快速开始',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '选择预设训练计划，立即开始训练',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPresetPlans() {
    final presetPlans = [
      _PresetPlan(
        title: '全身力量',
        duration: '45分钟',
        calories: 320,
        exercises: 6,
        difficulty: '中级',
        color: Colors.blue,
      ),
      _PresetPlan(
        title: '有氧燃脂',
        duration: '30分钟',
        calories: 280,
        exercises: 8,
        difficulty: '初级',
        color: Colors.orange,
      ),
      _PresetPlan(
        title: '增肌训练',
        duration: '60分钟',
        calories: 450,
        exercises: 5,
        difficulty: '高级',
        color: Colors.purple,
      ),
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '预设训练计划',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...presetPlans.map((plan) => _buildPresetPlanCard(plan)),
      ],
    );
  }
  
  Widget _buildPresetPlanCard(_PresetPlan plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: InkWell(
        onTap: () => _startPresetPlan(plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: plan.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: plan.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatChip('${plan.exercises}个动作', Icons.list),
                        const SizedBox(width: 8),
                        _buildStatChip(plan.duration, Icons.access_time),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: plan.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan.difficulty,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: plan.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatChip(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: GymatesTheme.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: GymatesTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速操作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickActionCard(
          '自选动作',
          Icons.tune,
          Colors.green,
          '自由选择训练动作',
          () {
            HapticFeedback.lightImpact();
            // TODO: 跳转到动作选择页面
          },
        ),
        const SizedBox(height: 12),
        _buildQuickActionCard(
          '查看今日计划',
          Icons.calendar_today,
          Colors.blue,
          '查看并开始今日训练计划',
          () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
  
  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: GymatesTheme.getCardShadow(false),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: GymatesTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: GymatesTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: GymatesTheme.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
  
  void _startPresetPlan(_PresetPlan plan) {
    HapticFeedback.lightImpact();
    
    // 这里使用一个模拟的训练计划
    final mockPlan = MockDataProvider.trainingPlans.first;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingDetailPage(trainingPlan: mockPlan),
      ),
    );
  }
}

class _PresetPlan {
  final String title;
  final String duration;
  final int calories;
  final int exercises;
  final String difficulty;
  final Color color;
  
  const _PresetPlan({
    required this.title,
    required this.duration,
    required this.calories,
    required this.exercises,
    required this.difficulty,
    required this.color,
  });
}

