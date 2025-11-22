import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../models/workout.dart';

/// 🤖 AI教练区域 - AICoachSection
/// 
/// 展示AI教练的推荐和建议

class AICoachSection extends StatelessWidget {
  final Function(TodayWorkoutPlan) onApplyAIPlan;
  final VoidCallback onViewAIDetail;

  const AICoachSection({
    super.key,
    required this.onApplyAIPlan,
    required this.onViewAIDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildRecommendation(),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI智能教练',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '根据你的数据智能推荐',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecommendation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                '💡 今日推荐',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '根据你昨天的训练强度，今天适合进行中等强度的有氧训练，帮助肌肉恢复。',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRecommendationTag('有氧训练', Icons.directions_run),
              _buildRecommendationTag('30分钟', Icons.access_time),
              _buildRecommendationTag('中等强度', Icons.fitness_center),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecommendationTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _applyAIRecommendation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 20),
                SizedBox(width: 8),
                Text(
                  '一键应用AI计划',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onViewAIDetail();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 18),
                SizedBox(width: 6),
                Text('查看AI计划详情'),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  void _applyAIRecommendation(BuildContext context) {
    // 生成AI推荐计划
    final aiPlan = TodayWorkoutPlan(
      id: 'ai_plan_${DateTime.now().millisecondsSinceEpoch}',
      title: 'AI推荐训练计划',
      exercises: [
        WorkoutExercise(
          id: '1',
          name: '跑步机有氧',
          sets: 3,
          reps: 20,
          restSeconds: 60,
          weight: 0.0,
          muscleGroup: '有氧',
        ),
        WorkoutExercise(
          id: '2',
          name: '动感单车',
          sets: 2,
          reps: 30,
          restSeconds: 120,
          weight: 0.0,
          muscleGroup: '有氧',
        ),
      ],
    );
    
    onApplyAIPlan(aiPlan);
  }
}

