import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/unified_auth_service.dart';

/// 🔑 统一Token管理器
/// 
/// 为所有Service提供统一的Token获取接口
/// 自动处理Token刷新和过期检查
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  final _authService = UnifiedAuthService();
  final _storage = const FlutterSecureStorage();

  /// 获取有效的访问令牌（自动刷新）
  Future<String?> getToken() async {
    return await _authService.getValidAccessToken();
  }

  /// 获取访问令牌（不检查过期）
  Future<String?> getAccessToken() async {
    return await _authService.getAccessToken();
  }

  /// 获取刷新令牌
  Future<String?> getRefreshToken() async {
    return await _authService.getRefreshToken();
  }

  /// 获取用户ID
  Future<String?> getUserId() async {
    return await _authService.getUserId();
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  /// 获取带Authorization头的请求头
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 获取基础请求头（不包含Token）
  Map<String, String> getBasicHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// 刷新Token
  Future<bool> refreshToken() async {
    return await _authService.refreshAccessToken();
  }

  /// 清除所有Token
  Future<void> clearTokens() async {
    await _authService.logout();
  }

  /// 验证Token是否有效
  Future<bool> validateToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 打印Token信息（用于调试）
  Future<void> debugPrintTokenInfo() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    final userId = await getUserId();
    final isLoggedIn = await this.isLoggedIn();

    print('🔑 Token Manager Debug Info:');
    print('  - Is Logged In: $isLoggedIn');
    print('  - User ID: $userId');
    print('  - Access Token: ${accessToken != null ? "✅ Present (${accessToken.length} chars)" : "❌ Missing"}');
    print('  - Refresh Token: ${refreshToken != null ? "✅ Present (${refreshToken.length} chars)" : "❌ Missing"}');
  }
}

