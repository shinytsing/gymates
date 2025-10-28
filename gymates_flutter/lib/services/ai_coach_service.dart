import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/smart_api_config.dart';

/// 🤖 AI教练服务 - AICoachService
/// 
/// 功能：
/// 1. 用户信息建模
/// 2. AI智能推荐训练计划
/// 3. 训练强度分析
/// 4. 个性化建议

class AICoachService {
  static final AICoachService _instance = AICoachService._internal();
  factory AICoachService() => _instance;
  AICoachService._internal();

  static String get _baseUrl => SmartApiConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 10);

  /// 获取用户信息进行建模
  Future<UserProfile> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ai-coach/user-profile?user_id=$userId'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return UserProfile.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('❌ 获取用户信息失败: $e');
    }

    // 返回默认用户信息
    return UserProfile.empty();
  }

  /// 获取AI推荐训练计划
  Future<TrainingRecommendation> getRecommendedPlan(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ai-coach/recommend-plan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return TrainingRecommendation.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('❌ 获取AI推荐失败: $e');
    }

    // 返回默认推荐
    return TrainingRecommendation.defaultRecommendation();
  }

  /// 分析训练数据并给出建议
  Future<AIAdvice> analyzeTraining(int userId, Map<String, dynamic> trainingData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ai-coach/analyze'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'training_data': trainingData,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return AIAdvice.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('❌ 分析训练数据失败: $e');
    }

    return AIAdvice.defaultAdvice();
  }

  /// 生成训练总结
  Future<TrainingSummary> generateSummary(int userId, List<dynamic> exercises) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ai-coach/generate-summary'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'exercises': exercises,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return TrainingSummary.fromJson(data['data']);
        }
      }
    } catch (e) {
      print('❌ 生成训练总结失败: $e');
    }

    return TrainingSummary.defaultSummary();
  }
}

/// 用户档案模型
class UserProfile {
  final int userId;
  final double height; // cm
  final double weight; // kg
  final int age;
  final String gender;
  final int trainingExperience; // 训练年限
  final int trainingFrequency; // 每周训练次数
  final String trainingGoal; // 增肌/减脂/塑形
  final double? bodyFat; // 体脂率
  final int? sleepHours; // 睡眠时长
  final List<String> preferences; // 训练偏好

  UserProfile({
    required this.userId,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.trainingExperience,
    required this.trainingFrequency,
    required this.trainingGoal,
    this.bodyFat,
    this.sleepHours,
    required this.preferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as int,
      height: (json['height'] as num?)?.toDouble() ?? 170,
      weight: (json['weight'] as num?)?.toDouble() ?? 70,
      age: json['age'] as int? ?? 25,
      gender: json['gender'] as String? ?? 'male',
      trainingExperience: json['training_experience'] as int? ?? 1,
      trainingFrequency: json['training_frequency'] as int? ?? 3,
      trainingGoal: json['training_goal'] as String? ?? '增肌',
      bodyFat: (json['body_fat'] as num?)?.toDouble(),
      sleepHours: json['sleep_hours'] as int?,
      preferences: (json['preferences'] as List?)?.cast<String>() ?? [],
    );
  }

  factory UserProfile.empty() {
    return UserProfile(
      userId: 0,
      height: 170,
      weight: 70,
      age: 25,
      gender: 'male',
      trainingExperience: 1,
      trainingFrequency: 3,
      trainingGoal: '增肌',
      preferences: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'training_experience': trainingExperience,
      'training_frequency': trainingFrequency,
      'training_goal': trainingGoal,
      'body_fat': bodyFat,
      'sleep_hours': sleepHours,
      'preferences': preferences,
    };
  }
}

/// 训练推荐模型
class TrainingRecommendation {
  final String planTitle;
  final String reason; // 推荐原因
  final List<RecommendedExercise> exercises;
  final int estimatedDuration; // 分钟
  final int estimatedCalories;
  final int restTime; // 秒
  final String intensity; // 低/中/高

  TrainingRecommendation({
    required this.planTitle,
    required this.reason,
    required this.exercises,
    required this.estimatedDuration,
    required this.estimatedCalories,
    required this.restTime,
    required this.intensity,
  });

  factory TrainingRecommendation.fromJson(Map<String, dynamic> json) {
    return TrainingRecommendation(
      planTitle: json['plan_title'] as String,
      reason: json['reason'] as String,
      exercises: (json['exercises'] as List?)
              ?.map((e) => RecommendedExercise.fromJson(e))
              .toList() ??
          [],
      estimatedDuration: json['estimated_duration'] as int? ?? 45,
      estimatedCalories: json['estimated_calories'] as int? ?? 300,
      restTime: json['rest_time'] as int? ?? 60,
      intensity: json['intensity'] as String? ?? 'medium',
    );
  }

  factory TrainingRecommendation.defaultRecommendation() {
    return TrainingRecommendation(
      planTitle: '全身力量训练',
      reason: '基于您的训练历史，建议今天进行中等强度的全身训练',
      exercises: [
        RecommendedExercise(
          name: '平板卧推',
          sets: 3,
          reps: 12,
          reason: '增强胸部肌肉力量',
        ),
        RecommendedExercise(
          name: '深蹲',
          sets: 3,
          reps: 15,
          reason: '提升下肢力量',
        ),
      ],
      estimatedDuration: 45,
      estimatedCalories: 320,
      restTime: 60,
      intensity: 'medium',
    );
  }
}

class RecommendedExercise {
  final String name;
  final int sets;
  final int reps;
  final String reason;
  final String? difficulty;

  RecommendedExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.reason,
    this.difficulty,
  });

  factory RecommendedExercise.fromJson(Map<String, dynamic> json) {
    return RecommendedExercise(
      name: json['name'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      reason: json['reason'] as String,
      difficulty: json['difficulty'] as String?,
    );
  }
}

/// AI建议模型
class AIAdvice {
  final String summary;
  final String strengthAnalysis;
  final String suggestion;
  final List<String> tips;

  AIAdvice({
    required this.summary,
    required this.strengthAnalysis,
    required this.suggestion,
    required this.tips,
  });

  factory AIAdvice.fromJson(Map<String, dynamic> json) {
    return AIAdvice(
      summary: json['summary'] as String? ?? '',
      strengthAnalysis: json['strength_analysis'] as String? ?? '',
      suggestion: json['suggestion'] as String? ?? '',
      tips: (json['tips'] as List?)?.cast<String>() ?? [],
    );
  }

  factory AIAdvice.defaultAdvice() {
    return AIAdvice(
      summary: '本次训练完成度良好',
      strengthAnalysis: '训练强度适中，符合您的训练计划',
      suggestion: '建议继续保持当前训练频率',
      tips: [
        '保持充分休息',
        '注意营养补充',
        '适当增加训练强度',
      ],
    );
  }
}

/// 训练总结模型
class TrainingSummary {
  final String overall;
  final int rating; // 1-5
  final List<String> achievements;
  final String nextRecommendation;

  TrainingSummary({
    required this.overall,
    required this.rating,
    required this.achievements,
    required this.nextRecommendation,
  });

  factory TrainingSummary.fromJson(Map<String, dynamic> json) {
    return TrainingSummary(
      overall: json['overall'] as String? ?? '',
      rating: json['rating'] as int? ?? 4,
      achievements: (json['achievements'] as List?)?.cast<String>() ?? [],
      nextRecommendation: json['next_recommendation'] as String? ?? '',
    );
  }

  factory TrainingSummary.defaultSummary() {
    return TrainingSummary(
      overall: '训练完成得很好，继续加油！',
      rating: 4,
      achievements: ['完成所有动作', '保持良好状态'],
      nextRecommendation: '建议明天休息，进行拉伸放松',
    );
  }
}

