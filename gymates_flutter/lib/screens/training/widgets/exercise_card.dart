/// 🏋️ 运动卡片组件
library;

import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

/// 运动卡片 - 显示运动概要信息
class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool showFavorite;
  final Widget? trailing;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.onFavorite,
    this.showFavorite = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 缩略图
              _buildThumbnail(),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: _buildInfo(context),
              ),
              // 右侧操作
              if (trailing != null) trailing!
              else if (showFavorite) _buildFavoriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
        image: exercise.thumbnailUrl != null
            ? DecorationImage(
                image: NetworkImage(exercise.thumbnailUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: exercise.thumbnailUrl == null
          ? const Icon(Icons.fitness_center, size: 40, color: Colors.grey)
          : null,
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 名称
        Text(
          exercise.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // 肌肉群和难度
        Row(
          children: [
            _buildChip(
              _getMuscleGroupText(exercise.muscleGroup),
              _getMuscleGroupColor(exercise.muscleGroup),
            ),
            const SizedBox(width: 8),
            _buildChip(
              _getDifficultyText(exercise.difficulty),
              _getDifficultyColor(exercise.difficulty),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 器械 (如果有)
        if (exercise.equipment != null)
          Text(
            exercise.equipment!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        const SizedBox(height: 4),
        // 预估数据
        Row(
          children: [
            const Icon(Icons.local_fire_department, size: 14, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              '${exercise.estimatedCalories} 卡',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.timer, size: 14, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              '${exercise.estimatedDuration} 秒',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      icon: Icon(
        exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: exercise.isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: onFavorite,
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getMuscleGroupText(String muscleGroup) {
    const map = {
      'chest': '胸部',
      'back': '背部',
      'legs': '腿部',
      'shoulders': '肩部',
      'arms': '手臂',
      'abs': '腹部',
      'cardio': '有氧',
    };
    return map[muscleGroup] ?? muscleGroup;
  }

  Color _getMuscleGroupColor(String muscleGroup) {
    const map = {
      'chest': Colors.blue,
      'back': Colors.green,
      'legs': Colors.purple,
      'shoulders': Colors.orange,
      'arms': Colors.red,
      'abs': Colors.teal,
      'cardio': Colors.pink,
    };
    return map[muscleGroup] ?? Colors.grey;
  }

  String _getDifficultyText(String difficulty) {
    const map = {
      'beginner': '初级',
      'intermediate': '中级',
      'advanced': '高级',
    };
    return map[difficulty] ?? difficulty;
  }

  Color _getDifficultyColor(String difficulty) {
    const map = {
      'beginner': Colors.green,
      'intermediate': Colors.orange,
      'advanced': Colors.red,
    };
    return map[difficulty] ?? Colors.grey;
  }
}

/// 训练计划中的运动卡片 (带完成状态)
class PlanExerciseCard extends StatelessWidget {
  final PlanExercise planExercise;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlanExerciseCard({
    super.key,
    required this.planExercise,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 顺序编号
                  _buildOrderBadge(),
                  const SizedBox(width: 12),
                  // 运动名称
                  Expanded(
                    child: Text(
                      planExercise.exercise.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 操作按钮
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: onDelete,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // 训练参数
              _buildParameters(),
              const SizedBox(height: 8),
              // 预估数据
              _buildEstimates(),
              if (planExercise.notes != null) ...[
                const SizedBox(height: 8),
                Text(
                  planExercise.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          '${planExercise.order}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildParameters() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildParameter(Icons.repeat, '${planExercise.sets} 组'),
        _buildParameter(Icons.fitness_center, '${planExercise.reps} 次'),
        if (planExercise.weight != null)
          _buildParameter(Icons.monitor_weight, '${planExercise.weight} kg'),
        if (planExercise.duration != null)
          _buildParameter(Icons.timer, '${planExercise.duration} 秒'),
        _buildParameter(Icons.hourglass_empty, '休息 ${planExercise.restTime}s'),
      ],
    );
  }

  Widget _buildParameter(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildEstimates() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          Text(
            '${planExercise.totalCalories} 卡',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.timer, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            '${(planExercise.totalDuration / 60).ceil()} 分钟',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

