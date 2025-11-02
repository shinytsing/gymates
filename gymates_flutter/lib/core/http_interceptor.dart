import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service_enhanced.dart';

/// 🔐 HTTP拦截器
/// 自动添加认证头，自动刷新过期Token
class HttpInterceptor {
  static final HttpInterceptor _instance = HttpInterceptor._internal();
  factory HttpInterceptor() => _instance;
  HttpInterceptor._internal();

  final _authService = AuthServiceEnhanced();
  bool _isRefreshing = false;
  final List<Function> _pendingRequests = [];

  /// GET 请求
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final requestHeaders = await _buildHeaders(headers);
    
    try {
      final response = await http
          .get(Uri.parse(url), headers: requestHeaders)
          .timeout(timeout ?? const Duration(seconds: 30));

      return await _handleResponse(response, () async {
        return await get(url, headers: headers, timeout: timeout);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// POST 请求
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    final requestHeaders = await _buildHeaders(headers);

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: requestHeaders,
            body: body is String ? body : jsonEncode(body),
          )
          .timeout(timeout ?? const Duration(seconds: 30));

      return await _handleResponse(response, () async {
        return await post(url, headers: headers, body: body, timeout: timeout);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// PUT 请求
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    final requestHeaders = await _buildHeaders(headers);

    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: requestHeaders,
            body: body is String ? body : jsonEncode(body),
          )
          .timeout(timeout ?? const Duration(seconds: 30));

      return await _handleResponse(response, () async {
        return await put(url, headers: headers, body: body, timeout: timeout);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE 请求
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final requestHeaders = await _buildHeaders(headers);

    try {
      final response = await http
          .delete(Uri.parse(url), headers: requestHeaders)
          .timeout(timeout ?? const Duration(seconds: 30));

      return await _handleResponse(response, () async {
        return await delete(url, headers: headers, timeout: timeout);
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 构建请求头（自动添加认证）
  Future<Map<String, String>> _buildHeaders(Map<String, String>? headers) async {
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    // 获取有效的访问令牌（自动刷新）
    final accessToken = await _authService.getValidAccessToken();
    if (accessToken != null) {
      requestHeaders['Authorization'] = 'Bearer $accessToken';
    }

    return requestHeaders;
  }

  /// 处理响应（自动刷新Token）
  Future<http.Response> _handleResponse(
    http.Response response,
    Future<http.Response> Function() retryRequest,
  ) async {
    // 如果是 401 未授权错误，尝试刷新Token
    if (response.statusCode == 401) {
      print('🔒 收到401错误，尝试刷新Token...');

      // 防止多个请求同时刷新Token
      if (_isRefreshing) {
        print('⏳ Token正在刷新中，等待完成...');
        // 将请求加入队列
        return await _waitForRefresh(retryRequest);
      }

      _isRefreshing = true;

      try {
        // 尝试刷新Token
        final success = await _authService.refreshAccessToken();

        if (success) {
          print('✅ Token刷新成功，重试请求');
          _isRefreshing = false;
          
          // 执行所有待处理的请求
          _executePendingRequests();
          
          // 重试原始请求
          return await retryRequest();
        } else {
          print('❌ Token刷新失败，需要重新登录');
          _isRefreshing = false;
          _clearPendingRequests();
          
          // Token刷新失败，用户需要重新登录
          // 可以在这里触发导航到登录页
          return response;
        }
      } catch (e) {
        print('❌ Token刷新异常: $e');
        _isRefreshing = false;
        _clearPendingRequests();
        return response;
      }
    }

    return response;
  }

  /// 等待Token刷新完成
  Future<http.Response> _waitForRefresh(
    Future<http.Response> Function() retryRequest,
  ) async {
    // 创建一个 Future 并加入队列
    final completer = Future<http.Response>(() async {
      // 等待刷新完成
      while (_isRefreshing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // 刷新完成后重试请求
      return await retryRequest();
    });

    return completer;
  }

  /// 执行所有待处理的请求
  void _executePendingRequests() {
    for (var request in _pendingRequests) {
      request();
    }
    _pendingRequests.clear();
  }

  /// 清除所有待处理的请求
  void _clearPendingRequests() {
    _pendingRequests.clear();
  }
}

/// 全局HTTP客户端实例
final httpClient = HttpInterceptor();

