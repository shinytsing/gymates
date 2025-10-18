import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/gymates_theme.dart';
import '../../../animations/gymates_animations.dart';

/// 📊 训练进度图表 - ProgressChart
/// 
/// 基于Figma设计的训练进度可视化组件
/// 包含周/月/年进度图表，卡路里消耗趋势等

class ProgressChart extends StatefulWidget {
  const ProgressChart({super.key});

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late AnimationController _barAnimationController;
  
  late Animation<double> _chartFadeAnimation;
  late Animation<double> _barAnimation;

  String _selectedPeriod = 'week';
  final List<String> _periods = ['week', 'month', 'year'];

  // 模拟数据
  final List<Map<String, dynamic>> _weekData = [
    {'day': '周一', 'calories': 320, 'workouts': 1},
    {'day': '周二', 'calories': 280, 'workouts': 1},
    {'day': '周三', 'calories': 450, 'workouts': 2},
    {'day': '周四', 'calories': 380, 'workouts': 1},
    {'day': '周五', 'calories': 520, 'workouts': 2},
    {'day': '周六', 'calories': 600, 'workouts': 3},
    {'day': '周日', 'calories': 200, 'workouts': 1},
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 图表动画控制器
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 柱状图动画控制器
    _barAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // 图表淡入动画
    _chartFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 柱状图动画
    _barAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _barAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始图表动画
    _chartAnimationController.forward();
    
    // 延迟开始柱状图动画
    await Future.delayed(const Duration(milliseconds: 300));
    _barAnimationController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    _barAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chartAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _chartFadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和周期选择
                _buildHeader(),
                
                // 图表
                _buildChart(),
                
                // 统计信息
                _buildStats(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '训练进度',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          // 周期选择器
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _periods.map((period) {
                final isSelected = _selectedPeriod == period;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Text(
                      _getPeriodLabel(period),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'week':
        return '周';
      case 'month':
        return '月';
      case 'year':
        return '年';
      default:
        return '周';
    }
  }

  Widget _buildChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedBuilder(
        animation: _barAnimation,
        builder: (context, child) {
          return BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 700,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${_weekData[group.x.toInt()]['calories']} 卡路里',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        _weekData[value.toInt()]['day'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _weekData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final calories = data['calories'] as int;
                
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: calories * _barAnimation.value,
                      color: _getBarColor(calories),
                      width: 24,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Color _getBarColor(int calories) {
    if (calories >= 500) {
      return const Color(0xFF10B981); // 绿色 - 高强度
    } else if (calories >= 300) {
      return const Color(0xFF6366F1); // 蓝色 - 中等强度
    } else {
      return const Color(0xFF8B5CF6); // 紫色 - 低强度
    }
  }

  Widget _buildStats() {
    final totalCalories = _weekData.fold<int>(0, (sum, data) => sum + (data['calories'] as int));
    final totalWorkouts = _weekData.fold<int>(0, (sum, data) => sum + (data['workouts'] as int));
    final avgCalories = (totalCalories / _weekData.length).round();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '总卡路里',
              '$totalCalories',
              Icons.local_fire_department,
              const Color(0xFFEF4444),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              '训练次数',
              '$totalWorkouts',
              Icons.fitness_center,
              const Color(0xFF6366F1),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              '平均卡路里',
              '$avgCalories',
              Icons.trending_up,
              const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
