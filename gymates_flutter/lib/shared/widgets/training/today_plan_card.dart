import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../pages/training/training_plan_editor.dart';
import '../../../pages/training/training_detail_page.dart';
import '../../../services/training_plan_sync_service.dart';
import '../../../shared/models/mock_data.dart';

/// 🏋️‍♀️ 今日训练计划卡片 - TodayPlanCard
/// 
/// 基于Figma设计的今日训练计划展示组件
/// 直接使用API数据，不依赖Mock数据
class TodayPlanCard extends StatefulWidget {
  const TodayPlanCard({super.key});

  @override
  State<TodayPlanCard> createState() => _TodayPlanCardState();
}

class _TodayPlanCardState extends State<TodayPlanCard>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late AnimationController _progressController;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 0.7, // 70% 进度
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    _cardAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: TrainingPlanSyncService.getTodayTraining(),
      builder: (context, snapshot) {
        print('🏋️‍♀️ TodayPlanCard - 数据状态: ${snapshot.connectionState}');
        print('🏋️‍♀️ TodayPlanCard - 数据: ${snapshot.data}');
        print('🏋️‍♀️ TodayPlanCard - 错误: ${snapshot.error}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        
        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }
        
        final todayTraining = snapshot.data;
        if (todayTraining == null) {
          return _buildEmptyCard();
        }
        
        return AnimatedBuilder(
          animation: _cardAnimationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _cardSlideAnimation.value.dy),
              child: Opacity(
                opacity: _cardFadeAnimation.value,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 训练计划图片
                      _buildPlanImage(todayTraining),
                      
                      // 训练计划信息
                      _buildPlanInfo(todayTraining),
                      
                      // 进度条
                      _buildProgressSection(),
                      
                      // 开始训练按钮
                      _buildStartButton(todayTraining),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlanImage(Map<String, dynamic> training) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        image: DecorationImage(
          image: NetworkImage(training['image'] ?? 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  training['day_name']?.toString() ?? '今日训练',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (training['isRestDay'] == true) ? '休息日' : '${training['totalExercises'] ?? 0} 个动作',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanInfo(Map<String, dynamic> training) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (training['isRestDay'] == true) ? '休息日' : '训练计划',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (training['isRestDay'] == true) 
                          ? '今天好好休息，明天继续努力！'
                          : '预计 ${training['totalDuration'] ?? 0} 分钟',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (training['isRestDay'] == true) ? '休息' : '${training['totalExercises'] ?? 0} 动作',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildExercisePreview(training),
        ],
      ),
    );
  }

  /// 今日动作预览（最多展示6个）
  Widget _buildExercisePreview(Map<String, dynamic> training) {
    final List<Map<String, dynamic>> preview = [];
    final parts = training['parts'] as List?;
    if (parts != null) {
      for (final part in parts) {
        if (part is Map<String, dynamic>) {
          final exercises = part['exercises'] as List?;
          if (exercises != null) {
            for (final e in exercises) {
              if (e is Map<String, dynamic>) {
                preview.add(e);
                if (preview.length >= 6) break;
              }
            }
          }
        }
        if (preview.length >= 6) break;
      }
    }

    if (preview.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: preview.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final e = preview[index];
          final name = (e['name'] ?? '动作').toString();
          final muscle = (e['muscle_group'] ?? '').toString();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              muscle.isEmpty ? name : '$name · $muscle',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '今日进度',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Text(
                    '${(_progressAnimation.value * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                minHeight: 8,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(Map<String, dynamic> training) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            _startTraining(training);
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                (training['isRestDay'] == true) ? Icons.bed : Icons.play_arrow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                (training['isRestDay'] == true) ? '休息日' : '开始训练',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建加载状态卡片
  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          const Text(
            '正在加载训练计划...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建错误状态卡片
  Widget _buildErrorCard(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Color(0xFFEF4444),
          ),
          const SizedBox(height: 16),
          const Text(
            '加载训练计划失败',
            style: TextStyle(
              fontSize: 18,
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
          const SizedBox(height: 16),
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

  /// 构建空状态卡片
  Widget _buildEmptyCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.fitness_center,
            size: 48,
            color: Color(0xFF6366F1),
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有训练计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '创建你的第一个训练计划，开始健身之旅！',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              print('🏋️‍♀️ 创建训练计划按钮被点击');
              HapticFeedback.lightImpact();
              // 导航到训练计划编辑页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTrainingPlanPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('创建训练计划'),
          ),
        ],
      ),
    );
  }

  /// 开始训练
  void _startTraining(Map<String, dynamic> training) {
    print('🏋️‍♀️ 开始训练 - 训练数据: $training');
    
    if (training['isRestDay'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('今天是休息日，好好放松一下吧！'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } else {
      // 将API数据转换为MockTrainingPlan格式
      final mockPlan = _convertToMockTrainingPlan(training);
      print('🏋️‍♀️ 转换后的训练计划: $mockPlan');
      
      // 直接路由到训练详情（使用 rootNavigator 避免嵌套导航栈拦截）
      Navigator.of(context, rootNavigator: true)
          .push(
        MaterialPageRoute(
          builder: (_) => TrainingDetailPage(trainingPlan: mockPlan),
        ),
      )
          .then((result) {
        print('🏋️‍♀️ 导航结果: $result');
      }).catchError((error) {
        print('❌ 导航错误: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导航失败: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  /// 将API训练数据转换为MockTrainingPlan格式
  MockTrainingPlan _convertToMockTrainingPlan(Map<String, dynamic> training) {
    // 提取动作列表（兼容多种字段命名）
    List<String> exerciseNames = [];
    List<MockExercise> exerciseDetails = [];

    List pickExercises(dynamic container) {
      if (container is Map<String, dynamic>) {
        // 常见字段：exercises / motions / items / exercise_list
        final candidates = [
          container['exercises'],
          container['motions'],
          container['items'],
          container['exercise_list'],
        ];
        for (final c in candidates) {
          if (c is List && c.isNotEmpty) return c;
        }
      }
      return const [];
    }

    final parts = (training['parts'] as List?) ?? const [];
    for (final part in parts) {
      final list = pickExercises(part);
      for (final exercise in list) {
        if (exercise is Map<String, dynamic>) {
          final name = (exercise['name'] ?? exercise['title'] ?? '未知动作').toString();
          exerciseNames.add(name);
          exerciseDetails.add(
            MockExercise(
              id: exercise['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
              description: (exercise['description'] ?? exercise['desc'] ?? '').toString(),
              muscleGroup: (exercise['muscle_group'] ?? exercise['muscle'] ?? '').toString(),
              difficulty: (exercise['difficulty'] ?? 'intermediate').toString(),
              equipment: (exercise['equipment'] ?? '').toString(),
              imageUrl: (exercise['image_url'] ?? '').toString(),
              videoUrl: (exercise['video_url'] ?? '').toString(),
              instructions: (exercise['instructions'] is List)
                  ? (exercise['instructions'] as List).map((e) => e.toString()).toList()
                  : (exercise['instructions'] is String)
                      ? <String>[exercise['instructions'] as String]
                      : const <String>[],
              tips: (exercise['notes'] is List)
                  ? (exercise['notes'] as List).map((e) => e.toString()).toList()
                  : (exercise['notes'] is String)
                      ? <String>[exercise['notes'] as String]
                      : const <String>[],
              sets: (exercise['sets'] ?? 3) as int,
              reps: (exercise['reps'] ?? 10) as int,
              weight: (exercise['weight'] is num) ? (exercise['weight'] as num).toDouble() : 0.0,
              restTime: (exercise['rest_seconds'] ?? exercise['rest_time'] ?? 60) as int,
              calories: (exercise['calories'] ?? 50) as int,
            ),
          );
        }
      }
    }

    // 若API未返回动作明细，但告知数量，则制造占位名称，避免详情页空白
    if (exerciseNames.isEmpty) {
      final count = (training['totalExercises'] ?? 0) as int;
      for (int i = 0; i < (count == 0 ? 3 : count.clamp(1, 6)); i++) {
        exerciseNames.add('动作 ${i + 1}');
      }
    }

    return MockTrainingPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: (training['planName'] ?? training['name'] ?? training['day_name'] ?? '今日训练').toString(),
      description: training['planDescription'] ?? '个性化训练计划',
      duration: '${training['totalDuration'] ?? 30}分钟',
      difficulty: 'intermediate',
      calories: training['totalCalories'] ?? 300,
      exercises: exerciseNames,
      image: training['image'] ?? 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
      isCompleted: false,
      progress: 0.0,
      trainingMode: '五分化',
      targetMuscles: ['胸部', '背部', '腿部', '肩部', '手臂'],
      exerciseDetails: exerciseDetails,
      suitableFor: '中级',
      weeklyFrequency: 5,
      createdAt: DateTime.now(),
      lastCompleted: null,
    );
  }
}