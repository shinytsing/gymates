import 'package:flutter/foundation.dart';
import '../../../services/training_plan_sync_service.dart';
import '../models/workout.dart';

class PlanController with ChangeNotifier {
	TodayWorkoutPlan? _todayPlan;
	bool _loading = false;
	String? _error;

	TodayWorkoutPlan? get todayPlan => _todayPlan;
	bool get loading => _loading;
	String? get error => _error;

	Future<void> loadTodayPlan() async {
		_loading = true;
		_error = null;
		notifyListeners();
		try {
			final data = await TrainingPlanSyncService.getTodayTraining();
			final exercises = <WorkoutExercise>[];
			final list = (data?['exercises'] as List?) ?? [];
			for (final item in list) {
				final m = Map<String, dynamic>.from(item as Map);
				exercises.add(WorkoutExercise(
					id: m['id']?.toString() ?? UniqueKey().toString(),
					name: m['name']?.toString() ?? '动作',
					sets: (m['sets'] ?? 3) as int,
					reps: (m['reps'] ?? 10) as int,
					restSeconds: (m['rest'] ?? m['restSeconds'] ?? 60) as int,
					weight: ((m['weight'] ?? 0) as num).toDouble(),
					videoUrl: m['videoUrl']?.toString(),
					gifUrl: m['gifUrl']?.toString(),
					muscleGroup: m['muscle']?.toString(),
				));
			}
			_todayPlan = TodayWorkoutPlan(
				id: (data?['id']?.toString()) ?? UniqueKey().toString(),
				title: (data?['planName'] ?? data?['name'] ?? '今日训练').toString(),
				exercises: exercises,
			);
		} catch (e) {
			_error = e.toString();
		} finally {
			_loading = false;
			notifyListeners();
		}
	}

	void toggleComplete(String exerciseId) {
		if (_todayPlan == null) return;
		final updated = _todayPlan!.exercises.map((e) {
			if (e.id == exerciseId) {
				return e.copyWith(isCompleted: !e.isCompleted);
			}
			return e;
		}).toList(growable: false);
		_todayPlan = TodayWorkoutPlan(id: _todayPlan!.id, title: _todayPlan!.title, exercises: updated);
		notifyListeners();
	}

	void updateWorkout(WorkoutExercise updatedExercise) {
		if (_todayPlan == null) return;
		final updated = _todayPlan!.exercises.map((e) {
			if (e.id == updatedExercise.id) {
				return updatedExercise;
			}
			return e;
		}).toList(growable: false);
		_todayPlan = TodayWorkoutPlan(id: _todayPlan!.id, title: _todayPlan!.title, exercises: updated);
		notifyListeners();
	}
}


