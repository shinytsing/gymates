import 'package:flutter/foundation.dart';

/// 🏋️‍♀️ 训练控制器 - TrainingController
/// 
/// 使用Riverpod进行状态管理
/// 负责管理今日训练计划、训练进度和状态

class TrainingController extends ChangeNotifier {
  // 今日训练计划
  TodayPlan? _todayPlan;
  
  // 训练进度
  TrainingProgress? _currentProgress;
  
  // 快捷功能状态
  bool _isQuickStartLoading = false;
  bool _isSelectingWorkouts = false;
  bool _isViewingPlan = false;
  
  // Getters
  TodayPlan? get todayPlan => _todayPlan;
  TrainingProgress? get currentProgress => _currentProgress;
  bool get isQuickStartLoading => _isQuickStartLoading;
  bool get isSelectingWorkouts => _isSelectingWorkouts;
  bool get isViewingPlan => _isViewingPlan;
  
  /// 加载今日训练计划
  Future<void> loadTodayPlan() async {
    // TODO: 从API加载今日训练计划
    // _todayPlan = await TrainingPlanSyncService.getTodayTraining();
    notifyListeners();
  }
  
  /// 开始快速训练
  Future<void> startQuickTraining() async {
    _isQuickStartLoading = true;
    notifyListeners();
    
    // TODO: 实现快速开始训练逻辑
    
    _isQuickStartLoading = false;
    notifyListeners();
  }
  
  /// 挑选训练动作
  void selectWorkouts() {
    _isSelectingWorkouts = true;
    notifyListeners();
  }
  
  /// 查看训练计划
  void viewPlan() {
    _isViewingPlan = true;
    notifyListeners();
  }
  
  /// 更新训练进度
  void updateProgress(TrainingProgress progress) {
    _currentProgress = progress;
    notifyListeners();
  }
  
  /// 完成训练
  Future<void> completeTraining() async {
    // TODO: 实现完成训练逻辑
    _currentProgress = null;
    notifyListeners();
  }
}

/// 今日计划数据模型
class TodayPlan {
  final String id;
  final String title;
  final int totalExercises;
  final int totalDuration; // 分钟
  final int totalCalories;
  final List<ExerciseItem> exercises;
  
  const TodayPlan({
    required this.id,
    required this.title,
    required this.totalExercises,
    required this.totalDuration,
    required this.totalCalories,
    required this.exercises,
  });
}

/// 训练动作项
class ExerciseItem {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final int restSeconds;
  
  const ExerciseItem({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.restSeconds,
  });
}

/// 训练进度模型
class TrainingProgress {
  final int completedExercises;
  final int totalExercises;
  final int completedSets;
  final int totalSets;
  final int elapsedMinutes;
  
  const TrainingProgress({
    required this.completedExercises,
    required this.totalExercises,
    required this.completedSets,
    required this.totalSets,
    required this.elapsedMinutes,
  });
  
  double get exerciseProgress => totalExercises > 0 
      ? completedExercises / totalExercises 
      : 0.0;
  
  double get setProgress => totalSets > 0 
      ? completedSets / totalSets 
      : 0.0;
  
  int get remainingExercises => totalExercises - completedExercises;
  int get remainingSets => totalSets - completedSets;
}

