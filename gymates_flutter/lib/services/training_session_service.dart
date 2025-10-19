import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/models/mock_data.dart';

/// 🏋️‍♀️ 训练会话状态管理服务 - TrainingSessionService
/// 
/// 负责保存和恢复训练会话状态，包括：
/// - 当前训练进度
/// - 已完成的动作
/// - 训练开始时间
/// - 暂停/恢复状态

class TrainingSessionService {
  static const String _sessionKey = 'training_session';
  static const String _progressKey = 'training_progress';
  static const String _completedExercisesKey = 'completed_exercises';
  static const String _sessionStartTimeKey = 'session_start_time';
  static const String _isPausedKey = 'is_paused';

  /// 保存训练会话状态
  static Future<void> saveSessionState({
    required String planId,
    required int currentExerciseIndex,
    required double progress,
    required List<String> completedExercises,
    required DateTime sessionStartTime,
    required bool isPaused,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存会话基本信息
      await prefs.setString(_sessionKey, json.encode({
        'planId': planId,
        'currentExerciseIndex': currentExerciseIndex,
        'progress': progress,
        'sessionStartTime': sessionStartTime.toIso8601String(),
        'isPaused': isPaused,
        'lastUpdated': DateTime.now().toIso8601String(),
      }));

      // 保存完成状态
      await prefs.setStringList(_completedExercisesKey, completedExercises);
      
      print('✅ 训练状态已保存: 进度 ${(progress * 100).toInt()}%, 当前动作 $currentExerciseIndex');
    } catch (e) {
      print('❌ 保存训练状态失败: $e');
    }
  }

  /// 获取训练会话状态
  static Future<TrainingSessionState?> getSessionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionData = prefs.getString(_sessionKey);
      
      if (sessionData == null) return null;
      
      final data = json.decode(sessionData);
      final completedExercises = prefs.getStringList(_completedExercisesKey) ?? [];
      
      return TrainingSessionState(
        planId: data['planId'],
        currentExerciseIndex: data['currentExerciseIndex'],
        progress: data['progress'].toDouble(),
        completedExercises: completedExercises,
        sessionStartTime: DateTime.parse(data['sessionStartTime']),
        isPaused: data['isPaused'],
        lastUpdated: DateTime.parse(data['lastUpdated']),
      );
    } catch (e) {
      print('❌ 获取训练状态失败: $e');
      return null;
    }
  }

  /// 清除训练会话状态
  static Future<void> clearSessionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_progressKey);
      await prefs.remove(_completedExercisesKey);
      await prefs.remove(_sessionStartTimeKey);
      await prefs.remove(_isPausedKey);
      
      print('✅ 训练状态已清除');
    } catch (e) {
      print('❌ 清除训练状态失败: $e');
    }
  }

  /// 检查是否有未完成的训练会话
  static Future<bool> hasActiveSession() async {
    final state = await getSessionState();
    return state != null && !state.isPaused;
  }

  /// 暂停训练会话
  static Future<void> pauseSession({
    required String planId,
    required int currentExerciseIndex,
    required double progress,
    required List<String> completedExercises,
    required DateTime sessionStartTime,
  }) async {
    await saveSessionState(
      planId: planId,
      currentExerciseIndex: currentExerciseIndex,
      progress: progress,
      completedExercises: completedExercises,
      sessionStartTime: sessionStartTime,
      isPaused: true,
    );
  }

  /// 恢复训练会话
  static Future<void> resumeSession() async {
    final state = await getSessionState();
    if (state != null) {
      await saveSessionState(
        planId: state.planId,
        currentExerciseIndex: state.currentExerciseIndex,
        progress: state.progress,
        completedExercises: state.completedExercises,
        sessionStartTime: state.sessionStartTime,
        isPaused: false,
      );
    }
  }

  /// 完成训练会话
  static Future<void> completeSession() async {
    await clearSessionState();
  }

  /// 保存训练历史记录
  static Future<void> saveTrainingHistory({
    required String planId,
    required String planTitle,
    required int totalExercises,
    required int completedExercises,
    required int totalCalories,
    required int durationMinutes,
    required DateTime completedAt,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyKey = 'training_history';
      
      // 获取现有历史记录
      final existingHistory = prefs.getStringList(historyKey) ?? [];
      
      // 创建新的历史记录
      final newRecord = TrainingHistoryRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        planId: planId,
        planTitle: planTitle,
        totalExercises: totalExercises,
        completedExercises: completedExercises,
        totalCalories: totalCalories,
        durationMinutes: durationMinutes,
        completedAt: completedAt,
        progress: completedExercises / totalExercises,
      );
      
      // 添加到历史记录
      existingHistory.insert(0, json.encode(newRecord.toJson()));
      
      // 只保留最近50条记录
      if (existingHistory.length > 50) {
        existingHistory.removeRange(50, existingHistory.length);
      }
      
      await prefs.setStringList(historyKey, existingHistory);
      
      print('✅ 训练历史已保存: $planTitle');
    } catch (e) {
      print('❌ 保存训练历史失败: $e');
    }
  }

  /// 获取训练历史记录
  static Future<List<TrainingHistoryRecord>> getTrainingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyData = prefs.getStringList('training_history') ?? [];
      
      return historyData.map((data) {
        final json = jsonDecode(data);
        return TrainingHistoryRecord.fromJson(json);
      }).toList();
    } catch (e) {
      print('❌ 获取训练历史失败: $e');
      return [];
    }
  }
}

/// 训练会话状态数据模型
class TrainingSessionState {
  final String planId;
  final int currentExerciseIndex;
  final double progress;
  final List<String> completedExercises;
  final DateTime sessionStartTime;
  final bool isPaused;
  final DateTime lastUpdated;

  TrainingSessionState({
    required this.planId,
    required this.currentExerciseIndex,
    required this.progress,
    required this.completedExercises,
    required this.sessionStartTime,
    required this.isPaused,
    required this.lastUpdated,
  });

  /// 计算训练持续时间
  Duration get duration => DateTime.now().difference(sessionStartTime);

  /// 检查会话是否过期（超过24小时）
  bool get isExpired => DateTime.now().difference(lastUpdated).inHours > 24;

  /// 获取进度百分比
  int get progressPercentage => (progress * 100).round();
}

/// 训练历史记录数据模型
class TrainingHistoryRecord {
  final String id;
  final String planId;
  final String planTitle;
  final int totalExercises;
  final int completedExercises;
  final int totalCalories;
  final int durationMinutes;
  final DateTime completedAt;
  final double progress;

  TrainingHistoryRecord({
    required this.id,
    required this.planId,
    required this.planTitle,
    required this.totalExercises,
    required this.completedExercises,
    required this.totalCalories,
    required this.durationMinutes,
    required this.completedAt,
    required this.progress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'planTitle': planTitle,
      'totalExercises': totalExercises,
      'completedExercises': completedExercises,
      'totalCalories': totalCalories,
      'durationMinutes': durationMinutes,
      'completedAt': completedAt.toIso8601String(),
      'progress': progress,
    };
  }

  factory TrainingHistoryRecord.fromJson(Map<String, dynamic> json) {
    return TrainingHistoryRecord(
      id: json['id'],
      planId: json['planId'],
      planTitle: json['planTitle'],
      totalExercises: json['totalExercises'],
      completedExercises: json['completedExercises'],
      totalCalories: json['totalCalories'],
      durationMinutes: json['durationMinutes'],
      completedAt: DateTime.parse(json['completedAt']),
      progress: json['progress'].toDouble(),
    );
  }

  /// 获取完成率百分比
  int get completionPercentage => (progress * 100).round();

  /// 获取训练状态文本
  String get statusText {
    if (progress >= 1.0) return '已完成';
    if (progress >= 0.8) return '即将完成';
    if (progress >= 0.5) return '进行中';
    return '刚开始';
  }
}
