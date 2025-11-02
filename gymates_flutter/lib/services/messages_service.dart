import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/smart_api_config.dart';
import '../core/token_manager.dart';
import '../models/message_models.dart';

/// 📩 消息服务类
/// 
/// 处理所有与消息、聊天、通知相关的API请求

class MessagesService {
  final String baseUrl = SmartApiConfig.baseUrl;
  final _tokenManager = TokenManager();

  // 获取授权头
  Future<Map<String, String>> _getHeaders() async {
    return await _tokenManager.getAuthHeaders();
  }

  // 获取认证 Token
  Future<String?> getAuthToken() async {
    return await _tokenManager.getAccessToken();
  }

  /// 获取聊天列表
  Future<List<ChatConversation>> getChats({int page = 1, int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/chats?page=$page&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final chats = (data['data']['chats'] as List)
              .map((chat) => ChatConversation.fromJson(chat))
              .toList();
          return chats;
        }
      }
      throw Exception('获取聊天列表失败');
    } catch (e) {
      print('获取聊天列表错误: $e');
      rethrow;
    }
  }

  /// 获取单个聊天
  Future<ChatConversation> getChat(int chatId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/chats/$chatId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ChatConversation.fromJson(data['data']);
        }
      }
      throw Exception('获取聊天失败');
    } catch (e) {
      print('获取聊天错误: $e');
      rethrow;
    }
  }

  /// 获取聊天消息
  Future<List<ChatMessage>> getMessages(int chatId, {int page = 1, int limit = 30}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/chats/$chatId/messages?page=$page&limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final messages = (data['data']['messages'] as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList();
          return messages;
        }
      }
      throw Exception('获取消息失败');
    } catch (e) {
      print('获取消息错误: $e');
      rethrow;
    }
  }

  /// 发送消息
  Future<ChatMessage> sendMessage(int chatId, SendMessageRequest request) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/chats/$chatId/messages'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ChatMessage.fromJson(data['data']);
        }
      }
      throw Exception('发送消息失败');
    } catch (e) {
      print('发送消息错误: $e');
      rethrow;
    }
  }

  /// 创建新聊天
  Future<ChatConversation> createChat(CreateChatRequest request) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/chats'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ChatConversation.fromJson(data['data']);
        }
      }
      throw Exception('创建聊天失败');
    } catch (e) {
      print('创建聊天错误: $e');
      rethrow;
    }
  }

  /// 标记消息为已读
  Future<void> markAsRead(int chatId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/messages/chats/$chatId/read'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('标记已读失败');
      }
    } catch (e) {
      print('标记已读错误: $e');
      rethrow;
    }
  }

  /// 获取未读消息数量
  Future<UnreadCount> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/messages/unread'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return UnreadCount.fromJson(data['data']);
        }
      }
      throw Exception('获取未读数量失败');
    } catch (e) {
      print('获取未读数量错误: $e');
      return UnreadCount();
    }
  }

  /// 获取通知列表
  Future<List<AppNotification>> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications?page=$page&limit=$limit'),
        headers: headers,
      );

      print('📥 获取通知响应: ${response.statusCode}');
      print('📥 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // 检查是否有 notifications 数据
          if (data['data'] != null && data['data']['notifications'] != null) {
            final notifications = (data['data']['notifications'] as List)
                .map((notif) => AppNotification.fromJson(notif))
                .toList();
            return notifications;
          } else {
            // 如果没有通知数据，返回空列表
            print('⚠️ 通知数据为空，返回空列表');
            return [];
          }
        } else {
          throw Exception(data['message'] ?? '获取通知失败');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? '获取通知失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 获取通知错误: $e');
      rethrow;
    }
  }

  /// 标记单个通知为已读
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('标记通知已读失败');
      }
    } catch (e) {
      print('标记通知已读错误: $e');
      rethrow;
    }
  }

  /// 标记所有通知为已读
  Future<void> markAllNotificationsAsRead() async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/read-all'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('标记所有通知已读失败');
      }
    } catch (e) {
      print('标记所有通知已读错误: $e');
      rethrow;
    }
  }

  /// 删除通知
  Future<void> deleteNotification(int notificationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/notifications/$notificationId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('删除通知失败');
      }
    } catch (e) {
      print('删除通知错误: $e');
      rethrow;
    }
  }

  /// 上传图片消息
  Future<ChatMessage> sendImageMessage(int chatId, String imagePath) async {
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/messages/chats/$chatId/images'),
      );
      
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ChatMessage.fromJson(data['data']);
        }
      }
      throw Exception('发送图片失败');
    } catch (e) {
      print('发送图片错误: $e');
      rethrow;
    }
  }

  /// 搜索用户（用于创建新聊天）
  Future<List<ChatUser>> searchUsers(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/search?q=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final users = (data['data']['users'] as List)
              .map((user) => ChatUser.fromJson(user))
              .toList();
          return users;
        }
      }
      throw Exception('搜索用户失败');
    } catch (e) {
      print('搜索用户错误: $e');
      return [];
    }
  }
}

