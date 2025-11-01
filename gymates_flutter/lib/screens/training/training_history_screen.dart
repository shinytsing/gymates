/// 📊 训练历史页面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'providers/training_provider.dart';
import 'models/training_history_model.dart';
import 'widgets/training_stat_card.dart';

class TrainingHistoryScreen extends StatefulWidget {
  const TrainingHistoryScreen({super.key});

  @override
  State<TrainingHistoryScreen> createState() => _TrainingHistoryScreenState();
}

class _TrainingHistoryScreenState extends State<TrainingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<TrainingProvider>();
    await Future.wait([
      provider.fetchTrainingHistory(),
      provider.fetchStatistics(period: _selectedPeriod),
      provider.fetchUserStats(),
    ]);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('训练历史'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '统计', icon: Icon(Icons.bar_chart)),
            Tab(text: '记录', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 周期选择
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            // 用户总统计
            Consumer<TrainingProvider>(
              builder: (context, provider, child) {
                if (provider.userStats == null) {
                  return const SizedBox.shrink();
                }
                return StreakCard(
                  currentStreak: provider.userStats!['current_streak'] ?? 0,
                  longestStreak: provider.userStats!['longest_streak'] ?? 0,
                );
              },
            ),
            const SizedBox(height: 16),
            // 周期统计
            Consumer<TrainingProvider>(
              builder: (context, provider, child) {
                if (provider.statistics == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final stats = provider.statistics!;
                return PeriodStatsCard(
                  period: _selectedPeriod,
                  workouts: stats.totalWorkouts,
                  minutes: stats.totalMinutes,
                  calories: stats.totalCalories,
                  averageDuration: stats.averageWorkoutDuration,
                );
              },
            ),
            const SizedBox(height: 16),
            // 趋势图表
            _buildTrendChart(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text(
            '时间段:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              children: [
                _buildPeriodChip('week', '本周'),
                _buildPeriodChip('month', '本月'),
                _buildPeriodChip('year', '本年'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedPeriod = period);
          final provider = context.read<TrainingProvider>();
          provider.fetchStatistics(period: period);
        }
      },
    );
  }

  Widget _buildTrendChart() {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        if (provider.statistics == null || provider.statistics!.dailyStats.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '训练趋势',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: provider.statistics!.dailyStats
                              .asMap()
                              .entries
                              .map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.calories.toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingHistory) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.trainingHistories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '还没有训练记录',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.trainingHistories.length,
            itemBuilder: (context, index) {
              final history = provider.trainingHistories[index];
              return _buildHistoryCard(history);
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(TrainingHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showHistoryDetail(history),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: history.isAIWorkout
                          ? Colors.purple.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      history.isAIWorkout ? Icons.auto_awesome : Icons.fitness_center,
                      color: history.isAIWorkout ? Colors.purple : Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          history.planName ?? '自由训练',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(history.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (history.completionRate == 100)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatBadge(
                    Icons.timer,
                    '${history.duration} 分钟',
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    Icons.local_fire_department,
                    '${history.caloriesBurned} 卡',
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildStatBadge(
                    Icons.fitness_center,
                    '${history.completedExercises}/${history.totalExercises}',
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: history.completionRate / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  history.completionRate == 100 ? Colors.green : Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.month}月${date.day}日 ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  void _showHistoryDetail(TrainingHistory history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      history.planName ?? '训练详情',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(history.date),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    // 详细统计...
                    const Text('训练详情功能待实现'),
                    if (history.notes != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        '备注',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(history.notes!),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

