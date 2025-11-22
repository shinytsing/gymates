import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../../../widgets/training/exercise_video_player.dart';
import '../models/workout.dart';

/// 🎯 动作详情页 - WorkoutDetailPage
/// 
/// 展示训练动作的详细信息：视频/GIF、动作要点、注意事项

class WorkoutDetailPage extends StatelessWidget {
  final WorkoutExercise exercise;

  const WorkoutDetailPage({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoSection(context),
                  const SizedBox(height: 24),
                  _buildMuscleGroupDiagram(),
                  const SizedBox(height: 24),
                  _buildExerciseInfo(),
                  const SizedBox(height: 24),
                  _buildInstructions(),
                  const SizedBox(height: 24),
                  _buildTips(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF6366F1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          exercise.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.fitness_center,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildVideoSection(BuildContext context) {
    // 如果有视频URL，使用视频播放器
    if (exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty) {
      return Column(
        children: [
          ExerciseVideoPlayer(
            videoUrl: exercise.videoUrl,
            title: exercise.name,
          ),
          const SizedBox(height: 12),
          _buildAudioGuideButton(context),
        ],
      );
    }

    // 否则使用GIF或占位符
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: exercise.gifUrl != null && exercise.gifUrl!.isNotEmpty
                  ? Image.network(
                      exercise.gifUrl!,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 60,
                            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 60,
                        color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioGuideButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showAudioGuideDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.volume_up,
              size: 20,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI语音讲解',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GymatesTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('AI语音讲解'),
        content: Text('正在为您讲解 ${exercise.name} 的正确做法...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMuscleGroupDiagram() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.accessibility, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 8),
              const Text(
                '发力肌群',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.accessibility_new,
                    size: 60,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getMuscleGroupDisplay(exercise.muscleGroup ?? '全身'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: GymatesTheme.lightTextPrimary,
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
  
  String _getMuscleGroupDisplay(String muscleGroup) {
    final mappings = {
      'chest': '胸部',
      'back': '背部',
      'legs': '腿部',
      'shoulders': '肩部',
      'arms': '手臂',
      'core': '核心',
      'full': '全身',
    };
    return mappings[muscleGroup.toLowerCase()] ?? muscleGroup;
  }

  Widget _buildExerciseInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '训练参数',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('目标组数', '${exercise.sets}组'),
          _buildInfoRow('每组次数', '${exercise.reps}次'),
          _buildInfoRow('目标重量', exercise.weight > 0 ? '${exercise.weight}kg' : '自体重'),
          _buildInfoRow('休息时间', '${exercise.restSeconds}秒'),
          if (exercise.muscleGroup != null)
            _buildInfoRow('目标肌群', exercise.muscleGroup!),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notes, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 8),
              Text(
                '动作要点',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionItem('1. 保持身体挺直，双脚与肩同宽'),
          _buildInstructionItem('2. 双臂伸直，手掌与肩同宽'),
          _buildInstructionItem('3. 身体下沉至胸部几乎触及地面'),
          _buildInstructionItem('4. 用胸部力量推起至初始位置'),
        ],
      ),
    );
  }
  
  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: GymatesTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.pink.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                '注意事项',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '• 保持呼吸顺畅，不要憋气\n• 动作要缓慢可控，避免受伤\n• 如果感到疼痛请立即停止',
            style: TextStyle(
              fontSize: 14,
              color: GymatesTheme.lightTextPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
