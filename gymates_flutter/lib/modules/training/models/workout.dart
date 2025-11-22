
class WorkoutExercise {
	final String id;
	final String name;
	final int sets;
	final int reps;
	final int restSeconds;
	final double weight;
	final String? videoUrl;
	final String? gifUrl;
	final String? muscleGroup;
	final bool isCompleted;

	const WorkoutExercise({
		required this.id,
		required this.name,
		required this.sets,
		required this.reps,
		required this.restSeconds,
		required this.weight,
		this.videoUrl,
		this.gifUrl,
		this.muscleGroup,
		this.isCompleted = false,
	});

	WorkoutExercise copyWith({
		bool? isCompleted,
		int? sets,
		int? reps,
		double? weight,
		int? restSeconds,
	}) {
		return WorkoutExercise(
			id: id,
			name: name,
			sets: sets ?? this.sets,
			reps: reps ?? this.reps,
			restSeconds: restSeconds ?? this.restSeconds,
			weight: weight ?? this.weight,
			videoUrl: videoUrl,
			gifUrl: gifUrl,
			muscleGroup: muscleGroup,
			isCompleted: isCompleted ?? this.isCompleted,
		);
	}
}

class TodayWorkoutPlan {
	final String id;
	final String title;
	final List<WorkoutExercise> exercises;

	const TodayWorkoutPlan({
		required this.id,
		required this.title,
		required this.exercises,
	});

	int get totalExercises => exercises.length;
	int get completedExercises => exercises.where((e) => e.isCompleted).length;
	double get progress => totalExercises == 0 ? 0 : completedExercises / totalExercises;
}

/// 训练记录模型
class WorkoutRecord {
	final String id;
	final DateTime date;
	final String planId;
	final String planTitle;
	final int durationMinutes;
	final int calories;
	final int totalExercises;
	final int completedExercises;
	final String aiSummary;

	const WorkoutRecord({
		required this.id,
		required this.date,
		required this.planId,
		required this.planTitle,
		required this.durationMinutes,
		required this.calories,
		required this.totalExercises,
		required this.completedExercises,
		required this.aiSummary,
	});

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'date': date.toIso8601String(),
			'planId': planId,
			'planTitle': planTitle,
			'durationMinutes': durationMinutes,
			'calories': calories,
			'totalExercises': totalExercises,
			'completedExercises': completedExercises,
			'aiSummary': aiSummary,
		};
	}

	factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
		return WorkoutRecord(
			id: json['id'],
			date: DateTime.parse(json['date']),
			planId: json['planId'],
			planTitle: json['planTitle'],
			durationMinutes: json['durationMinutes'],
			calories: json['calories'],
			totalExercises: json['totalExercises'],
			completedExercises: json['completedExercises'],
			aiSummary: json['aiSummary'],
		);
	}
}


