import 'record.dart';

/// 🏋️‍♀️ 训练会话结果模型 - TrainingSessionResult
/// 
/// 用于存储训练会话的完整结果数据

class TrainingSessionResult {
  final String sessionId;
  final DateTime startTime;
  final DateTime endTime;
  final List<SetRecord> completedSets;
  final int totalCalories;
  final String aiSummary;
  final TrainingMetrics metrics;

  const TrainingSessionResult({
    required this.sessionId,
    required this.startTime,
    required this.endTime,
    required this.completedSets,
    required this.totalCalories,
    required this.aiSummary,
    required this.metrics,
  });

  /// 训练时长（分钟）
  int get durationMinutes => endTime.difference(startTime).inMinutes;

  /// 训练时长（秒）
  int get durationSeconds => endTime.difference(startTime).inSeconds;

  /// 完成的动作数量
  int get completedExercises => completedSets.map((s) => s.exerciseId).toSet().length;

  /// 总组数
  int get totalSets => completedSets.length;

  /// 平均每组时长（秒）
  double get averageSetDuration {
    if (completedSets.isEmpty) return 0.0;
    return completedSets.fold(0, (sum, set) => sum + set.duration) / completedSets.length;
  }

  /// 转换为WorkoutRecord
  WorkoutRecord toWorkoutRecord({
    required String planId,
    required String planTitle,
  }) {
    return WorkoutRecord(
      id: sessionId,
      date: startTime,
      planId: planId,
      planTitle: planTitle,
      durationMinutes: durationMinutes,
      calories: totalCalories,
      totalExercises: completedExercises,
      completedExercises: completedExercises,
      aiSummary: aiSummary,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'completedSets': completedSets.map((s) => s.toJson()).toList(),
      'totalCalories': totalCalories,
      'aiSummary': aiSummary,
      'metrics': metrics.toJson(),
    };
  }

  factory TrainingSessionResult.fromJson(Map<String, dynamic> json) {
    return TrainingSessionResult(
      sessionId: json['sessionId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      completedSets: (json['completedSets'] as List)
          .map((s) => SetRecord.fromJson(s))
          .toList(),
      totalCalories: json['totalCalories'],
      aiSummary: json['aiSummary'],
      metrics: TrainingMetrics.fromJson(json['metrics']),
    );
  }
}

/// 组记录模型
class SetRecord {
  final String exerciseId;
  final String exerciseName;
  final int setNumber;
  final int reps;
  final double weight;
  final int duration; // 秒
  final DateTime completedAt;
  final SetQuality quality;
  final String? notes;

  const SetRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.duration,
    required this.completedAt,
    required this.quality,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'completedAt': completedAt.toIso8601String(),
      'quality': quality.name,
      'notes': notes,
    };
  }

  factory SetRecord.fromJson(Map<String, dynamic> json) {
    return SetRecord(
      exerciseId: json['exerciseId'],
      exerciseName: json['exerciseName'],
      setNumber: json['setNumber'],
      reps: json['reps'],
      weight: json['weight'].toDouble(),
      duration: json['duration'],
      completedAt: DateTime.parse(json['completedAt']),
      quality: SetQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => SetQuality.good,
      ),
      notes: json['notes'],
    );
  }
}

/// 组质量评估
enum SetQuality {
  excellent, // 优秀
  good,      // 良好
  fair,      // 一般
  poor,      // 较差
}

/// 训练指标
class TrainingMetrics {
  final double intensity; // 训练强度 (0-1)
  final double consistency; // 一致性 (0-1)
  final double effort; // 努力程度 (0-1)
  final double form; // 动作质量 (0-1)
  final int heartRateAvg; // 平均心率
  final int heartRateMax; // 最大心率
  final double caloriesPerMinute; // 每分钟卡路里消耗

  const TrainingMetrics({
    required this.intensity,
    required this.consistency,
    required this.effort,
    required this.form,
    required this.heartRateAvg,
    required this.heartRateMax,
    required this.caloriesPerMinute,
  });

  /// 综合评分 (0-100)
  double get overallScore {
    return (intensity + consistency + effort + form) * 25;
  }

  Map<String, dynamic> toJson() {
    return {
      'intensity': intensity,
      'consistency': consistency,
      'effort': effort,
      'form': form,
      'heartRateAvg': heartRateAvg,
      'heartRateMax': heartRateMax,
      'caloriesPerMinute': caloriesPerMinute,
    };
  }

  factory TrainingMetrics.fromJson(Map<String, dynamic> json) {
    return TrainingMetrics(
      intensity: json['intensity'].toDouble(),
      consistency: json['consistency'].toDouble(),
      effort: json['effort'].toDouble(),
      form: json['form'].toDouble(),
      heartRateAvg: json['heartRateAvg'],
      heartRateMax: json['heartRateMax'],
      caloriesPerMinute: json['caloriesPerMinute'].toDouble(),
    );
  }
}

/// 训练计划模板
class TrainingPlanTemplate {
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final int estimatedDuration; // 分钟
  final int estimatedCalories;
  final List<String> targetMuscles;
  final List<ExerciseTemplate> exercises;
  final String category; // 分类：增肌、减脂、塑形、康复等

  const TrainingPlanTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.estimatedDuration,
    required this.estimatedCalories,
    required this.targetMuscles,
    required this.exercises,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'estimatedDuration': estimatedDuration,
      'estimatedCalories': estimatedCalories,
      'targetMuscles': targetMuscles,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'category': category,
    };
  }

  factory TrainingPlanTemplate.fromJson(Map<String, dynamic> json) {
    return TrainingPlanTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      difficulty: json['difficulty'],
      estimatedDuration: json['estimatedDuration'],
      estimatedCalories: json['estimatedCalories'],
      targetMuscles: List<String>.from(json['targetMuscles']),
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseTemplate.fromJson(e))
          .toList(),
      category: json['category'],
    );
  }
}

/// 动作模板
class ExerciseTemplate {
  final String id;
  final String name;
  final String description;
  final String muscleGroup;
  final String equipment;
  final String difficulty;
  final int recommendedSets;
  final int recommendedReps;
  final double recommendedWeight;
  final int restTime; // 秒
  final String? videoUrl;
  final String? imageUrl;
  final List<String> instructions;
  final List<String> tips;

  const ExerciseTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.equipment,
    required this.difficulty,
    required this.recommendedSets,
    required this.recommendedReps,
    required this.recommendedWeight,
    required this.restTime,
    this.videoUrl,
    this.imageUrl,
    required this.instructions,
    required this.tips,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'difficulty': difficulty,
      'recommendedSets': recommendedSets,
      'recommendedReps': recommendedReps,
      'recommendedWeight': recommendedWeight,
      'restTime': restTime,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'instructions': instructions,
      'tips': tips,
    };
  }

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) {
    return ExerciseTemplate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      muscleGroup: json['muscleGroup'],
      equipment: json['equipment'],
      difficulty: json['difficulty'],
      recommendedSets: json['recommendedSets'],
      recommendedReps: json['recommendedReps'],
      recommendedWeight: json['recommendedWeight'].toDouble(),
      restTime: json['restTime'],
      videoUrl: json['videoUrl'],
      imageUrl: json['imageUrl'],
      instructions: List<String>.from(json['instructions']),
      tips: List<String>.from(json['tips']),
    );
  }
}
