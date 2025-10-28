import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/gymates_theme.dart';
import '../models/record.dart';
import '../models/session_result.dart';
import '../controllers/history_controller.dart';

/// 🏋️‍♀️ AI总结页 - TrainingSummaryPage
/// 
/// 功能包括：
/// 1. 展示本次训练统计：总组数、总时长、平均强度
/// 2. 每个动作完成情况（环形图/条形图）
/// 3. 结尾处展示 AI 评论语句（正向激励）
/// 4. 按钮：「打卡」→ 跳转打卡页并生成记录
/// 5. 按钮：「查看报告」→ 打开历史详情页
/// 6. 按钮：「分享」→ 打开分享页

class TrainingSummaryPage extends StatefulWidget {
  final WorkoutRecord record;
  final List<SetRecord> completedSets;
  final Function()? onCheckIn;
  final Function()? onViewReport;
  final Function()? onShare;

  const TrainingSummaryPage({
    super.key,
    required this.record,
    required this.completedSets,
    this.onCheckIn,
    this.onViewReport,
    this.onShare,
  });

  @override
  State<TrainingSummaryPage> createState() => _TrainingSummaryPageState();
}

class _TrainingSummaryPageState extends State<TrainingSummaryPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _chartAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _buttonAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _buttonAnimation;

  late HistoryController _historyController;
  String _aiComment = '';
  bool _isGeneratingComment = false;

  @override
  void initState() {
    super.initState();
    _historyController = HistoryController();
    _initializeAnimations();
    _startAnimations();
    _generateAIComment();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    _headerAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _chartAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _contentAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _buttonAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _chartAnimationController.dispose();
    _contentAnimationController.dispose();
    _buttonAnimationController.dispose();
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
                        const Text(
                          '训练总结',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '恭喜完成训练！',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 庆祝图标
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.celebration,
                      size: 20,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 训练完成庆祝
                  _buildCelebrationCard(),
                  
                  const SizedBox(height: 24),
                  
                  // 训练统计
                  _buildTrainingStats(),
                  
                  const SizedBox(height: 24),
                  
                  // 动作完成情况图表
                  _buildExerciseChart(),
                  
                  const SizedBox(height: 24),
                  
                  // AI评论
                  _buildAIComment(),
                  
                  const SizedBox(height: 100), // 底部安全区域
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebrationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
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
            '你完成了${widget.record.planTitle}训练',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCelebrationStat('${widget.record.durationMinutes}', '分钟'),
              _buildCelebrationStat('${widget.record.calories}', '卡路里'),
              _buildCelebrationStat('${widget.completedSets.length}', '组数'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationStat(String value, String label) {
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
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainingStats() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            '训练统计',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '总时长',
                  '${widget.record.durationMinutes}分钟',
                  Icons.access_time,
                  const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '消耗卡路里',
                  '${widget.record.calories}卡',
                  Icons.local_fire_department,
                  const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '完成动作',
                  '${widget.record.completedExercises}/${widget.record.totalExercises}',
                  Icons.check_circle,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '完成度',
                  '${((widget.record.completedExercises / widget.record.totalExercises) * 100).toInt()}%',
                  Icons.trending_up,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            '动作完成情况',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, child) {
                return PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: _buildPieChartSections(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildChartLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final completedPercentage = (widget.record.completedExercises / widget.record.totalExercises) * 100;
    final remainingPercentage = 100 - completedPercentage;
    
    return [
      PieChartSectionData(
        color: const Color(0xFF10B981),
        value: completedPercentage * _chartAnimation.value,
        title: '${completedPercentage.toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xFFE5E7EB),
        value: remainingPercentage * _chartAnimation.value,
        title: '${remainingPercentage.toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280),
        ),
      ),
    ];
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('已完成', const Color(0xFF10B981)),
        const SizedBox(width: 24),
        _buildLegendItem('未完成', const Color(0xFFE5E7EB)),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildAIComment() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Row(
            children: [
              Icon(
                Icons.psychology,
                color: Color(0xFF6366F1),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'AI 训练点评',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: _isGeneratingComment
                ? const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'AI正在分析你的训练数据...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  )
                : Text(
                    _aiComment.isNotEmpty ? _aiComment : 'AI分析中...',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return AnimatedBuilder(
      animation: _buttonAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _buttonAnimation.value)),
          child: Opacity(
            opacity: _buttonAnimation.value,
            child: Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 主要操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onCheckIn,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('打卡'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onViewReport,
                          icon: const Icon(Icons.assessment),
                          label: const Text('查看报告'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 分享按钮
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: widget.onShare,
                      icon: const Icon(Icons.share),
                      label: const Text('分享训练成果'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6366F1),
                        side: const BorderSide(color: Color(0xFF6366F1)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 方法实现
  Future<void> _generateAIComment() async {
    setState(() {
      _isGeneratingComment = true;
    });

    try {
      // 模拟AI分析过程
      await Future.delayed(const Duration(seconds: 2));
      
      // 基于训练数据生成AI评论
      final completionRate = widget.record.completedExercises / widget.record.totalExercises;
      final avgCaloriesPerMinute = widget.record.calories / widget.record.durationMinutes;
      
      String comment = '';
      
      if (completionRate >= 0.9) {
        comment += '🎉 太棒了！你的训练完成度达到了${(completionRate * 100).toInt()}%，表现非常优秀！';
      } else if (completionRate >= 0.7) {
        comment += '👍 训练完成度${(completionRate * 100).toInt()}%，表现良好！继续保持！';
      } else {
        comment += '💪 训练完成度${(completionRate * 100).toInt()}%，还有提升空间，加油！';
      }
      
      if (avgCaloriesPerMinute > 8) {
        comment += '\n\n🔥 卡路里消耗效率很高，训练强度适中，心肺功能得到了很好的锻炼。';
      } else if (avgCaloriesPerMinute > 5) {
        comment += '\n\n⚡ 卡路里消耗正常，建议下次可以适当增加训练强度。';
      } else {
        comment += '\n\n💡 建议增加训练强度以提高卡路里消耗效率。';
      }
      
      comment += '\n\n✨ 坚持就是胜利！继续保持这种训练节奏，你的身体会越来越强壮！';
      
      setState(() {
        _aiComment = comment;
        _isGeneratingComment = false;
      });
    } catch (e) {
      setState(() {
        _aiComment = 'AI分析暂时不可用，但你的训练表现很棒！继续保持！';
        _isGeneratingComment = false;
      });
    }
  }
}

// 数据模型
