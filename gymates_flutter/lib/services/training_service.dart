import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/smart_api_config.dart';
import '../core/token_manager.dart';

/// 🏋️ TrainingService - 训练数据服务
/// 
/// 功能：
/// - 获取今日训练计划
/// - 创建今日训练计划
/// - 开始训练会话
/// - 更新训练进度
/// - 完成训练
/// - 获取训练历史
/// - 获取训练统计
class TrainingService {
  final String baseUrl = SmartApiConfig.apiBaseUrl;
  final TokenManager _tokenManager = TokenManager();
  final _storage = const FlutterSecureStorage();
  
  /// 获取认证 Token
  Future<String?> _getAuthToken() async {
    try {
      return await _tokenManager.getAccessToken();
    } catch (e) {
      debugPrint('❌ 获取token失败: $e');
      return null;
    }
  }
  
  /// 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    final token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// 获取今日训练计划
  /// 
  /// [date] - 日期字符串 (YYYY-MM-DD)，默认为今天
  Future<Map<String, dynamic>> getTodayWorkout({String? date}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/training/today').replace(
        queryParameters: date != null ? {'date': date} : {},
      );

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('获取今日训练失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching today workout: $e');
      rethrow;
    }
  }

  /// 创建今日训练计划
  /// 
  /// [planId] - 训练计划ID（可选）
  /// [date] - 日期字符串 (YYYY-MM-DD)，默认为今天
  Future<Map<String, dynamic>> createTodayWorkout({
    int? planId,
    String? date,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      
      if (planId != null) {
        body['plan_id'] = planId;
      }
      if (date != null) {
        body['date'] = date;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/training/today'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('创建今日训练失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error creating today workout: $e');
      rethrow;
    }
  }

  /// 开始训练会话
  /// 
  /// [planId] - 训练计划ID（可选）
  /// [isAIWorkout] - 是否为AI训练
  Future<Map<String, dynamic>> startWorkoutSession({
    int? planId,
    bool isAIWorkout = false,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{
        'is_ai_workout': isAIWorkout,
      };
      
      if (planId != null) {
        body['plan_id'] = planId;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/training/sessions/start'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('开始训练失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error starting workout session: $e');
      rethrow;
    }
  }

  /// 更新训练进度
  /// 
  /// [workoutExerciseId] - 训练动作ID
  /// [setNumber] - 组数
  /// [reps] - 次数
  /// [weight] - 重量（可选）
  /// [duration] - 时长（秒，可选）
  Future<bool> updateWorkoutProgress({
    required int workoutExerciseId,
    required int setNumber,
    required int reps,
    double? weight,
    int? duration,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{
        'workout_exercise_id': workoutExerciseId,
        'set_number': setNumber,
        'reps': reps,
      };
      
      if (weight != null) {
        body['weight'] = weight;
      }
      if (duration != null) {
        body['duration'] = duration;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/training/sessions/progress'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error updating workout progress: $e');
      return false;
    }
  }

  /// 完成训练
  /// 
  /// [sessionId] - 训练会话ID
  Future<bool> completeWorkout(int sessionId) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{
        'session_id': sessionId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/training/sessions/complete'),
        headers: headers,
        body: json.encode(body),
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error completing workout: $e');
      return false;
    }
  }

  /// 获取训练历史
  /// 
  /// [page] - 页码
  /// [limit] - 每页数量
  Future<Map<String, dynamic>> getWorkoutHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/training/history').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('获取训练历史失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching workout history: $e');
      rethrow;
    }
  }

  /// 获取训练统计
  Future<Map<String, dynamic>> getTrainingStatistics() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/training/statistics'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('获取训练统计失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching training statistics: $e');
      rethrow;
    }
  }

  /// 获取用户统计
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/training/user-stats'),
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('获取用户统计失败: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching user stats: $e');
      rethrow;
    }
  }
}

