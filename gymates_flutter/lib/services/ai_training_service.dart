import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/smart_api_config.dart';
import 'unified_auth_service.dart';

/// 🤖 AI训练服务 - 完整版
/// 
/// 功能：
/// 1. 一键生成个性化训练计划
/// 2. 动作演示与语音指导
/// 3. 实时训练指导与纠正
/// 4. 训练数据上传与反馈
/// 5. 训练进度追踪

class AITrainingService {
  static final AITrainingService _instance = AITrainingService._internal();
  factory AITrainingService() => _instance;
  AITrainingService._internal();

  final UnifiedAuthService _authService = UnifiedAuthService();
  static String get _baseUrl => SmartApiConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  // ============================================
  // 1. 训练计划生成
  // ============================================

  /// 生成个性化训练计划
  Future<TrainingPlan> generatePersonalizedPlan({
    required int userId,
    required String goal, // 增肌/减脂/力量/耐力
    required int frequency, // 每周训练次数
    required String experience, // 初级/中级/高级
    String? preferredParts,
    double? currentWeight,
    double? targetWeight,
    String? gender,
    int? age,
    double? height,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('未登录');

      final response = await http.post(
        Uri.parse('$_baseUrl/training/ai/generate-plan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'goal': goal,
          'frequency': frequency,
          'experience': experience,
          'preferred_parts': preferredParts,
          'current_weight': currentWeight,
          'target_weight': targetWeight,
          'gender': gender,
          'age': age,
          'height': height,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return TrainingPlan.fromJson(data['data']);
        }
      }
      throw Exception('生成训练计划失败: ${response.statusCode}');
    } catch (e) {
      print('❌ 生成训练计划失败: $e');
      rethrow;
    }
  }

  /// 保存训练偏好
  Future<bool> saveTrainingPreferences({
    required int userId,
    required String goal,
    required int frequency,
    required String experience,
    String? preferredParts,
    double? currentWeight,
    double? targetWeight,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('未登录');

      final response = await http.post(
        Uri.parse('$_baseUrl/training/ai/preferences'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'goal': goal,
          'frequency': frequency,
          'experience': experience,
          'preferred_parts': preferredParts,
          'current_weight': currentWeight,
          'target_weight': targetWeight,
        }),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('❌ 保存训练偏好失败: $e');
      return false;
    }
  }

  // ============================================
  // 2. 动作演示与语音指导
  // ============================================

  /// 获取动作指导（文字+语音）
  Future<ExerciseGuidance> getExerciseGuidance(int exerciseId) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('未登录');

      final response = await http.get(
        Uri.parse('$_baseUrl/training/ai/exercise/$exerciseId/guidance'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ExerciseGuidance.fromJson(data['data']);
        }
      }
      throw Exception('获取动作指导失败: ${response.statusCode}');
    } catch (e) {
      print('❌ 获取动作指导失败: $e');
      rethrow;
    }
  }

  /// 开始训练
  Future<TrainingSession> startTraining({
    required int userId,
    required int planId,
    required int exerciseId,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('未登录');

      final response = await http.post(
        Uri.parse('$_baseUrl/training/ai/start'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'plan_id': planId,
          'exercise_id': exerciseId,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return TrainingSession.fromJson(data['data']);
        }
      }
      throw Exception('开始训练失败: ${response.statusCode}');
    } catch (e) {
      print('❌ 开始训练失败: $e');
      rethrow;
    }
  }

  // ============================================
  // 3. 实时纠正建议
  // ============================================

  /// 获取实时纠正建议
  Future<CorrectionAdvice> getRealTimeCorrection({
    required int userId,
    required int exerciseId,
    Map<String, dynamic>? sensorData,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('未登录');

      final response = await http.post(
        Uri.parse('$_baseUrl/training/ai/correction'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'exercise_id': exerciseId,
          'sensor_data': sensorData ?? {},
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return CorrectionAdvice.fromJson(data['data']);
        }
      }
      throw Exception('获取纠正建议失败: ${response.statusCode}');
    } catch (e) {
      print('❌ 获取纠正建议失败: $e');
      rethrow;
    }
  }

  // ============================================
  // 4. 训练数据上传与反馈
  // ============================================

  /// 上传训练数据
  Future<TrainingSummary> uploadTrainingData({
    required int userId,
    required TrainingSessionData sessionData,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('未登录');

      final response = await http.post(
        Uri.parse('$_baseUrl/training/ai/upload-data'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': userId,
          'session_data': sessionData.toJson(),
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return TrainingSummary.fromJson(data['data']['summary']);
        }
      }
      throw Exception('上传训练数据失败: ${response.statusCode}');
    } catch (e) {
      print('❌ 上传训练数据失败: $e');
      rethrow;
    }
  }

  /// 获取训练反馈
  Future<TrainingFeedback> getTrainingFeedback({
    required int userId,
    int? sessionId,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('未登录');

      final uri = Uri.parse('$_baseUrl/training/ai/feedback').replace(
        queryParameters: {
          'user_id': userId.toString(),
          if (sessionId != null) 'session_id': sessionId.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return TrainingFeedback.fromJson(data['data']);
        }
      }
      throw Exception('获取训练反馈失败: ${response.statusCode}');
    } catch (e) {
      print('❌ 获取训练反馈失败: $e');
      rethrow;
    }
  }

  /// 获取训练进度
  Future<TrainingProgress> getTrainingProgress({
    required int userId,
    int days = 30,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('未登录');

      final uri = Uri.parse('$_baseUrl/training/ai/progress').replace(
        queryParameters: {
          'user_id': userId.toString(),
          'days': days.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return TrainingProgress.fromJson(data['data']);
        }
      }
      throw Exception('获取训练进度失败: ${response.statusCode}');
    } catch (e) {
      print('❌ 获取训练进度失败: $e');
      rethrow;
    }
  }
}

// ============================================
// 数据模型
// ============================================

/// 训练计划
class TrainingPlan {
  final int id;
  final String name;
  final String description;
  final List<TrainingDay> days;
  final bool isActive;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.isActive,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      days: (json['days'] as List?)
              ?.map((d) => TrainingDay.fromJson(d))
              .toList() ??
          [],
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

/// 训练日
class TrainingDay {
  final int id;
  final String dayName;
  final int dayOfWeek;
  final bool isRestDay;
  final List<TrainingPart> parts;

  TrainingDay({
    required this.id,
    required this.dayName,
    required this.dayOfWeek,
    required this.isRestDay,
    required this.parts,
  });

  factory TrainingDay.fromJson(Map<String, dynamic> json) {
    return TrainingDay(
      id: json['id'] as int,
      dayName: json['day_name'] as String,
      dayOfWeek: json['day_of_week'] as int,
      isRestDay: json['is_rest_day'] as bool? ?? false,
      parts: (json['parts'] as List?)
              ?.map((p) => TrainingPart.fromJson(p))
              .toList() ??
          [],
    );
  }
}

/// 训练部位
class TrainingPart {
  final int id;
  final String muscleGroup;
  final String muscleGroupName;
  final List<TrainingExercise> exercises;

  TrainingPart({
    required this.id,
    required this.muscleGroup,
    required this.muscleGroupName,
    required this.exercises,
  });

  factory TrainingPart.fromJson(Map<String, dynamic> json) {
    return TrainingPart(
      id: json['id'] as int,
      muscleGroup: json['muscle_group'] as String,
      muscleGroupName: json['muscle_group_name'] as String,
      exercises: (json['exercises'] as List?)
              ?.map((e) => TrainingExercise.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// 训练动作
class TrainingExercise {
  final int id;
  final String name;
  final String description;
  final int sets;
  final int reps;
  final double weight;
  final int restSeconds;
  final String? notes;

  TrainingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restSeconds,
    this.notes,
  });

  factory TrainingExercise.fromJson(Map<String, dynamic> json) {
    return TrainingExercise(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      restSeconds: json['rest_seconds'] as int? ?? 60,
      notes: json['notes'] as String?,
    );
  }
}

/// 动作指导
class ExerciseGuidance {
  final int exerciseId;
  final String exerciseName;
  final String guidanceText;
  final String? speechUrl;
  final List<String> countdownPrompts;
  final List<String> restPrompts;
  final int duration;

  ExerciseGuidance({
    required this.exerciseId,
    required this.exerciseName,
    required this.guidanceText,
    this.speechUrl,
    required this.countdownPrompts,
    required this.restPrompts,
    required this.duration,
  });

  factory ExerciseGuidance.fromJson(Map<String, dynamic> json) {
    return ExerciseGuidance(
      exerciseId: json['exercise_id'] as int,
      exerciseName: json['exercise_name'] as String,
      guidanceText: json['guidance_text'] as String,
      speechUrl: json['speech_url'] as String?,
      countdownPrompts:
          (json['countdown_prompts'] as List?)?.cast<String>() ?? [],
      restPrompts: (json['rest_prompts'] as List?)?.cast<String>() ?? [],
      duration: json['duration'] as int? ?? 0,
    );
  }
}

/// 训练会话
class TrainingSession {
  final dynamic exercise;
  final ExerciseGuidance guidance;
  final int sessionId;

  TrainingSession({
    required this.exercise,
    required this.guidance,
    required this.sessionId,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      exercise: json['exercise'],
      guidance: ExerciseGuidance.fromJson(json['guidance']),
      sessionId: json['session_id'] as int,
    );
  }
}

/// 纠正建议
class CorrectionAdvice {
  final String correctionText;
  final String? speechUrl;
  final String severity;
  final DateTime timestamp;

  CorrectionAdvice({
    required this.correctionText,
    this.speechUrl,
    required this.severity,
    required this.timestamp,
  });

  factory CorrectionAdvice.fromJson(Map<String, dynamic> json) {
    return CorrectionAdvice(
      correctionText: json['correction_text'] as String,
      speechUrl: json['speech_url'] as String?,
      severity: json['severity'] as String? ?? 'info',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// 训练会话数据
class TrainingSessionData {
  final int planId;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final List<CompletedExerciseData> completedExercises;
  final int totalSets;
  final int totalReps;
  final int caloriesBurned;
  final String? notes;

  TrainingSessionData({
    required this.planId,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.completedExercises,
    required this.totalSets,
    required this.totalReps,
    required this.caloriesBurned,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration': duration,
      'completed_exercises': completedExercises.map((e) => e.toJson()).toList(),
      'total_sets': totalSets,
      'total_reps': totalReps,
      'calories_burned': caloriesBurned,
      'notes': notes,
    };
  }
}

/// 完成的动作数据
class CompletedExerciseData {
  final int exerciseId;
  final String exerciseName;
  final int setsDone;
  final List<int> repsPerSet;
  final List<double> weightUsed;
  final List<int> restTime;
  final String? notes;

  CompletedExerciseData({
    required this.exerciseId,
    required this.exerciseName,
    required this.setsDone,
    required this.repsPerSet,
    required this.weightUsed,
    required this.restTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'sets_done': setsDone,
      'reps_per_set': repsPerSet,
      'weight_used': weightUsed,
      'rest_time': restTime,
      'notes': notes,
    };
  }
}

/// 训练总结
class TrainingSummary {
  final String overallSummary;
  final String strengths;
  final String improvements;
  final String nextRecommendation;
  final int rating;
  final String? speechUrl;

  TrainingSummary({
    required this.overallSummary,
    required this.strengths,
    required this.improvements,
    required this.nextRecommendation,
    required this.rating,
    this.speechUrl,
  });

  factory TrainingSummary.fromJson(Map<String, dynamic> json) {
    return TrainingSummary(
      overallSummary: json['overall_summary'] as String,
      strengths: json['strengths'] as String,
      improvements: json['improvements'] as String,
      nextRecommendation: json['next_recommendation'] as String,
      rating: json['rating'] as int? ?? 4,
      speechUrl: json['speech_url'] as String?,
    );
  }
}

/// 训练反馈
class TrainingFeedback {
  final int totalSessions;
  final int recentSessions;
  final Map<String, int> muscleGroupStats;
  final List<dynamic> recentHistory;

  TrainingFeedback({
    required this.totalSessions,
    required this.recentSessions,
    required this.muscleGroupStats,
    required this.recentHistory,
  });

  factory TrainingFeedback.fromJson(Map<String, dynamic> json) {
    return TrainingFeedback(
      totalSessions: json['total_sessions'] as int? ?? 0,
      recentSessions: json['recent_sessions'] as int? ?? 0,
      muscleGroupStats: Map<String, int>.from(json['muscle_group_stats'] ?? {}),
      recentHistory: json['recent_history'] as List? ?? [],
    );
  }
}

/// 训练进度
class TrainingProgress {
  final Map<String, int> dailyStats;
  final int totalWorkouts;
  final int streak;
  final double completionRate;
  final String? goal;
  final int? targetFrequency;

  TrainingProgress({
    required this.dailyStats,
    required this.totalWorkouts,
    required this.streak,
    required this.completionRate,
    this.goal,
    this.targetFrequency,
  });

  factory TrainingProgress.fromJson(Map<String, dynamic> json) {
    return TrainingProgress(
      dailyStats: Map<String, int>.from(json['daily_stats'] ?? {}),
      totalWorkouts: json['total_workouts'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      goal: json['goal'] as String?,
      targetFrequency: json['target_frequency'] as int?,
    );
  }
}

