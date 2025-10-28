import 'package:flutter/material.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';

/// 📅 训练打卡日历组件 - CheckInCalendarWidget
/// 
/// 展示用户的训练打卡记录，高亮打卡日期

class CheckInCalendarWidget extends StatelessWidget {
  const CheckInCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 模拟打卡数据
    final checkInDates = _generateCheckInDates();
    
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '训练打卡',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
              ),
              Text(
                '本月',
                style: TextStyle(
                  fontSize: 13,
                  color: GymatesTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCalendar(checkInDates),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }
  
  Widget _buildCalendar(Set<DateTime> checkInDates) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final startWeekday = firstDay.weekday;
    
    // 创建日历网格 (7列 x 6行)
    final List<List<DateTime?>> weeks = [];
    List<DateTime?> week = [];
    
    // 填充第一周的前置空格
    for (int i = 0; i < startWeekday - 1; i++) {
      week.add(null);
    }
    
    // 填充日期
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(now.year, now.month, day);
      week.add(date);
      
      if (week.length == 7) {
        weeks.add(week);
        week = [];
      }
    }
    
    // 填充最后一周的后置空格
    if (week.isNotEmpty) {
      while (week.length < 7) {
        week.add(null);
      }
      weeks.add(week);
    }
    
    return Column(
      children: [
        // 星期标题
        Row(
          children: ['一', '二', '三', '四', '五', '六', '日'].map((day) {
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: GymatesTheme.lightTextSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // 日期网格
        ...weeks.map((week) => _buildWeekRow(week, checkInDates)),
      ],
    );
  }
  
  Widget _buildWeekRow(List<DateTime?> week, Set<DateTime> checkInDates) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: week.map((date) {
          return Expanded(
            child: Center(
              child: date == null
                  ? const SizedBox(width: 36, height: 36)
                  : _buildDayCell(date, checkInDates),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildDayCell(DateTime date, Set<DateTime> checkInDates) {
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final isCheckIn = checkInDates.contains(date);
    
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isCheckIn
            ? GymatesTheme.primaryColor
            : isToday
                ? GymatesTheme.primaryColor.withValues(alpha: 0.1)
                : null,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          date.day.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isToday || isCheckIn
                ? FontWeight.bold
                : FontWeight.normal,
            color: isCheckIn || isToday
                ? Colors.white
                : GymatesTheme.lightTextPrimary,
          ),
        ),
      ),
    );
  }
  
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.white, '今日'),
        const SizedBox(width: 16),
        _buildLegendItem(GymatesTheme.primaryColor.withValues(alpha: 0.3), '打卡'),
      ],
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
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
  
  Set<DateTime> _generateCheckInDates() {
    final now = DateTime.now();
    return {
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, 3),
      DateTime(now.year, now.month, 5),
      DateTime(now.year, now.month, 7),
      DateTime(now.year, now.month, 9),
      DateTime(now.year, now.month, 12),
      DateTime(now.year, now.month, 15),
      DateTime(now.year, now.month, 17),
      DateTime(now.year, now.month, 19),
      DateTime(now.year, now.month, 21),
      DateTime(now.year, now.month, 23),
      DateTime(now.year, now.month, 25),
    };
  }
}

