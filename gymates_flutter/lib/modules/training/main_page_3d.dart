import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/3d_components/index.dart';
import '../../core/theme/cartoon_3d_characters.dart';
import '../../../widgets/avatars/fitness_3d_avatar.dart';
import 'pages/today_page_3d.dart';
import 'pages/history_page_3d.dart';
import '../../../modules/ai/ai_training_page.dart';

/// 🏋️‍♀️ Apple Fitness+ Style Training Main Page
/// 
/// Design Features:
/// - 3D tab bar (floating tabs)
/// - 3D tab indicator (animated)
/// - Smooth tab transitions
/// - Today Training + History tabs
/// - 3D avatar (unified component)
/// - AI assistant button
/// - Animated gradient background

class TrainingMainPage3D extends StatefulWidget {
  const TrainingMainPage3D({super.key});

  @override
  State<TrainingMainPage3D> createState() => _TrainingMainPage3DState();
}

class _TrainingMainPage3DState extends State<TrainingMainPage3D>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _indicatorController = AnimationController(
      duration: AppleFitnessTheme.durationNormal,
      vsync: this,
    );
    
    _indicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _indicatorController,
        curve: AppleFitnessTheme.easeInOutCubic,
      ),
    );
    
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
      if (_tabController.indexIsChanging) {
        _indicatorController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  Today3DTrainingPage(),
                  HistoryTrainingPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: Row(
          children: [
            // 3D Avatar (unified component)
            Fitness3DAvatar(
              action: FitnessAction.weightlifting,
              emotion: CharacterEmotion.motivated,
              size: 60,
              animated: true,
            ),
            
            SizedBox(width: AppleFitnessTheme.spacingM),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '训练计划',
                    style: AppleFitnessTheme.displaySmall,
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingXS / 2),
                  Text(
                    '开始今天的挑战! 💪',
                    style: AppleFitnessTheme.bodySmall.copyWith(
                      color: AppleFitnessTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // AI assistant button
            Button3D.icon(
              icon: Icons.psychology_rounded,
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AITrainingPage(),
                  ),
                );
              },
              size: Button3DSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
      decoration: BoxDecoration(
        color: AppleFitnessTheme.backgroundSecondary,
        borderRadius: AppleFitnessTheme.radiusMedium,
        boxShadow: AppleFitnessTheme.softShadow(elevation: 2),
      ),
      child: Row(
        children: [
          _buildTabItem(
            icon: Icons.today_rounded,
            label: '今日训练',
            index: 0,
          ),
          _buildTabItem(
            icon: Icons.history_rounded,
            label: '历史记录',
            index: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentTab == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: AppleFitnessTheme.durationNormal,
          curve: AppleFitnessTheme.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            vertical: AppleFitnessTheme.spacingM,
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
                style: AppleFitnessTheme.bodyMedium.copyWith(
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
}

