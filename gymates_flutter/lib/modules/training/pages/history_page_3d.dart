import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/3d_components/index.dart';
import '../../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../secondary/history_3d_detail_page.dart';
import '../secondary/training_calendar_page.dart';
import '../secondary/trends_analysis_page.dart';

/// 📅 Apple Fitness+ Style History Training Page (3D)
/// 
/// Design Features:
/// - 3D view selector (animated tabs)
/// - 3D history cards (frosted glass with depth)
/// - 3D calendar view
/// - 3D trends charts
/// - Smooth animations and transitions
/// - Pull-to-refresh functionality

class HistoryTrainingPage extends StatefulWidget {
  const HistoryTrainingPage({super.key});

  @override
  State<HistoryTrainingPage> createState() => _HistoryTrainingPageState();
}

class _HistoryTrainingPageState extends State<HistoryTrainingPage>
    with TickerProviderStateMixin {
  String _selectedView = 'list'; // calendar, list, trends
  late AnimationController _viewTransitionController;
  final List<Map<String, dynamic>> _historyData = [];

  @override
  void initState() {
    super.initState();
    _viewTransitionController = AnimationController(
      duration: AppleFitnessTheme.durationNormal,
      vsync: this,
    );
    _loadHistoryData();
  }

  @override
  void dispose() {
    _viewTransitionController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    // Mock data - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    setState(() {
      _historyData.clear();
      for (int i = 0; i < 20; i++) {
        final date = DateTime.now().subtract(Duration(days: i));
        _historyData.add({
          'id': i,
          'date': date,
          'name': _getWorkoutName(i),
          'duration': 30 + (i % 5) * 5,
          'calories': 200 + (i % 10) * 20,
          'exercises': 5 + (i % 3),
        });
      }
    });
  }

  String _getWorkoutName(int index) {
    final names = [
      '胸肌训练',
      '背部训练',
      '腿部训练',
      '肩部训练',
      '手臂训练',
      '全身训练',
      '有氧训练',
      '核心训练',
    ];
    return names[index % names.length];
  }

  void _switchView(String view) {
    if (_selectedView == view) return;
    
    HapticFeedback.lightImpact();
    _viewTransitionController.forward(from: 0.0).then((_) {
      setState(() {
        _selectedView = view;
      });
      _viewTransitionController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadHistoryData,
      color: AppleFitnessTheme.primaryBlue,
      child: Column(
        children: [
          // 3D View Selector
          cartoon_animations.SlideInAnimation(
            direction: cartoon_animations.SlideDirection.fromTop,
            delay: const Duration(milliseconds: 100),
            child: _build3DViewSelector(),
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingM),
          
          // Main Content
          Expanded(
            child: FadeTransition(
              opacity: _viewTransitionController,
              child: _buildCurrentView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DViewSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
      decoration: BoxDecoration(
        color: AppleFitnessTheme.backgroundSecondary,
        borderRadius: AppleFitnessTheme.radiusMedium,
        boxShadow: AppleFitnessTheme.softShadow(elevation: 2),
      ),
      child: Row(
        children: [
          _build3DViewButton(
            icon: Icons.list_rounded,
            label: '列表',
            view: 'list',
          ),
          _build3DViewButton(
            icon: Icons.calendar_today_rounded,
            label: '日历',
            view: 'calendar',
          ),
          _build3DViewButton(
            icon: Icons.trending_up_rounded,
            label: '趋势',
            view: 'trends',
          ),
        ],
      ),
    );
  }

  Widget _build3DViewButton({
    required IconData icon,
    required String label,
    required String view,
  }) {
    final isSelected = _selectedView == view;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchView(view),
        child: AnimatedContainer(
          duration: AppleFitnessTheme.durationNormal,
          curve: AppleFitnessTheme.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            vertical: AppleFitnessTheme.spacingM,
            horizontal: AppleFitnessTheme.spacingS,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppleFitnessTheme.primaryGradient
                : null,
            borderRadius: AppleFitnessTheme.radiusMedium,
            boxShadow: isSelected
                ? AppleFitnessTheme.softShadow(elevation: 4)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AppleFitnessTheme.textSecondary,
                size: 24,
              ),
              SizedBox(height: AppleFitnessTheme.spacingXS / 2),
              Text(
                label,
                style: AppleFitnessTheme.bodySmall.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppleFitnessTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
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
        return _build3DHistoryList();
    }
  }

  Widget _build3DHistoryList() {
    if (_historyData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 80,
              color: AppleFitnessTheme.textSecondary.withValues(alpha: 0.3),
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              '暂无训练记录',
              style: AppleFitnessTheme.headlineSmall.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingXS),
            Text(
              '开始你的第一次训练吧！',
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      itemCount: _historyData.length,
      itemBuilder: (context, index) {
        return cartoon_animations.SlideInAnimation(
          direction: cartoon_animations.SlideDirection.fromRight,
          delay: Duration(milliseconds: 100 + (index % 5) * 50),
          child: _build3DHistoryCard(_historyData[index], index),
        );
      },
    );
  }

  Widget _build3DHistoryCard(Map<String, dynamic> data, int index) {
    final date = data['date'] as DateTime;
    final name = data['name'] as String;
    final duration = data['duration'] as int;
    final calories = data['calories'] as int;
    final exercises = data['exercises'] as int;

    return Container(
      margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
      child: Card3D(
        onTap: () => _openHistoryDetail(date),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
          child: Row(
            children: [
              // 3D Icon Container
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppleFitnessTheme.primaryGradient,
                  borderRadius: AppleFitnessTheme.radiusMedium,
                  boxShadow: AppleFitnessTheme.softShadow(elevation: 3),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              
              SizedBox(width: AppleFitnessTheme.spacingM),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppleFitnessTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppleFitnessTheme.spacingXS / 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: AppleFitnessTheme.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          _formatDate(date),
                          style: AppleFitnessTheme.bodySmall.copyWith(
                            color: AppleFitnessTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Stats
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.timer_rounded,
                        size: 16,
                        color: AppleFitnessTheme.primaryBlue,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$duration分钟',
                        style: AppleFitnessTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppleFitnessTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingXS / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: AppleFitnessTheme.error,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '$calories卡',
                        style: AppleFitnessTheme.bodySmall.copyWith(
                          color: AppleFitnessTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingXS / 2),
                  Text(
                    '$exercises个动作',
                    style: AppleFitnessTheme.bodySmall.copyWith(
                      color: AppleFitnessTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
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
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => History3DDetailPage(date: date),
      ),
    );
  }
}
