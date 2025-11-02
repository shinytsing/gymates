/// 搭子匹配相关数据模型
library;

/// 搭子资料
class MateProfile {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;
  final String? experience;
  final String? preferredTime;
  final List<String>? trainingTypes;
  final bool lookingForMate;
  final double distance; // 距离（米）
  final int matchScore; // 匹配度分数（0-100）
  final List<String> commonGoals; // 共同健身目标
  final List<String> commonTypes; // 共同训练类型
  final bool isOnline; // 是否在线
  final String? lastActiveAt; // 最后活跃时间
  final DateTime createdAt;
  final DateTime updatedAt;

  MateProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
    this.location,
    this.latitude,
    this.longitude,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.experience,
    this.preferredTime,
    this.trainingTypes,
    this.lookingForMate = false,
    this.distance = 0,
    this.matchScore = 0,
    this.commonGoals = const [],
    this.commonTypes = const [],
    this.isOnline = false,
    this.lastActiveAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MateProfile.fromJson(Map<String, dynamic> json) {
    return MateProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      age: json['age'],
      gender: json['gender'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      goal: json['goal'],
      experience: json['experience'],
      preferredTime: json['preferred_time'],
      trainingTypes: json['training_types'] != null 
          ? (json['training_types'] as String).split(',').map((e) => e.trim()).toList()
          : null,
      lookingForMate: json['looking_for_mate'] ?? false,
      distance: (json['distance'] ?? 0).toDouble(),
      matchScore: json['match_score'] ?? 0,
      commonGoals: json['common_goals'] != null
          ? List<String>.from(json['common_goals'])
          : [],
      commonTypes: json['common_types'] != null
          ? List<String>.from(json['common_types'])
          : [],
      isOnline: json['is_online'] ?? false,
      lastActiveAt: json['last_active_at'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (avatar != null) 'avatar': avatar,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (goal != null) 'goal': goal,
      if (experience != null) 'experience': experience,
      if (preferredTime != null) 'preferred_time': preferredTime,
      if (trainingTypes != null) 'training_types': trainingTypes!.join(','),
      'looking_for_mate': lookingForMate,
      'distance': distance,
      'match_score': matchScore,
      'common_goals': commonGoals,
      'common_types': commonTypes,
      'is_online': isOnline,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 获取格式化的距离
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}米';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
  }

  /// 获取匹配度描述
  String get matchScoreLabel {
    if (matchScore >= 80) return '高度匹配';
    if (matchScore >= 60) return '较为匹配';
    if (matchScore >= 40) return '一般匹配';
    return '匹配度低';
  }

  /// 获取匹配度颜色
  String get matchScoreColor {
    if (matchScore >= 80) return '#4CAF50'; // 绿色
    if (matchScore >= 60) return '#8BC34A'; // 浅绿色
    if (matchScore >= 40) return '#FFC107'; // 黄色
    return '#9E9E9E'; // 灰色
  }
}

/// 搭子筛选选项
class MateFilterOptions {
  final int maxDistance; // 最大距离（米）
  final String? gender; // 性别
  final List<String> trainingTypes; // 训练类型
  final List<String> goals; // 健身目标
  final String? preferredTime; // 偏好时间
  final String? experience; // 经验等级
  final int page;
  final int limit;

  MateFilterOptions({
    this.maxDistance = 5000,
    this.gender,
    this.trainingTypes = const [],
    this.goals = const [],
    this.preferredTime,
    this.experience,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'max_distance': maxDistance,
      'page': page,
      'limit': limit,
    };

    if (gender != null && gender!.isNotEmpty) {
      params['gender'] = gender;
    }

    if (trainingTypes.isNotEmpty) {
      params['training_types'] = trainingTypes.join(',');
    }

    if (goals.isNotEmpty) {
      params['goals'] = goals.join(',');
    }

    if (preferredTime != null && preferredTime!.isNotEmpty) {
      params['preferred_time'] = preferredTime;
    }

    if (experience != null && experience!.isNotEmpty) {
      params['experience'] = experience;
    }

    return params;
  }

  MateFilterOptions copyWith({
    int? maxDistance,
    String? gender,
    List<String>? trainingTypes,
    List<String>? goals,
    String? preferredTime,
    String? experience,
    int? page,
    int? limit,
  }) {
    return MateFilterOptions(
      maxDistance: maxDistance ?? this.maxDistance,
      gender: gender ?? this.gender,
      trainingTypes: trainingTypes ?? this.trainingTypes,
      goals: goals ?? this.goals,
      preferredTime: preferredTime ?? this.preferredTime,
      experience: experience ?? this.experience,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}

/// 搭子推荐响应
class MateRecommendationResponse {
  final List<MateProfile> recommendations;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  MateRecommendationResponse({
    required this.recommendations,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory MateRecommendationResponse.fromJson(Map<String, dynamic> json) {
    final recommendationsData = json['recommendations'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return MateRecommendationResponse(
      recommendations: recommendationsData
          .map((item) => MateProfile.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] ?? 1,
      limit: pagination['limit'] ?? 20,
      total: pagination['total'] ?? 0,
      totalPages: pagination['total_pages'] ?? 0,
      hasMore: pagination['has_more'] ?? false,
    );
  }
}

/// 搭子请求
class MateRequest {
  final int id;
  final int userId;
  final int mateId;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;
  final DateTime updatedAt;

  MateRequest({
    required this.id,
    required this.userId,
    required this.mateId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MateRequest.fromJson(Map<String, dynamic> json) {
    return MateRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      mateId: json['mate_id'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mate_id': mateId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// 训练类型常量
class TrainingTypes {
  static const strength = '力量训练';
  static const cardio = '有氧训练';
  static const yoga = '瑜伽';
  static const hiit = 'HIIT';
  static const crossfit = 'CrossFit';
  static const boxing = '拳击';
  static const swimming = '游泳';
  static const running = '跑步';
  static const cycling = '骑行';
  static const pilates = '普拉提';

  static List<String> get all => [
        strength,
        cardio,
        yoga,
        hiit,
        crossfit,
        boxing,
        swimming,
        running,
        cycling,
        pilates,
      ];
}

/// 健身目标常量
class FitnessGoals {
  static const muscleGain = '增肌';
  static const weightLoss = '减脂';
  static const toning = '塑形';
  static const endurance = '提高耐力';
  static const strength = '增强力量';
  static const flexibility = '提高柔韧性';
  static const maintenance = '保持体态';

  static List<String> get all => [
        muscleGain,
        weightLoss,
        toning,
        endurance,
        strength,
        flexibility,
        maintenance,
      ];
}

/// 经验等级常量
class ExperienceLevels {
  static const beginner = '初级';
  static const intermediate = '中级';
  static const advanced = '高级';

  static List<String> get all => [beginner, intermediate, advanced];
}

/// 偏好时间常量
class PreferredTimes {
  static const morning = '早上(6:00-9:00)';
  static const forenoon = '上午(9:00-12:00)';
  static const afternoon = '下午(12:00-18:00)';
  static const evening = '晚上(18:00-22:00)';
  static const night = '深夜(22:00-6:00)';
  static const flexible = '时间灵活';

  static List<String> get all => [
        morning,
        forenoon,
        afternoon,
        evening,
        night,
        flexible,
      ];
}

