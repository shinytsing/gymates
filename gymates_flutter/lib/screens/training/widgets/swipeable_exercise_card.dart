/// 🔄 可滑动的运动卡片组件 (左滑右滑添加到训练计划)
library;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/exercise_model.dart';

/// 可滑动的运动卡片 - 支持视频预览和详细介绍
class SwipeableExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback? onSwipeLeft; // 左滑 - 跳过
  final VoidCallback? onSwipeRight; // 右滑 - 添加
  final VoidCallback? onTap;

  const SwipeableExerciseCard({
    super.key,
    required this.exercise,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.onTap,
  });

  @override
  State<SwipeableExerciseCard> createState() => _SwipeableExerciseCardState();
}

class _SwipeableExerciseCardState extends State<SwipeableExerciseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  double _dragStartX = 0;
  double _dragUpdateX = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _initVideo();
  }

  void _initVideo() {
    if (widget.exercise.videoUrl != null) {
      _videoController = VideoPlayerController.network(widget.exercise.videoUrl!)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController?.setLooping(true);
            _videoController?.play();
          }
        }).catchError((error) {
          debugPrint('视频加载失败: $error');
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragUpdateX = details.globalPosition.dx - _dragStartX;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final threshold = MediaQuery.of(context).size.width * 0.3;

    if (_dragUpdateX > threshold) {
      // 右滑 - 添加
      _animateCard(Offset(2.0, 0.0), () {
        widget.onSwipeRight?.call();
      });
    } else if (_dragUpdateX < -threshold) {
      // 左滑 - 跳过
      _animateCard(Offset(-2.0, 0.0), () {
        widget.onSwipeLeft?.call();
      });
    } else {
      // 回弹
      setState(() {
        _dragUpdateX = 0;
      });
    }
  }

  void _animateCard(Offset endOffset, VoidCallback onComplete) {
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward().then((_) {
      onComplete();
      _controller.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dragPercentage = _dragUpdateX / MediaQuery.of(context).size.width;
    final isSwipingRight = _dragUpdateX > 0;
    final isSwipingLeft = _dragUpdateX < 0;
    final opacity = (1.0 - dragPercentage.abs() * 2).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onTap: widget.onTap,
      child: Stack(
        children: [
          // 背景提示 - 左滑跳过
          if (isSwipingLeft)
            Positioned.fill(
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 30),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(dragPercentage.abs()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(dragPercentage.abs() * 2),
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '跳过',
                      style: TextStyle(
                        color: Colors.white.withOpacity(dragPercentage.abs() * 2),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 背景提示 - 右滑添加
          if (isSwipingRight)
            Positioned.fill(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 30),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(dragPercentage.abs()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: Colors.white.withOpacity(dragPercentage.abs() * 2),
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '添加',
                      style: TextStyle(
                        color: Colors.white.withOpacity(dragPercentage.abs() * 2),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 主卡片
          Transform.translate(
            offset: Offset(_dragUpdateX, 0),
            child: Transform.rotate(
              angle: dragPercentage * 0.1,
              child: Opacity(
                opacity: opacity,
                child: _buildCardContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频预览区域
            _buildVideoSection(),
            // 信息区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildInfoSection(),
              ),
            ),
            // 操作按钮
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isVideoInitialized && _videoController != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            )
          else if (widget.exercise.thumbnailUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                widget.exercise.thumbnailUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          else
            const Icon(Icons.fitness_center, size: 80, color: Colors.white54),
          
          // 播放/暂停按钮
          if (_isVideoInitialized)
            Positioned(
              bottom: 10,
              right: 10,
              child: IconButton(
                icon: Icon(
                  _videoController!.value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 名称
        Text(
          widget.exercise.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // 标签
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              _getMuscleGroupText(widget.exercise.muscleGroup),
              _getMuscleGroupColor(widget.exercise.muscleGroup),
            ),
            _buildChip(
              _getDifficultyText(widget.exercise.difficulty),
              _getDifficultyColor(widget.exercise.difficulty),
            ),
            if (widget.exercise.equipment != null)
              _buildChip(widget.exercise.equipment!, Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        // 描述
        Text(
          widget.exercise.description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        // 预估数据
        Row(
          children: [
            _buildStatBadge(
              Icons.local_fire_department,
              '${widget.exercise.estimatedCalories} 卡',
              Colors.orange,
            ),
            const SizedBox(width: 12),
            _buildStatBadge(
              Icons.timer,
              '${widget.exercise.estimatedDuration} 秒/组',
              Colors.blue,
            ),
          ],
        ),
        // 动作要领
        if (widget.exercise.instructions != null && widget.exercise.instructions!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            '动作要领',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.exercise.instructions!.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
        // 训练提示
        if (widget.exercise.tips != null && widget.exercise.tips!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            '训练提示',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.exercise.tips!.map((tip) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // 跳过按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onSwipeLeft,
              icon: const Icon(Icons.close),
              label: const Text('跳过'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 添加按钮
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: widget.onSwipeRight,
              icon: const Icon(Icons.add_circle),
              label: const Text('添加到计划'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
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

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getMuscleGroupText(String muscleGroup) {
    const map = {
      'chest': '胸部',
      'back': '背部',
      'legs': '腿部',
      'shoulders': '肩部',
      'arms': '手臂',
      'abs': '腹部',
      'cardio': '有氧',
    };
    return map[muscleGroup] ?? muscleGroup;
  }

  Color _getMuscleGroupColor(String muscleGroup) {
    const map = {
      'chest': Colors.blue,
      'back': Colors.green,
      'legs': Colors.purple,
      'shoulders': Colors.orange,
      'arms': Colors.red,
      'abs': Colors.teal,
      'cardio': Colors.pink,
    };
    return map[muscleGroup] ?? Colors.grey;
  }

  String _getDifficultyText(String difficulty) {
    const map = {
      'beginner': '初级',
      'intermediate': '中级',
      'advanced': '高级',
    };
    return map[difficulty] ?? difficulty;
  }

  Color _getDifficultyColor(String difficulty) {
    const map = {
      'beginner': Colors.green,
      'intermediate': Colors.orange,
      'advanced': Colors.red,
    };
    return map[difficulty] ?? Colors.grey;
  }
}

