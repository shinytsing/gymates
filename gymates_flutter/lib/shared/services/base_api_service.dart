import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/config/smart_api_config.dart';
import '../../core/token_manager.dart';
import '../models/api_response.dart';

/// Base API Service with enhanced error handling and response parsing
/// All module-specific services should extend or use this class
class BaseApiService {
  final http.Client _client;
  final TokenManager _tokenManager;
  final Duration timeout;

  BaseApiService({
    http.Client? client,
    TokenManager? tokenManager,
    this.timeout = const Duration(seconds: 30),
  })  : _client = client ?? http.Client(),
        _tokenManager = tokenManager ?? TokenManager();

  /// Get base URL from smart config
  String get baseUrl => SmartApiConfig.apiBaseUrl;

  /// Get WebSocket URL
  String get wsUrl => SmartApiConfig.wsBaseUrl;

  /// Get auth headers with token
  Future<Map<String, String>> get _headers async {
    return await _tokenManager.getAuthHeaders();
  }

  /// GET request
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _headers;

      final response = await _client
          .get(uri, headers: headers)
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResult.error('No internet connection');
    } on HttpException {
      return ApiResult.error('Server error occurred');
    } on FormatException {
      return ApiResult.error('Invalid response format');
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// POST request
  Future<ApiResult<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _headers;

      final response = await _client
          .post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResult.error('No internet connection');
    } on HttpException {
      return ApiResult.error('Server error occurred');
    } on FormatException {
      return ApiResult.error('Invalid response format');
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// PUT request
  Future<ApiResult<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _headers;

      final response = await _client
          .put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResult.error('No internet connection');
    } on HttpException {
      return ApiResult.error('Server error occurred');
    } on FormatException {
      return ApiResult.error('Invalid response format');
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// DELETE request
  Future<ApiResult<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _headers;

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResult.error('No internet connection');
    } on HttpException {
      return ApiResult.error('Server error occurred');
    } on FormatException {
      return ApiResult.error('Invalid response format');
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// PATCH request
  Future<ApiResult<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final headers = await _headers;

      final response = await _client
          .patch(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResult.error('No internet connection');
    } on HttpException {
      return ApiResult.error('Server error occurred');
    } on FormatException {
      return ApiResult.error('Invalid response format');
    } catch (e) {
      return ApiResult.error(e.toString());
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullPath = '$baseUrl$path';
    
    if (queryParameters != null && queryParameters.isNotEmpty) {
      return Uri.parse(fullPath).replace(queryParameters: _cleanQueryParams(queryParameters));
    }
    
    return Uri.parse(fullPath);
  }

  /// Clean query parameters (remove null values)
  Map<String, String> _cleanQueryParams(Map<String, dynamic> params) {
    final cleaned = <String, String>{};
    params.forEach((key, value) {
      if (value != null) {
        cleaned[key] = value.toString();
      }
    });
    return cleaned;
  }

  /// Handle HTTP response
  ApiResult<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final statusCode = response.statusCode;
      final body = json.decode(response.body);

      // Success responses (200-299)
      if (statusCode >= 200 && statusCode < 300) {
        if (fromJson != null) {
          // Parse response data with provided parser
          final data = body['data'];
          if (data == null) {
            return ApiResult.success(null as T);
          }
          return ApiResult.success(fromJson(data));
        } else {
          // Return raw data
          return ApiResult.success(body['data'] as T);
        }
      }

      // Client errors (400-499)
      if (statusCode >= 400 && statusCode < 500) {
        final message = body['message'] ?? 'Client error occurred';
        return ApiResult.error(message, statusCode: statusCode);
      }

      // Server errors (500-599)
      if (statusCode >= 500) {
        final message = body['message'] ?? 'Server error occurred';
        return ApiResult.error(message, statusCode: statusCode);
      }

      // Other status codes
      return ApiResult.error('Unexpected error occurred', statusCode: statusCode);
    } catch (e) {
      return ApiResult.error('Failed to parse response: ${e.toString()}');
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

