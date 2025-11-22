import 'package:flutter/material.dart';
import '../../../core/3d_components/index.dart';
import '../../../services/training_service.dart';
import '../secondary/exercise_library_page.dart';
import '../secondary/training_plan_detail_page.dart';
import '../secondary/workout_3d_running_page.dart';
import '../../../modules/ai/ai_training_page.dart';
import '../models/workout.dart';

/// 📅 Apple Fitness+ Style Today Training Page
/// 
/// Design Features:
/// - 3D training plan cards (CoverFlow style)
/// - 3D stats cards (frosted glass)
/// - 3D start button (pulse animation)
/// - 3D mode selector (sliding cards)
/// - 3D quick action buttons
/// - Smooth animations and transitions

class Today3DTrainingPage extends StatefulWidget {
  const Today3DTrainingPage({super.key});

  @override
  State<Today3DTrainingPage> createState() => _Today3DTrainingPageState();
}

class _Today3DTrainingPageState extends State<Today3DTrainingPage> 
    with SingleTickerProviderStateMixin {
  final TrainingService _trainingService = TrainingService();
  String? _todayPlanId;
  final List<TodayExercise> _todayExercises = [];
  bool _isAIMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _workoutData; // 保存从API获取的训练数据
  late AnimationController _modeAnimationController;

  @override
  void initState() {
    super.initState();
    _modeAnimationController = AnimationController(
      duration: AppleFitnessTheme.durationNormal,
      vsync: this,
    );
    _loadTodayPlan();
  }

  @override
  void dispose() {
    _modeAnimationController.dispose();
    super.dispose();
  }

  /// 加载今日训练计划（从后端API）
  Future<void> _loadTodayPlan() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _trainingService.getTodayWorkout();
      
      if (!mounted) return;
      
      if (response['success'] == true && response['data'] != null) {
        final workoutData = response['data'] as Map<String, dynamic>;
        final planId = workoutData['plan_id']?.toString() ?? workoutData['id']?.toString();
        final exercises = workoutData['exercises'] as List<dynamic>? ?? [];
        
        setState(() {
          _workoutData = workoutData; // 保存训练数据
          _todayPlanId = planId;
          _todayExercises.clear();
          _todayExercises.addAll(exercises.map((e) {
            final exerciseData = e as Map<String, dynamic>;
            return TodayExercise(
              name: exerciseData['name'] ?? exerciseData['exercise_name'] ?? '未知动作',
              sets: exerciseData['sets'] ?? exerciseData['target_sets'] ?? 3,
              reps: exerciseData['reps'] ?? exerciseData['target_reps'] ?? 10,
              muscleGroup: exerciseData['muscle_group'] ?? exerciseData['target_muscle'] ?? 'unknown',
            );
          }).toList());
          _isLoading = false;
        });
      } else {
        // 今日暂无训练计划
        setState(() {
          _todayPlanId = null;
          _todayExercises.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading today plan: $e');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = '加载今日训练失败: $e';
        _todayPlanId = null;
        _todayExercises.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppleFitnessTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            _buildHeader(),
            
            // Mode selector
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                child: _buildModeSelector(),
              ),
            ),
            
            // Today's plan or empty state
            if (_todayPlanId != null)
              ..._buildPlanContent()
            else
              _buildEmptyState(),
            
            // Quick actions
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                child: _buildQuickActions(),
              ),
            ),
            
            // Stats section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                child: _buildStatsSection(),
              ),
            ),
            
            // Recommended exercises
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                child: _buildRecommendedSection(),
              ),
            ),
            
            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: AppleFitnessTheme.spacingXXL),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: AppleFitnessTheme.headlineMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingS),
            Text(
              '今日训练',
              style: AppleFitnessTheme.displayMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '早上好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  Widget _buildModeSelector() {
    return Card3D(
      useFrostedGlass: true,
      padding: EdgeInsets.all(AppleFitnessTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: _buildModeOption(
              icon: Icons.fitness_center,
              label: '普通训练',
              isSelected: !_isAIMode,
              onTap: () {
                setState(() => _isAIMode = false);
                _modeAnimationController.reverse();
              },
            ),
          ),
          SizedBox(width: AppleFitnessTheme.spacingM),
          Expanded(
            child: _buildModeOption(
              icon: Icons.psychology,
              label: 'AI 教练',
              isSelected: _isAIMode,
              onTap: () {
                setState(() => _isAIMode = true);
                _modeAnimationController.forward();
                _navigateToAITraining();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppleFitnessTheme.durationNormal,
        curve: AppleFitnessTheme.easeInOutCubic,
        padding: EdgeInsets.all(AppleFitnessTheme.spacingM),
        decoration: BoxDecoration(
          gradient: isSelected ? AppleFitnessTheme.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: AppleFitnessTheme.radiusMedium,
          boxShadow: isSelected 
              ? AppleFitnessTheme.softShadow(elevation: 8)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected 
                  ? Colors.white 
                  : AppleFitnessTheme.textSecondary,
            ),
            SizedBox(height: AppleFitnessTheme.spacingS),
            Text(
              label,
              style: AppleFitnessTheme.labelMedium.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : AppleFitnessTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlanContent() {
    return [
      // Plan overview card
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
          child: FadeIn3D(
            child: _buildPlanCard(),
          ),
        ),
      ),
      
      SliverToBoxAdapter(
        child: SizedBox(height: AppleFitnessTheme.spacingXL),
      ),
      
      // Exercise list
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '训练动作',
                style: AppleFitnessTheme.titleLarge,
              ),
              SizedBox(height: AppleFitnessTheme.spacingM),
            ],
          ),
        ),
      ),
      
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final exercise = _todayExercises[index];
            return Padding(
              padding: EdgeInsets.only(
                left: AppleFitnessTheme.spacingL,
                right: AppleFitnessTheme.spacingL,
                bottom: AppleFitnessTheme.spacingM,
              ),
              child: StaggeredAnimation3D(
                index: index,
                child: _buildExerciseCard(exercise, index),
              ),
            );
          },
          childCount: _todayExercises.length,
        ),
      ),
    ];
  }

  Widget _buildPlanCard() {
    final totalSets = _todayExercises.fold<int>(
      0, 
      (sum, e) => sum + e.sets,
    );
    final estimatedTime = totalSets * 3; // 3 minutes per set

    return Card3D(
      gradient: AppleFitnessTheme.workoutGradients['strength'],
      onTap: () => _navigateToPlanDetail(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今日计划',
                    style: AppleFitnessTheme.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingS),
                  Text(
                    '胸部训练',
                    style: AppleFitnessTheme.headlineMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingL),
          
          // Stats row
          Row(
            children: [
              _buildStatChip(
                icon: Icons.fitness_center,
                label: '${_todayExercises.length} 个动作',
              ),
              SizedBox(width: AppleFitnessTheme.spacingM),
              _buildStatChip(
                icon: Icons.repeat,
                label: '$totalSets 组',
              ),
              SizedBox(width: AppleFitnessTheme.spacingM),
              _buildStatChip(
                icon: Icons.timer_outlined,
                label: '$estimatedTime 分钟',
              ),
            ],
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingL),
          
          // Start button
          Button3D(
            text: '开始训练',
            icon: Icons.play_arrow,
            backgroundColor: Colors.white,
            foregroundColor: AppleFitnessTheme.primaryPink,
            enableGlow: true,
            enablePulse: true,
            onPressed: _startWorkout,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: AppleFitnessTheme.radiusSmall,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppleFitnessTheme.bodySmall.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(TodayExercise exercise, int index) {
    return Card3D(
      onTap: () => _navigateToExerciseDetail(exercise),
      child: Row(
        children: [
          // Exercise number
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppleFitnessTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppleFitnessTheme.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          SizedBox(width: AppleFitnessTheme.spacingM),
          
          // Exercise info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: AppleFitnessTheme.titleMedium,
                ),
                SizedBox(height: AppleFitnessTheme.spacingXS),
                Text(
                  '${exercise.sets} 组 × ${exercise.reps} 次',
                  style: AppleFitnessTheme.bodySmall.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Arrow
          Icon(
            Icons.chevron_right,
            color: AppleFitnessTheme.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        child: FadeIn3D(
          child: Card3D(
            useFrostedGlass: true,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppleFitnessTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: AppleFitnessTheme.spacingL),
                
                Text(
                  '还没有安排今日训练',
                  style: AppleFitnessTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppleFitnessTheme.spacingS),
                
                Text(
                  '选择动作或让AI为你推荐',
                  style: AppleFitnessTheme.bodyMedium.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: AppleFitnessTheme.spacingXL),
                
                Row(
                  children: [
                    Expanded(
                      child: Button3D.primary(
                        text: '选择动作',
                        icon: Icons.search,
                        onPressed: _navigateToExerciseLibrary,
                      ),
                    ),
                    SizedBox(width: AppleFitnessTheme.spacingM),
                    Expanded(
                      child: Button3D.secondary(
                        text: 'AI 推荐',
                        icon: Icons.psychology,
                        onPressed: _navigateToAITraining,
                      ),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快速操作',
          style: AppleFitnessTheme.titleLarge,
        ),
        SizedBox(height: AppleFitnessTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.library_books,
                label: '动作库',
                gradient: AppleFitnessTheme.primaryGradient,
                onTap: _navigateToExerciseLibrary,
              ),
            ),
            SizedBox(width: AppleFitnessTheme.spacingM),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.edit_calendar,
                label: '编辑计划',
                gradient: AppleFitnessTheme.purpleGradient,
                onTap: _navigateToEditPlan,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Card3D(
      gradient: gradient,
      onTap: onTap,
      enablePress: true,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: AppleFitnessTheme.spacingS),
          Text(
            label,
            style: AppleFitnessTheme.labelLarge.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '本周统计',
          style: AppleFitnessTheme.titleLarge,
        ),
        SizedBox(height: AppleFitnessTheme.spacingM),
        Card3D(
          useFrostedGlass: true,
          child: Column(
            children: [
              _buildStatRow(
                label: '训练天数',
                value: '4',
                unit: '天',
                progress: 0.57,
                color: AppleFitnessTheme.primaryBlue,
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              _buildStatRow(
                label: '总时长',
                value: '240',
                unit: '分钟',
                progress: 0.75,
                color: AppleFitnessTheme.primaryGreen,
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              _buildStatRow(
                label: '完成率',
                value: '85',
                unit: '%',
                progress: 0.85,
                color: AppleFitnessTheme.primaryOrange,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required String unit,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppleFitnessTheme.bodyMedium,
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: AppleFitnessTheme.titleLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: AppleFitnessTheme.bodySmall.copyWith(
                      color: AppleFitnessTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppleFitnessTheme.spacingS),
        LinearProgress3D(
          value: progress,
          height: 6,
          progressColor: color,
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    final recommendations = [
      ('深蹲', Icons.fitness_center, AppleFitnessTheme.greenGradient),
      ('引体向上', Icons.accessibility_new, AppleFitnessTheme.pinkGradient),
      ('平板支撑', Icons.self_improvement, AppleFitnessTheme.orangeGradient),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐动作',
          style: AppleFitnessTheme.titleLarge,
        ),
        SizedBox(height: AppleFitnessTheme.spacingM),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: AppleFitnessTheme.spacingM,
                ),
                child: SizedBox(
                  width: 150,
                  child: Card3D(
                    gradient: rec.$3,
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(rec.$2, color: Colors.white, size: 32),
                        SizedBox(height: AppleFitnessTheme.spacingS),
                        Text(
                          rec.$1,
                          style: AppleFitnessTheme.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Navigation methods
  Future<void> _startWorkout() async {
    if (_todayExercises.isEmpty || _todayPlanId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择训练计划')),
      );
      return;
    }
    
    try {
      // 调用API开始训练会话
      final planId = int.tryParse(_todayPlanId!);
      final response = await _trainingService.startWorkoutSession(
        planId: planId,
        isAIWorkout: _isAIMode,
      );
      
      if (!mounted) return;
      
      if (response['success'] == true && response['data'] != null) {
        final sessionData = response['data'] as Map<String, dynamic>;
        final sessionId = sessionData['id'] ?? sessionData['session_id'];
        
        final workoutPlan = TodayWorkoutPlan(
          id: _todayPlanId!,
          title: _workoutData?['title'] ?? _workoutData?['plan']?['title'] ?? '今日训练',
          exercises: _todayExercises.map((e) => WorkoutExercise(
            id: e.name.toLowerCase().replaceAll(' ', '_'),
            name: e.name,
            sets: e.sets,
            reps: e.reps,
            restSeconds: 60,
            weight: 0.0,
            muscleGroup: e.muscleGroup,
          )).toList(),
        );
        
        // 跳转到训练执行页面
        context.push3D(Workout3DRunningPage(
          workoutPlan: workoutPlan,
        ));
      } else {
        throw Exception(response['message'] ?? '开始训练失败');
      }
    } catch (e) {
      debugPrint('❌ Error starting workout: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('开始训练失败: $e')),
      );
    }
  }

  void _navigateToExerciseLibrary() {
    context.push3D(const ExerciseLibraryPage());
  }

  void _navigateToAITraining() {
    context.push3D(const AITrainingPage());
  }

  void _navigateToPlanDetail() {
    if (_todayPlanId == null) return;
    context.push3D(TrainingPlanDetailPage(
      planId: _todayPlanId!,
      exercises: _todayExercises,
    ));
  }

  void _navigateToExerciseDetail(TodayExercise exercise) {
    // TODO: Navigate to exercise detail
  }

  void _navigateToEditPlan() {
    // TODO: Navigate to plan editor
  }
}

// Mock data models
class TodayExercise {
  final String name;
  final int sets;
  final int reps;
  final String muscleGroup;
  final int restSeconds;

  TodayExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.muscleGroup,
    this.restSeconds = 60, // 默认休息60秒
  });
}

