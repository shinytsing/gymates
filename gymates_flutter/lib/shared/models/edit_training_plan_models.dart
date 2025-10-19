/// 🏋️‍♀️ 训练计划编辑数据模型 - Training Plan Edit Models
/// 
/// 支持一周7天的训练计划编辑功能

import 'package:flutter/material.dart';

/// 训练计划编辑模型
class EditTrainingPlan {
  final String id;
  final String name;
  final String description;
  final List<TrainingDay> days;
  final DateTime createdAt;
  final DateTime updatedAt;

  EditTrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'days': days.map((day) => day.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory EditTrainingPlan.fromJson(Map<String, dynamic> json) {
    return EditTrainingPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      days: (json['days'] as List).map((day) => TrainingDay.fromJson(day)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// 复制并更新
  EditTrainingPlan copyWith({
    String? name,
    String? description,
    List<TrainingDay>? days,
  }) {
    return EditTrainingPlan(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

/// 训练日模型
class TrainingDay {
  final String id;
  final int dayOfWeek; // 1-7 (周一-周日)
  final String dayName;
  final List<TrainingPart> parts;
  final bool isRestDay;
  final String? notes;

  TrainingDay({
    required this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.parts,
    this.isRestDay = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'dayName': dayName,
      'parts': parts.map((part) => part.toJson()).toList(),
      'isRestDay': isRestDay,
      'notes': notes,
    };
  }

  factory TrainingDay.fromJson(Map<String, dynamic> json) {
    return TrainingDay(
      id: json['id'],
      dayOfWeek: json['dayOfWeek'],
      dayName: json['dayName'],
      parts: (json['parts'] as List).map((part) => TrainingPart.fromJson(part)).toList(),
      isRestDay: json['isRestDay'] ?? false,
      notes: json['notes'],
    );
  }

  /// 复制并更新
  TrainingDay copyWith({
    List<TrainingPart>? parts,
    bool? isRestDay,
    String? notes,
  }) {
    return TrainingDay(
      id: id,
      dayOfWeek: dayOfWeek,
      dayName: dayName,
      parts: parts ?? this.parts,
      isRestDay: isRestDay ?? this.isRestDay,
      notes: notes ?? this.notes,
    );
  }

  /// 获取总训练时间（分钟）
  int get totalDuration {
    return parts.fold(0, (total, part) => total + part.totalDuration);
  }

  /// 获取总动作数
  int get totalExercises {
    return parts.fold(0, (total, part) => total + part.exercises.length);
  }
}

/// 训练部位模型
class TrainingPart {
  final String id;
  final String muscleGroup;
  final String muscleGroupName;
  final List<Exercise> exercises;
  final int order;

  TrainingPart({
    required this.id,
    required this.muscleGroup,
    required this.muscleGroupName,
    required this.exercises,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'muscleGroup': muscleGroup,
      'muscleGroupName': muscleGroupName,
      'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
      'order': order,
    };
  }

  factory TrainingPart.fromJson(Map<String, dynamic> json) {
    return TrainingPart(
      id: json['id'],
      muscleGroup: json['muscleGroup'],
      muscleGroupName: json['muscleGroupName'],
      exercises: (json['exercises'] as List).map((exercise) => Exercise.fromJson(exercise)).toList(),
      order: json['order'],
    );
  }

  /// 复制并更新
  TrainingPart copyWith({
    List<Exercise>? exercises,
  }) {
    return TrainingPart(
      id: id,
      muscleGroup: muscleGroup,
      muscleGroupName: muscleGroupName,
      exercises: exercises ?? this.exercises,
      order: order,
    );
  }

  /// 获取部位总训练时间（分钟）
  int get totalDuration {
    return exercises.fold(0, (total, exercise) {
      return total + (exercise.sets * exercise.reps * 2) + (exercise.sets * exercise.restSeconds ~/ 60);
    });
  }
}

/// 动作模型
class Exercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double weight;
  final int restSeconds;
  final String? notes;
  final bool isCompleted;
  final DateTime? completedAt;
  final int order;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restSeconds,
    this.notes,
    this.isCompleted = false,
    this.completedAt,
    required this.order,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'restSeconds': restSeconds,
      'notes': notes,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'order': order,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      muscleGroup: json['muscleGroup'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'].toDouble(),
      restSeconds: json['restSeconds'],
      notes: json['notes'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      order: json['order'],
    );
  }

  /// 复制并更新
  Exercise copyWith({
    String? name,
    String? description,
    int? sets,
    int? reps,
    double? weight,
    int? restSeconds,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return Exercise(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroup: muscleGroup,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      order: order,
    );
  }

  /// 获取动作总时间（分钟）
  int get totalDuration {
    return (sets * reps * 2) + (sets * restSeconds ~/ 60);
  }
}

/// 肌肉群常量
class MuscleGroups {
  static const Map<String, String> groups = {
    'chest': '胸部',
    'back': '背部',
    'legs': '腿部',
    'shoulders': '肩部',
    'arms': '手臂',
    'core': '核心',
    'cardio': '有氧',
  };

  static const Map<String, String> icons = {
    'chest': '💪',
    'back': '🏋️',
    'legs': '🦵',
    'shoulders': '🤸',
    'arms': '💪',
    'core': '🔥',
    'cardio': '❤️',
  };

  static const Map<String, Color> colors = {
    'chest': Color(0xFF6366F1),
    'back': Color(0xFF8B5CF6),
    'legs': Color(0xFF10B981),
    'shoulders': Color(0xFFF59E0B),
    'arms': Color(0xFFEF4444),
    'core': Color(0xFFEC4899),
    'cardio': Color(0xFF06B6D4),
  };
}

/// 星期常量
class WeekDays {
  static const List<String> dayNames = [
    '周一', '周二', '周三', '周四', '周五', '周六', '周日'
  ];

  static const List<String> dayNamesEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
}
