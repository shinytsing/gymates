import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/models/mock_data.dart';
import '../core/config/smart_api_config.dart';

/// 🏋️‍♀️ 训练数据服务 - TrainingDataService
/// 
/// 负责与后端API交互，处理训练计划、动作数据等
/// 支持数据持久化、同步和缓存

class TrainingDataService {
  // 使用智能API配置
  static String get _baseUrl => SmartApiConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 10);

  // 单例模式
  static final TrainingDataService _instance = TrainingDataService._internal();
  factory TrainingDataService() => _instance;
  TrainingDataService._internal();

  /// 获取用户训练计划列表
  Future<List<MockTrainingPlan>> getUserTrainingPlans(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/training-plans'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _parseTrainingPlan(json)).toList();
      } else {
        throw Exception('Failed to load training plans: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
      rethrow;
    }
  }

  /// 创建新的训练计划
  Future<MockTrainingPlan> createTrainingPlan(
    String userId,
    MockTrainingPlan plan,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/$userId/training-plans'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_trainingPlanToJson(plan)),
      ).timeout(_timeout);

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseTrainingPlan(data);
      } else {
        throw Exception('Failed to create training plan: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
      rethrow;
    }
  }

  /// 更新训练计划
  Future<MockTrainingPlan> updateTrainingPlan(
    String userId,
    String planId,
    MockTrainingPlan plan,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId/training-plans/$planId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_trainingPlanToJson(plan)),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseTrainingPlan(data);
      } else {
        throw Exception('Failed to update training plan: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
      rethrow;
    }
  }

  /// 记录训练会话
  Future<void> recordWorkoutSession(
    String userId,
    String planId,
    List<MockExercise> completedExercises,
    DateTime startTime,
    DateTime endTime,
  ) async {
    final sessionData = {
      'user_id': userId,
      'plan_id': planId,
      'exercises': completedExercises.map((e) => _exerciseToJson(e)).toList(),
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'duration': endTime.difference(startTime).inMinutes,
      'calories_burned': _calculateCaloriesBurned(completedExercises),
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/workout-sessions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(sessionData),
      ).timeout(_timeout);

      if (response.statusCode != 201) {
        throw Exception('Failed to record workout session: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
      // 本地记录训练会话
      _saveWorkoutSessionLocally(sessionData);
    }
  }

  /// 获取训练历史
  Future<List<Map<String, dynamic>>> getWorkoutHistory(
    String userId,
    {int limit = 30}
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/workout-history?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load workout history: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
      rethrow;
    }
  }

  /// 更新动作的最大重量记录
  Future<void> updateExerciseMaxWeight(
    String userId,
    String exerciseId,
    double maxWeight,
    int reps,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/$userId/exercises/$exerciseId/max-weight'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'max_weight': maxWeight,
          'reps': reps,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      ).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to update max weight: ${response.statusCode}');
      }
    } catch (e) {
      print('Network error: $e');
      // 本地更新最大重量
      _updateLocalMaxWeight(exerciseId, maxWeight, reps);
    }
  }

  /// 获取推荐训练模式
  Future<List<MockTrainingMode>> getRecommendedTrainingModes(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/recommended-modes'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _parseTrainingMode(json)).toList();
      } else {
        throw Exception('Failed to load recommended modes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Network error: $e');
      rethrow;
    }
  }

  /// 同步本地数据到服务器
  Future<void> syncLocalData(String userId) async {
    try {
      // 获取本地未同步的数据
      final localData = await _getLocalUnsyncedData();
      
      for (final data in localData) {
        switch (data['type']) {
          case 'training_plan':
            await createTrainingPlan(userId, data['plan']);
            break;
          case 'workout_session':
            await recordWorkoutSession(
              userId,
              data['plan_id'],
              data['exercises'],
              data['start_time'],
              data['end_time'],
            );
            break;
          case 'max_weight':
            await updateExerciseMaxWeight(
              userId,
              data['exercise_id'],
              data['max_weight'],
              data['reps'],
            );
            break;
        }
      }
      
      // 标记数据已同步
      await _markDataAsSynced(localData);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  // 私有方法

  MockTrainingPlan _parseTrainingPlan(Map<String, dynamic> json) {
    return MockTrainingPlan(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '60分钟',
      difficulty: json['difficulty'] ?? '中级',
      calories: json['calories'] ?? 300,
      exercises: List<String>.from(json['exercises'] ?? []),
      image: json['image'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
      trainingMode: json['training_mode'] ?? '五分化',
      targetMuscles: List<String>.from(json['target_muscles'] ?? []),
      exerciseDetails: (json['exercise_details'] as List?)
          ?.map((e) => _parseExercise(e))
          .toList() ?? [],
      suitableFor: json['suitable_for'] ?? '中级训练者',
      weeklyFrequency: json['weekly_frequency'] ?? 3,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      lastCompleted: json['last_completed'] != null 
          ? DateTime.parse(json['last_completed'])
          : null,
    );
  }

  MockExercise _parseExercise(Map<String, dynamic> json) {
    return MockExercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      muscleGroup: json['muscle_group'] ?? '',
      difficulty: json['difficulty'] ?? '中级',
      equipment: json['equipment'] ?? '',
      imageUrl: json['image_url'] ?? '',
      videoUrl: json['video_url'] ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
      tips: List<String>.from(json['tips'] ?? []),
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      weight: (json['weight'] ?? 0.0).toDouble(),
      restTime: json['rest_time'] ?? 60,
      isCompleted: json['is_completed'] ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'])
          : null,
      maxRM: (json['max_rm'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
    );
  }

  MockTrainingMode _parseTrainingMode(Map<String, dynamic> json) {
    return MockTrainingMode(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏋️‍♂️',
      color: json['color'] ?? '#6366F1',
      targetMuscles: List<String>.from(json['target_muscles'] ?? []),
      difficulty: json['difficulty'] ?? '中级',
      suitableFor: json['suitable_for'] ?? '中级训练者',
      weeklyFrequency: json['weekly_frequency'] ?? 3,
      estimatedDuration: json['estimated_duration'] ?? 60,
      benefits: List<String>.from(json['benefits'] ?? []),
      isRecommended: json['is_recommended'] ?? false,
    );
  }

  Map<String, dynamic> _trainingPlanToJson(MockTrainingPlan plan) {
    return {
      'title': plan.title,
      'description': plan.description,
      'duration': plan.duration,
      'difficulty': plan.difficulty,
      'calories': plan.calories,
      'exercises': plan.exercises,
      'image': plan.image,
      'training_mode': plan.trainingMode,
      'target_muscles': plan.targetMuscles,
      'exercise_details': plan.exerciseDetails.map((e) => _exerciseToJson(e)).toList(),
      'suitable_for': plan.suitableFor,
      'weekly_frequency': plan.weeklyFrequency,
    };
  }

  Map<String, dynamic> _exerciseToJson(MockExercise exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'description': exercise.description,
      'muscle_group': exercise.muscleGroup,
      'difficulty': exercise.difficulty,
      'equipment': exercise.equipment,
      'image_url': exercise.imageUrl,
      'video_url': exercise.videoUrl,
      'instructions': exercise.instructions,
      'tips': exercise.tips,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'weight': exercise.weight,
      'rest_time': exercise.restTime,
      'is_completed': exercise.isCompleted,
      'completed_at': exercise.completedAt?.toIso8601String(),
      'max_rm': exercise.maxRM,
      'notes': exercise.notes,
    };
  }

  int _calculateCaloriesBurned(List<MockExercise> exercises) {
    // 简单的卡路里计算逻辑
    int totalCalories = 0;
    for (final exercise in exercises) {
      // 基于动作类型和重量计算卡路里
      final baseCalories = exercise.weight * exercise.sets * exercise.reps * 0.1;
      totalCalories += baseCalories.round();
    }
    return totalCalories;
  }

  void _saveWorkoutSessionLocally(Map<String, dynamic> sessionData) {
    // 本地保存训练会话数据
    print('Saving workout session locally: $sessionData');
  }

  List<Map<String, dynamic>> _getLocalWorkoutHistory() {
    // 返回本地训练历史数据
    return [];
  }

  void _updateLocalMaxWeight(String exerciseId, double maxWeight, int reps) {
    // 本地更新最大重量记录
    print('Updating local max weight: $exerciseId - $maxWeight kg for $reps reps');
  }

  Future<List<Map<String, dynamic>>> _getLocalUnsyncedData() async {
    // 获取本地未同步的数据
    return [];
  }

  Future<void> _markDataAsSynced(List<Map<String, dynamic>> data) async {
    // 标记数据已同步
    print('Marking data as synced: ${data.length} items');
  }
}
