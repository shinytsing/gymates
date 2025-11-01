/// 📊 训练历史数据模型
library;

import 'training_plan_model.dart';

/// 训练历史记录
class TrainingHistory {
  final String id;
  final String userId;
  final String? planId;
  final String? planName;
  final DateTime date;
  final int duration; // minutes
  final int caloriesBurned;
  final int completedExercises;
  final int totalExercises;
  final double completionRate; // 0-100
  final bool isAIWorkout;
  final List<WorkoutExerciseHistory> exerciseHistory;
  final String? notes;

  TrainingHistory({
    required this.id,
    required this.userId,
    this.planId,
    this.planName,
    required this.date,
    required this.duration,
    required this.caloriesBurned,
    required this.completedExercises,
    required this.totalExercises,
    required this.completionRate,
    this.isAIWorkout = false,
    required this.exerciseHistory,
    this.notes,
  });

  factory TrainingHistory.fromJson(Map<String, dynamic> json) {
    final completed = json['completed_exercises'] ?? 0;
    final total = json['total_exercises'] ?? 1;
    return TrainingHistory(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      planId: json['plan_id']?.toString(),
      planName: json['plan_name'],
      date: DateTime.parse(json['date']),
      duration: json['duration'] ?? 0,
      caloriesBurned: json['calories_burned'] ?? 0,
      completedExercises: completed,
      totalExercises: total,
      completionRate: total > 0 ? (completed / total * 100) : 0,
      isAIWorkout: json['is_ai_workout'] ?? false,
      exerciseHistory: (json['exercise_history'] as List<dynamic>?)
              ?.map((e) => WorkoutExerciseHistory.fromJson(e))
              .toList() ??
          [],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'plan_name': planName,
      'date': date.toIso8601String(),
      'duration': duration,
      'calories_burned': caloriesBurned,
      'completed_exercises': completedExercises,
      'total_exercises': totalExercises,
      'completion_rate': completionRate,
      'is_ai_workout': isAIWorkout,
      'exercise_history': exerciseHistory.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }
}

/// 运动历史记录
class WorkoutExerciseHistory {
  final String exerciseName;
  final List<SetRecord> setRecords;
  final String muscleGroup;
  final bool completed;

  WorkoutExerciseHistory({
    required this.exerciseName,
    required this.setRecords,
    required this.muscleGroup,
    required this.completed,
  });

  factory WorkoutExerciseHistory.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseHistory(
      exerciseName: json['exercise_name'] ?? '',
      setRecords: (json['set_records'] as List<dynamic>?)
              ?.map((e) => SetRecord.fromJson(e))
              .toList() ??
          [],
      muscleGroup: json['muscle_group'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_name': exerciseName,
      'set_records': setRecords.map((e) => e.toJson()).toList(),
      'muscle_group': muscleGroup,
      'completed': completed,
    };
  }
}

/// 训练统计 (周/月)
class TrainingStatistics {
  final DateTime startDate;
  final DateTime endDate;
  final int totalWorkouts;
  final int totalMinutes;
  final int totalCalories;
  final double averageWorkoutDuration;
  final Map<String, int> workoutsByDay; // day -> count
  final Map<String, int> muscleGroupDistribution; // muscle group -> count
  final List<DailyStat> dailyStats;

  TrainingStatistics({
    required this.startDate,
    required this.endDate,
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCalories,
    required this.averageWorkoutDuration,
    required this.workoutsByDay,
    required this.muscleGroupDistribution,
    required this.dailyStats,
  });

  factory TrainingStatistics.fromJson(Map<String, dynamic> json) {
    return TrainingStatistics(
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalWorkouts: json['total_workouts'] ?? 0,
      totalMinutes: json['total_minutes'] ?? 0,
      totalCalories: json['total_calories'] ?? 0,
      averageWorkoutDuration:
          (json['average_workout_duration'] ?? 0).toDouble(),
      workoutsByDay: json['workouts_by_day'] != null
          ? Map<String, int>.from(json['workouts_by_day'])
          : {},
      muscleGroupDistribution: json['muscle_group_distribution'] != null
          ? Map<String, int>.from(json['muscle_group_distribution'])
          : {},
      dailyStats: (json['daily_stats'] as List<dynamic>?)
              ?.map((e) => DailyStat.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_workouts': totalWorkouts,
      'total_minutes': totalMinutes,
      'total_calories': totalCalories,
      'average_workout_duration': averageWorkoutDuration,
      'workouts_by_day': workoutsByDay,
      'muscle_group_distribution': muscleGroupDistribution,
      'daily_stats': dailyStats.map((e) => e.toJson()).toList(),
    };
  }
}

/// 每日统计
class DailyStat {
  final DateTime date;
  final int workouts;
  final int minutes;
  final int calories;

  DailyStat({
    required this.date,
    required this.workouts,
    required this.minutes,
    required this.calories,
  });

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: DateTime.parse(json['date']),
      workouts: json['workouts'] ?? 0,
      minutes: json['minutes'] ?? 0,
      calories: json['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'workouts': workouts,
      'minutes': minutes,
      'calories': calories,
    };
  }
}

