import 'package:flutter/material.dart';
import '../today_training_page.dart';

/// 今日训练计划卡片
class TodayPlanCard extends StatelessWidget {
  final String planId;
  final List<TodayExercise> exercises;
  final VoidCallback onStartWorkout;
  final VoidCallback onEditPlan;

  const TodayPlanCard({
    super.key,
    required this.planId,
    required this.exercises,
    required this.onStartWorkout,
    required this.onEditPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日训练计划',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercises.length}个动作',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onEditPlan,
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),
          
          // 动作列表
          if (exercises.isNotEmpty)
            Column(
              children: exercises.take(3).map((exercise) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: exercise.isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFFE5E7EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${exercise.sets}组 × ${exercise.reps}次',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (exercise.isCompleted)
                        const Icon(
                          Icons.check_circle,
                          size: 20,
                          color: Color(0xFF10B981),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          
          if (exercises.length > 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '还有 ${exercises.length - 3} 个动作...',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          
          // 开始训练按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStartWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '一键开始训练',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

