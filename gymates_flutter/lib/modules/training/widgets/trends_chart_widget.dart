import 'package:flutter/material.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';

/// 📊 训练趋势图表组件 - TrendsChartWidget
/// 
/// 展示用户的训练趋势，包括训练频率、强度、卡路里消耗等

class TrendsChartWidget extends StatelessWidget {
  const TrendsChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟最近7天的训练数据
    final trendsData = _generateTrendsData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '训练趋势',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  // TODO: 处理时间范围选择
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'week', child: Text('最近7天')),
                  const PopupMenuItem(value: 'month', child: Text('最近30天')),
                  const PopupMenuItem(value: 'year', child: Text('最近一年')),
                ],
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '最近7天',
                      style: TextStyle(
                        fontSize: 13,
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: GymatesTheme.lightTextSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildChart(trendsData),
          const SizedBox(height: 16),
          _buildStats(trendsData),
        ],
      ),
    );
  }
  
  Widget _buildChart(List<TrendDataPoint> data) {
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final chartHeight = 120.0;
    
    return SizedBox(
      height: chartHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: data.map((point) {
          final heightPercent = point.value / maxValue;
          final barHeight = chartHeight * heightPercent;
          
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    point.label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: GymatesTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildStats(List<TrendDataPoint> data) {
    final totalMinutes = data.map((d) => d.value).fold(0, (a, b) => a + b);
    final avgMinutes = totalMinutes ~/ data.length;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('总时长', '$totalMinutes分', Icons.access_time),
        _buildStatItem('平均时长', '$avgMinutes分', Icons.trending_up),
        _buildStatItem('训练天数', '${data.where((d) => d.value > 0).length}天', Icons.calendar_today),
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: GymatesTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: GymatesTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }
  
  List<TrendDataPoint> _generateTrendsData() {
    return [
      TrendDataPoint(label: '周一', value: 45),
      TrendDataPoint(label: '周二', value: 0), // 休息日
      TrendDataPoint(label: '周三', value: 60),
      TrendDataPoint(label: '周四', value: 0), // 休息日
      TrendDataPoint(label: '周五', value: 50),
      TrendDataPoint(label: '周六', value: 40),
      TrendDataPoint(label: '周日', value: 0), // 休息日
    ];
  }
}

class TrendDataPoint {
  final String label;
  final int value;
  
  const TrendDataPoint({
    required this.label,
    required this.value,
  });
}

