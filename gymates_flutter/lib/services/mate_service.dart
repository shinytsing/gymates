import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/smart_api_config.dart';
import '../models/mate_models.dart';

/// 搭子服务
class MateService {
  final String baseUrl;
  final String? token;

  MateService({
    String? baseUrl,
    this.token,
  }) : baseUrl = baseUrl ?? SmartApiConfig.apiBaseUrl;

  /// 获取搭子推荐列表
  Future<MateRecommendationResponse> getMateRecommendations({
    required MateFilterOptions filterOptions,
  }) async {
    final queryParams = filterOptions.toQueryParams();
    final uri = Uri.parse('$baseUrl/api/mates/recommendations').replace(
      queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())),
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return MateRecommendationResponse.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? '获取推荐搭子失败');
      }
    } else {
      throw Exception('获取推荐搭子失败: ${response.body}');
    }
  }

  /// 获取我的搭子列表
  Future<List<MateProfile>> getMyMates({
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$baseUrl/api/mates').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final mates = data['data']['mates'] as List;
        return mates.map((mate) => MateProfile.fromJson(mate)).toList();
      } else {
        throw Exception(data['message'] ?? '获取搭子列表失败');
      }
    } else {
      throw Exception('获取搭子列表失败: ${response.body}');
    }
  }

  /// 发送搭子请求
  Future<void> sendMateRequest(int mateId) async {
    final url = Uri.parse('$baseUrl/api/mates/requests');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'mate_id': mateId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? '发送搭子请求失败');
    }
  }

  /// 接受搭子请求
  Future<void> acceptMateRequest(int requestId) async {
    final url = Uri.parse('$baseUrl/api/mates/requests/$requestId/accept');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? '接受搭子请求失败');
    }
  }

  /// 拒绝搭子请求
  Future<void> rejectMateRequest(int requestId) async {
    final url = Uri.parse('$baseUrl/api/mates/requests/$requestId/reject');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? '拒绝搭子请求失败');
    }
  }

  /// 获取搭子请求列表
  Future<List<MateRequest>> getMateRequests({
    String type = 'received', // received 或 sent
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$baseUrl/api/mates/requests').replace(
      queryParameters: {
        'type': type,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final requests = data['data']['data'] as List;
        return requests.map((req) => MateRequest.fromJson(req)).toList();
      } else {
        throw Exception(data['message'] ?? '获取搭子请求失败');
      }
    } else {
      throw Exception('获取搭子请求失败: ${response.body}');
    }
  }

  /// 移除搭子
  Future<void> removeMate(int mateId) async {
    final url = Uri.parse('$baseUrl/api/mates/$mateId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? '移除搭子失败');
    }
  }

  /// 搜索搭子
  Future<List<MateProfile>> searchMates({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$baseUrl/api/mates/search').replace(
      queryParameters: {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        final mates = data['data']['mates'] as List;
        return mates.map((mate) => MateProfile.fromJson(mate)).toList();
      } else {
        throw Exception(data['message'] ?? '搜索搭子失败');
      }
    } else {
      throw Exception('搜索搭子失败: ${response.body}');
    }
  }

  /// 获取搭子统计
  Future<Map<String, dynamic>> getMateStats() async {
    final url = Uri.parse('$baseUrl/api/mates/stats');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? '获取搭子统计失败');
      }
    } else {
      throw Exception('获取搭子统计失败: ${response.body}');
    }
  }
}

