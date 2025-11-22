import 'package:flutter/material.dart';
import '../training_new/secondary/exercise_library_page.dart';
import '../training_new/secondary/training_plan_3d_detail_page.dart';
import '../../modules/training/pages/today_page_3d.dart' as today_3d show TodayExercise;
import '../training_new/secondary/workout_running_page.dart';
import '../training_new/secondary/ai_training_page.dart';
import 'widgets/today_plan_card.dart';
import 'widgets/mode_selection_widget.dart';

/// 📅 今日训练页面（一级页面）
class TodayTrainingPage extends StatefulWidget {
  const TodayTrainingPage({super.key});

  @override
  State<TodayTrainingPage> createState() => _TodayTrainingPageState();
}

class _TodayTrainingPageState extends State<TodayTrainingPage> {
  String? _todayPlanId;
  final List<TodayExercise> _todayExercises = [];
  bool _isAIRecommended = false;

  @override
  void initState() {
    super.initState();
    _loadTodayPlan();
  }

  // 加载今日训练计划
  void _loadTodayPlan() {
    // TODO: 从后端或本地加载今日计划
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 模式选择：普通训练 vs AI教练
          ModeSelectionWidget(
            isAIMode: _isAIRecommended,
            onModeChange: (isAI) {
              setState(() {
                _isAIRecommended = isAI;
              });
              if (isAI) {
                _navigateToAITraining();
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          // 今日训练计划展示
          if (_todayPlanId != null)
            TodayPlanCard(
              planId: _todayPlanId!,
              exercises: _todayExercises,
              onStartWorkout: () => _startWorkout(),
              onEditPlan: () => _editPlan(),
            )
          else
            _buildEmptyState(),
          
          const SizedBox(height: 24),
          
          // 快速操作
          _buildQuickActions(),
          
          const SizedBox(height: 24),
          
          // 推荐动作
          _buildRecommendedExercises(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 40,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有安排今日训练',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '选择动作或让AI为你推荐',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToExerciseLibrary(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '选择动作',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigateToAITraining(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'AI教练',
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.fitness_center,
                title: '挑选动作',
                color: const Color(0xFF6366F1),
                onTap: () => _navigateToExerciseLibrary(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.auto_awesome,
                title: 'AI推荐',
                color: const Color(0xFF8B5CF6),
                onTap: () => _navigateToAITraining(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedExercises() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '推荐动作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () => _navigateToExerciseLibrary(),
              child: const Text('查看全部'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // TODO: 加载推荐动作列表
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 40,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '胸肌训练',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '中级 • 45分钟',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 导航方法
  void _navigateToAITraining() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AITrainingPage(),
      ),
    );
  }

  void _navigateToExerciseLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseLibraryPage(),
      ),
    );
  }

  void _startWorkout() {
    if (_todayExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先选择训练动作'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutRunningPage(
          exercises: _todayExercises,
        ),
      ),
    );
  }

  void _editPlan() {
    if (_todayPlanId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingPlan3DDetailPage(
          planId: _todayPlanId!,
          exercises: _todayExercises.map((e) => today_3d.TodayExercise(
            name: e.name,
            sets: e.sets,
            reps: e.reps,
            muscleGroup: e.muscleGroup,
          )).toList(),
        ),
      ),
    );
  }
}

/// 今日训练动作数据模型
class TodayExercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String muscleGroup;
  final bool isCompleted;

  TodayExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.muscleGroup,
    this.isCompleted = false,
  });
}

