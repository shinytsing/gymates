import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';
import '../../shared/widgets/training/today_plan_card.dart';
import '../../shared/widgets/training/ai_plan_generator.dart';
import '../../shared/widgets/training/progress_chart.dart';
import '../../shared/widgets/training/checkin_calendar.dart';
import '../../shared/widgets/training/training_history_list.dart';
import '../../shared/widgets/training/training_mode_selection.dart';
import 'training_plan_editor.dart';
import '../../shared/models/mock_data.dart';
import '../../services/training_session_service.dart';
import '../../services/training_plan_sync_service.dart';

/// 🏋️‍♀️ 训练页 TrainingPage - 基于Figma设计的现代化健身训练界面
/// 
/// 设计规范：
/// - 主色调：#6366F1
/// - 背景色：#F9FAFB
/// - 卡片圆角：12px
/// - 页面边距：16px
/// - 组件间距：8/12/16px

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  String _activeTab = 'today';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 头部动画控制器
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 内容动画控制器
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 头部动画
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 内容动画
    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始头部动画
    _headerAnimationController.forward();
    
    // 延迟开始内容动画
    await Future.delayed(const Duration(milliseconds: 200));
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      extendBody: true, // 允许内容延伸到导航栏下方
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域 with precise Figma styling
            _buildHeader(isIOS),
            
            // 内容区域
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isIOS) {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题和操作按钮
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '训练',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: GymatesTheme.lightTextPrimary,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: GymatesTheme.spacing4),
                          Text(
                            '让我们开始今天的训练吧！',
                            style: TextStyle(
                              fontSize: 14,
                              color: GymatesTheme.lightTextSecondary,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // 移除搜索和通知按钮
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 进度统计
                  _buildProgressStats(),
                  
                  const SizedBox(height: 16),
                  
                  // 标签页
                  _buildTabs(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap, {bool hasBadge = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                icon,
                size: 20,
                color: GymatesTheme.lightTextSecondary,
              ),
            ),
            if (hasBadge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('12', '本周训练'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('2.3k', '消耗卡路里'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('85%', '目标完成'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing16),
      decoration: BoxDecoration(
        color: GymatesTheme.lightBackground,
        borderRadius: BorderRadius.circular(GymatesTheme.radius12),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: GymatesTheme.lightTextPrimary,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: GymatesTheme.spacing4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: GymatesTheme.lightTextSecondary,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(GymatesTheme.spacing4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(GymatesTheme.radius8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('today', '今日训练'),
          ),
          Expanded(
            child: _buildTabButton('history', '历史'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, String label) {
    final isSelected = _activeTab == tab;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _activeTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: GymatesTheme.spacing8, 
          horizontal: GymatesTheme.spacing16
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(GymatesTheme.radius8),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? GymatesTheme.primaryColor : GymatesTheme.lightTextSecondary,
            height: 1.2,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        // 计算底部安全区域和导航栏高度
        final safeAreaBottom = MediaQuery.of(context).padding.bottom;
        final navigationBarHeight = 80.0; // 底部导航栏高度
        final extraPadding = 80.0; // 增加更多额外边距确保按钮完全可见
        final bottomPadding = safeAreaBottom + navigationBarHeight + extraPadding;
        
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding), // 动态计算底部边距
              child: Column(
                children: [
                  if (_activeTab == 'today') ...[
                    // 检查是否有训练计划
                    _buildTrainingContent(),
                  ] else ...[
                    // 历史内容
                    const ProgressChart(),
                    const SizedBox(height: 16),
                    const CheckinCalendar(),
                    const SizedBox(height: 16),
                    const TrainingHistoryList(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrainingContent() {
    return FutureBuilder<bool>(
      future: TrainingPlanSyncService.hasTrainingPlan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          );
        }
        
        if (snapshot.hasError) {
          return _buildErrorContent(snapshot.error.toString());
        }
        
        final hasTrainingPlan = snapshot.data ?? false;
        
        if (!hasTrainingPlan) {
          // 没有训练计划，显示模式选择
          return _buildNoPlanContent();
        } else {
          // 有训练计划，显示今日训练内容
          return Column(
            children: [
              // 检查是否有未完成的训练会话
              FutureBuilder<bool>(
                future: TrainingSessionService.hasActiveSession(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return _buildResumeSessionCard();
                  }
                  return const SizedBox.shrink();
                },
              ),
              const TodayPlanCard(),
              const SizedBox(height: 16),
              const AIPlanGenerator(),
              const SizedBox(height: 16),
              _buildEditPlanButton(),
            ],
          );
        }
      },
    );
  }

  /// 构建错误内容
  Widget _buildErrorContent(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          const Text(
            '加载训练数据失败',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                // 重新触发FutureBuilder
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  /// 构建恢复训练会话卡片
  Widget _buildResumeSessionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '有未完成的训练',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '你有一个未完成的训练会话，是否要继续？',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    // 清除未完成的会话
                    await TrainingSessionService.clearSessionState();
                    setState(() {}); // 刷新UI
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('重新开始'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    // 恢复训练会话
                    final state = await TrainingSessionService.getSessionState();
                    if (state != null) {
                      final plan = MockDataProvider.trainingPlans.firstWhere(
                        (p) => p.id == state.planId,
                        orElse: () => MockDataProvider.trainingPlans.first,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrainingSessionPage(trainingPlan: plan),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFF59E0B),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('继续训练'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlanContent() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          // 图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 40,
              color: Color(0xFF6366F1),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 标题
          const Text(
            '开始你的健身之旅',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 描述
          const Text(
            '选择适合你的训练模式，制定专属的训练计划',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // 选择训练模式按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showTrainingModeSelection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '选择训练模式',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // AI推荐按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAIGenerator();
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('AI智能推荐'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                side: const BorderSide(color: Color(0xFF6366F1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTrainingModeSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingModeSelection(
          onModeSelected: (mode) {
            // 导航到训练计划编辑页面
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EditTrainingPlanPage(
                  existingPlan: MockDataProvider.trainingPlans.isNotEmpty
                      ? MockDataProvider.trainingPlans.first
                      : null,
                ),
              ),
            );
          },
          userProfile: MockDataProvider.users.first,
        ),
      ),
    );
  }

  Widget _buildEditPlanButton() {
    return Container(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showTrainingPlanEditor();
        },
        icon: const Icon(Icons.edit, size: 20),
        label: const Text('编辑训练计划', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          foregroundColor: GymatesTheme.primaryColor,
          side: BorderSide(color: GymatesTheme.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showTrainingPlanEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTrainingPlanPage(),
      ),
    );
  }

  /// 开始训练会话
  void _startTrainingSession() {
    if (MockDataProvider.trainingPlans.isNotEmpty) {
      final plan = MockDataProvider.trainingPlans.first;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainingSessionPage(trainingPlan: plan),
        ),
      );
    }
  }

  void _showAIGenerator() {
    // 显示AI生成器对话框
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.psychology,
              color: Color(0xFF6366F1),
            ),
            SizedBox(width: 8),
            Text('AI智能推荐'),
          ],
        ),
        content: const Text(
          'AI将根据你的健身目标、训练经验和身体状况，为你推荐最适合的训练模式。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 模拟AI推荐
              final recommendedMode = MockDataProvider.trainingModes.firstWhere(
                (mode) => mode.isRecommended,
              );
              _showTrainingModeSelection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('开始推荐'),
          ),
        ],
      ),
    );
  }
}

/// 🏋️‍♀️ 训练会话页面 - TrainingSessionPage
/// 
/// 训练进行时的页面，包含进度环、动作列表、完成动画等
class TrainingSessionPage extends StatefulWidget {
  final MockTrainingPlan trainingPlan;

  const TrainingSessionPage({
    super.key,
    required this.trainingPlan,
  });

  @override
  State<TrainingSessionPage> createState() => _TrainingSessionPageState();
}

class _TrainingSessionPageState extends State<TrainingSessionPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _exerciseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _exerciseAnimation;

  List<MockExercise> _exercises = [];
  int _currentExerciseIndex = 0;
  double _sessionProgress = 0.0;
  bool _isSessionActive = false;
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSession();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _exerciseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _exerciseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _exerciseController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _initializeSession() async {
    _exercises = List.from(widget.trainingPlan.exerciseDetails);
    _sessionStartTime = DateTime.now();
    _isSessionActive = true;
    
    // 检查是否有未完成的训练会话
    final savedState = await TrainingSessionService.getSessionState();
    if (savedState != null && !savedState.isExpired) {
      // 恢复之前的训练状态
      _currentExerciseIndex = savedState.currentExerciseIndex;
      _sessionProgress = savedState.progress;
      _sessionStartTime = savedState.sessionStartTime;
      
      // 标记已完成的动作
      for (int i = 0; i < _currentExerciseIndex && i < _exercises.length; i++) {
        _exercises[i] = MockExercise(
          id: _exercises[i].id,
          name: _exercises[i].name,
          description: _exercises[i].description,
          muscleGroup: _exercises[i].muscleGroup,
          difficulty: _exercises[i].difficulty,
          equipment: _exercises[i].equipment,
          imageUrl: _exercises[i].imageUrl,
          videoUrl: _exercises[i].videoUrl,
          instructions: _exercises[i].instructions,
          tips: _exercises[i].tips,
          sets: _exercises[i].sets,
          reps: _exercises[i].reps,
          weight: _exercises[i].weight,
          restTime: _exercises[i].restTime,
          isCompleted: true,
          completedAt: DateTime.now(),
          calories: _exercises[i].calories,
        );
      }
      
      print('🔄 恢复训练会话: 进度 ${(_sessionProgress * 100).toInt()}%, 当前动作 $_currentExerciseIndex');
    } else {
      // 清除过期的会话状态
      if (savedState != null) {
        await TrainingSessionService.clearSessionState();
      }
    }
    
    _progressController.forward();
    _exerciseController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              size: 24,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.trainingPlan.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${_exercises.length}个动作 • ${widget.trainingPlan.duration}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          _buildProgressRing(),
        ],
      ),
    );
  }

  Widget _buildProgressRing() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              // 背景圆环
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 4,
                  ),
                ),
              ),
              // 进度圆环
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: _sessionProgress,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6366F1),
                  ),
                ),
              ),
              // 进度文字
              Center(
                child: Text(
                  '${(_sessionProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentExercise(),
          const SizedBox(height: 24),
          _buildExerciseList(),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise() {
    if (_currentExerciseIndex >= _exercises.length) {
      return _buildSessionComplete();
    }

    final exercise = _exercises[_currentExerciseIndex];
    
    return AnimatedBuilder(
      animation: _exerciseAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _exerciseAnimation.value)),
          child: Opacity(
            opacity: _exerciseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
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
                              '当前动作',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${_currentExerciseIndex + 1}/${_exercises.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildExerciseDetails(exercise),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExerciseDetails(MockExercise exercise) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildDetailItem('${exercise.sets}组', Icons.repeat),
        _buildDetailItem('${exercise.reps}次', Icons.fitness_center),
        _buildDetailItem('${exercise.weight}kg', Icons.scale),
        _buildDetailItem('${exercise.restTime}秒', Icons.timer),
      ],
    );
  }

  Widget _buildDetailItem(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练动作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        ..._exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          final isCompleted = index < _currentExerciseIndex;
          final isCurrent = index == _currentExerciseIndex;
          
          return _buildExerciseItem(exercise, index, isCompleted, isCurrent);
        }).toList(),
      ],
    );
  }

  Widget _buildExerciseItem(MockExercise exercise, int index, bool isCompleted, bool isCurrent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent 
              ? const Color(0xFF6366F1)
              : isCompleted
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE5E7EB),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 状态图标
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF10B981)
                  : isCurrent
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted 
                  ? Icons.check
                  : isCurrent
                      ? Icons.play_arrow
                      : Icons.fitness_center,
              color: isCompleted || isCurrent 
                  ? Colors.white
                  : const Color(0xFF6B7280),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          // 动作信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted 
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1F2937),
                    decoration: isCompleted 
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.sets}组 × ${exercise.reps}次 × ${exercise.weight}kg',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // 操作按钮
          if (isCurrent)
            ElevatedButton(
              onPressed: () => _completeExercise(exercise),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('完成'),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionComplete() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            '训练完成！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '恭喜你完成了今天的训练计划',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatItem('${_exercises.length}', '动作'),
              const SizedBox(width: 24),
              _buildStatItem('${widget.trainingPlan.calories}', '卡路里'),
              const SizedBox(width: 24),
              _buildStatItem('${_getSessionDuration()}', '分钟'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _pauseTraining,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('暂停训练'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentExerciseIndex >= _exercises.length 
                  ? _shareSession
                  : _skipExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentExerciseIndex >= _exercises.length 
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentExerciseIndex >= _exercises.length 
                    ? '分享成果'
                    : '跳过动作',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeExercise(MockExercise exercise) async {
    HapticFeedback.lightImpact();
    
    setState(() {
      _currentExerciseIndex++;
      _sessionProgress = _currentExerciseIndex / _exercises.length;
    });

    // 保存训练状态
    await TrainingSessionService.saveSessionState(
      planId: widget.trainingPlan.id,
      currentExerciseIndex: _currentExerciseIndex,
      progress: _sessionProgress,
      completedExercises: _exercises.take(_currentExerciseIndex).map((e) => e.id).toList(),
      sessionStartTime: _sessionStartTime!,
      isPaused: false,
    );

    // 播放完成动画
    _exerciseController.reset();
    _exerciseController.forward();

    // 显示完成提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${exercise.name} 完成！'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _skipExercise() async {
    HapticFeedback.lightImpact();
    
    setState(() {
      _currentExerciseIndex++;
      _sessionProgress = _currentExerciseIndex / _exercises.length;
    });

    // 保存训练状态
    await TrainingSessionService.saveSessionState(
      planId: widget.trainingPlan.id,
      currentExerciseIndex: _currentExerciseIndex,
      progress: _sessionProgress,
      completedExercises: _exercises.take(_currentExerciseIndex).map((e) => e.id).toList(),
      sessionStartTime: _sessionStartTime!,
      isPaused: false,
    );

    _exerciseController.reset();
    _exerciseController.forward();
  }

  void _pauseTraining() async {
    HapticFeedback.lightImpact();
    
    // 保存暂停状态
    await TrainingSessionService.pauseSession(
      planId: widget.trainingPlan.id,
      currentExerciseIndex: _currentExerciseIndex,
      progress: _sessionProgress,
      completedExercises: _exercises.take(_currentExerciseIndex).map((e) => e.id).toList(),
      sessionStartTime: _sessionStartTime!,
    );
    
    Navigator.pop(context);
  }

  void _shareSession() async {
    HapticFeedback.lightImpact();
    
    // 保存训练历史记录
    await TrainingSessionService.saveTrainingHistory(
      planId: widget.trainingPlan.id,
      planTitle: widget.trainingPlan.title,
      totalExercises: _exercises.length,
      completedExercises: _currentExerciseIndex,
      totalCalories: widget.trainingPlan.calories,
      durationMinutes: int.parse(_getSessionDuration()),
      completedAt: DateTime.now(),
    );
    
    // 清除训练会话状态
    await TrainingSessionService.completeSession();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.share,
              color: Color(0xFF6366F1),
            ),
            SizedBox(width: 8),
            Text('分享训练成果'),
          ],
        ),
        content: const Text(
          '恭喜你完成了今天的训练！是否要分享到社区？',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('稍后分享'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              // 这里可以添加分享到社区的逻辑
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('立即分享'),
          ),
        ],
      ),
    );
  }

  String _getSessionDuration() {
    if (_sessionStartTime == null) return '0';
    final duration = DateTime.now().difference(_sessionStartTime!);
    return duration.inMinutes.toString();
  }
}