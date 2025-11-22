import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/llm_config_model.dart';
import '../core/config/smart_api_config.dart';
import 'unified_auth_service.dart';

/// LLM配置服务
class LLMConfigService {
  final UnifiedAuthService _authService = UnifiedAuthService();
  
  static String get _baseUrl => SmartApiConfig.apiBaseUrl;

  /// 获取可用的LLM列表
  Future<LLMConfigsResponse> getAvailableLLMs() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/ai/llm/configs'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📥 LLM配置响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LLMConfigsResponse.fromJson(data);
      } else {
        throw Exception('获取LLM配置失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 获取LLM配置失败: $e');
      rethrow;
    }
  }

  /// 设置用户的LLM提供商
  Future<void> setUserLLMProvider(String provider) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/ai/llm/set-provider'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider': provider,
        }),
      );

      print('📥 切换LLM响应: ${response.statusCode}');

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? '切换失败');
      }
    } catch (e) {
      print('❌ 切换LLM失败: $e');
      rethrow;
    }
  }

  /// 测试LLM连接
  Future<Map<String, dynamic>> testLLMConnection(String provider) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/ai/llm/test-connection'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'provider': provider,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? {};
      } else {
        throw Exception('测试连接失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 测试连接失败: $e');
      rethrow;
    }
  }
}

