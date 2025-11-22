import 'package:flutter/material.dart';
import '../../../core/3d_components/index.dart';

/// 📊 Apple Fitness+ Style History Detail Page
class History3DDetailPage extends StatefulWidget {
  final DateTime date;

  const History3DDetailPage({
    super.key,
    required this.date,
  });

  @override
  State<History3DDetailPage> createState() => _History3DDetailPageState();
}

class _History3DDetailPageState extends State<History3DDetailPage> {
  bool _isLoading = true;
  int _totalDuration = 0; // 分钟
  int _totalCalories = 0;
  int _totalExercises = 0;
  List<HistoryExercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Load from backend API
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock data for now
      final mockData = _generateMockHistoryData();
      
      if (mounted) {
        setState(() {
          _totalDuration = mockData['duration'] ?? 45;
          _totalCalories = mockData['calories'] ?? 320;
          _totalExercises = mockData['exercises']?.length ?? 0;
          _exercises = (mockData['exercises'] as List?)
                  ?.map((e) => HistoryExercise.fromJson(e))
                  .toList() ??
              [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载历史数据失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, dynamic> _generateMockHistoryData() {
    return {
      'duration': 45,
      'calories': 320,
      'exercises': List.generate(8, (index) {
        return {
          'id': 'exercise_$index',
          'name': '动作 ${index + 1}',
          'sets': 3,
          'reps': 12,
          'calories': 40,
        };
      }),
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '今天';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return '昨天';
    } else {
      return '${date.year}年${date.month}月${date.day}日';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _formatDate(widget.date),
          style: AppleFitnessTheme.titleLarge,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: _isLoading
            ? Center(
                child: CircularProgress3D(
                  value: 0.0,
                  size: 60,
                  progressColor: AppleFitnessTheme.primaryBlue,
                  showPercentage: false,
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadHistoryData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCards(),
                      SizedBox(height: AppleFitnessTheme.spacingXL),
                      _buildExerciseList(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer,
            label: '时长',
            value: '$_totalDuration分钟',
            color: AppleFitnessTheme.primaryBlue,
          ),
        ),
        SizedBox(width: AppleFitnessTheme.spacingM),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department,
            label: '消耗',
            value: '$_totalCalories卡',
            color: AppleFitnessTheme.primaryPink,
          ),
        ),
        SizedBox(width: AppleFitnessTheme.spacingM),
        Expanded(
          child: _buildStatCard(
            icon: Icons.fitness_center,
            label: '动作',
            value: '$_totalExercises个',
            color: AppleFitnessTheme.primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card3D(
      useFrostedGlass: true,
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: AppleFitnessTheme.spacingS),
          Text(
            value,
            style: AppleFitnessTheme.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppleFitnessTheme.spacingXS),
          Text(
            label,
            style: AppleFitnessTheme.bodySmall.copyWith(
              color: AppleFitnessTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 80,
              color: AppleFitnessTheme.textTertiary,
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              '暂无训练记录',
              style: AppleFitnessTheme.headlineSmall,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '训练动作',
          style: AppleFitnessTheme.titleLarge,
        ),
        SizedBox(height: AppleFitnessTheme.spacingM),
        ..._exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return StaggeredAnimation3D(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
              child: Card3D(
                useFrostedGlass: true,
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppleFitnessTheme.primaryGradient,
                      borderRadius: AppleFitnessTheme.radiusSmall,
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    exercise.name,
                    style: AppleFitnessTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${exercise.sets}组 × ${exercise.reps}次',
                    style: AppleFitnessTheme.bodySmall.copyWith(
                      color: AppleFitnessTheme.textSecondary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.check_circle,
                    color: AppleFitnessTheme.success,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// History exercise model
class HistoryExercise {
  final String id;
  final String name;
  final int sets;
  final int reps;
  final int calories;

  HistoryExercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.calories,
  });

  factory HistoryExercise.fromJson(Map<String, dynamic> json) {
    return HistoryExercise(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      calories: json['calories'] ?? 0,
    );
  }
}

