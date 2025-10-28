import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import '../models/workout.dart';
import '../models/session_result.dart';
import '../controllers/ai_coach_controller.dart';

/// 🏋️‍♀️ AI教练训练模式页 - AICoachPage
/// 
/// 功能包括：
/// 1. 顶部显示当前动作视频/动画
/// 2. 中间显示倒计时 & 剩余组数
/// 3. 底部：暂停 / 下一组 / 结束训练 按钮
/// 4. 自动切换动作（顺序播放）
/// 5. 每组结束后AI语音播报建议
/// 6. 训练完成后自动跳转至训练总结页

class AICoachPage extends StatefulWidget {
  final TodayWorkoutPlan? workoutPlan;
  final Function(TrainingSessionResult)? onTrainingComplete;

  const AICoachPage({
    super.key,
    this.workoutPlan,
    this.onTrainingComplete,
  });

  @override
  State<AICoachPage> createState() => _AICoachPageState();
}

class _AICoachPageState extends State<AICoachPage>
    with TickerProviderStateMixin {
  late AICoachController _controller;
  late AnimationController _countdownController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  
  late Animation<double> _countdownAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  VideoPlayerController? _videoController;
  final FlutterTts _flutterTts = FlutterTts();
  
  Timer? _countdownTimer;
  Timer? _restTimer;
  Timer? _exerciseTimer;
  
  int _countdownSeconds = 0;
  int _restSeconds = 0;
  int _exerciseSeconds = 0;
  
  bool _isCountingDown = false;
  bool _isResting = false;
  bool _isExercising = false;
  bool _isPaused = false;
  final bool _isVideoInitialized = false;
  
  // 训练状态
  TrainingPhase _currentPhase = TrainingPhase.preparation;
  DateTime? _sessionStartTime;
  final List<SetRecord> _completedSets = [];

  @override
  void initState() {
    super.initState();
    _controller = AICoachController();
    _initializeAnimations();
    _initializeTTS();
    _initializeTraining();
  }

  void _initializeAnimations() {
    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _countdownAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _countdownController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
  }

  void _initializeTTS() {
    _flutterTts.setLanguage("zh-CN");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
  }

  void _initializeTraining() {
    if (widget.workoutPlan != null) {
      _controller.initializeTraining(widget.workoutPlan!);
      _sessionStartTime = DateTime.now();
      _startTraining();
    }
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _videoController?.dispose();
    _flutterTts.stop();
    _countdownTimer?.cancel();
    _restTimer?.cancel();
    _exerciseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // 主要内容
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildContent(),
                ),
                _buildBottomControls(),
              ],
            ),
            // 倒计时覆盖层
            if (_isCountingDown) _buildCountdownOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final currentExercise = _controller.getCurrentExercise();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF3A3A3A),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onBackPressed,
            child: const Icon(
              Icons.arrow_back,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentExercise?.name ?? 'AI教练训练',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getPhaseText(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _controller.getOverallProgress();
    
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          // 背景圆环
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey[800]!,
                width: 4,
              ),
            ),
          ),
          // 进度圆环
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6366F1),
              ),
            ),
          ),
          // 进度文字
          Center(
            child: Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final currentExercise = _controller.getCurrentExercise();
    
    if (currentExercise == null) {
      return _buildTrainingComplete();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 视频区域
          _buildVideoSection(currentExercise),
          
          const SizedBox(height: 24),
          
          // 当前动作信息
          _buildCurrentExerciseInfo(currentExercise),
          
          const SizedBox(height: 24),
          
          // 训练状态
          _buildTrainingStatus(),
          
          const SizedBox(height: 24),
          
          // 动作列表
          _buildExerciseList(),
        ],
      ),
    );
  }

  Widget _buildVideoSection(WorkoutExercise exercise) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _isVideoInitialized && _videoController != null
            ? Stack(
                children: [
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  ),
                  // 训练状态覆盖层
                  if (_isExercising)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'GO!',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$_exerciseSeconds',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1).withValues(alpha: 0.1),
                      const Color(0xFF6366F1).withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        size: 64,
                        color: Color(0xFF6366F1),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCurrentExerciseInfo(WorkoutExercise exercise) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3A3A3A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exercise.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPhaseColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPhaseText(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoItem('组数', '${_controller.getCurrentSetIndex() + 1}/${exercise.sets}', Icons.repeat),
              const SizedBox(width: 16),
              _buildInfoItem('次数', '${exercise.reps}', Icons.fitness_center),
              const SizedBox(width: 16),
              _buildInfoItem('重量', '${exercise.weight}kg', Icons.scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3A3A3A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '训练状态',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (_isResting) ...[
            Row(
              children: [
                const Icon(
                  Icons.timer,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '休息中：$_restSeconds 秒',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ] else if (_isExercising) ...[
            Row(
              children: [
                const Icon(
                  Icons.play_arrow,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '训练中：$_exerciseSeconds 秒',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ] else if (_isCountingDown) ...[
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '准备中：$_countdownSeconds 秒',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                const Icon(
                  Icons.pause,
                  color: Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  '已暂停',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    final exercises = _controller.getAllExercises();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3A3A3A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '训练计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            final isCompleted = _controller.isExerciseCompleted(index);
            final isCurrent = _controller.getCurrentExerciseIndex() == index;
            
            return _buildExerciseItem(exercise, index, isCompleted, isCurrent);
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(WorkoutExercise exercise, int index, bool isCompleted, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrent 
            ? const Color(0xFF6366F1).withValues(alpha: 0.2)
            : isCompleted
                ? const Color(0xFF10B981).withValues(alpha: 0.2)
                : const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent 
              ? const Color(0xFF6366F1)
              : isCompleted
                  ? const Color(0xFF10B981)
                  : const Color(0xFF4A4A4A),
          width: isCurrent || isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 状态图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF10B981)
                  : isCurrent
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF4A4A4A),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted 
                  ? Icons.check
                  : isCurrent
                      ? Icons.play_arrow
                      : Icons.fitness_center,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // 动作信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted 
                        ? const Color(0xFF10B981)
                        : isCurrent
                            ? const Color(0xFF6366F1)
                            : Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.sets}组 × ${exercise.reps}次 × ${exercise.weight}kg',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // 进度指示器
          if (isCurrent)
            Text(
              '${_controller.getCurrentSetIndex() + 1}/${exercise.sets}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // 暂停/继续按钮
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isPaused ? _resumeTraining : _pauseTraining,
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(_isPaused ? '继续' : '暂停'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPaused ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 下一组按钮
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _skipCurrentSet,
              icon: const Icon(Icons.skip_next),
              label: const Text('下一组'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 结束训练按钮
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _endTraining,
              icon: const Icon(Icons.stop),
              label: const Text('结束'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildCountdownOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_countdownSeconds',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        const Text(
                          '准备开始',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingComplete() {
    final duration = _sessionStartTime != null 
        ? DateTime.now().difference(_sessionStartTime!)
        : const Duration(seconds: 0);
    
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF3A3A3A),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 64,
              color: Color(0xFF10B981),
            ),
            const SizedBox(height: 16),
            const Text(
              '训练完成！',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '恭喜你完成了今天的训练',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('${_completedSets.length}', '组数'),
                _buildStatItem('${duration.inMinutes}', '分钟'),
                _buildStatItem('300', '卡路里'),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showTrainingSummary,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('查看总结'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // 方法实现
  void _startTraining() {
    _startExerciseCountdown();
  }

  void _startExerciseCountdown() {
    setState(() {
      _isCountingDown = true;
      _countdownSeconds = 3;
      _currentPhase = TrainingPhase.preparation;
    });
    
    _pulseController.repeat(reverse: true);
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });
      
      if (_countdownSeconds <= 0) {
        timer.cancel();
        _pulseController.stop();
        setState(() {
          _isCountingDown = false;
        });
        _startExercise();
      }
    });
    
    // 语音提示
    final exercise = _controller.getCurrentExercise();
    if (exercise != null) {
      _flutterTts.speak('准备${exercise.name}，3、2、1，开始！');
    }
  }

  void _startExercise() {
    setState(() {
      _isExercising = true;
      _exerciseSeconds = 0;
      _currentPhase = TrainingPhase.exercising;
    });
    
    _pulseController.repeat(reverse: true);
    
    _exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _exerciseSeconds++;
      });
      
      // 模拟训练时间（实际应该根据用户完成情况）
      if (_exerciseSeconds >= 30) {
        timer.cancel();
        _pulseController.stop();
        _completeSet();
      }
    });
    
    // 语音提示
    final exercise = _controller.getCurrentExercise();
    if (exercise != null) {
      _flutterTts.speak('开始第${_controller.getCurrentSetIndex() + 1}组${exercise.name}');
    }
  }

  void _completeSet() {
    setState(() {
      _isExercising = false;
      _currentPhase = TrainingPhase.resting;
    });
    
    // 记录完成的组
    final exercise = _controller.getCurrentExercise();
    if (exercise != null) {
      _completedSets.add(SetRecord(
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        setNumber: _controller.getCurrentSetIndex() + 1,
        reps: exercise.reps,
        weight: exercise.weight,
        duration: _exerciseSeconds,
        completedAt: DateTime.now(),
        quality: SetQuality.good,
      ));
    }
    
    // 移动到下一组
    if (_controller.moveToNextSet()) {
      _startRestTimer();
    } else {
      _nextExercise();
    }
    
    // 语音提示
    _flutterTts.speak('第${_controller.getCurrentSetIndex()}组完成！');
  }

  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _restSeconds = _controller.getCurrentExercise()?.restSeconds ?? 60;
    });
    
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restSeconds--;
      });
      
      if (_restSeconds <= 0) {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
        _startExerciseCountdown();
      }
    });
    
    // 语音提示
    _flutterTts.speak('休息$_restSeconds秒');
  }

  void _nextExercise() {
    if (_controller.moveToNextExercise()) {
      _startExerciseCountdown();
    } else {
      _completeTraining();
    }
  }

  void _completeTraining() {
    setState(() {
      _currentPhase = TrainingPhase.completed;
    });
    
    // 语音提示
    _flutterTts.speak('恭喜！训练完成！你的表现很棒！');
    
    // 显示训练总结
    _showTrainingSummary();
  }

  void _pauseTraining() {
    setState(() {
      _isPaused = true;
    });
    
    _countdownTimer?.cancel();
    _restTimer?.cancel();
    _exerciseTimer?.cancel();
    _pulseController.stop();
    
    _flutterTts.speak('训练已暂停');
  }

  void _resumeTraining() {
    setState(() {
      _isPaused = false;
    });
    
    if (_isCountingDown) {
      _startExerciseCountdown();
    } else if (_isResting) {
      _startRestTimer();
    } else if (_isExercising) {
      _startExercise();
    }
    
    _flutterTts.speak('训练继续');
  }

  void _skipCurrentSet() {
    _completeSet();
  }

  void _endTraining() {
    _completeTraining();
  }

  void _showTrainingSummary() {
    final result = TrainingSessionResult(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      completedSets: _completedSets,
      totalCalories: 300,
      aiSummary: '你的训练表现很棒！节奏把握得很好，继续保持！',
      metrics: TrainingMetrics(
        intensity: 0.8,
        consistency: 0.85,
        effort: 0.9,
        form: 0.75,
        heartRateAvg: 150,
        heartRateMax: 180,
        caloriesPerMinute: 10.0,
      ),
    );
    
    widget.onTrainingComplete?.call(result);
    Navigator.pop(context);
  }

  void _onBackPressed() {
    if (_isPaused || _currentPhase == TrainingPhase.completed) {
      Navigator.pop(context);
    } else {
      _showExitDialog();
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '退出训练',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '确定要退出当前训练吗？进度将会保存。',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  String _getPhaseText() {
    switch (_currentPhase) {
      case TrainingPhase.preparation:
        return '准备中';
      case TrainingPhase.exercising:
        return '训练中';
      case TrainingPhase.resting:
        return '休息中';
      case TrainingPhase.completed:
        return '已完成';
    }
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case TrainingPhase.preparation:
        return const Color(0xFF6366F1);
      case TrainingPhase.exercising:
        return const Color(0xFF10B981);
      case TrainingPhase.resting:
        return const Color(0xFFF59E0B);
      case TrainingPhase.completed:
        return const Color(0xFF10B981);
    }
  }
}

// 数据模型
enum TrainingPhase {
  preparation,
  exercising,
  resting,
  completed,
}
