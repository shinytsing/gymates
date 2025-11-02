import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/smart_api_config.dart';

/// 🔐 认证服务
/// 处理用户登录、注册、登出等认证相关操作
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final String baseUrl = SmartApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage();
  
  // Token 相关常量
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  /// 登录
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('登录响应状态: ${response.statusCode}');
      debugPrint('登录响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final authData = data['data'];
          final token = authData['token'];
          final userData = authData['user'];

          // 保存认证信息
          await _storage.write(key: _tokenKey, value: token);
          await _storage.write(key: _userIdKey, value: userData['id'].toString());
          await _storage.write(key: _userEmailKey, value: userData['email']);

          return AuthResult(
            success: true,
            message: data['message'] ?? '登录成功',
            token: token,
            user: User.fromJson(userData),
          );
        } else {
          return AuthResult(
            success: false,
            message: data['message'] ?? '登录失败',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: errorData['message'] ?? '登录失败',
        );
      }
    } catch (e) {
      debugPrint('登录错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 注册
  Future<AuthResult> register({
    required String email,
    required String password,
    required String username,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
          if (phone != null) 'phone': phone,
        }),
      );

      debugPrint('注册响应状态: ${response.statusCode}');
      debugPrint('注册响应内容: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final authData = data['data'];
          final token = authData['token'];
          final userData = authData['user'];

          // 保存认证信息
          await _storage.write(key: _tokenKey, value: token);
          await _storage.write(key: _userIdKey, value: userData['id'].toString());
          await _storage.write(key: _userEmailKey, value: userData['email']);

          return AuthResult(
            success: true,
            message: data['message'] ?? '注册成功',
            token: token,
            user: User.fromJson(userData),
          );
        } else {
          return AuthResult(
            success: false,
            message: data['message'] ?? '注册失败',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        return AuthResult(
          success: false,
          message: errorData['message'] ?? '注册失败',
        );
      }
    } catch (e) {
      debugPrint('注册错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      final token = await getToken();
      
      if (token != null) {
        // 调用后端登出接口（可选）
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
      
      // 清除本地存储
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userEmailKey);
      
      debugPrint('登出成功');
    } catch (e) {
      debugPrint('登出错误: $e');
      // 即使出错也清除本地存储
      await _storage.deleteAll();
    }
  }

  /// 获取当前 Token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// 获取当前用户 ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// 获取当前用户邮箱
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 获取当前用户信息
  Future<User?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return User.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('获取用户信息错误: $e');
      return null;
    }
  }

  /// 验证 Token 是否有效
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Token 验证错误: $e');
      return false;
    }
  }
}

/// 认证结果模型
class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.error,
  });
}

/// 用户模型
class User {
  final int id;
  final String email;
  final String username;
  final String? phone;
  final String? avatar;
  final String? bio;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
    this.avatar,
    this.bio,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// 为了兼容性，添加 debugPrint
void debugPrint(String message) {
  print(message);
}

