import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../../../services/training_plan_sync_service.dart';
import '../pages/edit_training_plan_page.dart';

/// 📋 我的训练计划页面 - MyPlanPage
/// 
/// 展示和管理用户的训练计划

class MyPlanPage extends StatefulWidget {
  const MyPlanPage({super.key});

  @override
  State<MyPlanPage> createState() => _MyPlanPageState();
}

class _MyPlanPageState extends State<MyPlanPage> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadPlans();
  }
  
  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    
    try {
      final plans = await TrainingPlanSyncService.getUserTrainingPlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 加载计划失败: $e');
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: GymatesTheme.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '我的训练计划',
          style: TextStyle(
            color: GymatesTheme.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: GymatesTheme.primaryColor),
            onPressed: _createNewPlan,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? _buildEmptyState()
              : _buildPlanList(),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 80,
            color: GymatesTheme.lightTextSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            '还没有训练计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '创建你的第一个训练计划',
            style: TextStyle(
              fontSize: 14,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewPlan,
            icon: const Icon(Icons.add),
            label: const Text('创建训练计划'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GymatesTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlanList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _plans.length,
      itemBuilder: (context, index) {
        final plan = _plans[index];
        return _buildPlanCard(plan);
      },
    );
  }
  
  Widget _buildPlanCard(Map<String, dynamic> plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: InkWell(
        onTap: () => _editPlan(plan),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                plan['image'] ?? 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          plan['name'] ?? '训练计划',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GymatesTheme.lightTextPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '进行中',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: GymatesTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                    if (plan['description'] != null)
                      Text(
                        plan['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: GymatesTheme.lightTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildPlanStat('5天', Icons.calendar_today),
                      const SizedBox(width: 16),
                      _buildPlanStat('6个动作', Icons.fitness_center),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanStat(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: GymatesTheme.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: GymatesTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }
  
  void _createNewPlan() {
    HapticFeedback.lightImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditTrainingPlanPage(),
      ),
    ).then((_) => _loadPlans()); // 刷新计划列表
  }
  
  void _editPlan(Map<String, dynamic> plan) {
    HapticFeedback.lightImpact();
    
    // TODO: 加载完整计划数据并编辑
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditTrainingPlanPage(),
      ),
    ).then((_) => _loadPlans()); // 刷新计划列表
  }
}

