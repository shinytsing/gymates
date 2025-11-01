/// 🏋️ 运动数据模型
library;

/// 运动详情模型
class Exercise {
  final String id;
  final String name;
  final String description;
  final String muscleGroup; // chest, back, legs, shoulders, arms, abs, cardio
  final String difficulty; // beginner, intermediate, advanced
  final String? equipment; // dumbbells, barbell, machine, bodyweight, etc.
  final String? videoUrl;
  final String? thumbnailUrl;
  final int estimatedCalories; // per set
  final int estimatedDuration; // seconds per set
  final List<String>? instructions;
  final List<String>? tips;
  final bool isFavorite;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.difficulty,
    this.equipment,
    this.videoUrl,
    this.thumbnailUrl,
    required this.estimatedCalories,
    required this.estimatedDuration,
    this.instructions,
    this.tips,
    this.isFavorite = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      muscleGroup: json['muscle_group'] ?? '',
      difficulty: json['difficulty'] ?? 'beginner',
      equipment: json['equipment'],
      videoUrl: json['video_url'],
      thumbnailUrl: json['thumbnail_url'],
      estimatedCalories: json['estimated_calories'] ?? 0,
      estimatedDuration: json['estimated_duration'] ?? 0,
      instructions: json['instructions'] != null
          ? List<String>.from(json['instructions'])
          : null,
      tips: json['tips'] != null ? List<String>.from(json['tips']) : null,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscle_group': muscleGroup,
      'difficulty': difficulty,
      'equipment': equipment,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'estimated_calories': estimatedCalories,
      'estimated_duration': estimatedDuration,
      'instructions': instructions,
      'tips': tips,
      'is_favorite': isFavorite,
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    String? muscleGroup,
    String? difficulty,
    String? equipment,
    String? videoUrl,
    String? thumbnailUrl,
    int? estimatedCalories,
    int? estimatedDuration,
    List<String>? instructions,
    List<String>? tips,
    bool? isFavorite,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

/// 训练计划中的运动项
class PlanExercise {
  final String exerciseId;
  final Exercise exercise;
  final int sets;
  final int reps;
  final double? weight; // kg
  final int? duration; // seconds
  final int restTime; // seconds between sets
  final int order;
  final String? notes;

  PlanExercise({
    required this.exerciseId,
    required this.exercise,
    required this.sets,
    required this.reps,
    this.weight,
    this.duration,
    required this.restTime,
    required this.order,
    this.notes,
  });

  factory PlanExercise.fromJson(Map<String, dynamic> json) {
    return PlanExercise(
      exerciseId: json['exercise_id'].toString(),
      exercise: Exercise.fromJson(json['exercise']),
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: json['weight']?.toDouble(),
      duration: json['duration'],
      restTime: json['rest_time'] ?? 60,
      order: json['order'] ?? 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise_id': exerciseId,
      'exercise': exercise.toJson(),
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'rest_time': restTime,
      'order': order,
      'notes': notes,
    };
  }

  PlanExercise copyWith({
    String? exerciseId,
    Exercise? exercise,
    int? sets,
    int? reps,
    double? weight,
    int? duration,
    int? restTime,
    int? order,
    String? notes,
  }) {
    return PlanExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      restTime: restTime ?? this.restTime,
      order: order ?? this.order,
      notes: notes ?? this.notes,
    );
  }

  /// 计算总预计时长 (秒)
  int get totalDuration {
    final setDuration = duration ?? (exercise.estimatedDuration * reps);
    return (setDuration * sets) + (restTime * (sets - 1));
  }

  /// 计算总预计卡路里
  int get totalCalories {
    return exercise.estimatedCalories * sets * reps;
  }
}

/// 运动过滤器
class ExerciseFilter {
  final String? muscleGroup;
  final String? difficulty;
  final String? equipment;
  final String? searchQuery;

  ExerciseFilter({
    this.muscleGroup,
    this.difficulty,
    this.equipment,
    this.searchQuery,
  });

  ExerciseFilter copyWith({
    String? muscleGroup,
    String? difficulty,
    String? equipment,
    String? searchQuery,
  }) {
    return ExerciseFilter(
      muscleGroup: muscleGroup ?? this.muscleGroup,
      difficulty: difficulty ?? this.difficulty,
      equipment: equipment ?? this.equipment,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (muscleGroup != null) params['muscle_group'] = muscleGroup;
    if (difficulty != null) params['difficulty'] = difficulty;
    if (equipment != null) params['equipment'] = equipment;
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      params['search'] = searchQuery;
    }
    return params;
  }
}

