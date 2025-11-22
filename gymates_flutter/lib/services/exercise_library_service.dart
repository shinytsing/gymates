import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/exercise_library.dart';
import '../core/config/smart_api_config.dart';
import 'unified_auth_service.dart';

/// 动作库服务
class ExerciseLibraryService {
  final UnifiedAuthService _authService = UnifiedAuthService();
  
  // 使用 apiBaseUrl (已包含 /api 前缀)
  static String get _baseUrl => SmartApiConfig.apiBaseUrl;

  /// 获取动作库列表
  Future<ExerciseLibraryResponse> getExercises({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未登录');
      }

      // 构建查询参数
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (muscleGroup != null && muscleGroup.isNotEmpty) {
        queryParams['muscle_group'] = muscleGroup;
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queryParams['difficulty'] = difficulty;
      }
      if (equipment != null && equipment.isNotEmpty) {
        queryParams['equipment'] = equipment;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      // URL: http://10.0.2.2:8080/api/training/exercises
      final uri = Uri.parse('$_baseUrl/training/exercises')
          .replace(queryParameters: queryParams);

      print('🌐 请求 URL: $uri');
      print('🔑 Token: ${token.substring(0, min(20, token.length))}...');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 响应状态: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ExerciseLibraryResponse.fromJson(data);
      } else {
        throw Exception('获取动作库失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 获取动作库失败: $e');
      rethrow;
    }
  }

  /// 获取动作详情
  Future<ExerciseLibrary> getExerciseDetail(int id) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/training/exercises/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ExerciseLibrary.fromJson(data['data']);
      } else {
        throw Exception('获取动作详情失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 获取动作详情失败: $e');
      rethrow;
    }
  }

  /// 收藏/取消收藏动作
  Future<bool> toggleFavorite(int id) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/training/exercises/$id/favorite'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        throw Exception('操作失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 收藏操作失败: $e');
      rethrow;
    }
  }
}

