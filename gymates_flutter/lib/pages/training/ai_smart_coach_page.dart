import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/config/smart_api_config.dart';
import '../../shared/models/mock_data.dart';

/// 🏋️‍♀️ AI智能教练页面
/// 
/// 功能包括：
/// 1. 智能教练聊天（文字+语音）
/// 2. 语音陪练模式（训练中实时指导）
/// 3. 训练进度跟踪
/// 4. 自然语言问答
class AISmartCoachPage extends StatefulWidget {
  final int userId;
  final MockTrainingPlan? trainingPlan;

  const AISmartCoachPage({
    Key? key,
    required this.userId,
    this.trainingPlan,
  }) : super(key: key);

  @override
  _AISmartCoachPageState createState() => _AISmartCoachPageState();
}

class _AISmartCoachPageState extends State<AISmartCoachPage>
    with TickerProviderStateMixin {
  // 语音相关
  late FlutterTts _flutterTts;
  late SpeechToText _speechToText;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isTrainingMode = false;
  
  // 聊天相关
  final List<ChatMessage> _chatMessages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // 训练相关
  MockTrainingPlan? _currentTrainingPlan;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  Timer? _countdownTimer;
  int _countdownSeconds = 0;
  Timer? _restTimer;
  int _restSeconds = 0;
  
  // 动画控制器
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;
  
  // 训练状态
  TrainingState _trainingState = TrainingState.idle;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeAnimations();
    _loadTodayTrainingPlan();
    _addWelcomeMessage();
  }
  
  void _initializeServices() {
    _flutterTts = FlutterTts();
    _speechToText = SpeechToText();
    
    _flutterTts.setLanguage("zh-CN");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setVolume(1.0);
    _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
    
    _flutterTts.setErrorHandler((msg) {
      setState(() => _isSpeaking = false);
      print("TTS Error: $msg");
    });
  }
  
  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _addWelcomeMessage() {
    _chatMessages.add(ChatMessage(
      text: "你好！我是你的AI健身教练 💪\n\n我可以帮你：\n• 制定训练计划\n• 指导动作要领\n• 实时语音陪练\n• 回答健身问题\n\n有什么需要帮助的吗？",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }
  
  Future<void> _loadTodayTrainingPlan() async {
    try {
      final response = await http.get(
        Uri.parse('${SmartApiConfig.apiBaseUrl}/training/weekly-plans'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJlbWFpbCI6InhpYW93YW5nQGd5bWF0ZXMuY29tIiwiZXhwIjoxNzM0NjQ4NDAwfQ.8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data']['plans'].isNotEmpty) {
          final planData = data['data']['plans'][0];
          _currentTrainingPlan = _convertToMockTrainingPlan(planData);
        }
      }
    } catch (e) {
      print('加载训练计划失败: $e');
    }
  }
  
  MockTrainingPlan _convertToMockTrainingPlan(Map<String, dynamic> planData) {
    final exercises = <MockExercise>[];
    
    for (var day in planData['days']) {
      if (day['parts'] != null) {
        for (var part in day['parts']) {
          if (part['exercises'] != null) {
            for (var exercise in part['exercises']) {
              exercises.add(MockExercise(
                id: exercise['id'].toString(),
                name: exercise['name'],
                description: exercise['description'],
                muscleGroup: exercise['muscle_group'],
                difficulty: exercise['difficulty'] ?? 'intermediate',
                equipment: exercise['equipment'] ?? 'bodyweight',
                imageUrl: exercise['image_url'] ?? '',
                videoUrl: exercise['video_url'] ?? '',
                instructions: exercise['instructions'] ?? [],
                tips: exercise['tips'] ?? [],
                sets: exercise['sets'],
                reps: exercise['reps'],
                weight: exercise['weight'].toDouble(),
                restTime: exercise['rest_seconds'],
                isCompleted: false,
                completedAt: null,
                maxRM: exercise['max_rm']?.toDouble() ?? 0.0,
                notes: exercise['notes'] ?? '',
                calories: exercise['calories'] ?? 0,
              ));
            }
          }
        }
      }
    }
    
    return MockTrainingPlan(
      id: planData['id'].toString(),
      title: planData['name'],
      description: planData['description'],
      duration: '60',
      difficulty: 'intermediate',
      calories: 300,
      exercises: exercises.map((e) => e.name).toList(),
      image: '',
      isCompleted: false,
      progress: 0.0,
      trainingMode: 'custom',
      targetMuscles: ['chest', 'back', 'legs'],
      exerciseDetails: exercises,
      suitableFor: 'intermediate',
      weeklyFrequency: 3,
      createdAt: DateTime.now(),
      lastCompleted: null,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          _isTrainingMode ? 'AI语音陪练' : 'AI智能教练',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Colors.white,
            ),
            onPressed: _toggleListening,
          ),
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_up : Icons.volume_off,
              color: _isSpeaking ? Colors.blue : Colors.white,
            ),
            onPressed: _toggleSpeaking,
          ),
        ],
      ),
      body: Column(
        children: [
          // 训练状态栏
          if (_isTrainingMode) _buildTrainingStatusBar(),
          
          // 聊天区域
          Expanded(
            child: _buildChatArea(),
          ),
          
          // 输入区域
          if (!_isTrainingMode) _buildInputArea(),
          
          // 训练控制栏
          if (_isTrainingMode) _buildTrainingControls(),
        ],
      ),
    );
  }
  
  Widget _buildTrainingStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF2A2A2A),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentTrainingPlan?.title ?? '训练计划',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTrainingStateColor(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getTrainingStateText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_currentTrainingPlan != null && _currentTrainingPlan!.exercises.isNotEmpty)
            _buildProgressIndicator(),
        ],
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    final currentExercise = _currentTrainingPlan!.exerciseDetails[_currentExerciseIndex];
    final totalSets = currentExercise.sets;
    final progress = _currentSetIndex / totalSets;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${currentExercise.name}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              '第 ${_currentSetIndex + 1} 组 / 共 $totalSets 组',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[800],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ],
    );
  }
  
  Widget _buildChatArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _chatMessages.length,
        itemBuilder: (context, index) {
          final message = _chatMessages[index];
          return _buildChatBubble(message);
        },
      ),
    );
  }
  
  Widget _buildChatBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.smart_toy, color: Colors.white),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Colors.blue 
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      if (!message.isUser) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _speakText(message.text),
                          child: Icon(
                            Icons.volume_up,
                            size: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green,
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          top: BorderSide(color: Color(0xFF3A3A3A), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: '输入消息...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Color(0xFF3A3A3A),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (text) => _sendMessage(text),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _toggleListening,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _sendMessage(_textController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrainingControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          top: BorderSide(color: Color(0xFF3A3A3A), width: 1),
        ),
      ),
      child: Column(
        children: [
          // 倒计时显示
          if (_countdownSeconds > 0)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Text(
                      '$_countdownSeconds',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 16),
          
          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.play_arrow,
                label: '开始',
                color: Colors.green,
                onTap: _startTraining,
                enabled: _trainingState == TrainingState.idle,
              ),
              _buildControlButton(
                icon: _trainingState == TrainingState.paused 
                    ? Icons.play_arrow 
                    : Icons.pause,
                label: _trainingState == TrainingState.paused ? '继续' : '暂停',
                color: Colors.orange,
                onTap: _pauseTraining,
                enabled: _trainingState == TrainingState.running || 
                         _trainingState == TrainingState.paused,
              ),
              _buildControlButton(
                icon: Icons.stop,
                label: '结束',
                color: Colors.red,
                onTap: _stopTraining,
                enabled: _trainingState != TrainingState.idle,
              ),
              _buildControlButton(
                icon: Icons.skip_next,
                label: '跳过',
                color: Colors.blue,
                onTap: _skipExercise,
                enabled: _trainingState == TrainingState.running,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: enabled ? color : Colors.grey,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 聊天功能
  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _chatMessages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    
    _textController.clear();
    _scrollToBottom();
    
    // 发送到AI教练
    await _sendToAICoach(text);
  }
  
  Future<void> _sendToAICoach(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${SmartApiConfig.apiBaseUrl}/ai/coach'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJlbWFpbCI6InhpYW93YW5nQGd5bWF0ZXMuY29tIiwiZXhwIjoxNzM0NjQ4NDAwfQ.8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userId,
          'message': message,
          'context': {
            'training_plan': _currentTrainingPlan?.toJson(),
            'current_exercise': _currentExerciseIndex < (_currentTrainingPlan?.exerciseDetails.length ?? 0)
                ? _currentTrainingPlan!.exerciseDetails[_currentExerciseIndex].name
                : null,
            'training_state': _trainingState.toString(),
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final aiResponse = data['data']['response'];
          final shouldSpeak = data['data']['speak'] ?? false;
          
          setState(() {
            _chatMessages.add(ChatMessage(
              text: aiResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ));
          });
          
          if (shouldSpeak) {
            await _speakText(aiResponse);
          }
          
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('AI教练请求失败: $e');
      _addErrorMessage('抱歉，AI教练暂时无法回应，请稍后再试。');
    }
  }
  
  void _addErrorMessage(String message) {
    setState(() {
      _chatMessages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }
  
  // 语音功能
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              _sendMessage(result.recognizedWords);
              setState(() => _isListening = false);
            }
          },
        );
      }
    }
  }
  
  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
  }
  
  Future<void> _toggleSpeaking() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    }
  }
  
  // 训练功能
  void _startTraining() {
    if (_currentTrainingPlan == null || _currentTrainingPlan!.exerciseDetails.isEmpty) {
      _addErrorMessage('没有可用的训练计划，请先制定训练计划。');
      return;
    }
    
    setState(() {
      _isTrainingMode = true;
      _trainingState = TrainingState.running;
      _currentExerciseIndex = 0;
      _currentSetIndex = 0;
    });
    
    _startExerciseCountdown();
  }
  
  void _startExerciseCountdown() {
    _countdownSeconds = 3;
    _pulseController.repeat(reverse: true);
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdownSeconds--;
      });
      
      if (_countdownSeconds <= 0) {
        timer.cancel();
        _pulseController.stop();
        _startExercise();
      }
    });
    
    _speakText('准备${_currentTrainingPlan!.exerciseDetails[_currentExerciseIndex].name}，3、2、1，开始！');
  }
  
  void _startExercise() {
    final exercise = _currentTrainingPlan!.exerciseDetails[_currentExerciseIndex];
    _speakText('开始第${_currentSetIndex + 1}组${exercise.name}，目标${exercise.reps}次');
  }
  
  void _pauseTraining() {
    setState(() {
      _trainingState = _trainingState == TrainingState.paused 
          ? TrainingState.running 
          : TrainingState.paused;
    });
    
    if (_countdownTimer?.isActive == true) {
      _countdownTimer?.cancel();
    }
    if (_restTimer?.isActive == true) {
      _restTimer?.cancel();
    }
    
    _speakText(_trainingState == TrainingState.paused ? '训练已暂停' : '训练继续');
  }
  
  void _stopTraining() {
    setState(() {
      _isTrainingMode = false;
      _trainingState = TrainingState.idle;
      _currentExerciseIndex = 0;
      _currentSetIndex = 0;
    });
    
    _countdownTimer?.cancel();
    _restTimer?.cancel();
    _pulseController.stop();
    
    _speakText('训练结束，辛苦了！');
  }
  
  void _skipExercise() {
    _nextSet();
  }
  
  void _nextSet() {
    final exercise = _currentTrainingPlan!.exerciseDetails[_currentExerciseIndex];
    
    if (_currentSetIndex < exercise.sets - 1) {
      setState(() => _currentSetIndex++);
      _startRestTimer();
    } else {
      _nextExercise();
    }
  }
  
  void _nextExercise() {
    if (_currentExerciseIndex < _currentTrainingPlan!.exerciseDetails.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSetIndex = 0;
      });
      _startExerciseCountdown();
    } else {
      _completeTraining();
    }
  }
  
  void _startRestTimer() {
    final exercise = _currentTrainingPlan!.exerciseDetails[_currentExerciseIndex];
    _restSeconds = exercise.restTime;
    
    _speakText('休息${exercise.restTime}秒，下一个动作是${exercise.name}');
    
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restSeconds--;
      });
      
      if (_restSeconds <= 0) {
        timer.cancel();
        _startExerciseCountdown();
      }
    });
  }
  
  void _completeTraining() {
    setState(() {
      _isTrainingMode = false;
      _trainingState = TrainingState.idle;
    });
    
    _speakText('恭喜！训练完成！你的表现很棒！');
    
    // 保存训练记录
    _saveTrainingRecord();
  }
  
  Future<void> _saveTrainingRecord() async {
    try {
      await http.post(
        Uri.parse('${SmartApiConfig.apiBaseUrl}/ai/progress'),
        headers: {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJlbWFpbCI6InhpYW93YW5nQGd5bWF0ZXMuY29tIiwiZXhwIjoxNzM0NjQ4NDAwfQ.8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8QJ8',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userId,
          'plan_id': _currentTrainingPlan?.id,
          'completed_at': DateTime.now().toIso8601String(),
          'exercises_completed': _currentTrainingPlan?.exerciseDetails.length ?? 0,
          'duration': 60, // 训练时长（分钟）
          'calories_burned': 300, // 消耗卡路里
          'notes': 'AI智能教练陪练完成',
        }),
      );
    } catch (e) {
      print('保存训练记录失败: $e');
    }
  }
  
  // 辅助方法
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  Color _getTrainingStateColor() {
    switch (_trainingState) {
      case TrainingState.idle:
        return Colors.grey;
      case TrainingState.running:
        return Colors.green;
      case TrainingState.paused:
        return Colors.orange;
    }
  }
  
  String _getTrainingStateText() {
    switch (_trainingState) {
      case TrainingState.idle:
        return '待开始';
      case TrainingState.running:
        return '进行中';
      case TrainingState.paused:
        return '已暂停';
    }
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    _speechToText.stop();
    _countdownTimer?.cancel();
    _restTimer?.cancel();
    _pulseController.dispose();
    _progressController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// 数据模型
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

enum TrainingState {
  idle,
  running,
  paused,
}
