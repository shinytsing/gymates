class WorkoutRecord {
	final String id;
	final DateTime date;
	final String planId;
	final String planTitle;
	final int durationMinutes;
	final int calories;
	final int totalExercises;
	final int completedExercises;
	final String? aiSummary;

	const WorkoutRecord({
		required this.id,
		required this.date,
		required this.planId,
		required this.planTitle,
		required this.durationMinutes,
		required this.calories,
		required this.totalExercises,
		required this.completedExercises,
		this.aiSummary,
	});
}


