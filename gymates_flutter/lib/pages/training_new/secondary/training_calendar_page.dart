import 'package:flutter/material.dart';
import 'history_detail_page.dart';

/// 📅 训练日历页面（二级页面）
class TrainingCalendarPage extends StatelessWidget {
  const TrainingCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 35, // 5周
      itemBuilder: (context, index) {
        final date = DateTime.now().subtract(const Duration(days: 14)).add(
          Duration(days: index),
        );
        final hasWorkout = index % 3 == 0; // Mock data
        
        return _buildCalendarCell(date, hasWorkout, context);
      },
    );
  }

  Widget _buildCalendarCell(DateTime date, bool hasWorkout, BuildContext context) {
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;
    
    return GestureDetector(
      onTap: hasWorkout
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryDetailPage(date: date),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: hasWorkout
              ? const Color(0xFF6366F1)
              : isToday
                  ? const Color(0xFFF3F4F6)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hasWorkout
                    ? Colors.white
                    : isToday
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF6B7280),
              ),
            ),
            if (hasWorkout)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

