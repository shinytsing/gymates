/// 🌐 训练模块 API 服务
library;

import 'package:dio/dio.dart';
import '../../../core/config/smart_api_config.dart';
import '../models/exercise_model.dart';
import '../models/training_plan_model.dart';
import '../models/training_history_model.dart';

class TrainingApiService {
  static final TrainingApiService _instance = TrainingApiService._internal();
  factory TrainingApiService() => _instance;
  TrainingApiService._internal();

  late Dio _dio;
  final String _baseUrl = SmartApiConfig.baseUrl;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));

    // 添加拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // ==================== 运动库接口 ====================

  /// 获取运动库列表
  Future<Map<String, dynamic>> getExerciseLibrary({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (muscleGroup != null) queryParams['muscle_group'] = muscleGroup;
      if (difficulty != null) queryParams['difficulty'] = difficulty;
      if (equipment != null) queryParams['equipment'] = equipment;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/training/exercises',
        queryParameters: queryParams,
      );

      if (response.data['success']) {
        final exercises = (response.data['data'] as List)
            .map((e) => Exercise.fromJson(e))
            .toList();
        return {
          'exercises': exercises,
          'total': response.data['total'],
          'page': response.data['page'],
          'limit': response.data['limit'],
        };
      } else {
        throw Exception(response.data['message'] ?? '获取运动库失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取运动详情
  Future<Exercise> getExerciseDetail(String exerciseId) async {
    try {
      final response = await _dio.get('/api/training/exercises/$exerciseId');

      if (response.data['success']) {
        return Exercise.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '获取运动详情失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavoriteExercise(String exerciseId) async {
    try {
      final response = await _dio.post('/api/training/exercises/$exerciseId/favorite');

      if (response.data['success']) {
        return response.data['is_favorited'] ?? false;
      } else {
        throw Exception(response.data['message'] ?? '操作失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 训练计划接口 ====================

  /// 创建训练计划
  Future<TrainingPlan> createTrainingPlan(TrainingPlan plan) async {
    try {
      final response = await _dio.post(
        '/api/training/plans',
        data: plan.toJson(),
      );

      if (response.data['success']) {
        return TrainingPlan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '创建训练计划失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取训练计划列表
  Future<Map<String, dynamic>> getTrainingPlans({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/training/plans',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success']) {
        final plans = (response.data['data'] as List)
            .map((e) => TrainingPlan.fromJson(e))
            .toList();
        return {
          'plans': plans,
          'total': response.data['total'],
          'page': response.data['page'],
          'limit': response.data['limit'],
        };
      } else {
        throw Exception(response.data['message'] ?? '获取训练计划失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取训练计划详情
  Future<TrainingPlan> getTrainingPlanDetail(String planId) async {
    try {
      final response = await _dio.get('/api/training/plans/$planId');

      if (response.data['success']) {
        return TrainingPlan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '获取训练计划详情失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 更新训练计划
  Future<TrainingPlan> updateTrainingPlan(TrainingPlan plan) async {
    try {
      final response = await _dio.put(
        '/api/training/plans/${plan.id}',
        data: plan.toJson(),
      );

      if (response.data['success']) {
        return TrainingPlan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '更新训练计划失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除训练计划
  Future<void> deleteTrainingPlan(String planId) async {
    try {
      final response = await _dio.delete('/api/training/plans/$planId');

      if (!response.data['success']) {
        throw Exception(response.data['message'] ?? '删除训练计划失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 今日训练接口 ====================

  /// 获取今日训练
  Future<TodayWorkout?> getTodayWorkout({DateTime? date}) async {
    try {
      final dateStr = date?.toIso8601String().split('T')[0] ?? 
          DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _dio.get(
        '/api/training/today',
        queryParameters: {'date': dateStr},
      );

      if (response.data['success']) {
        if (response.data['data'] == null) {
          return null;
        }
        return TodayWorkout.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '获取今日训练失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 创建今日训练
  Future<TodayWorkout> createTodayWorkout({
    String? planId,
    DateTime? date,
  }) async {
    try {
      final dateStr = date?.toIso8601String().split('T')[0] ?? 
          DateTime.now().toIso8601String().split('T')[0];
      
      final response = await _dio.post(
        '/api/training/today',
        data: {
          'plan_id': planId,
          'date': dateStr,
        },
      );

      if (response.data['success']) {
        return TodayWorkout.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '创建今日训练失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 训练会话接口 ====================

  /// 开始训练会话
  Future<Map<String, dynamic>> startWorkoutSession({
    String? planId,
    bool isAIWorkout = false,
  }) async {
    try {
      final response = await _dio.post(
        '/api/training/sessions/start',
        data: {
          'plan_id': planId,
          'is_ai_workout': isAIWorkout,
        },
      );

      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? '开始训练失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 更新训练进度
  Future<void> updateWorkoutProgress({
    required String workoutExerciseId,
    required int setNumber,
    required int reps,
    double? weight,
    int? duration,
  }) async {
    try {
      final response = await _dio.post(
        '/api/training/sessions/progress',
        data: {
          'workout_exercise_id': workoutExerciseId,
          'set_number': setNumber,
          'reps': reps,
          'weight': weight,
          'duration': duration,
        },
      );

      if (!response.data['success']) {
        throw Exception(response.data['message'] ?? '更新进度失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 完成训练
  Future<void> completeWorkout(String sessionId) async {
    try {
      final response = await _dio.post(
        '/api/training/sessions/complete',
        data: {'session_id': sessionId},
      );

      if (!response.data['success']) {
        throw Exception(response.data['message'] ?? '完成训练失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 训练历史接口 ====================

  /// 获取训练历史
  Future<Map<String, dynamic>> getTrainingHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _dio.get(
        '/api/training/history',
        queryParameters: queryParams,
      );

      if (response.data['success']) {
        final histories = (response.data['data'] as List)
            .map((e) => TrainingHistory.fromJson(e))
            .toList();
        return {
          'histories': histories,
          'total': response.data['total'],
          'page': response.data['page'],
          'limit': response.data['limit'],
        };
      } else {
        throw Exception(response.data['message'] ?? '获取训练历史失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取训练统计
  Future<TrainingStatistics> getTrainingStatistics({
    String period = 'week',
  }) async {
    try {
      final response = await _dio.get(
        '/api/training/statistics',
        queryParameters: {'period': period},
      );

      if (response.data['success']) {
        return TrainingStatistics.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '获取统计数据失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取用户统计
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _dio.get('/api/training/user-stats');

      if (response.data['success']) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? '获取用户统计失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== AI训练接口 ====================

  /// 生成AI训练计划
  Future<TrainingPlan> generateAIWorkoutPlan({
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _dio.post(
        '/api/training/ai/generate-plan',
        data: preferences ?? {},
      );

      if (response.data['success']) {
        return TrainingPlan.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '生成训练计划失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取实时反馈
  Future<String> getRealtimeFeedback({
    required String exerciseName,
    required int currentSet,
    required int targetSets,
    Map<String, dynamic>? performance,
  }) async {
    try {
      final response = await _dio.post(
        '/api/training/ai/feedback',
        data: {
          'exercise_name': exerciseName,
          'current_set': currentSet,
          'target_sets': targetSets,
          'performance': performance ?? {},
        },
      );

      if (response.data['success']) {
        return response.data['feedback'] ?? '';
      } else {
        throw Exception(response.data['message'] ?? '获取反馈失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 生成激励消息
  Future<String> generateMotivationalMessage(String context) async {
    try {
      final response = await _dio.post(
        '/api/training/ai/motivation',
        data: {'context': context},
      );

      if (response.data['success']) {
        return response.data['message'] ?? '';
      } else {
        throw Exception(response.data['message'] ?? '生成激励消息失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 错误处理 ====================

  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('网络连接超时，请检查网络设置');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? '请求失败';
        return Exception('请求失败 ($statusCode): $message');
      case DioExceptionType.cancel:
        return Exception('请求已取消');
      case DioExceptionType.connectionError:
        return Exception('网络连接错误，请检查网络设置');
      case DioExceptionType.badCertificate:
        return Exception('证书验证失败');
      case DioExceptionType.unknown:
      default:
        return Exception('未知错误: ${e.message}');
    }
  }
}

