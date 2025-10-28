import 'package:flutter/material.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../../services/training_session_service.dart';

/// 🔥 训练打卡与激励系统 - WorkoutCheckInWidget
/// 
/// 功能包括：
/// 1. 连续打卡天数统计
/// 2. 成就徽章展示
/// 3. 打卡记录日历
/// 4. 激励标语

class WorkoutCheckInWidget extends StatelessWidget {
  const WorkoutCheckInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CheckInData>(
      future: _loadCheckInData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? CheckInData.empty();

        return Column(
          children: [
            _buildStreakCard(data),
            const SizedBox(height: 16),
            _buildAchievementBadges(data.achievements),
          ],
        );
      },
    );
  }

  Future<CheckInData> _loadCheckInData() async {
    final history = await TrainingSessionService.getTrainingHistory();
    
    // 计算连续打卡天数
    final consecutiveDays = _calculateConsecutiveDays(history);
    
    // 生成成就徽章
    final achievements = _generateAchievements(consecutiveDays, history.length);
    
    return CheckInData(
      consecutiveDays: consecutiveDays,
      totalDays: history.length,
      achievements: achievements,
      checkInDates: history.map((r) => r.completedAt).toSet(),
    );
  }

  int _calculateConsecutiveDays(List<TrainingHistoryRecord> history) {
    if (history.isEmpty) return 0;
    
    // 按日期排序（最新的在前）
    final sortedHistory = List<DateTime>.from(
      history.map((r) => r.completedAt).toList()
    )..sort((a, b) => b.compareTo(a));
    
    final today = DateTime.now();
    int consecutiveDays = 0;
    DateTime currentDate = today;
    
    for (final date in sortedHistory) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final currentDateOnly = DateTime(currentDate.year, currentDate.month, currentDate.day);
      
      if (dateOnly == currentDateOnly || dateOnly == currentDateOnly.subtract(const Duration(days: 1))) {
        consecutiveDays++;
        currentDate = dateOnly;
      } else {
        break;
      }
    }
    
    return consecutiveDays;
  }

  List<Achievement> _generateAchievements(int consecutiveDays, int totalDays) {
    final achievements = <Achievement>[];
    
    // 连续打卡成就
    if (consecutiveDays >= 7) {
      achievements.add(const Achievement(
        id: 'streak_7',
        name: '坚持达人',
        description: '连续7天打卡',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        unlocked: true,
      ));
    }
    
    if (consecutiveDays >= 30) {
      achievements.add(const Achievement(
        id: 'streak_30',
        name: '月度之星',
        description: '连续30天打卡',
        icon: Icons.emoji_events,
        color: Colors.purple,
        unlocked: true,
      ));
    }
    
    // 总训练天数成就
    if (totalDays >= 50) {
      achievements.add(const Achievement(
        id: 'total_50',
        name: '训练狂魔',
        description: '累计50次训练',
        icon: Icons.fitness_center,
        color: Colors.red,
        unlocked: true,
      ));
    }
    
    if (totalDays >= 100) {
      achievements.add(const Achievement(
        id: 'total_100',
        name: '百炼成钢',
        description: '累计100次训练',
        icon: Icons.school,
        color: Colors.blue,
        unlocked: true,
      ));
    }
    
    return achievements;
  }

  Widget _buildStreakCard(CheckInData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '连续打卡 ${data.consecutiveDays} 天',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '累计打卡 ${data.totalDays} 天',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStreakProgress(data.consecutiveDays),
        ],
      ),
    );
  }

  Widget _buildStreakProgress(int consecutiveDays) {
    final nextMilestone = _getNextMilestone(consecutiveDays);
    final progress = consecutiveDays / nextMilestone;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '距离下一目标',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            Text(
              '${nextMilestone - consecutiveDays}天',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  int _getNextMilestone(int current) {
    final milestones = [7, 14, 30, 60, 100];
    for (final milestone in milestones) {
      if (current < milestone) return milestone;
    }
    return 100;
  }

  Widget _buildAchievementBadges(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: GymatesTheme.getCardShadow(false),
        ),
        child: Column(
          children: [
            const Text(
              '成就徽章',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: GymatesTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '继续训练，解锁更多成就！',
              style: TextStyle(
                fontSize: 14,
                color: GymatesTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

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
          const Text(
            '成就徽章',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: achievements.map((achievement) => 
              _buildBadgeItem(achievement)
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            achievement.color.withValues(alpha: 0.1),
            achievement.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            achievement.icon,
            color: achievement.color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            achievement.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class CheckInData {
  final int consecutiveDays;
  final int totalDays;
  final List<Achievement> achievements;
  final Set<DateTime> checkInDates;

  CheckInData({
    required this.consecutiveDays,
    required this.totalDays,
    required this.achievements,
    required this.checkInDates,
  });

  factory CheckInData.empty() {
    return CheckInData(
      consecutiveDays: 0,
      totalDays: 0,
      achievements: [],
      checkInDates: {},
    );
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
  });
}

