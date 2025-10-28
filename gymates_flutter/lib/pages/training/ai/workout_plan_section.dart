import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../models/workout.dart';

/// 📋 训练计划区域 - WorkoutPlanSection
/// 
/// 展示今日训练计划，支持编辑和添加动作

class WorkoutPlanSection extends StatelessWidget {
  final TodayWorkoutPlan? workoutPlan;
  final VoidCallback onEditPlan;
  final VoidCallback onAddExercise;
  final Function(WorkoutExercise) onExerciseTap;

  const WorkoutPlanSection({
    super.key,
    required this.workoutPlan,
    required this.onEditPlan,
    required this.onAddExercise,
    required this.onExerciseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          if (workoutPlan == null || workoutPlan!.exercises.isEmpty)
            _buildEmptyState()
          else
            ...workoutPlan!.exercises.map((exercise) => _buildExerciseCard(exercise)),
          _buildAddButton(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '今日训练计划',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '共 ${workoutPlan?.exercises.length ?? 0} 个动作',
                style: TextStyle(
                  fontSize: 13,
                  color: GymatesTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: GymatesTheme.primaryColor),
            onPressed: onEditPlan,
            tooltip: '编辑计划',
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: GymatesTheme.lightTextSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有训练计划',
            style: TextStyle(
              fontSize: 16,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '点击下方按钮添加动作',
            style: TextStyle(
              fontSize: 14,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExerciseCard(WorkoutExercise exercise) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () => onExerciseTap(exercise),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          // TODO: 显示编辑/删除菜单
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: GymatesTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${exercise.sets}组 × ${exercise.reps}次',
                      style: const TextStyle(
                        fontSize: 13,
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (exercise.muscleGroup != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    exercise.muscleGroup!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: GymatesTheme.primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            onAddExercise();
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            '添加训练动作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: GymatesTheme.primaryColor,
            side: BorderSide(color: GymatesTheme.primaryColor, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

