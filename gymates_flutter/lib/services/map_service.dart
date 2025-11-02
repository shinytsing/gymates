import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/smart_api_config.dart';

/// 地图服务
class MapService {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();

  MapService({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? SmartApiConfig.apiBaseUrl;

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

  /// 地理编码 - 将地址转换为经纬度
  Future<Map<String, dynamic>> geocodeAddress(String address) async {
    final url = Uri.parse('$baseUrl/map/geocode');
    
    final body = {
      'address': address,
    };

    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('地理编码失败: ${response.body}');
    }
  }

  /// 搜索附近的健身房
  Future<Map<String, dynamic>> searchNearbyGyms({
    required double latitude,
    required double longitude,
    int radius = 3000,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/map/gyms/nearby');
      
      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      };

      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      print('📍 搜索健身房响应: ${response.statusCode}');
      print('📍 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? '搜索健身房失败');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? '搜索健身房失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 搜索健身房错误: $e');
      rethrow;
    }
  }

  /// 计算两点之间的距离
  Future<Map<String, dynamic>> calculateDistance({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
  }) async {
    final url = Uri.parse('$baseUrl/map/distance');
    
    final body = {
      'origin_lat': originLat,
      'origin_lng': originLng,
      'destination_lat': destinationLat,
      'destination_lng': destinationLng,
    };

    final headers = await _getHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('计算距离失败: ${response.body}');
    }
  }

  /// 获取健身房详情
  Future<Map<String, dynamic>> getGymDetails(String gymId) async {
    final url = Uri.parse('$baseUrl/map/gyms/$gymId');

    final headers = await _getHeaders();
    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('获取健身房详情失败: ${response.body}');
    }
  }

  /// 按城市搜索健身房
  Future<Map<String, dynamic>> searchGymsByCity({
    required String city,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/map/gyms/city?city=$city&page=$page&page_size=$pageSize',
      );

      final headers = await _getHeaders();
      final response = await http.get(
        url,
        headers: headers,
      );

      print('🏙️ 按城市搜索健身房响应: ${response.statusCode}');
      print('🏙️ 响应内容: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        } else {
          throw Exception(data['message'] ?? '搜索健身房失败');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? '搜索健身房失败: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ 按城市搜索健身房错误: $e');
      rethrow;
    }
  }
}

