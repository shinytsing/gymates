import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:flutter/material.dart';

/// 🔊 训练语音播报服务 - TrainingVoiceService
/// 
/// 功能：
/// 1. 倒计时提示（3, 2, 1...）
/// 2. 加油鼓励语
/// 3. 动作指导提示
/// 4. 休息时间提醒
/// 5. 蓝牙设备支持（自动检测）

class TrainingVoiceService {
  static final TrainingVoiceService _instance = TrainingVoiceService._internal();
  factory TrainingVoiceService() => _instance;
  TrainingVoiceService._internal();

  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  Timer? _countdownTimer;

  /// 初始化TTS
  Future<void> initialize() async {
    if (_isInitialized) return;

    _flutterTts = FlutterTts();

    // 设置语言和语音
    await _flutterTts.setLanguage("zh-CN");
    await _flutterTts.setSpeechRate(0.5); // 中等速度
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // 设置完成回调
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    _isInitialized = true;
  }

  /// 播放语音
  Future<void> speak(String text, {double speechRate = 0.5}) async {
    if (!_isInitialized) await initialize();
    
    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    _isSpeaking = true;
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.speak(text);
  }

  /// 停止播报
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    _isSpeaking = false;
    await _flutterTts.stop();
    _countdownTimer?.cancel();
  }

  /// 播报倒计时（3, 2, 1, 开始！）
  Future<void> speakCountdown({
    int seconds = 3,
    VoidCallback? onComplete,
  }) async {
    if (!_isInitialized) await initialize();

    _countdownTimer?.cancel();
    
    int count = seconds;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (count > 0) {
        await speak('$count');
        count--;
      } else {
        timer.cancel();
        await speak('开始！');
        onComplete?.call();
      }
    });
  }

  /// 播报动作指导
  Future<void> speakExerciseGuide(String exerciseName, int sets, int reps) async {
    await speak('开始 $exerciseName，共 $sets 组，每组 $reps 次', speechRate: 0.4);
  }

  /// 播报休息提醒
  Future<void> speakRestReminder(int restSeconds) async {
    if (restSeconds >= 60) {
      final minutes = restSeconds ~/ 60;
      await speak('休息 $minutes 分钟', speechRate: 0.4);
    } else {
      await speak('休息 $restSeconds 秒', speechRate: 0.4);
    }
  }

  /// 播报组间倒计时
  Future<void> speakRestCountdown(int seconds, VoidCallback? onComplete) async {
    int remaining = seconds;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (remaining > 0 && remaining <= 3) {
        await speak('$remaining');
      } else if (remaining == 0) {
        timer.cancel();
        await speak('时间到，继续训练', speechRate: 0.4);
        onComplete?.call();
      }
      remaining--;
    });
  }

  /// 播报鼓励语
  Future<void> speakEncouragement() async {
    final encouragements = [
      '加油，你可以的！',
      '坚持就是胜利！',
      '很棒，继续保持！',
      '做得很好！',
      '非常出色！',
      '继续保持这个状态！',
    ];
    
    final random = DateTime.now().millisecondsSinceEpoch % encouragements.length;
    await speak(encouragements[random], speechRate: 0.45);
  }

  /// 播报动作完成提示
  Future<void> speakExerciseComplete(String exerciseName) async {
    await speak('$exerciseName 完成，很棒！', speechRate: 0.45);
  }

  /// 播报训练完成
  Future<void> speakTrainingComplete(int totalTime, int calories) async {
    await speak('恭喜完成训练！总时长 $totalTime 分钟，消耗 $calories 卡路里', speechRate: 0.4);
  }

  /// 播报下一动作
  Future<void> speakNextExercise(String exerciseName, int exerciseIndex, int totalExercises) async {
    await speak('下一个动作：$exerciseName，当前进度 ${exerciseIndex + 1}/$totalExercises', speechRate: 0.4);
  }

  /// 检查是否正在播报
  bool get isSpeaking => _isSpeaking;

  /// 释放资源
  void dispose() {
    stop();
    _countdownTimer?.cancel();
  }
}

