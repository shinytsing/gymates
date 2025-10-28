import 'package:flutter/material.dart';
import '../training_new/secondary/history_detail_page.dart';
import '../training_new/secondary/training_calendar_page.dart';
import '../training_new/secondary/trends_analysis_page.dart';

/// 📅 历史记录页面（一级页面）
class HistoryTrainingPage extends StatefulWidget {
  const HistoryTrainingPage({super.key});

  @override
  State<HistoryTrainingPage> createState() => _HistoryTrainingPageState();
}

class _HistoryTrainingPageState extends State<HistoryTrainingPage> {
  String _selectedView = 'calendar'; // calendar, list, trends

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 视图切换
        _buildViewSelector(),
        
        // 主要内容
        Expanded(
          child: _buildCurrentView(),
        ),
      ],
    );
  }

  Widget _buildViewSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildViewButton(
              icon: Icons.calendar_today,
              label: '日历',
              isSelected: _selectedView == 'calendar',
              onTap: () => setState(() => _selectedView = 'calendar'),
            ),
          ),
          Expanded(
            child: _buildViewButton(
              icon: Icons.list,
              label: '列表',
              isSelected: _selectedView == 'list',
              onTap: () => setState(() => _selectedView = 'list'),
            ),
          ),
          Expanded(
            child: _buildViewButton(
              icon: Icons.trending_up,
              label: '趋势',
              isSelected: _selectedView == 'trends',
              onTap: () => setState(() => _selectedView = 'trends'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6366F1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_selectedView) {
      case 'calendar':
        return const TrainingCalendarPage();
      case 'trends':
        return const TrendsAnalysisPage();
      case 'list':
      default:
        return _buildHistoryList();
    }
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 20, // Mock data
      itemBuilder: (context, index) {
        return _buildHistoryCard(index);
      },
    );
  }

  Widget _buildHistoryCard(int index) {
    final date = DateTime.now().subtract(Duration(days: index));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openHistoryDetail(date),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '胸肌训练',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '45分钟',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '300卡',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      return '${date.month}月${date.day}日';
    }
  }

  void _openHistoryDetail(DateTime date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryDetailPage(date: date),
      ),
    );
  }
}

