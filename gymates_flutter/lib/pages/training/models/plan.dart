class TrainingPlanModel {
	final String id;
	final String name;
	final String? description;
	final List<String> targetMuscles;
	final int weeklyFrequency;

	const TrainingPlanModel({
		required this.id,
		required this.name,
		this.description,
		required this.targetMuscles,
		required this.weeklyFrequency,
	});
}


