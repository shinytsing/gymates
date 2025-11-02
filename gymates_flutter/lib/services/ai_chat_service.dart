import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/smart_api_config.dart';

/// AI 聊天服务
class AIChatService {
  final String baseUrl;
  final String? token;

  AIChatService({
    String? baseUrl,
    this.token,
  }) : baseUrl = baseUrl ?? SmartApiConfig.apiBaseUrl;

  /// 基础 AI 聊天
  Future<Map<String, dynamic>> chat({
    required String message,
    String? systemPrompt,
    List<Map<String, String>>? messages,
  }) async {
    final url = Uri.parse('$baseUrl/ai/chat');
    
    final body = {
      'message': message,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
      if (messages != null) 'messages': messages,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('AI 聊天失败: ${response.body}');
    }
  }

  /// 获取个性化健身建议
  Future<Map<String, dynamic>> getFitnessAdvice({
    required int age,
    required double height,
    required double weight,
    required String goal,
    required String experience,
  }) async {
    final url = Uri.parse('$baseUrl/ai/fitness-advice');
    
    final body = {
      'age': age,
      'height': height,
      'weight': weight,
      'goal': goal,
      'experience': experience,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('获取健身建议失败: ${response.body}');
    }
  }

  /// 生成训练计划
  Future<Map<String, dynamic>> generateWorkoutPlan({
    required String goal,
    required String level,
    required int duration,
  }) async {
    final url = Uri.parse('$baseUrl/ai/workout-plan');
    
    final body = {
      'goal': goal,
      'level': level,
      'duration': duration,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('生成训练计划失败: ${response.body}');
    }
  }

  /// 分析动作姿势
  Future<Map<String, dynamic>> analyzeWorkoutForm({
    required String exerciseName,
    required String description,
  }) async {
    final url = Uri.parse('$baseUrl/ai/analyze-form');
    
    final body = {
      'exercise_name': exerciseName,
      'description': description,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('分析动作失败: ${response.body}');
    }
  }

  /// 获取营养建议
  Future<Map<String, dynamic>> getNutritionAdvice({
    required String goal,
    required double weight,
    required String activityLevel,
  }) async {
    final url = Uri.parse('$baseUrl/ai/nutrition-advice');
    
    final body = {
      'goal': goal,
      'weight': weight,
      'activity_level': activityLevel,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('获取营养建议失败: ${response.body}');
    }
  }
}

