import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/gymates_theme.dart';
import '../models/record.dart';
import '../controllers/history_controller.dart';

/// 🏋️‍♀️ 历史详情页 - HistoryDetailPage
/// 
/// 功能包括：
/// 1. 接收参数：TrainingRecord record
/// 2. 展示内容：日期、时长、消耗、训练部位
/// 3. 动作完成情况表格（动作名 / 组数 / 次数 / 重量）
/// 4. AI总结建议（"你上次深蹲节奏偏快，建议下次放慢节奏"）
/// 5. 可点击"重新生成报告" → 调用AI接口重新生成总结
/// 6. 导出按钮 → 生成训练报告PDF或图片
/// 7. 分享按钮 → 一键分享到社区模块

class HistoryDetailPage extends StatefulWidget {
  final WorkoutRecord record;
  final Function(WorkoutRecord)? onRecordUpdate;

  const HistoryDetailPage({
    super.key,
    required this.record,
    this.onRecordUpdate,
  });

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _chartAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _chartAnimation;

  late HistoryController _controller;
  bool _isGeneratingReport = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _controller = HistoryController();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    _headerAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _contentAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    _chartAnimationController.dispose();
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
                        Text(
                          widget.record.planTitle,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          _formatDate(widget.record.date),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 分享按钮
                  GestureDetector(
                    onTap: _shareRecord,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.share,
                        size: 20,
                        color: Color(0xFF6B7280),
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
                  // 训练概览
                  _buildTrainingOverview(),
                  
                  const SizedBox(height: 24),
                  
                  // 训练统计图表
                  _buildTrainingStats(),
                  
                  const SizedBox(height: 24),
                  
                  // 动作完成情况
                  _buildExerciseDetails(),
                  
                  const SizedBox(height: 24),
                  
                  // AI总结
                  _buildAISummary(),
                  
                  const SizedBox(height: 100), // 底部安全区域
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrainingOverview() {
    return Container(
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
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '训练概览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  '时长',
                  '${widget.record.durationMinutes}分钟',
                  Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  '消耗',
                  '${widget.record.calories}卡',
                  Icons.local_fire_department,
                ),
              ),
              Expanded(
                child: _buildOverviewItem(
                  '完成度',
                  '${((widget.record.completedExercises / widget.record.totalExercises) * 100).toInt()}%',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
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
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  _buildProgressChart('动作完成', widget.record.completedExercises, widget.record.totalExercises),
                  const SizedBox(height: 16),
                  _buildProgressChart('训练强度', 85, 100),
                  const SizedBox(height: 16),
                  _buildProgressChart('卡路里目标', widget.record.calories, 400),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(String label, int current, int total) {
    final progress = total > 0 ? current / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
            Text(
              '$current / $total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress * _chartAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseDetails() {
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
          _buildExerciseTable(),
        ],
      ),
    );
  }

  Widget _buildExerciseTable() {
    // 模拟动作数据
    final exercises = [
      ExerciseDetail(name: '俯卧撑', sets: 3, reps: 15, weight: 0, isCompleted: true),
      ExerciseDetail(name: '深蹲', sets: 4, reps: 20, weight: 0, isCompleted: true),
      ExerciseDetail(name: '平板支撑', sets: 3, reps: 30, weight: 0, isCompleted: true),
      ExerciseDetail(name: '引体向上', sets: 3, reps: 8, weight: 0, isCompleted: false),
    ];

    return Column(
      children: [
        // 表头
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  '动作名称',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '组数',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '次数',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '状态',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 表格内容
        ...exercises.map((exercise) => _buildExerciseRow(exercise)),
      ],
    );
  }

  Widget _buildExerciseRow(ExerciseDetail exercise) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              exercise.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: exercise.isCompleted 
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${exercise.sets}',
              style: TextStyle(
                fontSize: 14,
                color: exercise.isCompleted 
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${exercise.reps}',
              style: TextStyle(
                fontSize: 14,
                color: exercise.isCompleted 
                    ? const Color(0xFF1F2937)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: exercise.isCompleted 
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                exercise.isCompleted ? '完成' : '未完成',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: exercise.isCompleted 
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISummary() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    'AI训练总结',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _regenerateAISummary,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isGeneratingReport)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                          ),
                        )
                      else
                        const Icon(
                          Icons.refresh,
                          size: 14,
                          color: Color(0xFF6366F1),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        _isGeneratingReport ? '生成中...' : '重新生成',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
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
            child: Text(
              widget.record.aiSummary ?? '你上次深蹲节奏偏快，建议下次放慢节奏。俯卧撑动作很标准，继续保持！',
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
            child: OutlinedButton.icon(
              onPressed: _exportReport,
              icon: _isExporting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isExporting ? '导出中...' : '导出报告'),
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
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _shareToCommunity,
              icon: const Icon(Icons.share),
              label: const Text('分享到社区'),
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
    );
  }

  // 方法实现
  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  void _regenerateAISummary() async {
    if (_isGeneratingReport) return;
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _isGeneratingReport = true;
    });
    
    // 模拟AI生成过程
    await Future.delayed(const Duration(seconds: 2));
    
    // 更新记录
    final updatedRecord = WorkoutRecord(
      id: widget.record.id,
      date: widget.record.date,
      planId: widget.record.planId,
      planTitle: widget.record.planTitle,
      durationMinutes: widget.record.durationMinutes,
      calories: widget.record.calories,
      totalExercises: widget.record.totalExercises,
      completedExercises: widget.record.completedExercises,
      aiSummary: '基于你的训练数据，AI重新分析：你的核心力量有明显提升，建议增加重量训练。有氧运动表现优秀，继续保持！',
    );
    
    widget.onRecordUpdate?.call(updatedRecord);
    
    setState(() {
      _isGeneratingReport = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI总结已更新'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportReport() async {
    if (_isExporting) return;
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _isExporting = true;
    });
    
    try {
      // 模拟导出过程
      await Future.delayed(const Duration(seconds: 2));
      
      // 这里可以实现真实的PDF或图片导出逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('训练报告已导出到相册'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('导出失败：$e'),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _shareRecord() {
    HapticFeedback.lightImpact();
    
    Share.share(
      '我在Gymates完成了${widget.record.planTitle}训练！\n'
      '训练时长：${widget.record.durationMinutes}分钟\n'
      '消耗卡路里：${widget.record.calories}卡\n'
      '完成度：${((widget.record.completedExercises / widget.record.totalExercises) * 100).toInt()}%\n\n'
      '一起来健身吧！💪',
    );
  }

  void _shareToCommunity() {
    HapticFeedback.lightImpact();
    
    // 这里可以导航到社区发布页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('跳转到社区发布页面'),
        backgroundColor: Color(0xFF6366F1),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class ExerciseDetail {
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final bool isCompleted;

  ExerciseDetail({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.isCompleted,
  });
}
