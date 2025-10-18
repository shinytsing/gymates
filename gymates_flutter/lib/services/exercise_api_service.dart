import 'dart:convert';
import 'package:http/http.dart' as http;
import '../shared/models/mock_data.dart';

/// 🏋️‍♀️ 训练动作API服务 - ExerciseApiService
/// 
/// 提供训练动作的API接口，包括搜索、获取详情等功能
/// 使用Go后端API

class ExerciseApiService {
  static const String _baseUrl = 'http://localhost:8080/api'; // Go后端地址
  static const Duration _timeout = Duration(seconds: 10);

  /// 搜索训练动作
  static Future<List<MockExercise>> searchExercises({
    String? query,
    String? muscleGroup,
    String? difficulty,
    String? equipment,
  }) async {
    try {
      // 构建查询参数
      final Map<String, String> queryParams = {};
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (muscleGroup != null && muscleGroup.isNotEmpty) {
        queryParams['muscle_group'] = muscleGroup;
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queryParams['difficulty'] = difficulty;
      }
      if (equipment != null && equipment.isNotEmpty) {
        queryParams['equipment'] = equipment;
      }

      final uri = Uri.parse('$_baseUrl/training/exercises/search').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseExercisesFromGoResponse(data);
      } else {
        // 如果API失败，返回模拟数据
        return _getMockExercises(query: query);
      }
    } catch (e) {
      // 网络错误时返回模拟数据
      print('API Error: $e');
      return _getMockExercises(query: query);
    }
  }

  /// 获取所有训练动作
  static Future<List<MockExercise>> getAllExercises() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/training/exercises'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseExercisesFromGoResponse(data);
      } else {
        return MockDataProvider.exercises;
      }
    } catch (e) {
      print('API Error: $e');
      return MockDataProvider.exercises;
    }
  }

  /// 根据ID获取动作详情
  static Future<MockExercise?> getExerciseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/training/exercises/$id'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseExerciseFromGoResponse(data);
      } else {
        return MockDataProvider.exercises.firstWhere(
          (exercise) => exercise.id == id,
          orElse: () => MockDataProvider.exercises.first,
        );
      }
    } catch (e) {
      print('API Error: $e');
      return MockDataProvider.exercises.firstWhere(
        (exercise) => exercise.id == id,
        orElse: () => MockDataProvider.exercises.first,
      );
    }
  }

  /// 获取训练计划
  static Future<List<MockTrainingPlan>> getTrainingPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/training/plans'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseTrainingPlansFromGoResponse(data);
      } else {
        return MockDataProvider.trainingPlans;
      }
    } catch (e) {
      print('API Error: $e');
      return MockDataProvider.trainingPlans;
    }
  }

  /// 保存训练计划
  static Future<bool> saveTrainingPlan(MockTrainingPlan plan) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/training/plans'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_trainingPlanToGoRequest(plan)),
      ).timeout(_timeout);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('API Error: $e');
      return false;
    }
  }

  /// 更新训练计划
  static Future<bool> updateTrainingPlan(String id, MockTrainingPlan plan) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/training/plans/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_trainingPlanToGoRequest(plan)),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      print('API Error: $e');
      return false;
    }
  }

  /// 从Go后端响应解析动作列表
  static List<MockExercise> _parseExercisesFromGoResponse(dynamic data) {
    if (data is Map && data.containsKey('data')) {
      final responseData = data['data'];
      if (responseData is Map && responseData.containsKey('exercises')) {
        final exercises = responseData['exercises'] as List;
        return exercises.map((json) => _parseExerciseFromGoResponse(json)).toList();
      }
    }
    return MockDataProvider.exercises;
  }

  /// 从Go后端响应解析单个动作
  static MockExercise _parseExerciseFromGoResponse(dynamic json) {
    return MockExercise(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['instructions']?.toString() ?? '',
      muscleGroup: json['muscle_group']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? '中级',
      equipment: json['equipment']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      videoUrl: json['video_url']?.toString() ?? '',
      instructions: (json['instructions']?.toString() ?? '').split('\n').where((s) => s.isNotEmpty).toList(),
      tips: [], // Go后端暂时没有tips字段
      sets: json['sets'] ?? 3,
      reps: json['reps'] ?? 10,
      weight: (json['weight'] ?? 0.0).toDouble(),
      restTime: json['rest_time'] ?? 60,
      calories: json['calories'] ?? 50,
    );
  }

  /// 从Go后端响应解析训练计划列表
  static List<MockTrainingPlan> _parseTrainingPlansFromGoResponse(dynamic data) {
    if (data is Map && data.containsKey('data')) {
      final responseData = data['data'];
      if (responseData is Map && responseData.containsKey('plans')) {
        final plans = responseData['plans'] as List;
        return plans.map((json) => _parseTrainingPlanFromGoResponse(json)).toList();
      }
    }
    return MockDataProvider.trainingPlans;
  }

  /// 从Go后端响应解析单个训练计划
  static MockTrainingPlan _parseTrainingPlanFromGoResponse(dynamic json) {
    return MockTrainingPlan(
      id: json['id']?.toString() ?? '',
      title: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      duration: '${json['duration'] ?? 60}分钟',
      difficulty: json['difficulty']?.toString() ?? '中级',
      calories: json['calories_burned'] ?? 300,
      exercises: (json['exercises'] as List?)?.map((e) => e['name']?.toString() ?? '').toList() ?? [],
      image: json['image_url']?.toString() ?? '',
      isCompleted: false,
      progress: 0.0,
      createdAt: DateTime.now(),
    );
  }

  /// 将训练计划转换为Go后端请求格式
  static Map<String, dynamic> _trainingPlanToGoRequest(MockTrainingPlan plan) {
    return {
      'name': plan.title,
      'description': plan.description,
      'duration': int.tryParse(plan.duration.replaceAll('分钟', '')) ?? 60,
      'calories_burned': plan.calories,
      'difficulty': plan.difficulty,
      'is_public': true,
      'exercises': plan.exerciseDetails.map((e) => _exerciseToGoRequest(e)).toList(),
    };
  }

  /// 将动作转换为Go后端请求格式
  static Map<String, dynamic> _exerciseToGoRequest(MockExercise exercise) {
    return {
      'name': exercise.name,
      'muscle_group': exercise.muscleGroup,
      'difficulty': exercise.difficulty,
      'equipment': exercise.equipment,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'weight': exercise.weight,
      'rest_time': exercise.restTime,
      'instructions': exercise.instructions.join('\n'),
      'image_url': exercise.imageUrl,
      'video_url': exercise.videoUrl,
      'calories': exercise.calories,
    };
  }

  /// 获取模拟数据（当API不可用时）
  static List<MockExercise> _getMockExercises({String? query}) {
    List<MockExercise> exercises = MockDataProvider.exercises;
    
    if (query != null && query.isNotEmpty) {
      exercises = exercises.where((exercise) {
        return exercise.name.toLowerCase().contains(query.toLowerCase()) ||
               exercise.muscleGroup.toLowerCase().contains(query.toLowerCase()) ||
               exercise.description.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    
    return exercises;
  }
}
