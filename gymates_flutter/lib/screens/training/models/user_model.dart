/// 👤 用户数据模型 (用于 AI 训练推荐)
library;

/// 用户信息
class UserProfile {
  final String id;
  final String username;
  final String email;
  final int? age;
  final String? gender; // male, female, other
  final double? weight; // kg
  final double? height; // cm
  final String? fitnessLevel; // beginner, intermediate, advanced
  final String? fitnessGoal; // strength, muscle, endurance, weight_loss, flexibility
  final List<String>? healthConditions;
  final List<String>? preferences; // equipment preferences, time preferences, etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.fitnessLevel,
    this.fitnessGoal,
    this.healthConditions,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      age: json['age'],
      gender: json['gender'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      fitnessLevel: json['fitness_level'],
      fitnessGoal: json['fitness_goal'],
      healthConditions: json['health_conditions'] != null
          ? List<String>.from(json['health_conditions'])
          : null,
      preferences: json['preferences'] != null
          ? List<String>.from(json['preferences'])
          : null,
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
      'username': username,
      'email': email,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'fitness_level': fitnessLevel,
      'fitness_goal': fitnessGoal,
      'health_conditions': healthConditions,
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 计算 BMI
  double? get bmi {
    if (weight == null || height == null || height == 0) return null;
    return weight! / ((height! / 100) * (height! / 100));
  }

  /// BMI 分类
  String? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;
    if (bmiValue < 18.5) return 'underweight';
    if (bmiValue < 25) return 'normal';
    if (bmiValue < 30) return 'overweight';
    return 'obese';
  }
}

/// 用户训练统计
class UserTrainingStats {
  final String userId;
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCaloriesBurned;
  final int currentStreak; // consecutive days
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final Map<String, int>? muscleGroupFrequency; // muscle group -> count
  final List<String>? recentActivities;
  final double? averageIntensity; // 0-1

  UserTrainingStats({
    required this.userId,
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCaloriesBurned,
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutDate,
    this.muscleGroupFrequency,
    this.recentActivities,
    this.averageIntensity,
  });

  factory UserTrainingStats.fromJson(Map<String, dynamic> json) {
    return UserTrainingStats(
      userId: json['user_id'].toString(),
      totalWorkouts: json['total_workouts'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      totalCaloriesBurned: json['total_calories_burned'] ?? 0,
      currentStreak: json['current_streak'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      lastWorkoutDate: json['last_workout_date'] != null
          ? DateTime.parse(json['last_workout_date'])
          : null,
      muscleGroupFrequency: json['muscle_group_frequency'] != null
          ? Map<String, int>.from(json['muscle_group_frequency'])
          : null,
      recentActivities: json['recent_activities'] != null
          ? List<String>.from(json['recent_activities'])
          : null,
      averageIntensity: json['average_intensity']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'total_calories_burned': totalCaloriesBurned,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'muscle_group_frequency': muscleGroupFrequency,
      'recent_activities': recentActivities,
      'average_intensity': averageIntensity,
    };
  }

  /// 训练频率 (per week)
  double get workoutsPerWeek {
    if (totalWorkouts == 0 || lastWorkoutDate == null) return 0;
    final daysSinceFirst =
        DateTime.now().difference(lastWorkoutDate!).inDays + 1;
    if (daysSinceFirst == 0) return 0;
    return (totalWorkouts / daysSinceFirst) * 7;
  }

  /// 是否活跃用户
  bool get isActive {
    if (lastWorkoutDate == null) return false;
    final daysSinceLastWorkout =
        DateTime.now().difference(lastWorkoutDate!).inDays;
    return daysSinceLastWorkout <= 7;
  }
}

