/// 🔄 训练模块状态管理
library;

import 'package:flutter/foundation.dart';
import '../models/exercise_model.dart';
import '../models/training_plan_model.dart';
import '../models/training_history_model.dart';
import '../services/training_api_service.dart';

class TrainingProvider with ChangeNotifier {
  final TrainingApiService _apiService = TrainingApiService();

  // ==================== 状态变量 ====================

  // 运动库
  List<Exercise> _exercises = [];
  bool _isLoadingExercises = false;
  String? _exercisesError;
  int _exercisesTotal = 0;
  int _exercisesPage = 1;

  // 训练计划
  List<TrainingPlan> _trainingPlans = [];
  bool _isLoadingPlans = false;
  String? _plansError;
  TrainingPlan? _currentPlan;

  // 今日训练
  TodayWorkout? _todayWorkout;
  bool _isLoadingToday = false;
  String? _todayError;

  // 训练会话
  Map<String, dynamic>? _currentSession;
  bool _isTraining = false;

  // 训练历史
  List<TrainingHistory> _trainingHistories = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  // 训练统计
  TrainingStatistics? _statistics;
  Map<String, dynamic>? _userStats;

  // 过滤器
  ExerciseFilter _exerciseFilter = ExerciseFilter();

  // ==================== Getters ====================

  List<Exercise> get exercises => _exercises;
  bool get isLoadingExercises => _isLoadingExercises;
  String? get exercisesError => _exercisesError;
  int get exercisesTotal => _exercisesTotal;
  int get exercisesPage => _exercisesPage;

  List<TrainingPlan> get trainingPlans => _trainingPlans;
  bool get isLoadingPlans => _isLoadingPlans;
  String? get plansError => _plansError;
  TrainingPlan? get currentPlan => _currentPlan;

  TodayWorkout? get todayWorkout => _todayWorkout;
  bool get isLoadingToday => _isLoadingToday;
  String? get todayError => _todayError;

  Map<String, dynamic>? get currentSession => _currentSession;
  bool get isTraining => _isTraining;

  List<TrainingHistory> get trainingHistories => _trainingHistories;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;

  TrainingStatistics? get statistics => _statistics;
  Map<String, dynamic>? get userStats => _userStats;

  ExerciseFilter get exerciseFilter => _exerciseFilter;

  // ==================== 运动库方法 ====================

  /// 获取运动库
  Future<void> fetchExercises({
    bool loadMore = false,
    bool refresh = false,
  }) async {
    if (_isLoadingExercises) return;

    if (refresh) {
      _exercisesPage = 1;
      _exercises.clear();
    }

    if (loadMore) {
      _exercisesPage++;
    }

    _isLoadingExercises = true;
    _exercisesError = null;
    notifyListeners();

    try {
      final result = await _apiService.getExerciseLibrary(
        muscleGroup: _exerciseFilter.muscleGroup,
        difficulty: _exerciseFilter.difficulty,
        equipment: _exerciseFilter.equipment,
        search: _exerciseFilter.searchQuery,
        page: _exercisesPage,
        limit: 20,
      );

      if (loadMore || refresh) {
        if (refresh) {
          _exercises = result['exercises'];
        } else {
          _exercises.addAll(result['exercises']);
        }
      } else {
        _exercises = result['exercises'];
      }

      _exercisesTotal = result['total'];
    } catch (e) {
      _exercisesError = e.toString();
      debugPrint('获取运动库失败: $e');
    } finally {
      _isLoadingExercises = false;
      notifyListeners();
    }
  }

  /// 更新过滤器
  void updateExerciseFilter(ExerciseFilter filter) {
    _exerciseFilter = filter;
    fetchExercises(refresh: true);
  }

  /// 切换收藏
  Future<void> toggleFavorite(String exerciseId) async {
    try {
      final isFavorited = await _apiService.toggleFavoriteExercise(exerciseId);
      
      // 更新本地状态
      final index = _exercises.indexWhere((e) => e.id == exerciseId);
      if (index != -1) {
        _exercises[index] = _exercises[index].copyWith(isFavorite: isFavorited);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('切换收藏失败: $e');
      rethrow;
    }
  }

  // ==================== 训练计划方法 ====================

  /// 获取训练计划列表
  Future<void> fetchTrainingPlans({bool refresh = false}) async {
    if (_isLoadingPlans) return;

    _isLoadingPlans = true;
    _plansError = null;
    notifyListeners();

    try {
      final result = await _apiService.getTrainingPlans(page: 1, limit: 50);
      _trainingPlans = result['plans'];
    } catch (e) {
      _plansError = e.toString();
      debugPrint('获取训练计划失败: $e');
    } finally {
      _isLoadingPlans = false;
      notifyListeners();
    }
  }

  /// 创建训练计划
  Future<TrainingPlan> createTrainingPlan(TrainingPlan plan) async {
    try {
      final createdPlan = await _apiService.createTrainingPlan(plan);
      _trainingPlans.insert(0, createdPlan);
      notifyListeners();
      return createdPlan;
    } catch (e) {
      debugPrint('创建训练计划失败: $e');
      rethrow;
    }
  }

  /// 更新训练计划
  Future<TrainingPlan> updateTrainingPlan(TrainingPlan plan) async {
    try {
      final updatedPlan = await _apiService.updateTrainingPlan(plan);
      final index = _trainingPlans.indexWhere((p) => p.id == plan.id);
      if (index != -1) {
        _trainingPlans[index] = updatedPlan;
        notifyListeners();
      }
      return updatedPlan;
    } catch (e) {
      debugPrint('更新训练计划失败: $e');
      rethrow;
    }
  }

  /// 删除训练计划
  Future<void> deleteTrainingPlan(String planId) async {
    try {
      await _apiService.deleteTrainingPlan(planId);
      _trainingPlans.removeWhere((p) => p.id == planId);
      notifyListeners();
    } catch (e) {
      debugPrint('删除训练计划失败: $e');
      rethrow;
    }
  }

  /// 设置当前计划
  void setCurrentPlan(TrainingPlan? plan) {
    _currentPlan = plan;
    notifyListeners();
  }

  // ==================== 今日训练方法 ====================

  /// 获取今日训练
  Future<void> fetchTodayWorkout({DateTime? date}) async {
    if (_isLoadingToday) return;

    _isLoadingToday = true;
    _todayError = null;
    notifyListeners();

    try {
      _todayWorkout = await _apiService.getTodayWorkout(date: date);
    } catch (e) {
      _todayError = e.toString();
      debugPrint('获取今日训练失败: $e');
    } finally {
      _isLoadingToday = false;
      notifyListeners();
    }
  }

  /// 创建今日训练
  Future<TodayWorkout> createTodayWorkout({
    String? planId,
    DateTime? date,
  }) async {
    try {
      final workout = await _apiService.createTodayWorkout(
        planId: planId,
        date: date,
      );
      _todayWorkout = workout;
      notifyListeners();
      return workout;
    } catch (e) {
      debugPrint('创建今日训练失败: $e');
      rethrow;
    }
  }

  // ==================== 训练会话方法 ====================

  /// 开始训练
  Future<void> startWorkout({
    String? planId,
    bool isAIWorkout = false,
  }) async {
    try {
      _currentSession = await _apiService.startWorkoutSession(
        planId: planId,
        isAIWorkout: isAIWorkout,
      );
      _isTraining = true;
      notifyListeners();
    } catch (e) {
      debugPrint('开始训练失败: $e');
      rethrow;
    }
  }

  /// 更新训练进度
  Future<void> updateProgress({
    required String workoutExerciseId,
    required int setNumber,
    required int reps,
    double? weight,
    int? duration,
  }) async {
    try {
      await _apiService.updateWorkoutProgress(
        workoutExerciseId: workoutExerciseId,
        setNumber: setNumber,
        reps: reps,
        weight: weight,
        duration: duration,
      );
      // 刷新今日训练数据
      await fetchTodayWorkout();
    } catch (e) {
      debugPrint('更新进度失败: $e');
      rethrow;
    }
  }

  /// 完成训练
  Future<void> completeWorkout() async {
    if (_currentSession == null) return;

    try {
      await _apiService.completeWorkout(_currentSession!['id'].toString());
      _isTraining = false;
      _currentSession = null;
      notifyListeners();
      
      // 刷新今日训练和统计
      await Future.wait([
        fetchTodayWorkout(),
        fetchUserStats(),
      ]);
    } catch (e) {
      debugPrint('完成训练失败: $e');
      rethrow;
    }
  }

  // ==================== 训练历史方法 ====================

  /// 获取训练历史
  Future<void> fetchTrainingHistory({
    DateTime? startDate,
    DateTime? endDate,
    bool refresh = false,
  }) async {
    if (_isLoadingHistory) return;

    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      final result = await _apiService.getTrainingHistory(
        startDate: startDate,
        endDate: endDate,
        page: 1,
        limit: 50,
      );
      _trainingHistories = result['histories'];
    } catch (e) {
      _historyError = e.toString();
      debugPrint('获取训练历史失败: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// 获取训练统计
  Future<void> fetchStatistics({String period = 'week'}) async {
    try {
      _statistics = await _apiService.getTrainingStatistics(period: period);
      notifyListeners();
    } catch (e) {
      debugPrint('获取统计数据失败: $e');
      rethrow;
    }
  }

  /// 获取用户统计
  Future<void> fetchUserStats() async {
    try {
      _userStats = await _apiService.getUserStats();
      notifyListeners();
    } catch (e) {
      debugPrint('获取用户统计失败: $e');
    }
  }

  // ==================== AI训练方法 ====================

  /// 生成AI训练计划
  Future<TrainingPlan> generateAIPlan({
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final plan = await _apiService.generateAIWorkoutPlan(
        preferences: preferences,
      );
      _trainingPlans.insert(0, plan);
      notifyListeners();
      return plan;
    } catch (e) {
      debugPrint('生成AI训练计划失败: $e');
      rethrow;
    }
  }

  /// 获取实时反馈
  Future<String> getRealtimeFeedback({
    required String exerciseName,
    required int currentSet,
    required int targetSets,
    Map<String, dynamic>? performance,
  }) async {
    try {
      return await _apiService.getRealtimeFeedback(
        exerciseName: exerciseName,
        currentSet: currentSet,
        targetSets: targetSets,
        performance: performance,
      );
    } catch (e) {
      debugPrint('获取实时反馈失败: $e');
      return '继续加油! 💪';
    }
  }

  /// 生成激励消息
  Future<String> getMotivation(String context) async {
    try {
      return await _apiService.generateMotivationalMessage(context);
    } catch (e) {
      debugPrint('生成激励消息失败: $e');
      return '相信自己,你可以做到! 💪';
    }
  }

  // ==================== 清理方法 ====================

  void clear() {
    _exercises.clear();
    _trainingPlans.clear();
    _todayWorkout = null;
    _currentSession = null;
    _isTraining = false;
    _trainingHistories.clear();
    _statistics = null;
    _userStats = null;
    notifyListeners();
  }
}

