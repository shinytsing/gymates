import 'dart:async';
import 'package:flutter/material.dart';
import 'training_summary_page.dart';
import '../today_training_page.dart';

/// 💪 训练进行页面（二级页面）
/// 实时计时器、动作进度条、剩余组数、下一动作提示
class WorkoutRunningPage extends StatefulWidget {
  final List<TodayExercise> exercises;

  const WorkoutRunningPage({
    super.key,
    required this.exercises,
  });

  @override
  State<WorkoutRunningPage> createState() => _WorkoutRunningPageState();
}

class _WorkoutRunningPageState extends State<WorkoutRunningPage> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  int _restSeconds = 0;
  bool _isResting = false;
  Timer? _timer;

  TodayExercise get _currentExercise => widget.exercises[_currentExerciseIndex];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    _restSeconds = seconds;
    _isResting = true;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() {
          _restSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
      }
    });
  }

  void _completeSet() {
    setState(() {
      _currentSetIndex++;
      
      if (_currentSetIndex >= _currentExercise.sets) {
        // 完成当前动作的所有组数
        _currentSetIndex = 0;
        _currentExerciseIndex++;
        
        if (_currentExerciseIndex >= widget.exercises.length) {
          // 训练完成
          _completeWorkout();
        } else {
          _startRestTimer(_currentExercise.restSeconds);
        }
      } else {
        _startRestTimer(_currentExercise.restSeconds);
      }
    });
  }

  void _skipExercise() {
    setState(() {
      _currentExerciseIndex++;
      if (_currentExerciseIndex >= widget.exercises.length) {
        _completeWorkout();
      }
    });
  }

  void _completeWorkout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TrainingSummaryPage(
          exercises: widget.exercises,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentExerciseIndex >= widget.exercises.length) {
      return _buildCompletedView();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(
          '${_currentExerciseIndex + 1}/${widget.exercises.length}',
        ),
      ),
      body: Column(
        children: [
          // 进度条
          _buildProgressBar(),
          
          // 动作信息
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 动作名称
                  Text(
                    _currentExercise.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentExercise.muscleGroup,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 组数/次数
                  _buildSetRepsCard(),
                  
                  const SizedBox(height: 40),
                  
                  // 休息倒计时
                  if (_isResting) _buildRestTimer(),
                ],
              ),
            ),
          ),
          
          // 操作按钮
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _currentExerciseIndex / widget.exercises.length;
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: const Color(0xFF2A2A2A),
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
      minHeight: 4,
    );
  }

  Widget _buildSetRepsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '第 ${_currentSetIndex + 1} 组',
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${_currentExercise.reps} 次',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimer() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '休息时间',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_restSeconds 秒',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          top: BorderSide(
            color: Color(0xFF3A3A3A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _skipExercise,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                '跳过',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isResting ? null : _completeSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '完成组',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedView() {
    return const Scaffold(
      body: Center(
        child: Text(
          '训练完成！',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出训练'),
        content: const Text('确定要退出当前训练吗？进度将不会被保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              '退出',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

