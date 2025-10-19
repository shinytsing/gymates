import 'dart:io';
import 'package:flutter/foundation.dart';

/// 🚀 智能API配置系统
/// 
/// 自动检测运行环境并选择正确的API地址
/// 支持Android模拟器、Web浏览器、iOS模拟器等
class SmartApiConfig {
  static String? _cachedBaseUrl;
  
  /// 获取API基础URL
  static String get baseUrl {
    if (_cachedBaseUrl != null) {
      return _cachedBaseUrl!;
    }
    
    _cachedBaseUrl = _determineApiUrl();
    return _cachedBaseUrl!;
  }
  
  /// 获取API完整URL
  static String get apiBaseUrl => '$baseUrl/api';
  
  /// 获取WebSocket URL
  static String get wsBaseUrl => baseUrl.replaceFirst('http', 'ws');
  
  /// 智能检测API地址
  static String _determineApiUrl() {
    // 1. 检查是否在Web环境
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    
    // 2. 检查是否在Android模拟器
    if (Platform.isAndroid) {
      // Android模拟器使用10.0.2.2访问宿主机
      return 'http://10.0.2.2:8080';
    }
    
    // 3. 检查是否在iOS模拟器
    if (Platform.isIOS) {
      // iOS模拟器可以直接使用localhost
      return 'http://localhost:8080';
    }
    
    // 4. 其他平台默认使用localhost
    return 'http://localhost:8080';
  }
  
  /// 重置缓存（用于测试或动态切换）
  static void resetCache() {
    _cachedBaseUrl = null;
  }
  
  /// 手动设置API地址（用于测试）
  static void setCustomUrl(String url) {
    _cachedBaseUrl = url;
  }
  
  /// 获取当前环境信息
  static Map<String, dynamic> getEnvironmentInfo() {
    return {
      'platform': kIsWeb ? 'Web' : Platform.operatingSystem,
      'isWeb': kIsWeb,
      'isAndroid': !kIsWeb && Platform.isAndroid,
      'isIOS': !kIsWeb && Platform.isIOS,
      'apiUrl': baseUrl,
      'apiBaseUrl': apiBaseUrl,
    };
  }
  
  /// 打印环境信息（调试用）
  static void printEnvironmentInfo() {
    final info = getEnvironmentInfo();
    print('🌍 API Environment Info:');
    info.forEach((key, value) {
      print('  $key: $value');
    });
  }
}

/// API端点常量
class ApiEndpoints {
  // 认证相关
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authRefresh = '/auth/refresh';
  
  // 训练相关
  static const String trainingPlans = '/training/plans';
  static const String weeklyPlans = '/training/weekly-plans';
  static const String exercises = '/training/exercises';
  static const String exerciseSearch = '/training/exercises/search';
  static const String aiRecommendations = '/training/ai-recommendations';
  
  // 社区相关
  static const String communityPosts = '/community/posts';
  static const String communityComments = '/community/posts';
  
  // 好友相关
  static const String mates = '/mates';
  static const String mateRequests = '/mates/requests';
  
  // 消息相关
  static const String messages = '/messages';
  static const String chats = '/messages/chats';
  
  // 用户资料
  static const String profile = '/profile';
  static const String profileMe = '/profile/me';
  static const String profileUpdate = '/profile/update';
}

/// API配置常量
class ApiConstants {
  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // 请求头
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
