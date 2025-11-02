/// AI 聊天消息
class ChatMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
    );
  }
}

/// AI 聊天响应
class AIChatResponse {
  final bool success;
  final String response;
  final String? message;

  AIChatResponse({
    required this.success,
    required this.response,
    this.message,
  });

  factory AIChatResponse.fromJson(Map<String, dynamic> json) {
    return AIChatResponse(
      success: json['success'] ?? false,
      response: json['response'] ?? '',
      message: json['message'],
    );
  }
}

/// 健身建议请求
class FitnessAdviceRequest {
  final int age;
  final double height;
  final double weight;
  final String goal;
  final String experience;

  FitnessAdviceRequest({
    required this.age,
    required this.height,
    required this.weight,
    required this.goal,
    required this.experience,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'height': height,
        'weight': weight,
        'goal': goal,
        'experience': experience,
      };
}

/// 训练计划请求
class WorkoutPlanRequest {
  final String goal;
  final String level;
  final int duration;

  WorkoutPlanRequest({
    required this.goal,
    required this.level,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'goal': goal,
        'level': level,
        'duration': duration,
      };
}

