/// 🏋️ 训练模块数据模型

class TrainingPlan {
  final String id;
  final String name;
  final String description;
  final int duration;
  final int caloriesBurned;
  final String difficulty;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TrainingExercise> exercises;

  TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.caloriesBurned,
    required this.difficulty,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.exercises,
  });

  factory TrainingPlan.fromJson(Map<String, dynamic> json) {
    return TrainingPlan(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      caloriesBurned: json['calories_burned'] ?? 0,
      difficulty: json['difficulty'] ?? 'beginner',
      isPublic: json['is_public'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => TrainingExercise.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration': duration,
      'calories_burned': caloriesBurned,
      'difficulty': difficulty,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class TrainingExercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double? weight;
  final int? duration;
  final int restTime;
  final String? instructions;
  final String? imageUrl;
  final String? muscleGroup;
  final String? difficulty;
  final String? equipment;
  final int order;

  TrainingExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.duration,
    required this.restTime,
    this.instructions,
    this.imageUrl,
    this.muscleGroup,
    this.difficulty,
    this.equipment,
    required this.order,
  });

  factory TrainingExercise.fromJson(Map<String, dynamic> json) {
    return TrainingExercise(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      restTime: json['rest_time'] ?? 0,
      instructions: json['instructions'],
      imageUrl: json['image_url'],
      muscleGroup: json['muscle_group'],
      difficulty: json['difficulty'],
      equipment: json['equipment'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'rest_time': restTime,
      'instructions': instructions,
      'image_url': imageUrl,
      'muscle_group': muscleGroup,
      'difficulty': difficulty,
      'equipment': equipment,
      'order': order,
    };
  }
}

class TodayTrainingPlan {
  final String? planId;
  final List<TodayExercise> exercises;
  final bool isAIRecommended;
  final DateTime? createdAt;

  TodayTrainingPlan({
    this.planId,
    required this.exercises,
    this.isAIRecommended = false,
    this.createdAt,
  });

  factory TodayTrainingPlan.fromJson(Map<String, dynamic> json) {
    return TodayTrainingPlan(
      planId: json['plan_id'],
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => TodayExercise.fromJson(e))
              .toList() ??
          [],
      isAIRecommended: json['is_ai_recommended'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'is_ai_recommended': isAIRecommended,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class TodayExercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int restSeconds;
  final String muscleGroup;
  final bool isCompleted;

  TodayExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.muscleGroup,
    this.isCompleted = false,
  });

  factory TodayExercise.fromJson(Map<String, dynamic> json) {
    return TodayExercise(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      restSeconds: json['rest_seconds'] ?? json['rest_time'] ?? 60,
      muscleGroup: json['muscle_group'] ?? '',
      isCompleted: json['is_completed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest_seconds': restSeconds,
      'muscle_group': muscleGroup,
      'is_completed': isCompleted,
    };
  }

  TodayExercise copyWith({
    String? id,
    String? name,
    int? sets,
    int? reps,
    int? restSeconds,
    String? muscleGroup,
    bool? isCompleted,
  }) {
    return TodayExercise(
      id: id ?? this.id,
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class TrainingSession {
  final String id;
  final String userId;
  final String trainingPlanId;
  final String status; // ongoing, completed, paused
  final int progress; // 0-100
  final DateTime startTime;
  final DateTime? endTime;
  final int? duration;
  final int? caloriesBurned;

  TrainingSession({
    required this.id,
    required this.userId,
    required this.trainingPlanId,
    required this.status,
    required this.progress,
    required this.startTime,
    this.endTime,
    this.duration,
    this.caloriesBurned,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      trainingPlanId: json['training_plan_id'].toString(),
      status: json['status'] ?? 'ongoing',
      progress: json['progress'] ?? 0,
      startTime: DateTime.parse(json['start_time']),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : null,
      duration: json['duration'],
      caloriesBurned: json['calories_burned'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'training_plan_id': trainingPlanId,
      'status': status,
      'progress': progress,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration': duration,
      'calories_burned': caloriesBurned,
    };
  }
}

class TrainingHistory {
  final String id;
  final String trainingPlanName;
  final DateTime date;
  final int duration;
  final int caloriesBurned;
  final int completedExercises;
  final int totalExercises;
  final double completionRate;

  TrainingHistory({
    required this.id,
    required this.trainingPlanName,
    required this.date,
    required this.duration,
    required this.caloriesBurned,
    required this.completedExercises,
    required this.totalExercises,
    required this.completionRate,
  });

  factory TrainingHistory.fromJson(Map<String, dynamic> json) {
    final completed = json['completed_exercises'] ?? 0;
    final total = json['total_exercises'] ?? 1;
    return TrainingHistory(
      id: json['id'].toString(),
      trainingPlanName: json['training_plan_name'] ?? '',
      date: DateTime.parse(json['date']),
      duration: json['duration'] ?? 0,
      caloriesBurned: json['calories_burned'] ?? 0,
      completedExercises: completed,
      totalExercises: total,
      completionRate: total > 0 ? completed / total * 100 : 0,
    );
  }
}

class AIRecommendation {
  final String id;
  final List<TodayExercise> exercises;
  final String reason;
  final DateTime createdAt;
  final String goal;
  final String level;

  AIRecommendation({
    required this.id,
    required this.exercises,
    required this.reason,
    required this.createdAt,
    required this.goal,
    required this.level,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'].toString(),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => TodayExercise.fromJson(e))
              .toList() ??
          [],
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      goal: json['goal'] ?? '',
      level: json['level'] ?? '',
    );
  }
}

