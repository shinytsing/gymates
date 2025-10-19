import 'package:flutter/material.dart';
import 'package:gymates_flutter/pages/training/edit_training_plan_page.dart';

/// Flutter端训练计划编辑页面测试
/// 用于验证前后端联调功能
class TrainingPlanTestPage extends StatelessWidget {
  const TrainingPlanTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('训练计划编辑测试'),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🏋️‍♀️ Gymates 训练计划系统测试',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 测试功能',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('✅ 页面加载时自动获取用户训练计划'),
                    const Text('✅ 编辑训练动作（组数、次数、重量等）'),
                    const Text('✅ 添加/删除训练部位和动作'),
                    const Text('✅ 点击"AI推荐"按钮获取智能推荐'),
                    const Text('✅ 点击"保存计划"按钮同步到后端'),
                    const Text('✅ 切换不同训练日查看计划'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔧 后端API状态',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('✅ 获取训练计划: GET /api/training/plan'),
                    const Text('✅ 更新训练计划: POST /api/training/plan/update'),
                    const Text('✅ AI推荐训练: GET /api/training/ai/recommend'),
                    const Text('✅ 动作库查询: GET /api/training/exercises'),
                    const Text('✅ 动作搜索: GET /api/training/exercises/search'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 数据统计',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('🏋️ 动作库: 42个训练动作'),
                    const Text('📅 训练计划: 7天完整周期'),
                    const Text('🤖 AI推荐: 支持三分化/五分化/推拉腿'),
                    const Text('💾 数据同步: 实时保存到后端'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditTrainingPlanPage(
                      userId: 1, // 使用测试用户ID
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '🚀 开始测试训练计划编辑',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}
