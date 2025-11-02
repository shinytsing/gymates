import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/smart_api_config.dart';

/// 📡 CommunityService - 社区数据服务
/// 
/// 功能：
/// - 获取不同Tab的帖子列表（推荐/关注/附近）
/// - 点赞、评论、收藏操作
/// - 发布新帖子
/// - 关注用户
class CommunityService {
  final String baseUrl = SmartApiConfig.baseUrl;
  final _storage = const FlutterSecureStorage();
  
  /// 获取认证 Token
  Future<String?> _getAuthToken() async {
    try {
      return await _storage.read(key: 'access_token');
    } catch (e) {
      print('❌ 获取token失败: $e');
      return null;
    }
  }
  
  /// 获取请求头
  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    final token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// 获取帖子列表
  /// 
  /// [tab] - 'recommended', 'following', 'nearby'
  /// [page] - 页码
  /// [limit] - 每页数量
  /// [latitude] - 纬度（附近Tab使用）
  /// [longitude] - 经度（附近Tab使用）
  Future<Map<String, dynamic>> getPosts({
    required String tab,
    int page = 1,
    int limit = 10,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/community/posts').replace(
        queryParameters: {
          'tab': tab,
          'page': page.toString(),
          'limit': limit.toString(),
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
        },
      );

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  /// 获取单个帖子详情
  Future<Map<String, dynamic>> getPost(int postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/community/posts/$postId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load post: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching post: $e');
      rethrow;
    }
  }

  /// 创建新帖子
  Future<Map<String, dynamic>> createPost({
    required String content,
    required String type,
    List<String>? images,
    List<String>? tags,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/community/posts'),
        headers: headers,
        body: json.encode({
          'content': content,
          'type': type,
          'images': images ?? [],
          'tags': tags ?? [],
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  /// 点赞帖子
  Future<bool> likePost(int postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/community/posts/$postId/like'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  /// 取消点赞
  Future<bool> unlikePost(int postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/community/posts/$postId/like'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error unliking post: $e');
      return false;
    }
  }

  /// 评论帖子
  Future<Map<String, dynamic>> commentPost(int postId, String content) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/community/posts/$postId/comments'),
        headers: headers,
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error commenting: $e');
      rethrow;
    }
  }

  /// 获取帖子评论列表
  Future<Map<String, dynamic>> getComments(int postId, {int page = 1, int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/community/posts/$postId/comments').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      rethrow;
    }
  }

  /// 收藏帖子
  Future<bool> collectPost(int postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/community/posts/$postId/collect'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error collecting post: $e');
      return false;
    }
  }

  /// 取消收藏
  Future<bool> uncollectPost(int postId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/community/posts/$postId/collect'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error uncollecting post: $e');
      return false;
    }
  }

  /// 关注用户
  Future<bool> followUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/mates/follow/$userId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error following user: $e');
      return false;
    }
  }

  /// 取消关注
  Future<bool> unfollowUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/mates/follow/$userId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error unfollowing user: $e');
      return false;
    }
  }

  /// 搜索帖子
  Future<Map<String, dynamic>> searchPosts(String query, {int page = 1, int limit = 10}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/community/search').replace(
        queryParameters: {
          'q': query,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching posts: $e');
      rethrow;
    }
  }
}

