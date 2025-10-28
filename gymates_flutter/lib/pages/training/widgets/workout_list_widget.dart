import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../training_detail_page.dart';
import '../controllers/plan_controller.dart';
import '../models/workout.dart';
import '../subpages/workout_detail_page.dart';
import '../../../shared/models/mock_data.dart';

class WorkoutListWidget extends StatelessWidget {
	const WorkoutListWidget({super.key});

	@override
	Widget build(BuildContext context) {
		return ChangeNotifierProvider(
			create: (_) => PlanController()..loadTodayPlan(),
			child: Consumer<PlanController>(
				builder: (context, ctrl, _) {
					if (ctrl.loading) {
						return const Center(child: CircularProgressIndicator());
					}
					if (ctrl.error != null) {
						return Center(child: Text('加载失败: ${ctrl.error}'));
					}
					final plan = ctrl.todayPlan;
					if (plan == null) {
						return const SizedBox.shrink();
					}
					return Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							_buildHeader(context, plan),
							const SizedBox(height: 12),
							...plan.exercises.map((e) => _ExerciseCard(exercise: e)),
						],
					);
				},
			),
		);
	}

	Widget _buildHeader(BuildContext context, TodayWorkoutPlan plan) {
		final completed = plan.completedExercises;
		final total = plan.totalExercises;
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Row(
					children: [
						Expanded(
							child: Text(
								plan.title,
								style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
							),
						),
						GestureDetector(
							onTap: () {
								HapticFeedback.lightImpact();
								final mock = MockTrainingPlan(
									id: plan.id,
									title: plan.title,
									description: '今日训练计划',
									duration: '30分钟',
									difficulty: 'intermediate',
									calories: 300,
									exercises: plan.exercises.map((e) => e.name).toList(),
									image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
									isCompleted: false,
									progress: plan.progress,
									trainingMode: '自定义',
									targetMuscles: const ['胸部','背部','腿部'],
									exerciseDetails: plan.exercises.map((e) => MockExercise(
										id: e.id,
										name: e.name,
										description: '',
										muscleGroup: e.muscleGroup ?? '',
										difficulty: 'intermediate',
										equipment: '',
										imageUrl: '',
										videoUrl: e.videoUrl ?? '',
										instructions: const [],
										tips: const [],
										sets: e.sets,
										reps: e.reps,
										weight: e.weight,
										restTime: e.restSeconds,
									)).toList(),
									suitableFor: '中级',
									weeklyFrequency: 5,
									createdAt: DateTime.now(),
									lastCompleted: null,
								);
								Navigator.push(context, MaterialPageRoute(builder: (_) => TrainingDetailPage(trainingPlan: mock)));
							},
							child: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
						),
					],
				),
				const SizedBox(height: 8),
				Stack(
					children: [
						Container(
							height: 8,
							decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(4)),
						),
						FractionallySizedBox(
							widthFactor: plan.progress,
							child: Container(
								height: 8,
								decoration: BoxDecoration(
									gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
									borderRadius: BorderRadius.circular(4),
								),
							),
						),
					],
				),
				const SizedBox(height: 4),
				Text('$completed/$total 完成', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
			],
		);
	}
}

class _ExerciseCard extends StatefulWidget {
	final WorkoutExercise exercise;
	const _ExerciseCard({required this.exercise});

	@override
	State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> with SingleTickerProviderStateMixin {
	late AnimationController _controller;
	late Animation<double> _scale;

	@override
	void initState() {
		super.initState();
		_controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
		_scale = Tween<double>(begin: 1, end: 0.97).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final ctrl = context.read<PlanController>();
		final e = widget.exercise;
		return GestureDetector(
			onTap: () {
				// 导航到动作详情页
				HapticFeedback.lightImpact();
				Navigator.push(
					context,
					MaterialPageRoute(
						builder: (context) => WorkoutDetailPage(
							exercise: e,
						),
					),
				);
			},
			child: AnimatedBuilder(
				animation: _controller,
				builder: (_, __) {
					return Transform.scale(
						scale: e.isCompleted ? 0.99 : _scale.value,
						child: Opacity(
							opacity: e.isCompleted ? 0.6 : 1,
							child: Container(
								margin: const EdgeInsets.only(bottom: 12),
								padding: const EdgeInsets.all(12),
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(12),
									border: Border.all(color: const Color(0xFFE5E7EB)),
									boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
								),
								child: Row(
									children: [
										Expanded(
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text(e.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
													const SizedBox(height: 4),
													Row(children: [
														_iconText(Icons.repeat, '${e.sets}组'),
														const SizedBox(width: 8),
														_iconText(Icons.fitness_center, '${e.reps}次'),
														const SizedBox(width: 8),
														_iconText(Icons.timer, '${e.restSeconds}s'),
													]),
												],
											),
										),
										IconButton(
											icon: Icon(e.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: e.isCompleted ? const Color(0xFF10B981) : const Color(0xFF9CA3AF)),
											onPressed: () async {
												HapticFeedback.selectionClick();
												await _controller.forward();
												await _controller.reverse();
												ctrl.toggleComplete(e.id);
											},
										),
									],
								),
							),
						),
					);
				},
			),
		);
	}

	Widget _iconText(IconData icon, String text) {
		return Row(children: [Icon(icon, size: 14, color: const Color(0xFF6B7280)), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)))]);
	}
}


