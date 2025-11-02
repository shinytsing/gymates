/// 👤 用户成就和统计数据模型
/// 
/// 用于个人中心页面的完整用户数据模型
library;

class UserAchievementData {
  // 基本信息
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String? bio;
  final String? fitnessGoal;
  final bool isVerified;
  final bool isPremium;
  
  // 社交数据
  final int followers;
  final int following;
  final int posts;
  
  // 训练统计
  final int totalSessions;      // 总训练次数
  final double totalHours;      // 总训练时长（小时）
  final int totalCalories;      // 总消耗卡路里
  final double weightChange;    // 体重变化（kg）
  final int consecutiveDays;    // 连续训练天数
  final int monthlyGoal;        // 月度目标
  final int monthlyProgress;    // 月度进度
  
  // 成就徽章
  final List<AchievementBadge> badges;
  final int totalBadges;
  final int unlockedBadges;
  
  // 个人记录
  final List<PersonalRecord> personalRecords;
  
  // 内容统计
  final int workoutPlans;
  final int completedWorkouts;
  final int savedPosts;
  
  // 会员信息
  final DateTime? membershipExpiry;
  final String membershipTier;
  
  UserAchievementData({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    this.bio,
    this.fitnessGoal,
    this.isVerified = false,
    this.isPremium = false,
    required this.followers,
    required this.following,
    required this.posts,
    required this.totalSessions,
    required this.totalHours,
    required this.totalCalories,
    required this.weightChange,
    required this.consecutiveDays,
    required this.monthlyGoal,
    required this.monthlyProgress,
    required this.badges,
    required this.totalBadges,
    required this.unlockedBadges,
    required this.personalRecords,
    required this.workoutPlans,
    required this.completedWorkouts,
    required this.savedPosts,
    this.membershipExpiry,
    this.membershipTier = 'free',
  });

  factory UserAchievementData.fromJson(Map<String, dynamic> json) {
    return UserAchievementData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      bio: json['bio'],
      fitnessGoal: json['fitness_goal'],
      isVerified: json['is_verified'] ?? false,
      isPremium: json['is_premium'] ?? false,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      posts: json['posts'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      totalCalories: json['total_calories'] ?? 0,
      weightChange: (json['weight_change'] ?? 0).toDouble(),
      consecutiveDays: json['consecutive_days'] ?? 0,
      monthlyGoal: json['monthly_goal'] ?? 12,
      monthlyProgress: json['monthly_progress'] ?? 0,
      badges: (json['badges'] as List?)
              ?.map((b) => AchievementBadge.fromJson(b))
              .toList() ??
          [],
      totalBadges: json['total_badges'] ?? 0,
      unlockedBadges: json['unlocked_badges'] ?? 0,
      personalRecords: (json['personal_records'] as List?)
              ?.map((r) => PersonalRecord.fromJson(r))
              .toList() ??
          [],
      workoutPlans: json['workout_plans'] ?? 0,
      completedWorkouts: json['completed_workouts'] ?? 0,
      savedPosts: json['saved_posts'] ?? 0,
      membershipExpiry: json['membership_expiry'] != null
          ? DateTime.parse(json['membership_expiry'])
          : null,
      membershipTier: json['membership_tier'] ?? 'free',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'avatar': avatar,
      'bio': bio,
      'fitness_goal': fitnessGoal,
      'is_verified': isVerified,
      'is_premium': isPremium,
      'followers': followers,
      'following': following,
      'posts': posts,
      'total_sessions': totalSessions,
      'total_hours': totalHours,
      'total_calories': totalCalories,
      'weight_change': weightChange,
      'consecutive_days': consecutiveDays,
      'monthly_goal': monthlyGoal,
      'monthly_progress': monthlyProgress,
      'badges': badges.map((b) => b.toJson()).toList(),
      'total_badges': totalBadges,
      'unlocked_badges': unlockedBadges,
      'personal_records': personalRecords.map((r) => r.toJson()).toList(),
      'workout_plans': workoutPlans,
      'completed_workouts': completedWorkouts,
      'saved_posts': savedPosts,
      'membership_expiry': membershipExpiry?.toIso8601String(),
      'membership_tier': membershipTier,
    };
  }

  /// 获取月度完成百分比
  double get monthlyProgressPercentage {
    if (monthlyGoal == 0) return 0.0;
    return (monthlyProgress / monthlyGoal).clamp(0.0, 1.0);
  }

  /// 是否达成月度目标
  bool get isMonthlyGoalAchieved => monthlyProgress >= monthlyGoal;

  /// 模拟数据
  static UserAchievementData mockData() {
    return UserAchievementData(
      id: '1',
      name: '健身达人',
      username: 'fitness_pro',
      avatar: '👨‍💼',
      bio: '热爱健身，追求健康生活方式 💪',
      fitnessGoal: '增肌塑形',
      isVerified: true,
      isPremium: true,
      followers: 1280,
      following: 456,
      posts: 89,
      totalSessions: 156,
      totalHours: 234.5,
      totalCalories: 125000,
      weightChange: -5.2,
      consecutiveDays: 15,
      monthlyGoal: 12,
      monthlyProgress: 9,
      badges: [
        AchievementBadge(
          id: '1',
          title: '健身新手',
          description: '完成第一次训练',
          icon: '🏆',
          isUnlocked: true,
          unlockedDate: DateTime.now().subtract(const Duration(days: 150)),
          category: 'milestone',
        ),
        AchievementBadge(
          id: '2',
          title: '坚持达人',
          description: '连续训练7天',
          icon: '🔥',
          isUnlocked: true,
          unlockedDate: DateTime.now().subtract(const Duration(days: 120)),
          category: 'consistency',
        ),
        AchievementBadge(
          id: '3',
          title: '力量之王',
          description: '卧推突破100kg',
          icon: '💪',
          isUnlocked: true,
          unlockedDate: DateTime.now().subtract(const Duration(days: 60)),
          category: 'strength',
        ),
        AchievementBadge(
          id: '4',
          title: '社交达人',
          description: '获得1000个点赞',
          icon: '❤️',
          isUnlocked: false,
          category: 'social',
        ),
        AchievementBadge(
          id: '5',
          title: '马拉松挑战',
          description: '完成42公里跑步',
          icon: '🏃',
          isUnlocked: false,
          category: 'endurance',
        ),
      ],
      totalBadges: 20,
      unlockedBadges: 12,
      personalRecords: [
        PersonalRecord(
          id: '1',
          exercise: '卧推',
          value: 100.0,
          unit: 'kg',
          date: DateTime.now().subtract(const Duration(days: 30)),
        ),
        PersonalRecord(
          id: '2',
          exercise: '深蹲',
          value: 150.0,
          unit: 'kg',
          date: DateTime.now().subtract(const Duration(days: 20)),
        ),
        PersonalRecord(
          id: '3',
          exercise: '硬拉',
          value: 180.0,
          unit: 'kg',
          date: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
      workoutPlans: 8,
      completedWorkouts: 156,
      savedPosts: 45,
      membershipExpiry: DateTime.now().add(const Duration(days: 90)),
      membershipTier: 'premium',
    );
  }
}

/// 成就徽章模型
class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final String category; // milestone, consistency, strength, social, endurance

  AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedDate,
    required this.category,
  });

  factory AchievementBadge.fromJson(Map<String, dynamic> json) {
    return AchievementBadge(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '🏆',
      isUnlocked: json['is_unlocked'] ?? false,
      unlockedDate: json['unlocked_date'] != null
          ? DateTime.parse(json['unlocked_date'])
          : null,
      category: json['category'] ?? 'milestone',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'is_unlocked': isUnlocked,
      'unlocked_date': unlockedDate?.toIso8601String(),
      'category': category,
    };
  }
}

/// 个人记录模型
class PersonalRecord {
  final String id;
  final String exercise;
  final double value;
  final String unit;
  final DateTime date;

  PersonalRecord({
    required this.id,
    required this.exercise,
    required this.value,
    required this.unit,
    required this.date,
  });

  factory PersonalRecord.fromJson(Map<String, dynamic> json) {
    return PersonalRecord(
      id: json['id'] ?? '',
      exercise: json['exercise'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercise': exercise,
      'value': value,
      'unit': unit,
      'date': date.toIso8601String(),
    };
  }
}

