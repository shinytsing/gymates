/// 🏋️ 训练计划数据模型
library;

import 'exercise_model.dart';

/// 训练计划
class TrainingPlan {
  final String id;
  final String name;
  final String description;
  final String userId;
  final List<PlanExercise> exercises;
  final String difficulty; // beginner, intermediate, advanced
  final String goal; // strength, muscle, endurance, weight_loss, flexibility
  final bool isAIGenerated;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final int? estimatedDuration; // total minutes
  final int? estimatedCalories; // total calories

  TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.exercises,
    required this.difficulty,
    required this.goal,
    this.isAIGenerated = false,
    this.isPublic = false,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.estimatedDuration,
    this.estimatedCalories,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      userId: json['user_id'].toString(),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => PlanExercise.fromJson(e))
              .toList() ??
          [],
      difficulty: json['difficulty'] ?? 'beginner',
      goal: json['goal'] ?? 'strength',
      isAIGenerated: json['is_ai_generated'] ?? false,
      isPublic: json['is_public'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      imageUrl: json['image_url'],
      estimatedDuration: json['estimated_duration'],
      estimatedCalories: json['estimated_calories'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user_id': userId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'difficulty': difficulty,
      'goal': goal,
      'is_ai_generated': isAIGenerated,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_url': imageUrl,
      'estimated_duration': estimatedDuration,
      'estimated_calories': estimatedCalories,
    };
  }

  TrainingPlan copyWith({
    String? id,
    String? name,
    String? description,
    String? userId,
    List<PlanExercise>? exercises,
    String? difficulty,
    String? goal,
    bool? isAIGenerated,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    int? estimatedDuration,
    int? estimatedCalories,
  }) {
    return TrainingPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      exercises: exercises ?? this.exercises,
      difficulty: difficulty ?? this.difficulty,
      goal: goal ?? this.goal,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
    );
  }

  /// 计算总时长 (分钟)
  int get totalDuration {
    if (estimatedDuration != null) return estimatedDuration!;
    return exercises.fold(0, (sum, ex) => sum + ex.totalDuration) ~/ 60;
  }

  /// 计算总卡路里
  int get totalCalories {
    if (estimatedCalories != null) return estimatedCalories!;
    return exercises.fold(0, (sum, ex) => sum + ex.totalCalories);
  }
}

/// 今日训练计划
class TodayWorkout {
  final TrainingPlan? plan;
  final List<WorkoutExercise> exercises;
  final DateTime date;
  final String status; // not_started, in_progress, completed
  final int? sessionId;

  TodayWorkout({
    this.plan,
    required this.exercises,
    required this.date,
    required this.status,
    this.sessionId,
  });

  factory TodayWorkout.fromJson(Map<String, dynamic> json) {
    return TodayWorkout(
      plan: json['plan'] != null ? TrainingPlan.fromJson(json['plan']) : null,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e))
              .toList() ??
          [],
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      status: json['status'] ?? 'not_started',
      sessionId: json['session_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan': plan?.toJson(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'date': date.toIso8601String(),
      'status': status,
      'session_id': sessionId,
    };
  }

  /// 完成进度 (0-100)
  int get completionProgress {
    if (exercises.isEmpty) return 0;
    final completed =
        exercises.where((ex) => ex.completedSets == ex.totalSets).length;
    return ((completed / exercises.length) * 100).round();
  }

  /// 是否全部完成
  bool get isAllCompleted {
    return exercises.every((ex) => ex.completedSets == ex.totalSets);
  }
}

/// 训练中的运动项 (带完成状态)
class WorkoutExercise {
  final PlanExercise planExercise;
  final int completedSets;
  final int totalSets;
  final List<SetRecord> setRecords;

  WorkoutExercise({
    required this.planExercise,
    required this.completedSets,
    required this.totalSets,
    required this.setRecords,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      planExercise: PlanExercise.fromJson(json['plan_exercise']),
      completedSets: json['completed_sets'] ?? 0,
      totalSets: json['total_sets'] ?? 0,
      setRecords: (json['set_records'] as List<dynamic>?)
              ?.map((e) => SetRecord.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_exercise': planExercise.toJson(),
      'completed_sets': completedSets,
      'total_sets': totalSets,
      'set_records': setRecords.map((e) => e.toJson()).toList(),
    };
  }

  WorkoutExercise copyWith({
    PlanExercise? planExercise,
    int? completedSets,
    int? totalSets,
    List<SetRecord>? setRecords,
  }) {
    return WorkoutExercise(
      planExercise: planExercise ?? this.planExercise,
      completedSets: completedSets ?? this.completedSets,
      totalSets: totalSets ?? this.totalSets,
      setRecords: setRecords ?? this.setRecords,
    );
  }

  /// 是否已完成
  bool get isCompleted => completedSets == totalSets;

  /// 完成进度 (0-1)
  double get progress => totalSets > 0 ? completedSets / totalSets : 0;
}

/// 单组记录
class SetRecord {
  final int setNumber;
  final int reps;
  final double? weight;
  final int? duration;
  final DateTime completedAt;
  final String? notes;

  SetRecord({
    required this.setNumber,
    required this.reps,
    this.weight,
    this.duration,
    required this.completedAt,
    this.notes,
  });

  factory SetRecord.fromJson(Map<String, dynamic> json) {
    return SetRecord(
      setNumber: json['set_number'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : DateTime.now(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'completed_at': completedAt.toIso8601String(),
      'notes': notes,
    };
  }
}

