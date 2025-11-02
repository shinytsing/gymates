import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/smart_api_config.dart';
import '../shared/models/api_models.dart';

/// 🔐 增强认证服务
/// 支持手机号登录、社交登录、Token自动刷新
class AuthServiceEnhanced {
  static final AuthServiceEnhanced _instance = AuthServiceEnhanced._internal();
  factory AuthServiceEnhanced() => _instance;
  AuthServiceEnhanced._internal();

  final String baseUrl = SmartApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage();
  
  /// 🔍 检查服务器连接状态
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
  
  // Token 相关常量
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  /// 📱 发送验证码
  Future<SendCodeResult> sendVerificationCode({
    required String phone,
    required String type, // login, register, reset_password
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'type': type,
        }),
      );

      print('📤 发送验证码响应: ${response.statusCode}');
      print('📤 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return SendCodeResult(
            success: true,
            message: data['message'] ?? '验证码已发送',
            code: data['data']?['code'], // 仅开发环境返回
            sentAt: data['data']?['sent_at'],
            expiresIn: data['data']?['expires_in'] ?? 300,
          );
        } else {
          return SendCodeResult(
            success: false,
            message: data['message'] ?? '发送失败',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        return SendCodeResult(
          success: false,
          message: errorData['message'] ?? '发送失败',
        );
      }
    } catch (e) {
      print('❌ 发送验证码错误: $e');
      return SendCodeResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 📱 手机号登录
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

      print('📱 手机号登录响应: ${response.statusCode}');
      print('📱 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final authData = data['data'];
          await _saveAuthData(authData);

          return AuthResult(
            success: true,
            message: data['message'] ?? '登录成功',
            accessToken: authData['access_token'],
            refreshToken: authData['refresh_token'],
            user: User.fromJson(authData['user']),
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
      print('❌ 手机号登录错误: $e');
      
      // 提供更详细的错误信息
      String errorMessage = '网络错误，请稍后重试';
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage = '无法连接到服务器，请检查：\n1. 后端服务是否已启动\n2. 网络连接是否正常\n3. API地址配置是否正确\n\n当前API地址: $baseUrl';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '网络连接失败，请检查网络设置';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = '请求超时，请稍后重试';
      }
      
      return AuthResult(
        success: false,
        message: errorMessage,
        error: e.toString(),
      );
    }
  }

  /// 📱 手机号注册
  Future<AuthResult> phoneRegister({
    required String phone,
    required String code,
    required String name,
    String? password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/phone/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'code': code,
          'name': name,
          if (password != null) 'password': password,
        }),
      );

      print('📝 手机号注册响应: ${response.statusCode}');
      print('📝 响应内容: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final authData = data['data'];
          await _saveAuthData(authData);

          return AuthResult(
            success: true,
            message: data['message'] ?? '注册成功',
            accessToken: authData['access_token'],
            refreshToken: authData['refresh_token'],
            user: User.fromJson(authData['user']),
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
      print('❌ 手机号注册错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 📧 邮箱登录
  Future<AuthResult> emailLogin({
    required String email,
    required String password,
  }) async {
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
      print('📧 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final authData = data['data'];
          await _saveAuthData(authData);

          return AuthResult(
            success: true,
            message: data['message'] ?? '登录成功',
            accessToken: authData['access_token'],
            refreshToken: authData['refresh_token'],
            user: User.fromJson(authData['user']),
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
      print('❌ 邮箱登录错误: $e');
      
      // 提供更详细的错误信息
      String errorMessage = '网络错误，请稍后重试';
      if (e.toString().contains('Failed host lookup') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        errorMessage = '无法连接到服务器，请检查：\n1. 后端服务是否已启动\n2. 网络连接是否正常\n3. API地址配置是否正确\n\n当前API地址: $baseUrl';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = '网络连接失败，请检查网络设置';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = '请求超时，请稍后重试';
      }
      
      return AuthResult(
        success: false,
        message: errorMessage,
        error: e.toString(),
      );
    }
  }

  /// 🍎 社交登录 (Apple, Google, WeChat)
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
      print('🍎 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final authData = data['data'];
          await _saveAuthData(authData);

          return AuthResult(
            success: true,
            message: data['message'] ?? '登录成功',
            accessToken: authData['access_token'],
            refreshToken: authData['refresh_token'],
            user: User.fromJson(authData['user']),
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
      print('❌ 社交登录错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 🍎 Apple 登录（调用后端API获取真实token）
  Future<AuthResult> mockAppleLogin() async {
    print('🍎 Apple 登录开始（调用后端API获取真实token）...');
    return await mockPhoneLogin(); // 复用快捷登录逻辑
  }

  /// 💚 微信登录（调用后端API获取真实token）
  Future<AuthResult> mockWeChatLogin() async {
    print('💚 微信登录开始（调用后端API获取真实token）...');
    return await mockPhoneLogin(); // 复用快捷登录逻辑
  }

  /// 📱 快捷登录（调用后端游客登录 API，获取真实 token）
  Future<AuthResult> mockPhoneLogin() async {
    print('📱 快捷登录开始（调用后端 API 获取真实 token）...');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/guest/login'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📱 快捷登录响应: ${response.statusCode}');
      print('📱 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final authData = data['data'];
    
          // 保存认证数据（会自动持久化存储）
          await _saveAuthData(authData);
    
          print('✅ 快捷登录成功，已获取真实 token');
    
    return AuthResult(
      success: true,
            message: data['message'] ?? '登录成功',
            accessToken: authData['access_token'],
            refreshToken: authData['refresh_token'],
            user: User.fromJson(authData['user']),
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
      print('❌ 快捷登录错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 👤 游客登录
  Future<AuthResult> guestLogin() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/guest/login'),
        headers: {'Content-Type': 'application/json'},
      );

      print('👤 游客登录响应: ${response.statusCode}');
      print('👤 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          final authData = data['data'];
          await _saveAuthData(authData);

          return AuthResult(
            success: true,
            message: data['message'] ?? '游客登录成功',
            accessToken: authData['access_token'],
            refreshToken: authData['refresh_token'],
            user: User.fromJson(authData['user']),
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
      print('❌ 游客登录错误: $e');
      return AuthResult(
        success: false,
        message: '网络错误，请稍后重试',
        error: e.toString(),
      );
    }
  }

  /// 🔄 刷新访问令牌
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
          final authData = data['data'];
          await _saveAuthData(authData);
          print('✅ Token刷新成功');
          return true;
        }
      }
      
      print('❌ Token刷新失败');
      return false;
    } catch (e) {
      print('❌ 刷新令牌错误: $e');
      return false;
    }
  }

  /// 🚪 登出
  Future<void> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      final accessToken = await getAccessToken();
      
      if (refreshToken != null && accessToken != null) {
        // 调用后端撤销令牌接口
        await http.post(
          Uri.parse('$baseUrl/api/auth/revoke'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({
            'refresh_token': refreshToken,
          }),
        );
      }
    } catch (e) {
      print('❌ 登出错误: $e');
    } finally {
      // 无论如何都清除本地存储
      await _clearAuthData();
      print('✅ 本地登出成功');
    }
  }

  /// 💾 保存认证数据
  Future<void> _saveAuthData(Map<String, dynamic> authData) async {
    final accessToken = authData['access_token'];
    final refreshToken = authData['refresh_token'];
    final expiresIn = authData['expires_in'] ?? 1800;
    final user = authData['user'];

    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: user['id'].toString());
    await _storage.write(key: _userDataKey, value: jsonEncode(user));
    
    // 计算过期时间
    final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));
    await _storage.write(key: _tokenExpiryKey, value: expiryTime.toIso8601String());
  }

  /// 🗑️ 清除认证数据
  Future<void> _clearAuthData() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenExpiryKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userDataKey);
  }

  /// 获取访问令牌
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// 获取当前用户 ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// 获取当前用户数据
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      if (userData == null) return null;
      
      return User.fromJson(jsonDecode(userData));
    } catch (e) {
      print('❌ 获取用户数据错误: $e');
      return null;
    }
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// 检查 Token 是否即将过期（提前5分钟刷新）
  Future<bool> isTokenExpiring() async {
    try {
      final expiryStr = await _storage.read(key: _tokenExpiryKey);
      if (expiryStr == null) return true;
      
      final expiryTime = DateTime.parse(expiryStr);
      final now = DateTime.now();
      
      // 如果在5分钟内过期，返回 true
      return now.isAfter(expiryTime.subtract(const Duration(minutes: 5)));
    } catch (e) {
      return true;
    }
  }

  /// 获取有效的访问令牌（自动刷新）
  Future<String?> getValidAccessToken() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;

    // 检查是否即将过期
    if (await isTokenExpiring()) {
      print('🔄 Token即将过期，尝试刷新...');
      final success = await refreshAccessToken();
      if (success) {
        return await getAccessToken();
      } else {
        // 刷新失败，返回原token让后端决定
        return accessToken;
      }
    }

    return accessToken;
  }
}

/// 📝 认证结果模型
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
}

/// 📱 发送验证码结果模型
class SendCodeResult {
  final bool success;
  final String message;
  final String? code; // 仅开发环境
  final String? sentAt;
  final int? expiresIn;
  final String? error;

  SendCodeResult({
    required this.success,
    required this.message,
    this.code,
    this.sentAt,
    this.expiresIn,
    this.error,
  });
}

