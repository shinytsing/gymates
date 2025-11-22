import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/smart_api_config.dart';

/// 🔐 统一认证服务
/// 整合了基础认证和增强认证功能
/// 支持：邮箱登录、手机登录、社交登录、Token管理、自动刷新
class UnifiedAuthService {
  static final UnifiedAuthService _instance = UnifiedAuthService._internal();
  factory UnifiedAuthService() => _instance;
  UnifiedAuthService._internal();

  final String baseUrl = SmartApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage();

  // Storage Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  // ============================================
  // 基础认证方法
  // ============================================

  /// 📧 邮箱登录
  Future<AuthResult> emailLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('📧 邮箱登录响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _saveAuthData(data['data']);
          return AuthResult(
            success: true,
            message: data['message'] ?? '登录成功',
            accessToken: data['data']['access_token'] ?? data['data']['token'],
            user: User.fromJson(data['data']['user']),
          );
        }
      }
      
      final errorData = jsonDecode(response.body);
      return AuthResult(
        success: false,
        message: errorData['message'] ?? '登录失败',
      );
    } catch (e) {
      print('❌ 邮箱登录错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 📱 手机号登录（开发模式：跳过验证码验证）
  Future<AuthResult> phoneLogin({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/phone/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'code': code,
        }),
      );

      print('📱 手机登录响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _saveAuthData(data['data']);
          return AuthResult(
            success: true,
            message: data['message'] ?? '登录成功',
            accessToken: data['data']['access_token'],
            refreshToken: data['data']['refresh_token'],
            user: User.fromJson(data['data']['user']),
          );
        }
      }

      final errorData = jsonDecode(response.body);
      return AuthResult(
        success: false,
        message: errorData['message'] ?? '登录失败',
      );
    } catch (e) {
      print('❌ 手机登录错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 🍎 社交登录（Apple, Google, 微信）
  Future<AuthResult> socialLogin({
    required String provider, // apple, google, wechat
    required String accessToken,
    Map<String, dynamic>? userInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/social/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'provider': provider,
          'access_token': accessToken,
          if (userInfo != null) 'user_info': userInfo,
        }),
      );

      print('🍎 社交登录响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🍎 解析响应成功, success=${data['success']}');
        if (data['success'] == true) {
          print('🍎 开始保存认证数据...');
          await _saveAuthData(data['data']);
          return AuthResult(
            success: true,
            message: data['message'] ?? '登录成功',
            accessToken: data['data']['access_token'],
            refreshToken: data['data']['refresh_token'],
            user: User.fromJson(data['data']['user']),
          );
        }
      }

      final errorData = jsonDecode(response.body);
      return AuthResult(
        success: false,
        message: errorData['message'] ?? '登录失败',
      );
    } catch (e) {
      print('❌ 社交登录错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 📝 注册
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

      print('📝 注册响应: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _saveAuthData(data['data']);
          return AuthResult(
            success: true,
            message: data['message'] ?? '注册成功',
            accessToken: data['data']['access_token'] ?? data['data']['token'],
            user: User.fromJson(data['data']['user']),
          );
        }
      }

      final errorData = jsonDecode(response.body);
      return AuthResult(
        success: false,
        message: errorData['message'] ?? '注册失败',
      );
    } catch (e) {
      print('❌ 注册错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  // ============================================
  // Mock 登录方法（开发用）
  // ============================================

  /// 💚 微信登录（Mock）
  Future<AuthResult> mockWeChatLogin() async {
    print('💚 微信登录（Mock）...');
    return await socialLogin(
      provider: 'wechat',
      accessToken: 'mock_wechat_token_${DateTime.now().millisecondsSinceEpoch}',
      userInfo: {
        'nickname': '微信用户',
        'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
      },
    );
  }

  /// 🍎 Apple 登录（Mock）
  Future<AuthResult> mockAppleLogin() async {
    print('🍎 Apple 登录（Mock）...');
    return await socialLogin(
      provider: 'apple',
      accessToken: 'mock_apple_token_${DateTime.now().millisecondsSinceEpoch}',
      userInfo: {
        'nickname': 'Apple用户',
        'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
      },
    );
  }

  /// 📱 快捷登录（Mock）
  Future<AuthResult> mockPhoneLogin() async {
    print('📱 快捷登录（Mock）...');
    return await phoneLogin(
      phone: '13800138000',
      code: '123456',
    );
  }

  // ============================================
  // Token 管理
  // ============================================

  /// 保存认证数据
  Future<void> _saveAuthData(Map<String, dynamic> authData) async {
    print('💾 开始保存认证数据...');
    final accessToken = authData['access_token'] ?? authData['token'];
    final refreshToken = authData['refresh_token'];
    final expiresIn = authData['expires_in'] ?? 7200;
    final user = authData['user'];

    print('💾 Access Token: ${accessToken?.substring(0, 20)}...');
    print('💾 Refresh Token: ${refreshToken?.substring(0, 20)}...');
    print('💾 Expires In: $expiresIn seconds');

    if (accessToken != null) {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      print('✅ Access Token 已保存到: $_accessTokenKey');
    }
    
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      print('✅ Refresh Token 已保存');
    }

    // 计算过期时间
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    await _storage.write(key: _tokenExpiryKey, value: expiryTime.toIso8601String());
    print('✅ Token 过期时间已保存: $expiryTime');

    if (user != null) {
      await _storage.write(key: _userIdKey, value: user['id'].toString());
      await _storage.write(key: _userDataKey, value: jsonEncode(user));
      print('✅ 用户数据已保存: ${user['name']}');
    }

    print('✅ 认证数据已全部保存');
  }

  /// 获取访问令牌（带迁移逻辑）
  Future<String?> getAccessToken() async {
    // 先尝试从新 key 读取
    String? token = await _storage.read(key: _accessTokenKey);
    print('🔍 从 $_accessTokenKey 读取 Token: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
    
    // 如果没有，尝试从旧 key 迁移
    if (token == null) {
      token = await _storage.read(key: 'auth_token'); // 旧的 key
      if (token != null) {
        // 迁移到新 key
        await _storage.write(key: _accessTokenKey, value: token);
        await _storage.delete(key: 'auth_token');
        print('✅ Token 已从旧存储迁移到新存储');
      } else {
        print('❌ 未找到任何 Token（新key和旧key都没有）');
      }
    }
    
    return token;
  }

  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 获取用户 ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// 获取用户数据
  Future<User?> getUserData() async {
    try {
      final userDataStr = await _storage.read(key: _userDataKey);
      if (userDataStr != null) {
        final userData = jsonDecode(userDataStr);
        return User.fromJson(userData);
      }
    } catch (e) {
      print('❌ 获取用户数据错误: $e');
    }
    return null;
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// 获取有效的 Token（自动刷新）
  Future<String?> getValidToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    // 检查是否即将过期
    final expiryStr = await _storage.read(key: _tokenExpiryKey);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)))) {
        // Token 即将过期，尝试刷新
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getAccessToken();
        }
      }
    }

    return accessToken;
  }

  /// 刷新访问令牌
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        print('❌ 没有刷新令牌');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      print('🔄 刷新令牌响应: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await _saveAuthData(data['data']);
          print('✅ Token 刷新成功');
          return true;
        }
      }

      print('❌ Token 刷新失败');
      return false;
    } catch (e) {
      print('❌ Token 刷新错误: $e');
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      final token = await getAccessToken();
      
      if (token != null) {
        // 调用后端登出接口
        await http.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      print('❌ 登出请求错误: $e');
    } finally {
      // 无论如何都清除本地数据
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _tokenExpiryKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _userDataKey);
      print('✅ 登出成功');
    }
  }

  /// 获取当前用户信息（从服务器）
  Future<User?> getCurrentUser() async {
    try {
      final token = await getValidToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final user = User.fromJson(data['data']);
          // 更新本地缓存
          await _storage.write(key: _userDataKey, value: jsonEncode(data['data']));
          return user;
        }
      }
      return null;
    } catch (e) {
      print('❌ 获取用户信息错误: $e');
      return null;
    }
  }

  /// 验证 Token 是否有效
  Future<bool> validateToken() async {
    try {
      final token = await getAccessToken();
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
      print('❌ Token 验证错误: $e');
      return false;
    }
  }

  /// 检查服务器连接
  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('服务器连接超时', const Duration(seconds: 5));
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ 服务器连接检查失败: $e');
      return false;
    }
  }

  // ============================================
  // 兼容性方法（用于平滑迁移）
  // ============================================

  /// 兼容旧的 login 方法
  Future<AuthResult> login(String email, String password) async {
    return await emailLogin(email, password);
  }

  /// 兼容旧的 getToken 方法
  Future<String?> getToken() async {
    return await getAccessToken();
  }

  /// 兼容旧的 getUserEmail 方法
  Future<String?> getUserEmail() async {
    final user = await getUserData();
    return user?.email;
  }

  /// 兼容旧的 getValidAccessToken 方法
  Future<String?> getValidAccessToken() async {
    return await getValidToken();
  }
}

// ============================================
// 数据模型
// ============================================

/// 认证结果模型
class AuthResult {
  final bool success;
  final String message;
  final String? accessToken;
  final String? refreshToken;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    required this.message,
    this.accessToken,
    this.refreshToken,
    this.user,
    this.error,
  });

  // 兼容旧的 token 字段
  String? get token => accessToken;
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

  // 兼容性 getter
  String get name => username;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
      bio: json['bio']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
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

