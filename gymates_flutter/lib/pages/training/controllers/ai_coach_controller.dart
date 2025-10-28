import 'package:flutter/foundation.dart';
import '../models/workout.dart';

/// 🏋️‍♀️ AI教练控制器 - AICoachController
/// 
/// 负责管理AI教练训练模式的状态和逻辑：
/// 1. 训练计划管理
/// 2. 当前动作和组数跟踪
/// 3. 训练进度计算
/// 4. 动作切换逻辑

class AICoachController with ChangeNotifier {
  TodayWorkoutPlan? _workoutPlan;
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  List<bool> _exerciseCompletionStatus = [];
  
  // Getters
  TodayWorkoutPlan? get workoutPlan => _workoutPlan;
  int get currentExerciseIndex => _currentExerciseIndex;
  int get currentSetIndex => _currentSetIndex;
  
  /// 初始化训练
  void initializeTraining(TodayWorkoutPlan plan) {
    _workoutPlan = plan;
    _currentExerciseIndex = 0;
    _currentSetIndex = 0;
    _exerciseCompletionStatus = List.filled(plan.exercises.length, false);
    notifyListeners();
  }
  
  /// 获取当前动作
  WorkoutExercise? getCurrentExercise() {
    if (_workoutPlan == null || _currentExerciseIndex >= _workoutPlan!.exercises.length) {
      return null;
    }
    return _workoutPlan!.exercises[_currentExerciseIndex];
  }
  
  /// 获取当前组索引
  int getCurrentSetIndex() {
    return _currentSetIndex;
  }
  
  /// 获取当前动作索引
  int getCurrentExerciseIndex() {
    return _currentExerciseIndex;
  }
  
  /// 获取所有动作
  List<WorkoutExercise> getAllExercises() {
    return _workoutPlan?.exercises ?? [];
  }
  
  /// 检查动作是否完成
  bool isExerciseCompleted(int exerciseIndex) {
    if (exerciseIndex >= _exerciseCompletionStatus.length) return false;
    return _exerciseCompletionStatus[exerciseIndex];
  }
  
  /// 移动到下一组
  bool moveToNextSet() {
    final currentExercise = getCurrentExercise();
    if (currentExercise == null) return false;
    
    if (_currentSetIndex < currentExercise.sets - 1) {
      _currentSetIndex++;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// 移动到下一个动作
  bool moveToNextExercise() {
    if (_workoutPlan == null) return false;
    
    // 标记当前动作为完成
    if (_currentExerciseIndex < _exerciseCompletionStatus.length) {
      _exerciseCompletionStatus[_currentExerciseIndex] = true;
    }
    
    // 移动到下一个动作
    if (_currentExerciseIndex < _workoutPlan!.exercises.length - 1) {
      _currentExerciseIndex++;
      _currentSetIndex = 0;
      notifyListeners();
      return true;
    }
    return false;
  }
  
  /// 获取整体进度
  double getOverallProgress() {
    if (_workoutPlan == null) return 0.0;
    
    int totalSets = 0;
    int completedSets = 0;
    
    for (int i = 0; i < _workoutPlan!.exercises.length; i++) {
      final exercise = _workoutPlan!.exercises[i];
      totalSets += exercise.sets;
      
      if (i < _currentExerciseIndex) {
        // 完全完成的动作
        completedSets += exercise.sets;
      } else if (i == _currentExerciseIndex) {
        // 当前动作
        completedSets += _currentSetIndex;
      }
    }
    
    return totalSets > 0 ? completedSets / totalSets : 0.0;
  }
  
  /// 获取当前动作的进度
  double getCurrentExerciseProgress() {
    final currentExercise = getCurrentExercise();
    if (currentExercise == null) return 0.0;
    
    return _currentSetIndex / currentExercise.sets;
  }
  
  /// 检查是否所有动作都完成
  bool isTrainingComplete() {
    if (_workoutPlan == null) return false;
    
    for (int i = 0; i < _workoutPlan!.exercises.length; i++) {
      if (!isExerciseCompleted(i)) {
        return false;
      }
    }
    return true;
  }
  
  /// 获取剩余动作数量
  int getRemainingExercises() {
    if (_workoutPlan == null) return 0;
    return _workoutPlan!.exercises.length - _currentExerciseIndex;
  }
  
  /// 获取剩余组数
  int getRemainingSets() {
    final currentExercise = getCurrentExercise();
    if (currentExercise == null) return 0;
    
    int remaining = currentExercise.sets - _currentSetIndex;
    
    // 加上后续动作的组数
    for (int i = _currentExerciseIndex + 1; i < (_workoutPlan?.exercises.length ?? 0); i++) {
      remaining += _workoutPlan!.exercises[i].sets;
    }
    
    return remaining;
  }
  
  /// 重置训练状态
  void resetTraining() {
    _currentExerciseIndex = 0;
    _currentSetIndex = 0;
    _exerciseCompletionStatus = List.filled(_workoutPlan?.exercises.length ?? 0, false);
    notifyListeners();
  }
  
  /// 跳转到指定动作
  void jumpToExercise(int exerciseIndex) {
    if (_workoutPlan == null || exerciseIndex >= _workoutPlan!.exercises.length) return;
    
    _currentExerciseIndex = exerciseIndex;
    _currentSetIndex = 0;
    notifyListeners();
  }
  
  /// 获取训练统计信息
  TrainingStats getTrainingStats() {
    if (_workoutPlan == null) {
      return TrainingStats(
        totalExercises: 0,
        completedExercises: 0,
        totalSets: 0,
        completedSets: 0,
        estimatedDuration: 0,
        estimatedCalories: 0,
      );
    }
    
    int totalExercises = _workoutPlan!.exercises.length;
    int completedExercises = _exerciseCompletionStatus.where((completed) => completed).length;
    
    int totalSets = 0;
    int completedSets = 0;
    
    for (int i = 0; i < _workoutPlan!.exercises.length; i++) {
      final exercise = _workoutPlan!.exercises[i];
      totalSets += exercise.sets;
      
      if (i < _currentExerciseIndex) {
        completedSets += exercise.sets;
      } else if (i == _currentExerciseIndex) {
        completedSets += _currentSetIndex;
      }
    }
    
    // 估算训练时长（每组30秒 + 休息时间）
    int estimatedDuration = 0;
    for (final exercise in _workoutPlan!.exercises) {
      estimatedDuration += exercise.sets * (30 + exercise.restSeconds);
    }
    
    // 估算卡路里消耗（基于动作数量和重量）
    int estimatedCalories = 0;
    for (final exercise in _workoutPlan!.exercises) {
      estimatedCalories += exercise.sets * exercise.reps * (exercise.weight * 0.1).round();
    }
    
    return TrainingStats(
      totalExercises: totalExercises,
      completedExercises: completedExercises,
      totalSets: totalSets,
      completedSets: completedSets,
      estimatedDuration: estimatedDuration,
      estimatedCalories: estimatedCalories,
    );
  }
}

/// 训练统计信息
class TrainingStats {
  final int totalExercises;
  final int completedExercises;
  final int totalSets;
  final int completedSets;
  final int estimatedDuration; // 秒
  final int estimatedCalories;
  
  TrainingStats({
    required this.totalExercises,
    required this.completedExercises,
    required this.totalSets,
    required this.completedSets,
    required this.estimatedDuration,
    required this.estimatedCalories,
  });
  
  double get exerciseProgress => totalExercises > 0 ? completedExercises / totalExercises : 0.0;
  double get setProgress => totalSets > 0 ? completedSets / totalSets : 0.0;
  int get remainingExercises => totalExercises - completedExercises;
  int get remainingSets => totalSets - completedSets;
}
