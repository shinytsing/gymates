/// 🤖 AI教练页面
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/training_provider.dart';
import 'widgets/training_stat_card.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  bool _isGenerating = false;
  String? _generatedPlanId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('AI智能教练'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildUserInfoCard(),
            const SizedBox(height: 16),
            _buildPreferencesCard(),
            const SizedBox(height: 24),
            _buildGenerateButton(),
            if (_generatedPlanId != null) ...[
              const SizedBox(height: 24),
              _buildGeneratedPlanCard(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[400]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'AI智能训练计划',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '基于您的个人数据和训练历史\n为您生成个性化训练计划',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        final stats = provider.userStats;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '您的训练数据',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (stats != null) ...[
                  _buildInfoRow('总训练次数', '${stats['total_workouts'] ?? 0} 次'),
                  _buildInfoRow('总训练时长', '${stats['total_minutes'] ?? 0} 分钟'),
                  _buildInfoRow('总消耗卡路里', '${stats['total_calories_burned'] ?? 0} 卡'),
                  _buildInfoRow('连续打卡', '${stats['current_streak'] ?? 0} 天'),
                ] else
                  const Text('暂无训练数据'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '训练偏好',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'AI将根据您的目标、健身水平和训练历史，\n为您生成最适合的训练计划',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildPreferenceChip('增肌', Icons.fitness_center),
            _buildPreferenceChip('减脂', Icons.local_fire_department),
            _buildPreferenceChip('增强力量', Icons.sports_mma),
            _buildPreferenceChip('提高耐力', Icons.directions_run),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        backgroundColor: Colors.purple[50],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generateAIPlan,
          icon: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_isGenerating ? '生成中...' : '生成AI训练计划'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedPlanCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI训练计划已生成!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '已为您生成个性化训练计划，快去查看吧！',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('查看计划'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateAIPlan() async {
    setState(() => _isGenerating = true);

    try {
      final provider = context.read<TrainingProvider>();
      final plan = await provider.generateAIPlan();

      setState(() {
        _isGenerating = false;
        _generatedPlanId = plan.id;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 AI训练计划生成成功!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('生成失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

