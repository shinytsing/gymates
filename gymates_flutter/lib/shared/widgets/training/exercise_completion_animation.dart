import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/models/mock_data.dart';

/// 🏋️‍♀️ 动作完成动画组件 - ExerciseCompletionAnimation
/// 
/// 基于Figma设计的动作完成动画效果
/// 包含进度可视化、完成状态、成就徽章等功能

class ExerciseCompletionAnimation extends StatefulWidget {
  final MockExercise exercise;
  final VoidCallback? onCompleted;
  final bool showProgress;

  const ExerciseCompletionAnimation({
    super.key,
    required this.exercise,
    this.onCompleted,
    this.showProgress = true,
  });

  @override
  State<ExerciseCompletionAnimation> createState() => _ExerciseCompletionAnimationState();
}

class _ExerciseCompletionAnimationState extends State<ExerciseCompletionAnimation>
    with TickerProviderStateMixin {
  late AnimationController _completionController;
  late AnimationController _progressController;
  late AnimationController _celebrationController;
  
  late Animation<double> _completionAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isCompleted = false;
  int _currentSet = 0;
  int _completedSets = 0;
  double _currentWeight = 0.0;
  int _currentReps = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeExerciseData();
  }

  void _initializeAnimations() {
    // 完成动画控制器
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 进度动画控制器
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // 庆祝动画控制器
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // 完成动画
    _completionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeOutCubic,
    ));

    // 进度动画
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    // 庆祝动画
    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    // 滑动动画
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeOutCubic,
    ));

    // 缩放动画
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _completionController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeExerciseData() {
    _currentSet = 1;
    _currentWeight = widget.exercise.weight;
    _currentReps = widget.exercise.reps;
  }

  @override
  void dispose() {
    _completionController.dispose();
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 动作信息头部
          _buildExerciseHeader(),
          
          const SizedBox(height: 16),
          
          // 进度可视化
          if (widget.showProgress) _buildProgressVisualization(),
          
          const SizedBox(height: 16),
          
          // 当前组信息
          _buildCurrentSetInfo(),
          
          const SizedBox(height: 16),
          
          // 操作按钮
          _buildActionButtons(),
          
          const SizedBox(height: 16),
          
          // 完成状态
          if (_isCompleted) _buildCompletionCelebration(),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Row(
      children: [
        // 动作图片
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(widget.exercise.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 动作信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.exercise.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.exercise.muscleGroup,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildInfoChip('${widget.exercise.sets}组', Icons.repeat),
                  const SizedBox(width: 8),
                  _buildInfoChip('${widget.exercise.reps}次', Icons.fitness_center),
                  const SizedBox(width: 8),
                  _buildInfoChip('${widget.exercise.weight}kg', Icons.scale),
                ],
              ),
            ],
          ),
        ),
        
        // 难度标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getDifficultyColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getDifficultyColor().withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            widget.exercise.difficulty,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getDifficultyColor(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressVisualization() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '训练进度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            Text(
              '$_completedSets / ${widget.exercise.sets}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // 进度条
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_completedSets / widget.exercise.sets) * _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // 组进度指示器
        Row(
          children: List.generate(widget.exercise.sets, (index) {
            final isCompleted = index < _completedSets;
            final isCurrent = index == _completedSets && !_isCompleted;
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < widget.exercise.sets - 1 ? 8 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? const Color(0xFF10B981)
                      : isCurrent 
                          ? const Color(0xFF6366F1)
                          : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCurrentSetInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
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
            '第 $_currentSet 组',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildSetInfoItem('重量', '${_currentWeight}kg', Icons.scale),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSetInfoItem('次数', '$_currentReps次', Icons.repeat),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSetInfoItem('休息', '${widget.exercise.restTime}秒', Icons.timer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // 完成组按钮
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isCompleted ? null : _completeSet,
            icon: const Icon(Icons.check),
            label: Text(_isCompleted ? '已完成' : '完成这组'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted 
                  ? const Color(0xFF10B981)
                  : const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 跳过按钮
        OutlinedButton.icon(
          onPressed: _isCompleted ? null : _skipSet,
          icon: const Icon(Icons.skip_next),
          label: const Text('跳过'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6B7280),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCelebration() {
    return AnimatedBuilder(
      animation: _celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.celebration,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '动作完成！',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '恭喜你完成了 ${widget.exercise.name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 成就统计
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAchievementStat('总重量', '${_currentWeight * widget.exercise.sets}kg'),
                      _buildAchievementStat('总次数', '${widget.exercise.reps * widget.exercise.sets}次'),
                      _buildAchievementStat('消耗', '${widget.exercise.calories ?? 50}卡'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (widget.exercise.difficulty) {
      case '初级':
        return const Color(0xFF10B981);
      case '中级':
        return const Color(0xFFF59E0B);
      case '高级':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _completeSet() {
    HapticFeedback.lightImpact();
    
    setState(() {
      _completedSets++;
      if (_completedSets >= widget.exercise.sets) {
        _isCompleted = true;
        _currentSet = widget.exercise.sets;
      } else {
        _currentSet++;
      }
    });
    
    // 开始动画
    _progressController.forward();
    
    if (_isCompleted) {
      _completionController.forward();
      _celebrationController.forward();
      
      // 延迟调用完成回调
      Future.delayed(const Duration(milliseconds: 1000), () {
        widget.onCompleted?.call();
      });
    }
  }

  void _skipSet() {
    HapticFeedback.lightImpact();
    
    setState(() {
      _completedSets++;
      if (_completedSets >= widget.exercise.sets) {
        _isCompleted = true;
        _currentSet = widget.exercise.sets;
      } else {
        _currentSet++;
      }
    });
    
    // 开始动画
    _progressController.forward();
    
    if (_isCompleted) {
      _completionController.forward();
      _celebrationController.forward();
      
      // 延迟调用完成回调
      Future.delayed(const Duration(milliseconds: 1000), () {
        widget.onCompleted?.call();
      });
    }
  }
}
