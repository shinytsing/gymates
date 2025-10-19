import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AITrainingPage extends StatefulWidget {
  final int userId;

  const AITrainingPage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _AITrainingPageState createState() => _AITrainingPageState();
}

class _AITrainingPageState extends State<AITrainingPage>
    with TickerProviderStateMixin {
  // 数据状态
  AITrainingRecommendation? _recommendation;
  bool _isLoading = true;
  String? _errorMessage;
  List<ChatMessage> _chatMessages = [];
  bool _isChatOpen = false;
  bool _isVoiceEnabled = true;
  bool _isTrainingMode = false;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _restTimeRemaining = 0;
  TrainingState _trainingState = TrainingState.idle;

  // 动画控制器
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late AnimationController _countdownController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _countdownAnimation;

  // TTS
  FlutterTts? _flutterTts;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTTS();
    _loadAIRecommendation();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _countdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _countdownController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializeTTS() async {
    _flutterTts = FlutterTts();
    await _flutterTts?.setLanguage("zh-CN");
    await _flutterTts?.setSpeechRate(0.5);
    await _flutterTts?.setVolume(1.0);
    await _flutterTts?.setPitch(1.0);

    _flutterTts?.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });

    _flutterTts?.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts?.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _loadAIRecommendation() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/training/ai/recommend?user_id=${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _recommendation = AITrainingRecommendation.fromJson(data['data']);
            _isLoading = false;
          });
          _addWelcomeMessage();
        } else {
          throw Exception(data['message'] ?? '获取推荐失败');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _addWelcomeMessage() {
    if (_recommendation != null) {
      final message = ChatMessage(
        text: '你好！我是你的AI健身教练。今天为你推荐了${_recommendation!.exercises.length}个训练动作，让我们开始吧！',
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _chatMessages.add(message);
      });
      _speakText(message.text);
    }
  }

  Future<void> _speakText(String text) async {
    if (_isVoiceEnabled && _flutterTts != null) {
      await _flutterTts!.speak(text);
    }
  }

  Future<void> _saveToMyPlan() async {
    if (_recommendation == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/training/plan/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'plan': _recommendation!.exercises.map((exercise) => {
            'day': 'Monday',
            'parts': [{
              'part_name': exercise.part,
              'exercises': [{
                'name': exercise.name,
                'sets': exercise.sets,
                'reps': exercise.reps,
                'weight': exercise.weight,
                'rest_seconds': exercise.restSeconds,
                'notes': exercise.notes,
              }]
            }]
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('训练计划已保存到我的计划')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  Future<void> _regenerateRecommendation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _loadAIRecommendation();
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
    });
    if (_isChatOpen) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  void _startTraining() {
    if (_recommendation == null || _recommendation!.exercises.isEmpty) return;
    
    setState(() {
      _isTrainingMode = true;
      _currentExerciseIndex = 0;
      _currentSet = 1;
      _trainingState = TrainingState.active;
    });
    
    _startExercise();
  }

  void _startExercise() {
    if (_currentExerciseIndex >= _recommendation!.exercises.length) {
      _finishTraining();
      return;
    }
    
    final exercise = _recommendation!.exercises[_currentExerciseIndex];
    _speakText('接下来进行${exercise.name}，${exercise.sets}组${exercise.reps}次，建议重量${exercise.weight}公斤。准备好了吗？');
    
    setState(() {
      _trainingState = TrainingState.active;
    });
  }

  void _startSet() {
    final exercise = _recommendation!.exercises[_currentExerciseIndex];
    _speakText('第${_currentSet}组开始，3，2，1，开始！');
    
    setState(() {
      _trainingState = TrainingState.active;
    });
  }

  void _completeSet() {
    final exercise = _recommendation!.exercises[_currentExerciseIndex];
    
    if (_currentSet < exercise.sets) {
      setState(() {
        _currentSet++;
        _restTimeRemaining = exercise.restSeconds;
        _trainingState = TrainingState.resting;
      });
      _startRestTimer();
    } else {
      _nextExercise();
    }
  }

  void _startRestTimer() {
    if (_restTimeRemaining <= 0) {
      _startSet();
      return;
    }
    
    _speakText('休息${_restTimeRemaining}秒');
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restTimeRemaining--;
      });
      
      if (_restTimeRemaining <= 0) {
        timer.cancel();
        _startSet();
      } else if (_restTimeRemaining <= 10) {
        _speakText('${_restTimeRemaining}秒');
      }
    });
  }

  void _nextExercise() {
    setState(() {
      _currentExerciseIndex++;
      _currentSet = 1;
    });
    
    if (_currentExerciseIndex < _recommendation!.exercises.length) {
      _startExercise();
    } else {
      _finishTraining();
    }
  }

  void _finishTraining() {
    _speakText('今天的训练结束，完成度90%，很棒！别忘了拉伸哦。');
    
    setState(() {
      _isTrainingMode = false;
      _trainingState = TrainingState.finished;
    });
    
    _saveTrainingSession();
  }

  Future<void> _saveTrainingSession() async {
    if (_recommendation == null) return;
    
    try {
      final completedExercises = _recommendation!.exercises.map((exercise) => {
        'name': exercise.name,
        'sets_done': exercise.sets,
      }).toList();
      
      await http.post(
        Uri.parse('http://localhost:8080/api/training/ai/session'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'date': DateTime.now().toIso8601String().split('T')[0],
          'plan_id': 1,
          'completed_exercises': completedExercises,
        }),
      );
    } catch (e) {
      print('保存训练会话失败: $e');
    }
  }

  Future<void> _sendChatMessage(String message) async {
    final userMessage = ChatMessage(
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    setState(() {
      _chatMessages.add(userMessage);
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/training/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': widget.userId,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final aiMessage = ChatMessage(
            text: data['data']['reply'],
            isUser: false,
            timestamp: DateTime.now(),
            speechUrl: data['data']['speech_url'],
          );
          setState(() {
            _chatMessages.add(aiMessage);
          });
          _speakText(aiMessage.text);
        }
      }
    } catch (e) {
      final errorMessage = ChatMessage(
        text: '抱歉，我现在无法回答你的问题。请稍后再试。',
        isUser: false,
        timestamp: DateTime.now(),
      );
      setState(() {
        _chatMessages.add(errorMessage);
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _countdownController.dispose();
    _flutterTts?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 主内容
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _errorMessage != null
                          ? _buildErrorState()
                          : _isTrainingMode
                              ? _buildTrainingMode()
                              : _buildRecommendationContent(),
                ),
              ],
            ),
            // AI聊天浮层
            if (_isChatOpen) _buildChatOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D1B69), Color(0xFF1A1A1A)],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI 智能训练',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _isVoiceEnabled = !_isVoiceEnabled),
                    icon: Icon(
                      _isVoiceEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _isVoiceEnabled ? Colors.blue : Colors.grey,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleChat,
                    icon: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isChatOpen ? 1.0 : _pulseAnimation.value,
                          child: const Icon(
                            Icons.chat,
                            color: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_recommendation != null) _buildOverview(),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewItem('目标', _recommendation!.overview.goal),
              _buildOverviewItem('类型', _recommendation!.overview.trainingType),
              _buildOverviewItem('频率', '${_recommendation!.overview.frequency}次/周'),
              _buildOverviewItem('完成率', '${(_recommendation!.overview.completionRate * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _regenerateRecommendation,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重新生成'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saveToMyPlan,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('保存计划'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _startTraining,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: const Text('开始训练'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'AI正在为你生成训练计划...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            '加载失败',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '未知错误',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadAIRecommendation,
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _recommendation!.exercises.length,
      itemBuilder: (context, index) {
        final exercise = _recommendation!.exercises[index];
        return _buildExerciseCard(exercise, index);
      },
    );
  }

  Widget _buildExerciseCard(RecommendedExercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ExpansionTile(
        title: Text(
          exercise.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${exercise.part} • ${exercise.sets}组 ${exercise.reps}次 • ${exercise.weight}kg',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.2),
          child: Text(
            '${index + 1}',
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _speakText('接下来进行${exercise.name} ${exercise.sets}组 ${exercise.reps}次，建议重量 ${exercise.weight}公斤'),
              icon: Icon(
                _isSpeaking ? Icons.stop : Icons.play_arrow,
                color: Colors.blue,
              ),
            ),
            IconButton(
              onPressed: () => _sendChatMessage('请解释${exercise.name}的动作要领'),
              icon: const Icon(Icons.help_outline, color: Colors.green),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (exercise.description.isNotEmpty)
                  Text(
                    exercise.description,
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildExerciseDetail('组数', '${exercise.sets}'),
                    _buildExerciseDetail('次数', '${exercise.reps}'),
                    _buildExerciseDetail('重量', '${exercise.weight}kg'),
                    _buildExerciseDetail('休息', '${exercise.restSeconds}秒'),
                  ],
                ),
                if (exercise.videoUrl.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_circle_outline, color: Colors.white, size: 48),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseDetail(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingMode() {
    if (_currentExerciseIndex >= _recommendation!.exercises.length) {
      return _buildTrainingComplete();
    }
    
    final exercise = _recommendation!.exercises[_currentExerciseIndex];
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 训练进度
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('动作 ${_currentExerciseIndex + 1}/${_recommendation!.exercises.length}'),
                Text('组数 $_currentSet/${exercise.sets}'),
                Text('休息 ${_restTimeRemaining}秒'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 当前动作信息
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTrainingDetail('组数', '${exercise.sets}'),
                    _buildTrainingDetail('次数', '${exercise.reps}'),
                    _buildTrainingDetail('重量', '${exercise.weight}kg'),
                    _buildTrainingDetail('休息', '${exercise.restSeconds}秒'),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 训练状态显示
                if (_trainingState == TrainingState.active)
                  _buildActiveState()
                else if (_trainingState == TrainingState.resting)
                  _buildRestingState()
                else
                  _buildIdleState(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveState() {
    return Column(
      children: [
        const Text(
          '训练中...',
          style: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _completeSet,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('完成这组'),
        ),
      ],
    );
  }

  Widget _buildRestingState() {
    return Column(
      children: [
        const Text(
          '休息中...',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$_restTimeRemaining 秒',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIdleState() {
    return ElevatedButton(
      onPressed: _startSet,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: const Text('开始这组'),
    );
  }

  Widget _buildTrainingComplete() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text(
            '训练完成！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '完成度 90%，很棒！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isTrainingMode = false;
                _currentExerciseIndex = 0;
                _currentSet = 1;
                _trainingState = TrainingState.idle;
              });
            },
            child: const Text('返回计划'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatOverlay() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.smart_toy, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AI 健身教练',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleChat,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final message = _chatMessages[index];
                  return _buildChatMessage(message);
                },
              ),
            ),
            _buildChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    final textController = TextEditingController();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '询问AI教练...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                _sendChatMessage(textController.text);
                textController.clear();
              }
            },
            icon: const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

// 训练状态枚举
enum TrainingState {
  idle,
  active,
  resting,
  finished,
}

// 数据模型
class AITrainingRecommendation {
  final int userId;
  final TrainingOverview overview;
  final List<RecommendedExercise> exercises;
  final DateTime generated;

  AITrainingRecommendation({
    required this.userId,
    required this.overview,
    required this.exercises,
    required this.generated,
  });

  factory AITrainingRecommendation.fromJson(Map<String, dynamic> json) {
    return AITrainingRecommendation(
      userId: json['user_id'],
      overview: TrainingOverview.fromJson(json['overview']),
      exercises: (json['exercises'] as List)
          .map((e) => RecommendedExercise.fromJson(e))
          .toList(),
      generated: DateTime.parse(json['generated']),
    );
  }
}

class TrainingOverview {
  final String goal;
  final String trainingType;
  final int frequency;
  final double completionRate;
  final DateTime? lastTraining;
  final int weeklyProgress;

  TrainingOverview({
    required this.goal,
    required this.trainingType,
    required this.frequency,
    required this.completionRate,
    this.lastTraining,
    required this.weeklyProgress,
  });

  factory TrainingOverview.fromJson(Map<String, dynamic> json) {
    return TrainingOverview(
      goal: json['goal'],
      trainingType: json['training_type'],
      frequency: json['frequency'],
      completionRate: json['completion_rate'].toDouble(),
      lastTraining: json['last_training'] != null 
          ? DateTime.parse(json['last_training']) 
          : null,
      weeklyProgress: json['weekly_progress'],
    );
  }
}

class RecommendedExercise {
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final int restSeconds;
  final String part;
  final String description;
  final String videoUrl;
  final String notes;

  RecommendedExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restSeconds,
    required this.part,
    required this.description,
    required this.videoUrl,
    required this.notes,
  });

  factory RecommendedExercise.fromJson(Map<String, dynamic> json) {
    return RecommendedExercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'].toDouble(),
      restSeconds: json['rest_seconds'],
      part: json['part'],
      description: json['description'] ?? '',
      videoUrl: json['video_url'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? speechUrl;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.speechUrl,
  });
}