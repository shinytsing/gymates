import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../../../services/training_voice_service.dart';
import '../models/workout.dart';
import '../models/record.dart' as training_record;
import '../subpages/training_summary_page.dart';
import '../models/session_result.dart';

/// 🏋️‍♀️ 训练执行页面 - WorkoutRunningPage
/// 
/// 显示当前训练进度、动作详情和操作按钮

class WorkoutRunningPage extends StatefulWidget {
  final TodayWorkoutPlan workoutPlan;

  const WorkoutRunningPage({
    super.key,
    required this.workoutPlan,
  });

  @override
  State<WorkoutRunningPage> createState() => _WorkoutRunningPageState();
}

class _WorkoutRunningPageState extends State<WorkoutRunningPage> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  final bool _isResting = false;
  bool _isCompleted = false;
  late TrainingVoiceService _voiceService;
  final bool _voiceEnabled = true;
  final List<SetRecord> _completedSets = [];
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _voiceService = TrainingVoiceService();
    _voiceService.initialize().then((_) {
      _startExerciseWithVoice();
    });
  }

  @override
  void dispose() {
    _voiceService.dispose();
    super.dispose();
  }

  void _startExerciseWithVoice() {
    if (!_voiceEnabled) return;
    
    final currentExercise = widget.workoutPlan.exercises[_currentExerciseIndex];
    _voiceService.speakExerciseGuide(
      currentExercise.name,
      currentExercise.sets,
      currentExercise.reps,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletedView();
    }
    
    if (_currentExerciseIndex >= widget.workoutPlan.exercises.length) {
      _isCompleted = true;
      return _buildCompletedView();
    }
    
    final currentExercise = widget.workoutPlan.exercises[_currentExerciseIndex];
    
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: GymatesTheme.lightTextPrimary),
          onPressed: () => _showExitDialog(),
        ),
        title: const Text(
          '训练中',
          style: TextStyle(
            color: GymatesTheme.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentExerciseIndex + 1}/${widget.workoutPlan.exercises.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 进度条
          _buildProgressBar(),
          
          // 动作信息
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildExerciseContent(currentExercise),
            ),
          ),
          
          // 操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildProgressBar() {
    final progress = (_currentExerciseIndex + (_currentSetIndex / currentExercise.sets)) / 
        widget.workoutPlan.exercises.length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '训练进度',
                style: TextStyle(
                  fontSize: 14,
                  color: GymatesTheme.lightTextSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
  
  Widget _buildExerciseContent(WorkoutExercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 动作卡片
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: GymatesTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: GymatesTheme.getCardShadow(false),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前动作',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildExerciseDetail('${exercise.sets}组', Icons.repeat),
                  const SizedBox(width: 16),
                  _buildExerciseDetail('${exercise.reps}次', Icons.fitness_center),
                  const SizedBox(width: 16),
                  _buildExerciseDetail('${exercise.restSeconds}秒', Icons.timer),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 组次信息
        Container(
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
                '当前组次',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(exercise.sets, (index) {
                  final isCurrent = index == _currentSetIndex;
                  final isCompleted = index < _currentSetIndex;
                  
                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green
                                : isCurrent
                                    ? GymatesTheme.primaryColor
                                    : const Color(0xFFF3F4F6),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check, color: Colors.white)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isCurrent ? Colors.white : GymatesTheme.lightTextSecondary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildExerciseDetail(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _pauseTraining,
              child: const Text('暂停'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _completeSet,
              icon: const Icon(Icons.check),
              label: const Text('完成'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GymatesTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompletedView() {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '训练完成！',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '恭喜你完成了今天的训练计划',
                style: TextStyle(
                  fontSize: 16,
                  color: GymatesTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    final record = training_record.WorkoutRecord(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      date: _startTime ?? DateTime.now(),
                      planId: widget.workoutPlan.id,
                      planTitle: widget.workoutPlan.title,
                      durationMinutes: _startTime != null 
                          ? DateTime.now().difference(_startTime!).inMinutes 
                          : 0,
                      calories: 0, // Calculate from exercises
                      totalExercises: widget.workoutPlan.exercises.length,
                      completedExercises: _completedSets.length,
                      aiSummary: '',
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrainingSummaryPage(
                          record: record,
                          completedSets: _completedSets,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymatesTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('查看总结'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _completeSet() {
    HapticFeedback.mediumImpact();
    
    setState(() {
      if (_currentSetIndex < currentExercise.sets - 1) {
        _currentSetIndex++;
      } else {
        if (_currentExerciseIndex < widget.workoutPlan.exercises.length - 1) {
          _currentExerciseIndex++;
          _currentSetIndex = 0;
        } else {
          _isCompleted = true;
        }
      }
    });
  }
  
  void _pauseTraining() {
    HapticFeedback.mediumImpact();
    // TODO: 实现暂停逻辑
    Navigator.pop(context);
  }
  
  void _showExitDialog() {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出训练'),
        content: const Text('确定要退出当前训练吗？进度将被保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回上一页
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GymatesTheme.primaryColor,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
  
  WorkoutExercise get currentExercise => widget.workoutPlan.exercises[_currentExerciseIndex];
}

