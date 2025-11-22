import 'package:flutter/foundation.dart';
import '../models/record.dart';

/// 🏋️‍♀️ 历史控制器 - HistoryController
/// 
/// 负责管理训练历史记录的状态和逻辑：
/// 1. 训练记录管理
/// 2. AI总结生成
/// 3. 数据统计和分析
/// 4. 导出和分享功能

class HistoryController with ChangeNotifier {
  List<WorkoutRecord> _records = [];
  bool _loading = false;
  String? _error;

  // Getters
  List<WorkoutRecord> get records => _records;
  bool get loading => _loading;
  String? get error => _error;

  /// 加载训练记录
  Future<void> loadRecords() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // 模拟从数据库或API加载数据
      await Future.delayed(const Duration(seconds: 1));
      
      _records = _generateMockRecords();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 添加新的训练记录
  void addRecord(WorkoutRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }

  /// 更新训练记录
  void updateRecord(WorkoutRecord updatedRecord) {
    final index = _records.indexWhere((record) => record.id == updatedRecord.id);
    if (index != -1) {
      _records[index] = updatedRecord;
      notifyListeners();
    }
  }

  /// 删除训练记录
  void deleteRecord(String recordId) {
    _records.removeWhere((record) => record.id == recordId);
    notifyListeners();
  }

  /// 获取指定日期的记录
  List<WorkoutRecord> getRecordsByDate(DateTime date) {
    return _records.where((record) => 
      record.date.year == date.year &&
      record.date.month == date.month &&
      record.date.day == date.day
    ).toList();
  }

  /// 获取指定时间范围的记录
  List<WorkoutRecord> getRecordsByDateRange(DateTime startDate, DateTime endDate) {
    return _records.where((record) => 
      record.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
      record.date.isBefore(endDate.add(const Duration(days: 1)))
    ).toList();
  }

  /// 获取本周记录
  List<WorkoutRecord> getThisWeekRecords() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return getRecordsByDateRange(startOfWeek, endOfWeek);
  }

  /// 获取本月记录
  List<WorkoutRecord> getThisMonthRecords() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return getRecordsByDateRange(startOfMonth, endOfMonth);
  }

  /// 生成AI总结
  Future<String> generateAISummary(WorkoutRecord record) async {
    try {
      // 模拟AI分析过程
      await Future.delayed(const Duration(seconds: 2));
      
      // 基于训练数据生成总结
      final completionRate = record.completedExercises / record.totalExercises;
      final avgCaloriesPerMinute = record.calories / record.durationMinutes;
      
      String summary = '';
      
      if (completionRate >= 0.9) {
        summary += '训练完成度很高，表现优秀！';
      } else if (completionRate >= 0.7) {
        summary += '训练完成度良好，继续保持！';
      } else {
        summary += '训练完成度有待提升，建议调整训练强度。';
      }
      
      if (avgCaloriesPerMinute > 8) {
        summary += ' 卡路里消耗效率很高，训练强度适中。';
      } else if (avgCaloriesPerMinute > 5) {
        summary += ' 卡路里消耗正常，可以适当增加训练强度。';
      } else {
        summary += ' 建议增加训练强度以提高卡路里消耗。';
      }
      
      summary += ' 建议下次训练时注意动作质量，保持正确的呼吸节奏。';
      
      return summary;
    } catch (e) {
      return 'AI分析暂时不可用，请稍后再试。';
    }
  }

  /// 获取训练统计
  TrainingStatistics getStatistics() {
    if (_records.isEmpty) {
      return TrainingStatistics.empty();
    }

    int totalWorkouts = _records.length;
    int totalDuration = _records.fold(0, (sum, record) => sum + record.durationMinutes);
    int totalCalories = _records.fold(0, (sum, record) => sum + record.calories);
    int totalExercises = _records.fold(0, (sum, record) => sum + record.totalExercises);
    int completedExercises = _records.fold(0, (sum, record) => sum + record.completedExercises);
    
    double avgDuration = totalDuration / totalWorkouts;
    double avgCalories = totalCalories / totalWorkouts;
    double completionRate = totalExercises > 0 ? completedExercises / totalExercises : 0.0;
    
    // 计算连续训练天数
    int consecutiveDays = _calculateConsecutiveDays();
    
    // 计算最活跃的训练日
    String mostActiveDay = _getMostActiveDay();
    
    return TrainingStatistics(
      totalWorkouts: totalWorkouts,
      totalDuration: totalDuration,
      totalCalories: totalCalories,
      avgDuration: avgDuration,
      avgCalories: avgCalories,
      completionRate: completionRate,
      consecutiveDays: consecutiveDays,
      mostActiveDay: mostActiveDay,
    );
  }

  /// 计算连续训练天数
  int _calculateConsecutiveDays() {
    if (_records.isEmpty) return 0;
    
    // 按日期排序
    final sortedRecords = List<WorkoutRecord>.from(_records)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int consecutiveDays = 0;
    DateTime currentDate = DateTime.now();
    
    for (final record in sortedRecords) {
      final recordDate = DateTime(record.date.year, record.date.month, record.date.day);
      final checkDate = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      if (recordDate.isAtSameMomentAs(checkDate) || 
          recordDate.isAtSameMomentAs(checkDate.subtract(Duration(days: consecutiveDays)))) {
        consecutiveDays++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }

  /// 获取最活跃的训练日
  String _getMostActiveDay() {
    if (_records.isEmpty) return '无';
    
    final dayCounts = <int, int>{};
    
    for (final record in _records) {
      final weekday = record.date.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }
    
    if (dayCounts.isEmpty) return '无';
    
    final mostActiveWeekday = dayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[mostActiveWeekday - 1];
  }

  /// 获取训练趋势
  List<TrainingTrend> getTrainingTrends() {
    if (_records.isEmpty) return [];
    
    final trends = <TrainingTrend>[];
    final now = DateTime.now();
    
    // 获取最近30天的数据
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayRecords = getRecordsByDate(date);
      
      int totalDuration = dayRecords.fold(0, (sum, record) => sum + record.durationMinutes);
      int totalCalories = dayRecords.fold(0, (sum, record) => sum + record.calories);
      
      trends.add(TrainingTrend(
        date: date,
        duration: totalDuration,
        calories: totalCalories,
        workoutCount: dayRecords.length,
      ));
    }
    
    return trends;
  }

  /// 生成模拟数据
  List<WorkoutRecord> _generateMockRecords() {
    final now = DateTime.now();
    return [
      WorkoutRecord(
        id: '1',
        date: now.subtract(const Duration(days: 1)),
        planId: 'plan_1',
        planTitle: '胸背训练',
        durationMinutes: 45,
        calories: 320,
        totalExercises: 6,
        completedExercises: 5,
        aiSummary: '训练表现优秀！胸部力量有明显提升，建议下次增加重量。背部动作很标准，继续保持！',
      ),
      WorkoutRecord(
        id: '2',
        date: now.subtract(const Duration(days: 3)),
        planId: 'plan_2',
        planTitle: '腿部训练',
        durationMinutes: 60,
        calories: 450,
        totalExercises: 5,
        completedExercises: 5,
        aiSummary: '腿部训练完成度100%！深蹲动作很标准，建议下次尝试增加重量。有氧运动表现也很棒！',
      ),
      WorkoutRecord(
        id: '3',
        date: now.subtract(const Duration(days: 5)),
        planId: 'plan_3',
        planTitle: '全身训练',
        durationMinutes: 50,
        calories: 380,
        totalExercises: 8,
        completedExercises: 7,
        aiSummary: '全身训练表现良好！核心力量有明显提升，建议保持当前训练强度。',
      ),
      WorkoutRecord(
        id: '4',
        date: now.subtract(const Duration(days: 7)),
        planId: 'plan_4',
        planTitle: '上肢训练',
        durationMinutes: 40,
        calories: 280,
        totalExercises: 6,
        completedExercises: 4,
        aiSummary: '上肢训练完成度有待提升，建议调整训练计划。动作质量很好，继续保持！',
      ),
      WorkoutRecord(
        id: '5',
        date: now.subtract(const Duration(days: 10)),
        planId: 'plan_5',
        planTitle: '有氧训练',
        durationMinutes: 30,
        calories: 250,
        totalExercises: 4,
        completedExercises: 4,
        aiSummary: '有氧训练完成度100%！心肺功能有明显改善，建议保持当前训练频率。',
      ),
    ];
  }
}

/// 训练统计信息
class TrainingStatistics {
  final int totalWorkouts;
  final int totalDuration;
  final int totalCalories;
  final double avgDuration;
  final double avgCalories;
  final double completionRate;
  final int consecutiveDays;
  final String mostActiveDay;

  TrainingStatistics({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.totalCalories,
    required this.avgDuration,
    required this.avgCalories,
    required this.completionRate,
    required this.consecutiveDays,
    required this.mostActiveDay,
  });

  factory TrainingStatistics.empty() {
    return TrainingStatistics(
      totalWorkouts: 0,
      totalDuration: 0,
      totalCalories: 0,
      avgDuration: 0.0,
      avgCalories: 0.0,
      completionRate: 0.0,
      consecutiveDays: 0,
      mostActiveDay: '无',
    );
  }
}

/// 训练趋势数据
class TrainingTrend {
  final DateTime date;
  final int duration;
  final int calories;
  final int workoutCount;

  TrainingTrend({
    required this.date,
    required this.duration,
    required this.calories,
    required this.workoutCount,
  });
}
