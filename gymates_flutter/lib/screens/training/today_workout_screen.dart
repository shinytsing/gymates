/// 📅 今日训练页面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/training_plan_model.dart';
import 'providers/training_provider.dart';
import 'widgets/exercise_card.dart';
import 'widgets/training_stat_card.dart';
import 'widgets/training_progress_bar.dart';
import 'training_plan_editor.dart';
import 'ai_coach_screen.dart';

class TodayWorkoutScreen extends StatefulWidget {
  const TodayWorkoutScreen({super.key});

  @override
  State<TodayWorkoutScreen> createState() => _TodayWorkoutScreenState();
}

class _TodayWorkoutScreenState extends State<TodayWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<TrainingProvider>();
    await Future.wait([
      provider.fetchTodayWorkout(),
      provider.fetchUserStats(),
    ]);
  }

  Future<void> _refresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('今日训练'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/training/history');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Consumer<TrainingProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingToday) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.todayError != null) {
              return _buildErrorView(provider.todayError!);
            }

            if (provider.todayWorkout == null) {
              return _buildEmptyState();
            }

            return _buildWorkoutView(provider.todayWorkout!);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            // 空状态图标
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '今日还没有训练计划',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '创建一个训练计划开始今天的训练吧!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // 创建训练计划按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToCreatePlan,
                icon: const Icon(Icons.add),
                label: const Text('创建训练计划'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // AI训练按钮
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToAICoach,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('AI智能训练'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.purple,
                  side: const BorderSide(color: Colors.purple),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // 用户统计
            Consumer<TrainingProvider>(
              builder: (context, provider, child) {
                if (provider.userStats == null) {
                  return const SizedBox.shrink();
                }

                final stats = provider.userStats!;
                return _buildUserStatsCard(stats);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutView(TodayWorkout workout) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日统计摘要
          TodayStatsSummary(
            caloriesBurned: _calculateBurnedCalories(workout),
            minutesTrained: _calculateMinutes(workout),
            exercisesCompleted: workout.exercises
                .where((e) => e.completedSets == e.totalSets)
                .length,
            totalExercises: workout.exercises.length,
          ),
          const SizedBox(height: 16),
          // 总体进度
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressBar(
              progress: workout.completionProgress / 100,
              height: 12,
              color: Colors.green,
              label: '总体进度',
              showPercentage: true,
            ),
          ),
          const SizedBox(height: 24),
          // 运动列表
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '训练项目',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!workout.isAllCompleted)
                  TextButton(
                    onPressed: _showAddExerciseDialog,
                    child: const Text('添加运动'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...workout.exercises.map((exercise) {
            return ExerciseProgressCard(
              exerciseName: exercise.planExercise.exercise.name,
              completedSets: exercise.completedSets,
              totalSets: exercise.totalSets,
              onStart: () => _startExercise(exercise),
            );
          }),
          const SizedBox(height: 24),
          // 完成按钮
          if (workout.isAllCompleted)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _completeWorkout,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('完成训练'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildUserStatsCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '我的训练统计',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '总训练',
                    '${stats['total_workouts'] ?? 0} 次',
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '总时长',
                    '${stats['total_minutes'] ?? 0} 分',
                    Icons.timer,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '总消耗',
                    '${stats['total_calories_burned'] ?? 0} 卡',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '连续',
                    '${stats['current_streak'] ?? 0} 天',
                    Icons.whatshot,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refresh,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  int _calculateBurnedCalories(TodayWorkout workout) {
    return workout.exercises.fold(0, (sum, exercise) {
      final completed = exercise.completedSets;
      final caloriesPerSet = exercise.planExercise.exercise.estimatedCalories;
      return sum + (completed * caloriesPerSet * exercise.planExercise.reps);
    });
  }

  int _calculateMinutes(TodayWorkout workout) {
    return workout.exercises.fold(0, (sum, exercise) {
      final completed = exercise.completedSets;
      final duration = exercise.planExercise.totalDuration ~/ exercise.totalSets;
      return sum + (completed * duration);
    }) ~/ 60;
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null) {
      final provider = context.read<TrainingProvider>();
      await provider.fetchTodayWorkout(date: date);
    }
  }

  void _navigateToCreatePlan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrainingPlanEditorScreen(),
      ),
    );

    if (result != null && result is String) {
      // 创建今日训练
      final provider = context.read<TrainingProvider>();
      await provider.createTodayWorkout(planId: result);
    }
  }

  void _navigateToAICoach() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AICoachScreen(),
      ),
    );
    _refresh();
  }

  void _showAddExerciseDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '选择运动',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Consumer<TrainingProvider>(
                    builder: (context, provider, child) {
                      if (provider.exercises.isEmpty) {
                        provider.fetchExercises();
                      }

                      if (provider.isLoadingExercises) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: provider.exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = provider.exercises[index];
                          return ExerciseCard(
                            exercise: exercise,
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: 添加运动到今日训练
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _startExercise(WorkoutExercise exercise) {
    Navigator.pushNamed(
      context,
      '/training/exercise-detail',
      arguments: exercise,
    );
  }

  void _completeWorkout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('完成训练'),
        content: const Text('确认完成今日训练吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = context.read<TrainingProvider>();
        await provider.completeWorkout();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 恭喜你完成今日训练!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('完成失败: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

