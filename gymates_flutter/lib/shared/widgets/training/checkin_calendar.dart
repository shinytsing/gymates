import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';
import '../../../animations/gymates_animations.dart';

/// 📅 训练打卡日历 - CheckinCalendar
/// 
/// 基于Figma设计的训练打卡日历组件
/// 显示每日训练状态，支持打卡功能

class CheckinCalendar extends StatefulWidget {
  const CheckinCalendar({super.key});

  @override
  State<CheckinCalendar> createState() => _CheckinCalendarState();
}

class _CheckinCalendarState extends State<CheckinCalendar>
    with TickerProviderStateMixin {
  late AnimationController _calendarAnimationController;
  late AnimationController _checkinController;
  
  late Animation<double> _calendarFadeAnimation;
  late Animation<double> _checkinAnimation;

  DateTime _currentDate = DateTime.now();
  final List<DateTime> _checkedInDates = [
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now().subtract(const Duration(days: 3)),
    DateTime.now().subtract(const Duration(days: 5)),
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now().subtract(const Duration(days: 10)),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 日历动画控制器
    _calendarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 打卡动画控制器
    _checkinController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 日历淡入动画
    _calendarFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _calendarAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 打卡动画
    _checkinAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkinController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() async {
    // 开始日历动画
    _calendarAnimationController.forward();
    
    // 延迟开始打卡动画
    await Future.delayed(const Duration(milliseconds: 400));
    _checkinController.forward();
  }

  @override
  void dispose() {
    _calendarAnimationController.dispose();
    _checkinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _calendarAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _calendarFadeAnimation.value,
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
                // 标题和统计
                _buildHeader(),
                
                // 日历网格
                _buildCalendarGrid(),
                
                // 打卡按钮
                _buildCheckinButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final checkedInCount = _checkedInDates.length;
    final streak = _calculateStreak();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '训练打卡',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '本月已打卡 $checkedInCount 天',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          
          // 连续打卡天数
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak 天',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak() {
    int streak = 0;
    DateTime current = DateTime.now();
    
    for (int i = 0; i < 30; i++) {
      final checkDate = current.subtract(Duration(days: i));
      if (_checkedInDates.any((date) => 
          date.year == checkDate.year &&
          date.month == checkDate.month &&
          date.day == checkDate.day)) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 星期标题
          _buildWeekdayHeaders(),
          
          const SizedBox(height: 8),
          
          // 日期网格
          _buildDateGrid(firstWeekday, daysInMonth),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateGrid(int firstWeekday, int daysInMonth) {
    final List<Widget> dateWidgets = [];
    
    // 添加空白占位符
    for (int i = 1; i < firstWeekday; i++) {
      dateWidgets.add(const SizedBox(height: 40));
    }
    
    // 添加日期
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentDate.year, _currentDate.month, day);
      final isToday = _isToday(date);
      final isCheckedIn = _isCheckedIn(date);
      
      dateWidgets.add(
        _buildDateCell(day, isToday, isCheckedIn, date),
      );
    }
    
    return Wrap(
      children: dateWidgets,
    );
  }

  Widget _buildDateCell(int day, bool isToday, bool isCheckedIn, DateTime date) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (!isCheckedIn) {
          _showCheckinDialog(date);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getDateCellColor(isToday, isCheckedIn),
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(
            color: const Color(0xFF6366F1),
            width: 2,
          ) : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: _getDateTextColor(isToday, isCheckedIn),
            ),
          ),
        ),
      ),
    );
  }

  Color _getDateCellColor(bool isToday, bool isCheckedIn) {
    if (isCheckedIn) {
      return const Color(0xFF10B981);
    } else if (isToday) {
      return const Color(0xFF6366F1).withOpacity(0.1);
    } else {
      return Colors.transparent;
    }
  }

  Color _getDateTextColor(bool isToday, bool isCheckedIn) {
    if (isCheckedIn) {
      return Colors.white;
    } else if (isToday) {
      return const Color(0xFF6366F1);
    } else {
      return const Color(0xFF1F2937);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool _isCheckedIn(DateTime date) {
    return _checkedInDates.any((checkedDate) =>
        checkedDate.year == date.year &&
        checkedDate.month == date.month &&
        checkedDate.day == date.day);
  }

  Widget _buildCheckinButton() {
    final today = DateTime.now();
    final isTodayCheckedIn = _isCheckedIn(today);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isTodayCheckedIn ? null : () {
            HapticFeedback.lightImpact();
            _performCheckin();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isTodayCheckedIn 
                ? const Color(0xFF10B981)
                : const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: AnimatedBuilder(
            animation: _checkinAnimation,
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: isTodayCheckedIn ? 1.0 : _checkinAnimation.value,
                    child: Icon(
                      isTodayCheckedIn ? Icons.check : Icons.fitness_center,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTodayCheckedIn ? '今日已打卡' : '今日打卡',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _performCheckin() {
    setState(() {
      _checkedInDates.add(DateTime.now());
    });
    
    _checkinController.forward().then((_) {
      _checkinController.reset();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('打卡成功！继续保持！'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _showCheckinDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '${date.month}月${date.day}日打卡',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '确定要为这一天添加训练打卡记录吗？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _checkedInDates.add(date);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('打卡记录已添加'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
