/// 🏋️ 实时训练指导页面
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/ai_training_service.dart';

class RealtimeTrainingScreen extends StatefulWidget {
  final TrainingExercise exercise;
  final int planId;
  final int userId;

  const RealtimeTrainingScreen({
    super.key,
    required this.exercise,
    required this.planId,
    required this.userId,
  });

  @override
  State<RealtimeTrainingScreen> createState() => _RealtimeTrainingScreenState();
}

class _RealtimeTrainingScreenState extends State<RealtimeTrainingScreen> {
  final AITrainingService _aiService = AITrainingService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  ExerciseGuidance? _guidance;
  bool _isLoading = true;
  
  // 训练状态
  int _currentSet = 1;
  int _currentRep = 0;
  bool _isTraining = false;
  bool _isResting = false;
  int _restTimeRemaining = 0;
  
  Timer? _timer;
  Timer? _restTimer;
  
  // 完成数据
  final List<int> _completedReps = [];
  final List<double> _usedWeights = [];
  final List<int> _restTimes = [];

  @override
  void initState() {
    super.initState();
    _loadGuidance();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadGuidance() async {
    try {
      final guidance = await _aiService.getExerciseGuidance(widget.exercise.id);
      setState(() {
        _guidance = guidance;
        _isLoading = false;
      });
      
      // 播放开始语音
      if (guidance.speechUrl != null) {
        _playAudio(guidance.speechUrl!);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载指导失败: $e')),
        );
      }
    }
  }

  Future<void> _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('播放音频失败: $e');
    }
  }

  void _startSet() {
    setState(() {
      _isTraining = true;
      _currentRep = 0;
    });
    
    // 倒计时提示
    _showCountdown();
  }

  void _showCountdown() {
    if (_guidance == null) return;
    
    int countdown = 3;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        _speak(_guidance!.countdownPrompts[3 - countdown]);
        countdown--;
      } else {
        timer.cancel();
        _speak('开始！');
        _startRepCounting();
      }
    });
  }

  void _startRepCounting() {
    // 自动计数或手动计数
    // 这里实现手动计数，实际可以接入传感器自动计数
  }

  void _completeRep() {
    setState(() {
      _currentRep++;
      
      if (_currentRep >= widget.exercise.reps) {
        _completeSet();
      } else {
        // 中途提示
        if (_currentRep == widget.exercise.reps ~/ 2) {
          _speak('还剩${widget.exercise.reps - _currentRep}次');
        }
        if (_currentRep == widget.exercise.reps - 1) {
          _speak('最后一次，加油！');
        }
      }
    });
  }

  void _completeSet() {
    _speak('完成！');
    
    setState(() {
      _isTraining = false;
      _completedReps.add(_currentRep);
      _usedWeights.add(widget.exercise.weight);
    });
    
    if (_currentSet < widget.exercise.sets) {
      _startRest();
    } else {
      _completeExercise();
    }
  }

  void _startRest() {
    setState(() {
      _isResting = true;
      _restTimeRemaining = widget.exercise.restSeconds;
    });
    
    _speak('休息${widget.exercise.restSeconds}秒');
    
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restTimeRemaining--;
        
        if (_restTimeRemaining == 30) {
          _speak('还剩30秒');
        } else if (_restTimeRemaining == 10) {
          _speak('还剩10秒');
        } else if (_restTimeRemaining == 0) {
          timer.cancel();
          _endRest();
        }
      });
    });
  }

  void _endRest() {
    _restTimes.add(widget.exercise.restSeconds);
    
    setState(() {
      _isResting = false;
      _currentSet++;
    });
    
    _speak('准备下一组');
  }

  void _completeExercise() {
    _speak('训练完成，做得很好！');
    
    // 返回结果
    Navigator.pop(context, {
      'completed_reps': _completedReps,
      'used_weights': _usedWeights,
      'rest_times': _restTimes,
    });
  }

  void _speak(String text) {
    // 显示文字提示
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.purple,
        ),
      );
    }
    
    // 播放语音（如果有）
    // 实际应用中应该调用TTS服务
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('加载中...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.exercise.name),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showGuidanceDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(child: _buildMainContent()),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _currentSet / widget.exercise.sets;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 $_currentSet / ${widget.exercise.sets} 组',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                '$_currentRep / ${widget.exercise.reps} 次',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isResting) {
      return _buildRestScreen();
    } else if (_isTraining) {
      return _buildTrainingScreen();
    } else {
      return _buildReadyScreen();
    }
  }

  Widget _buildReadyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 120, color: Colors.purple),
          const SizedBox(height: 32),
          Text(
            widget.exercise.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.exercise.sets} 组 × ${widget.exercise.reps} 次',
            style: const TextStyle(color: Colors.white70, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            '重量: ${widget.exercise.weight.toStringAsFixed(1)} kg',
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 48),
          if (_guidance != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _guidance!.guidanceText,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTrainingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '第 $_currentSet 组',
            style: const TextStyle(color: Colors.white70, fontSize: 24),
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 250,
                height: 250,
                child: CircularProgressIndicator(
                  value: _currentRep / widget.exercise.reps,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_currentRep',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/ ${widget.exercise.reps}',
                    style: const TextStyle(color: Colors.white70, fontSize: 32),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _completeRep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              '完成一次',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hotel, size: 80, color: Colors.orange),
          const SizedBox(height: 32),
          const Text(
            '休息中',
            style: TextStyle(color: Colors.white70, fontSize: 24),
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _restTimeRemaining / widget.exercise.restSeconds,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$_restTimeRemaining',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '秒',
                    style: TextStyle(color: Colors.white70, fontSize: 24),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () {
              _restTimer?.cancel();
              _endRest();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange, width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('跳过休息', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!_isTraining && !_isResting)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _startSet,
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始训练', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          if (_isTraining || _isResting) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _timer?.cancel();
                  _restTimer?.cancel();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.stop),
                label: const Text('结束训练'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showGuidanceDialog() {
    if (_guidance == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('动作指导'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_guidance!.guidanceText),
              const SizedBox(height: 16),
              const Text(
                '动作要点：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.exercise.description),
              if (widget.exercise.notes != null) ...[
                const SizedBox(height: 16),
                const Text(
                  '注意事项：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(widget.exercise.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

