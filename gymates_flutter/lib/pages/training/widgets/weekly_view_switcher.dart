import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shared/models/edit_training_plan_models.dart';

/// 🏋️‍♀️ 一周视图切换器 - WeeklyViewSwitcher
/// 
/// 显示一周7天的训练计划切换器
class WeeklyViewSwitcher extends StatefulWidget {
  final int selectedDayIndex;
  final Function(int) onDaySelected;
  final List<TrainingDay> trainingDays;

  const WeeklyViewSwitcher({
    super.key,
    required this.selectedDayIndex,
    required this.onDaySelected,
    required this.trainingDays,
  });

  @override
  State<WeeklyViewSwitcher> createState() => _WeeklyViewSwitcherState();
}

class _WeeklyViewSwitcherState extends State<WeeklyViewSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.trainingDays.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  final isSelected = index == widget.selectedDayIndex;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildDayButton(day, index, isSelected),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDayButton(TrainingDay day, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onDaySelected(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              day.dayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            if (day.isRestDay)
              Icon(
                Icons.hotel,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              )
            else
              Text(
                '${day.totalExercises}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
            if (!day.isRestDay)
              Text(
                '动作',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF6B7280),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
