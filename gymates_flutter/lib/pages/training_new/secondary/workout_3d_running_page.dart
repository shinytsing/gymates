import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../core/3d_components/index.dart';
import '../../../services/training_voice_service.dart';
import '../../training/models/workout.dart' hide WorkoutRecord;
import '../../training/models/record.dart';
import '../../training/models/session_result.dart';
import '../../training/subpages/training_summary_page.dart';

/// 🏋️ Apple Fitness+ Style Workout Running Page
/// 
/// Design Features:
/// - Immersive 3D interface
/// - 3D circular countdown timer
/// - 3D exercise card showcase
/// - 3D set completion animations
/// - Celebration animations on completion
/// - Frosted glass UI elements
/// - Smooth, natural transitions

class Workout3DRunningPage extends StatefulWidget {
  final TodayWorkoutPlan workoutPlan;

  const Workout3DRunningPage({
    super.key,
    required this.workoutPlan,
  });

  @override
  State<Workout3DRunningPage> createState() => _Workout3DRunningPageState();
}

class _Workout3DRunningPageState extends State<Workout3DRunningPage> 
    with TickerProviderStateMixin {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _isResting = false;
  bool _isCompleted = false;
  int _restTimeRemaining = 0;
  
  late TrainingVoiceService _voiceService;
  final bool _voiceEnabled = true;
  final List<SetRecord> _completedSets = [];
  DateTime? _startTime;
  
  // Animation controllers
  late AnimationController _cardEnterController;
  late AnimationController _timerController;
  late AnimationController _checkmarkController;
  late AnimationController _celebrationController;
  
  late Animation<double> _cardEnterAnimation;
  late Animation<double> _timerRotationAnimation;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _voiceService = TrainingVoiceService();
    _initAnimations();
    
    _voiceService.initialize().then((_) {
      _startExerciseWithVoice();
      _cardEnterController.forward();
    });
  }

  void _initAnimations() {
    // Card enter animation
    _cardEnterController = AnimationController(
      duration: AppleFitnessTheme.durationSlow,
      vsync: this,
    );
    _cardEnterAnimation = CurvedAnimation(
      parent: _cardEnterController,
      curve: Curves.easeOutCubic,
    );
    
    // Timer rotation animation
    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _timerRotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_timerController);
    
    // Checkmark animation
    _checkmarkController = AnimationController(
      duration: AppleFitnessTheme.durationNormal,
      vsync: this,
    );
    
    // Celebration animation
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _cardEnterController.dispose();
    _timerController.dispose();
    _checkmarkController.dispose();
    _celebrationController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  void _startExerciseWithVoice() {
    if (!_voiceEnabled || _currentExerciseIndex >= widget.workoutPlan.exercises.length) return;
    
    final currentExercise = widget.workoutPlan.exercises[_currentExerciseIndex];
    _voiceService.speakExerciseGuide(
      currentExercise.name,
      currentExercise.sets,
      currentExercise.reps,
    );
  }

  void _completeSet() async {
    HapticFeedback.mediumImpact();
    _checkmarkController.forward(from: 0);
    
    final currentExercise = widget.workoutPlan.exercises[_currentExerciseIndex];
    
    // Record completed set
    _completedSets.add(SetRecord(
      exerciseId: currentExercise.id,
      exerciseName: currentExercise.name,
      setNumber: _currentSetIndex + 1,
      reps: currentExercise.reps,
      weight: currentExercise.weight,
      duration: 0, // Duration will be calculated
      completedAt: DateTime.now(),
      quality: SetQuality.good,
    ));
    
    if (_currentSetIndex < currentExercise.sets - 1) {
      // More sets remaining
      setState(() {
        _currentSetIndex++;
        _isResting = true;
        _restTimeRemaining = 60; // 60 seconds rest
      });
      _startRestTimer();
    } else {
      // Exercise completed, move to next
      _nextExercise();
    }
  }

  void _startRestTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_isResting) return;
      setState(() {
        _restTimeRemaining--;
      });
      if (_restTimeRemaining > 0) {
        _startRestTimer();
      } else {
        setState(() {
          _isResting = false;
        });
      }
    });
  }

  void _nextExercise() async {
    if (_currentExerciseIndex < widget.workoutPlan.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSetIndex = 0;
      });
      _cardEnterController.forward(from: 0);
      _startExerciseWithVoice();
    } else {
      // Workout completed!
      setState(() {
        _isCompleted = true;
      });
      _celebrationController.forward();
      HapticFeedback.heavyImpact();
      
      // Show summary after delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        _navigateToSummary();
      }
    }
  }

  void _navigateToSummary() {
    final duration = DateTime.now().difference(_startTime!);
    final record = WorkoutRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _startTime!,
      planId: widget.workoutPlan.id,
      planTitle: widget.workoutPlan.title,
      durationMinutes: duration.inMinutes,
      calories: 0, // TODO: Calculate calories
      totalExercises: widget.workoutPlan.exercises.length,
      completedExercises: widget.workoutPlan.exercises.where((e) => e.isCompleted).length,
      aiSummary: '训练完成！',
    );
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TrainingSummaryPage(
          record: record,
          completedSets: _completedSets,
        ),
      ),
    );
  }

  void _showExitDialog() async {
    final shouldExit = await showAlertDialog3D(
      context: context,
      title: '确认退出',
      message: '您的训练进度将不会保存',
      confirmText: '退出',
      cancelText: '继续训练',
    );
    
    if (shouldExit == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletedView();
    }
    
    if (_currentExerciseIndex >= widget.workoutPlan.exercises.length) {
      return _buildCompletedView();
    }
    
    final currentExercise = widget.workoutPlan.exercises[_currentExerciseIndex];
    final progress = (_currentExerciseIndex + (_currentSetIndex / currentExercise.sets)) / 
        widget.workoutPlan.exercises.length;
    
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Gradient background
          _buildGradientBackground(),
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Progress indicator
                _buildProgressIndicator(progress),
                
                // Main exercise content
                Expanded(
                  child: _isResting
                      ? _buildRestView()
                      : _buildExerciseView(currentExercise),
                ),
                
                // Bottom action area
                _buildActionArea(currentExercise),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppleFitnessTheme.textPrimary),
        onPressed: _showExitDialog,
      ),
      title: Text(
        '训练中',
        style: AppleFitnessTheme.titleLarge,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppleFitnessTheme.backgroundSecondary,
                borderRadius: AppleFitnessTheme.radiusSmall,
              ),
              child: Text(
                '${_currentExerciseIndex + 1}/${widget.workoutPlan.exercises.length}',
                style: AppleFitnessTheme.labelMedium.copyWith(
                  color: AppleFitnessTheme.primaryBlue,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '整体进度',
                style: AppleFitnessTheme.bodyMedium.copyWith(
                  color: AppleFitnessTheme.textSecondary,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppleFitnessTheme.labelLarge.copyWith(
                  color: AppleFitnessTheme.primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: AppleFitnessTheme.spacingS),
          LinearProgress3D(
            value: progress,
            height: 8,
            gradient: AppleFitnessTheme.primaryGradient,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseView(WorkoutExercise exercise) {
    return FadeIn3D(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: Column(
          children: [
            // Exercise card with 3D effect
            _buildExerciseCard(exercise),
            
            SizedBox(height: AppleFitnessTheme.spacingXL),
            
            // Set indicators
            _buildSetIndicators(exercise),
            
            SizedBox(height: AppleFitnessTheme.spacingXL),
            
            // Exercise details
            _buildExerciseDetails(exercise),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise) {
    return AnimatedBuilder(
      animation: _cardEnterAnimation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(-0.1 * (1 - _cardEnterAnimation.value))
            ..translate(0.0, 100 * (1 - _cardEnterAnimation.value), 0.0),
          alignment: Alignment.center,
          child: Opacity(
            opacity: _cardEnterAnimation.value,
            child: child,
          ),
        );
      },
      child: Card3D(
        gradient: AppleFitnessTheme.workoutGradients['strength'],
        padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前动作',
              style: AppleFitnessTheme.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingS),
            Text(
              exercise.name,
              style: AppleFitnessTheme.displaySmall.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.repeat,
                  label: '${exercise.sets} 组',
                ),
                SizedBox(width: AppleFitnessTheme.spacingM),
                _buildInfoChip(
                  icon: Icons.fitness_center,
                  label: '${exercise.reps} 次',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppleFitnessTheme.radiusMedium,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppleFitnessTheme.labelMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetIndicators(WorkoutExercise exercise) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        exercise.sets,
        (index) => AnimatedBuilder(
          animation: _checkmarkController,
          builder: (context, child) {
            final isCompleted = index < _currentSetIndex;
            final isCurrent = index == _currentSetIndex;
            final scale = isCurrent && _checkmarkController.isAnimating
                ? 1.0 + (_checkmarkController.value * 0.3)
                : 1.0;
            
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isCompleted || isCurrent
                      ? AppleFitnessTheme.primaryGradient
                      : null,
                  color: isCompleted || isCurrent
                      ? null
                      : AppleFitnessTheme.backgroundSecondary,
                  boxShadow: isCompleted || isCurrent
                      ? AppleFitnessTheme.softGlow(
                          AppleFitnessTheme.primaryBlue,
                          intensity: 0.4,
                        )
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24,
                        )
                      : Text(
                          '${index + 1}',
                          style: AppleFitnessTheme.titleMedium.copyWith(
                            color: isCurrent
                                ? Colors.white
                                : AppleFitnessTheme.textTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExerciseDetails(WorkoutExercise exercise) {
    return Card3D(
      useFrostedGlass: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '动作要点',
            style: AppleFitnessTheme.titleMedium,
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          ...['保持正确姿势', '控制动作速度', '感受肌肉发力'].map((instruction) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppleFitnessTheme.primaryBlue,
                  ),
                ),
                Expanded(
                  child: Text(
                    instruction,
                    style: AppleFitnessTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRestView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '休息时间',
            style: AppleFitnessTheme.headlineMedium.copyWith(
              color: AppleFitnessTheme.textSecondary,
            ),
          ),
          SizedBox(height: AppleFitnessTheme.spacingXL),
          CircularProgress3D(
            value: 1 - (_restTimeRemaining / 60),
            size: 200,
            strokeWidth: 16,
            progressColor: AppleFitnessTheme.primaryBlue,
            centerWidget: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_restTimeRemaining',
                  style: AppleFitnessTheme.displayLarge.copyWith(
                    color: AppleFitnessTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '秒',
                  style: AppleFitnessTheme.bodyLarge.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppleFitnessTheme.spacingXXL),
          Button3D.secondary(
            text: '跳过休息',
            onPressed: () {
              setState(() {
                _isResting = false;
                _restTimeRemaining = 0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(WorkoutExercise exercise) {
    return Container(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isResting) ...[
              Button3D.primary(
                text: '完成本组',
                icon: Icons.check,
                size: Button3DSize.large,
                onPressed: _completeSet,
              ),
              SizedBox(height: AppleFitnessTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: Button3D.outline(
                      text: '跳过动作',
                      onPressed: _nextExercise,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedView() {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _celebrationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_celebrationController.value * 0.2),
                  child: Opacity(
                    opacity: 1.0 - (_celebrationController.value * 0.3),
                    child: child,
                  ),
                );
              },
              child: SuccessCheckmark3D(
                size: 120,
                color: AppleFitnessTheme.success,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingXXL),
            Text(
              '训练完成！',
              style: AppleFitnessTheme.displayMedium,
            ),
            SizedBox(height: AppleFitnessTheme.spacingM),
            Text(
              '太棒了！坚持就是胜利',
              style: AppleFitnessTheme.bodyLarge.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

