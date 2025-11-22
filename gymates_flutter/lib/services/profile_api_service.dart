import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/smart_api_config.dart';
import '../core/token_manager.dart';
import '../models/user_achievement_data.dart';

/// 👤 个人中心API服务 - ProfileApiService
/// 
/// 负责个人中心相关的所有API调用：
/// - 用户信息获取和更新
/// - 训练统计数据
/// - 成就徽章
/// - 社交数据

class ProfileApiService {
  static final ProfileApiService _instance = ProfileApiService._internal();
  factory ProfileApiService() => _instance;
  ProfileApiService._internal();

  static String get _baseUrl => SmartApiConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 10);

  final _tokenManager = TokenManager();

  /// 获取请求头（自动包含Token）
  Future<Map<String, String>> get _headers async {
    return await _tokenManager.getAuthHeaders();
  }

  /// 设置Auth Token (已废弃，使用TokenManager自动管理)
  @Deprecated('Token is now managed automatically by TokenManager')
  void setAuthToken(String token) {
    print('⚠️ setAuthToken is deprecated. Token is now managed automatically.');
  }

  /// 清除Auth Token (已废弃，使用TokenManager)
  @Deprecated('Use TokenManager().clearTokens() instead')
  void clearAuthToken() {
    print('⚠️ clearAuthToken is deprecated. Use TokenManager().clearTokens() instead.');
  }

  /// 获取用户完整信息（包含成就数据）
  Future<UserAchievementData?> getUserAchievementData(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/profile'),
        headers: headers,
      ).timeout(_timeout);

      print('📊 获取用户成就数据: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return UserAchievementData.fromJson(data['data']);
        }
      } else if (response.statusCode == 401) {
        print('❌ 未授权，需要登录');
        return null;
      }
    } catch (e) {
      print('❌ 获取用户数据失败: $e');
    }
    
    return null;
  }

  /// 获取用户基本信息
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: headers,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('❌ 获取用户信息失败: $e');
    }
    
    return null;
  }

  /// 获取用户训练统计
  Future<Map<String, dynamic>?> getUserTrainingStats(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/training/stats'),
        headers: headers,
      ).timeout(_timeout);

      print('📊 获取训练统计: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('❌ 获取训练统计失败: $e');
    }
    
    return null;
  }

  /// 获取用户成就徽章
  Future<List<AchievementBadge>> getUserBadges(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/achievements'),
        headers: headers,
      ).timeout(_timeout);

      print('🏆 获取成就徽章: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final badgesData = data['data']['badges'] as List;
          return badgesData.map((b) => AchievementBadge.fromJson(b)).toList();
        }
      }
    } catch (e) {
      print('❌ 获取成就徽章失败: $e');
    }
    
    return [];
  }

  /// 获取用户成就列表（包含进度）
  Future<Map<String, dynamic>> getUserAchievements(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/achievements'),
        headers: headers,
      ).timeout(_timeout);

      print('🏆 获取成就列表: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return {
            'achievements': data['data']['achievements'] ?? [],
            'total': data['data']['total'] ?? 0,
            'unlocked': data['data']['unlocked'] ?? 0,
          };
        }
      }
    } catch (e) {
      print('❌ 获取成就列表失败: $e');
    }
    
    return {
      'achievements': [],
      'total': 0,
      'unlocked': 0,
    };
  }

  /// 获取用户个人记录
  Future<List<PersonalRecord>> getUserPersonalRecords(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/records'),
        headers: headers,
      ).timeout(_timeout);

      print('📈 获取个人记录: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final recordsData = data['data']['records'] as List;
          return recordsData.map((r) => PersonalRecord.fromJson(r)).toList();
        }
      }
    } catch (e) {
      print('❌ 获取个人记录失败: $e');
    }
    
    return [];
  }

  /// 获取用户社交数据
  Future<Map<String, dynamic>?> getUserSocialStats(String userId) async {
    try {
      final headers = await _headers;
      final response = await http.get(
        Uri.parse('$_baseUrl/users/$userId/social/stats'),
        headers: headers,
      ).timeout(_timeout);

      print('👥 获取社交数据: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('❌ 获取社交数据失败: $e');
    }
    
    return null;
  }

  /// 更新用户信息
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      final headers = await _headers;
      final response = await http.put(
        Uri.parse('$_baseUrl/users/$userId'),
        headers: headers,
        body: json.encode(profileData),
      ).timeout(_timeout);

      print('✏️ 更新用户信息: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('❌ 更新用户信息失败: $e');
    }
    
    return false;
  }

  /// 组合获取完整的用户成就数据
  Future<UserAchievementData> fetchCompleteUserData(String userId) async {
    try {
      // 并行请求多个接口
      final results = await Future.wait([
        getUserProfile(userId),
        getUserTrainingStats(userId),
        getUserBadges(userId),
        getUserPersonalRecords(userId),
        getUserSocialStats(userId),
      ]);

      final profile = results[0] as Map<String, dynamic>?;
      final trainingStats = results[1] as Map<String, dynamic>?;
      final badges = results[2] as List<AchievementBadge>;
      final records = results[3] as List<PersonalRecord>;
      final socialStats = results[4] as Map<String, dynamic>?;

      if (profile == null) {
        print('⚠️ 用户信息为空');
        throw Exception('用户信息不存在');
      }

      // 组合数据
      return UserAchievementData(
        id: userId,
        name: profile['name'] ?? '健身达人',
        username: profile['username'] ?? 'user',
        avatar: profile['avatar'] ?? '👨‍💼',
        bio: profile['bio'],
        fitnessGoal: profile['fitness_goal'] ?? profile['fitnessGoal'],
        isVerified: profile['is_verified'] ?? profile['isVerified'] ?? false,
        isPremium: profile['is_premium'] ?? profile['isPremium'] ?? false,
        
        // 社交数据
        followers: socialStats?['followers'] ?? profile['followers'] ?? 0,
        following: socialStats?['following'] ?? profile['following'] ?? 0,
        posts: socialStats?['posts'] ?? profile['posts'] ?? 0,
        
        // 训练统计
        totalSessions: trainingStats?['total_sessions'] ?? trainingStats?['totalSessions'] ?? 0,
        totalHours: (trainingStats?['total_hours'] ?? trainingStats?['totalHours'] ?? 0).toDouble(),
        totalCalories: trainingStats?['total_calories'] ?? trainingStats?['totalCalories'] ?? 0,
        weightChange: (trainingStats?['weight_change'] ?? trainingStats?['weightChange'] ?? 0).toDouble(),
        consecutiveDays: trainingStats?['consecutive_days'] ?? trainingStats?['consecutiveDays'] ?? 0,
        monthlyGoal: trainingStats?['monthly_goal'] ?? trainingStats?['monthlyGoal'] ?? 12,
        monthlyProgress: trainingStats?['monthly_progress'] ?? trainingStats?['monthlyProgress'] ?? 0,
        
        // 成就数据
        badges: badges,
        totalBadges: trainingStats?['total_badges'] ?? trainingStats?['totalBadges'] ?? 20,
        unlockedBadges: badges.where((b) => b.isUnlocked).length,
        
        // 个人记录
        personalRecords: records,
        
        // 内容统计
        workoutPlans: trainingStats?['workout_plans'] ?? trainingStats?['workoutPlans'] ?? 0,
        completedWorkouts: trainingStats?['completed_workouts'] ?? trainingStats?['completedWorkouts'] ?? 0,
        savedPosts: socialStats?['saved_posts'] ?? socialStats?['savedPosts'] ?? 0,
        
        // 会员信息
        membershipExpiry: profile['membership_expiry'] != null
            ? DateTime.parse(profile['membership_expiry'])
            : null,
        membershipTier: profile['membership_tier'] ?? profile['membershipTier'] ?? 'free',
      );
    } catch (e) {
      print('❌ 获取完整用户数据失败: $e');
      rethrow;
    }
  }
}

