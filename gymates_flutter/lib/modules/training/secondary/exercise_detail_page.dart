import 'package:flutter/material.dart';
import '../../../models/exercise_library.dart';

/// 🏋️ 动作详情页面（二级页面）
/// 包含动作演示视频、正确姿势、发力肌群图示、AI语音讲解
class ExerciseDetailPage extends StatelessWidget {
  final ExerciseLibrary exercise;
  
  const ExerciseDetailPage({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          
          // 内容
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 动作名称和标签
                  Text(
                    exercise.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip(exercise.part),
                      _buildChip(exercise.levelText),
                      _buildChip(exercise.equipment),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 推荐参数
                  _buildSection(
                    title: '推荐参数',
                    child: Column(
                      children: [
                        _buildParameterRow('预计时长', '${exercise.estimatedDuration}秒'),
                        _buildParameterRow('预计消耗', '${exercise.estimatedCalories}卡路里'),
                        _buildParameterRow('器械', exercise.equipment),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 动作描述
                  if (exercise.description.isNotEmpty)
                    _buildSection(
                      title: '动作描述',
                      child: Text(
                        exercise.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.6,
                        ),
                      ),
                    ),
                  
                  if (exercise.description.isNotEmpty)
                    const SizedBox(height: 24),
                  
                  // 动作步骤
                  if (exercise.instructions.isNotEmpty)
                    _buildSection(
                      title: '动作步骤',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: exercise.instructions.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${entry.key + 1}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  if (exercise.instructions.isNotEmpty)
                    const SizedBox(height: 24),
                  
                  // 目标肌群
                  _buildSection(
                    title: '目标肌群',
                    child: Column(
                      children: [
                        _buildMuscleRow(exercise.part, 90),
                        // 如果有次要肌群且与主要肌群不同，则显示
                        if (exercise.muscleGroups.isNotEmpty && 
                            exercise.muscleGroups != exercise.part)
                          _buildMuscleRow(exercise.muscleGroups, 70),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 操作按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: 添加至今日训练
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('添加至今日训练'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6366F1),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildParameterRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuscleRow(String muscle, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                muscle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

