/// 📈 训练进度条组件
library;

import 'package:flutter/material.dart';

/// 圆形进度指示器
class CircularProgressIndicator extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;
  final Widget? child;

  const CircularProgressIndicator({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆环
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                backgroundColor.withOpacity(0.3),
              ),
            ),
          ),
          // 进度圆环
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // 中心内容
          if (child != null) child!,
        ],
      ),
    );
  }
}

/// 线性进度条
class LinearProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double height;
  final Color color;
  final Color backgroundColor;
  final String? label;
  final bool showPercentage;

  const LinearProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: backgroundColor.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

/// 运动完成进度卡片
class ExerciseProgressCard extends StatelessWidget {
  final String exerciseName;
  final int completedSets;
  final int totalSets;
  final VoidCallback? onStart;

  const ExerciseProgressCard({
    super.key,
    required this.exerciseName,
    required this.completedSets,
    required this.totalSets,
    this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSets > 0 ? completedSets / totalSets : 0.0;
    final isCompleted = completedSets == totalSets;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 完成状态图标
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.fitness_center,
                    color: isCompleted ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                // 运动名称和进度
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exerciseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedSets / $totalSets 组',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 开始按钮
                if (!isCompleted && onStart != null)
                  ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('开始'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // 进度条
            LinearProgressBar(
              progress: progress,
              height: 6,
              color: isCompleted ? Colors.green : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

/// 训练会话总进度
class WorkoutSessionProgress extends StatelessWidget {
  final int completedExercises;
  final int totalExercises;
  final int minutesElapsed;
  final int caloriesBurned;

  const WorkoutSessionProgress({
    super.key,
    required this.completedExercises,
    required this.totalExercises,
    required this.minutesElapsed,
    required this.caloriesBurned,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalExercises > 0
        ? completedExercises / totalExercises
        : 0.0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[400]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Text(
              '训练进度',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              progress: progress,
              size: 120,
              strokeWidth: 12,
              color: Colors.white,
              backgroundColor: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$completedExercises/$totalExercises',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.timer,
                  '$minutesElapsed 分钟',
                ),
                _buildStatItem(
                  Icons.local_fire_department,
                  '$caloriesBurned 卡',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 组进度指示器
class SetProgressIndicator extends StatelessWidget {
  final int currentSet;
  final int totalSets;
  final List<bool> completedSets;

  const SetProgressIndicator({
    super.key,
    required this.currentSet,
    required this.totalSets,
    required this.completedSets,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSets, (index) {
        final isCompleted = index < completedSets.length && completedSets[index];
        final isCurrent = index == currentSet - 1;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 32 : 24,
          height: isCurrent ? 32 : 24,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isCurrent
                    ? Colors.blue
                    : Colors.grey[300],
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: isCurrent ? 14 : 12,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

