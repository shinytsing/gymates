// API Service for Gymates Flutter App
// This file handles all communication with the Go backend
// NO business logic should be implemented here - only API communication

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/smart_api_config.dart';

class ApiConfig {
  // 使用智能API配置
  static String get baseUrl => SmartApiConfig.apiBaseUrl;
  static String get wsUrl => SmartApiConfig.wsBaseUrl;
  static const Duration timeout = Duration(seconds: 30);
}

class ApiResponse<T> {
  final String status;
  final String message;
  final T? data;
  final String? errorCode;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
    this.errorCode,
    this.details,
    required this.timestamp,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      errorCode: json['error_code'],
      details: json['details'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  bool get isSuccess => status == 'success';
  bool get isError => status == 'error';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  Future<ApiResponse<T>> _makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers).timeout(ApiConfig.timeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.timeout);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(ApiConfig.timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers).timeout(ApiConfig.timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse.fromJson(responseData, fromJson);
    } on SocketException {
      throw Exception('No internet connection');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  // Authentication endpoints
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return _makeRequest<Map<String, dynamic>>(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> register(Map<String, dynamic> userData) async {
    return _makeRequest<Map<String, dynamic>>(
      'POST',
      '/auth/register',
      body: userData,
    );
  }

  Future<ApiResponse<void>> logout() async {
    return _makeRequest<void>(
      'POST',
      '/auth/logout',
    );
  }

  // User endpoints
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return _makeRequest<Map<String, dynamic>>(
      'GET',
      '/users/profile',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserProfile(Map<String, dynamic> profileData) async {
    return _makeRequest<Map<String, dynamic>>(
      'PUT',
      '/users/profile',
      body: profileData,
    );
  }

  // Training endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getTrainingPlans() async {
    return _makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/training/plans',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTrainingPlan(String planId) async {
    return _makeRequest<Map<String, dynamic>>(
      'GET',
      '/training/plans/$planId',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> startTrainingSession(String planId) async {
    return _makeRequest<Map<String, dynamic>>(
      'POST',
      '/training/sessions',
      body: {'plan_id': planId, 'start_time': DateTime.now().toIso8601String()},
    );
  }

  // Community endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getCommunityPosts({int page = 1, int limit = 20}) async {
    return _makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/community/posts?page=$page&limit=$limit',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createPost(Map<String, dynamic> postData) async {
    return _makeRequest<Map<String, dynamic>>(
      'POST',
      '/community/posts',
      body: postData,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> likePost(String postId) async {
    return _makeRequest<Map<String, dynamic>>(
      'POST',
      '/community/posts/$postId/like',
    );
  }

  // Messaging endpoints
  Future<ApiResponse<List<Map<String, dynamic>>>> getConversations() async {
    return _makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/messages/conversations',
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getMessages(String conversationId) async {
    return _makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/messages/conversations/$conversationId/messages',
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> sendMessage(String conversationId, String content) async {
    return _makeRequest<Map<String, dynamic>>(
      'POST',
      '/messages/conversations/$conversationId/messages',
      body: {'content': content},
    );
  }
}

// Error handling utility
class ApiError {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromResponse(ApiResponse response) {
    return ApiError(
      code: response.errorCode ?? 'UNKNOWN_ERROR',
      message: response.message,
      details: response.details,
    );
  }

  @override
  String toString() => 'ApiError($code): $message';
}
