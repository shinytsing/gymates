import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';
import '../../../animations/gymates_animations.dart';
import '../../../shared/models/mock_data.dart';

/// 📋 训练历史列表 - TrainingHistoryList
/// 
/// 基于Figma设计的训练历史记录组件
/// 显示历史训练记录，支持查看详情

class TrainingHistoryList extends StatefulWidget {
  const TrainingHistoryList({super.key});

  @override
  State<TrainingHistoryList> createState() => _TrainingHistoryListState();
}

class _TrainingHistoryListState extends State<TrainingHistoryList>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  late AnimationController _itemAnimationController;
  
  late Animation<double> _listFadeAnimation;
  late Animation<double> _itemAnimation;

  final List<MockTrainingPlan> _historyPlans = [
    MockTrainingPlan(
      id: '1',
      title: '全身力量训练',
      description: '胸、背、腿、肩部综合训练',
      duration: '45分钟',
      difficulty: '中级',
      calories: 350,
      exercises: ['卧推', '深蹲', '硬拉', '引体向上'],
      image: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3ZWlnaHQlMjB0cmFpbmluZyUyMGd5bSUyMHdvcmtvdXR8ZW58MXx8fHwxNzU5NTMwOTE4fDA&ixlib=rb-4.1.0&q=80&w=400',
      isCompleted: true,
      progress: 1.0,
    ),
    MockTrainingPlan(
      id: '2',
      title: '瑜伽放松',
      description: '舒缓的瑜伽练习，帮助放松身心',
      duration: '30分钟',
      difficulty: '初级',
      calories: 120,
      exercises: ['下犬式', '猫式', '婴儿式', '冥想'],
      image: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b2dhJTIwd29ya291dCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc1OTUzMDkxOXww&ixlib=rb-4.1.0&q=80&w=400',
      isCompleted: true,
      progress: 1.0,
    ),
    MockTrainingPlan(
      id: '3',
      title: 'HIIT高强度训练',
      description: '高强度间歇训练，快速燃脂',
      duration: '25分钟',
      difficulty: '高级',
      calories: 450,
      exercises: ['波比跳', '登山者', '高抬腿', '开合跳'],
      image: 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxydW5uaW5nJTIwZXhlcmNpc2UlMjBmaXRnZXNzJTIwd29ya291dHxlbnwxfHx8fDE3NTk1MzA5MjB8MA&ixlib=rb-4.1.0&q=80&w=400',
      isCompleted: true,
      progress: 1.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // 列表动画控制器
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 项目动画控制器
    _itemAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 列表淡入动画
    _listFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 项目动画
    _itemAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _itemAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始列表动画
    _listAnimationController.forward();
    
    // 延迟开始项目动画
    await Future.delayed(const Duration(milliseconds: 200));
    _itemAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _itemAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _listFadeAnimation.value,
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
                // 标题
                _buildHeader(),
                
                // 历史记录列表
                _buildHistoryList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '训练历史',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          // 查看全部按钮
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('查看全部历史记录功能待实现'),
                  backgroundColor: Color(0xFF6366F1),
                ),
              );
            },
            child: const Text(
              '查看全部',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return AnimatedBuilder(
      animation: _itemAnimation,
      builder: (context, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _historyPlans.length,
          itemBuilder: (context, index) {
            final plan = _historyPlans[index];
            final animationDelay = index * 0.1;
            
            return Transform.translate(
              offset: Offset(0, 20 * (1 - _itemAnimation.value)),
              child: Opacity(
                opacity: _itemAnimation.value,
                child: _buildHistoryItem(plan, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(MockTrainingPlan plan, int index) {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: index == _historyPlans.length - 1 ? 16 : 12,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showPlanDetail(plan);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // 训练图片
                _buildPlanImage(plan),
                
                const SizedBox(width: 12),
                
                // 训练信息
                Expanded(
                  child: _buildPlanInfo(plan),
                ),
                
                // 完成状态
                _buildCompletionStatus(plan),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanImage(MockTrainingPlan plan) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(plan.image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPlanInfo(MockTrainingPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          plan.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // 描述
        Text(
          plan.description,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 8),
        
        // 训练信息
        Row(
          children: [
            _buildInfoChip(plan.duration, Icons.access_time),
            const SizedBox(width: 8),
            _buildInfoChip('${plan.calories}卡', Icons.local_fire_department),
            const SizedBox(width: 8),
            _buildDifficultyChip(plan.difficulty),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color color;
    switch (difficulty) {
      case '初级':
        color = const Color(0xFF10B981);
        break;
      case '中级':
        color = const Color(0xFFF59E0B);
        break;
      case '高级':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = const Color(0xFF6B7280);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCompletionStatus(MockTrainingPlan plan) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  void _showPlanDetail(MockTrainingPlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // 拖拽指示器
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // 标题
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                plan.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            
            // 训练图片
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(plan.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 训练详情
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 基本信息
                    _buildDetailSection('训练信息', [
                      _buildDetailItem('时长', plan.duration),
                      _buildDetailItem('难度', plan.difficulty),
                      _buildDetailItem('卡路里', '${plan.calories}卡'),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    // 训练项目
                    _buildDetailSection('训练项目', [
                      ...plan.exercises.map((exercise) => 
                        _buildDetailItem('动作', exercise)),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
