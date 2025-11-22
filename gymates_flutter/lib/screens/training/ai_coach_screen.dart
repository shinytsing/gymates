/// 🤖 AI教练页面 - 增强版
library;

import 'package:flutter/material.dart';
import '../../services/ai_training_service.dart';
import '../../services/unified_auth_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final AITrainingService _aiService = AITrainingService();
  final UnifiedAuthService _authService = UnifiedAuthService();
  
  bool _isGenerating = false;
  TrainingPlan? _generatedPlan;
  
  // 表单数据
  String _selectedGoal = '增肌';
  int _selectedFrequency = 4;
  String _selectedExperience = '中级';
  final Set<String> _selectedParts = {};
  
  double? _currentWeight;
  double? _targetWeight;

  final List<String> _goals = ['增肌', '减脂', '力量', '耐力', '塑形'];
  final List<int> _frequencies = [3, 4, 5, 6];
  final List<String> _experiences = ['初级', '中级', '高级'];
  final List<Map<String, dynamic>> _bodyParts = [
    {'name': '胸部', 'key': 'chest', 'icon': Icons.fitness_center},
    {'name': '背部', 'key': 'back', 'icon': Icons.accessibility_new},
    {'name': '腿部', 'key': 'legs', 'icon': Icons.directions_run},
    {'name': '肩部', 'key': 'shoulders', 'icon': Icons.sports_mma},
    {'name': '手臂', 'key': 'arms', 'icon': Icons.sports_handball},
    {'name': '核心', 'key': 'core', 'icon': Icons.self_improvement},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('AI智能教练'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: _generatedPlan == null
          ? _buildConfigurationForm()
          : _buildGeneratedPlanView(),
    );
  }

  /// 配置表单
  Widget _buildConfigurationForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildUserInfoCard(),
          const SizedBox(height: 16),
          _buildGoalSection(),
          const SizedBox(height: 16),
          _buildFrequencySection(),
          const SizedBox(height: 16),
          _buildExperienceSection(),
          const SizedBox(height: 16),
          _buildBodyPartsSection(),
          const SizedBox(height: 16),
          _buildPhysicalDataSection(),
          const SizedBox(height: 24),
          _buildGenerateButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 生成的计划视图
  Widget _buildGeneratedPlanView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanHeader(),
          const SizedBox(height: 16),
          _buildPlanSummary(),
          const SizedBox(height: 16),
          _buildWeeklySchedule(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DeepSeek AI',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '智能健身教练',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '已激活',
                    style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '根据您的目标和身体状况，AI将为您生成科学的训练计划',
              style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
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

  /// 训练目标选择
  Widget _buildGoalSection() {
    return _buildSection(
      title: '训练目标',
      icon: Icons.flag,
      iconColor: Colors.orange,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _goals.map((goal) {
          final isSelected = _selectedGoal == goal;
          return ChoiceChip(
            label: Text(goal),
            selected: isSelected,
            onSelected: (selected) {
              setState(() => _selectedGoal = goal);
            },
            selectedColor: Colors.purple[100],
            backgroundColor: Colors.white,
          );
        }).toList(),
      ),
    );
  }

  /// 训练频率选择
  Widget _buildFrequencySection() {
    return _buildSection(
      title: '每周训练频率',
      icon: Icons.calendar_today,
      iconColor: Colors.blue,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '每周 $_selectedFrequency 次',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                _getFrequencyDescription(_selectedFrequency),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          Slider(
            value: _selectedFrequency.toDouble(),
            min: 3,
            max: 6,
            divisions: 3,
            label: '$_selectedFrequency 次/周',
            onChanged: (value) {
              setState(() => _selectedFrequency = value.toInt());
            },
            activeColor: Colors.purple,
          ),
        ],
      ),
    );
  }

  /// 训练经验选择
  Widget _buildExperienceSection() {
    return _buildSection(
      title: '训练经验',
      icon: Icons.military_tech,
      iconColor: Colors.green,
      child: Row(
        children: _experiences.map((exp) {
          final isSelected = _selectedExperience == exp;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () {
                  setState(() => _selectedExperience = exp);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? Colors.purple : Colors.white,
                  foregroundColor: isSelected ? Colors.white : Colors.black87,
                  elevation: isSelected ? 4 : 1,
                ),
                child: Text(exp),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 训练部位选择
  Widget _buildBodyPartsSection() {
    return _buildSection(
      title: '偏好训练部位（可多选）',
      icon: Icons.accessibility,
      iconColor: Colors.red,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _bodyParts.map((part) {
          final isSelected = _selectedParts.contains(part['key']);
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(part['icon'] as IconData, size: 18),
                const SizedBox(width: 4),
                Text(part['name'] as String),
              ],
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedParts.add(part['key'] as String);
                } else {
                  _selectedParts.remove(part['key']);
                }
              });
            },
            selectedColor: Colors.purple[100],
            backgroundColor: Colors.white,
          );
        }).toList(),
      ),
    );
  }

  /// 身体数据输入
  Widget _buildPhysicalDataSection() {
    return _buildSection(
      title: '身体数据（选填）',
      icon: Icons.monitor_weight,
      iconColor: Colors.teal,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: '当前体重 (kg)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _currentWeight = double.tryParse(value);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: '目标体重 (kg)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _targetWeight = double.tryParse(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 通用区块组件
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
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
                Icon(icon, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  /// 生成按钮
  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isGenerating ? null : _generateAIPlan,
          icon: _isGenerating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.auto_awesome, size: 28),
          label: Text(
            _isGenerating ? 'DeepSeek AI 生成中...' : '一键生成训练计划',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
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

  /// 生成的计划头部
  Widget _buildPlanHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.teal[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            '训练计划已生成',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '目标：$_selectedGoal | 频率：每周$_selectedFrequency次',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 计划摘要
  Widget _buildPlanSummary() {
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
                Icon(Icons.auto_awesome, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'AI 分析结果',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('训练目标', _selectedGoal),
            _buildInfoRow('训练频率', '每周 $_selectedFrequency 次'),
            _buildInfoRow('训练经验', _selectedExperience),
            if (_selectedParts.isNotEmpty)
              _buildInfoRow('重点部位', _selectedParts.join('、')),
            if (_currentWeight != null && _targetWeight != null)
              _buildInfoRow(
                '体重目标',
                '${_currentWeight!.toStringAsFixed(1)} kg → ${_targetWeight!.toStringAsFixed(1)} kg',
              ),
          ],
        ),
      ),
    );
  }

  /// 每周训练安排
  Widget _buildWeeklySchedule() {
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
                Icon(Icons.calendar_today, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '每周训练安排',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '根据您的目标和经验，AI 为您制定了以下训练计划：',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            _buildDaySchedule('周一', '胸部 + 三头肌', '6个动作 · 45分钟'),
            _buildDaySchedule('周三', '背部 + 二头肌', '6个动作 · 50分钟'),
            _buildDaySchedule('周五', '腿部 + 肩部', '7个动作 · 55分钟'),
            if (_selectedFrequency >= 4)
              _buildDaySchedule('周六', '核心 + 有氧', '5个动作 · 40分钟'),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day, String focus, String details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                day.substring(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  focus,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ 训练计划已开始！'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text(
                '开始训练',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _generatedPlan = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新生成'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.purple),
                    foregroundColor: Colors.purple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('取消'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey[400]!),
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 辅助方法
  String _getFrequencyDescription(int frequency) {
    switch (frequency) {
      case 3:
        return '轻度训练';
      case 4:
        return '中度训练';
      case 5:
        return '高强度训练';
      case 6:
        return '专业训练';
      default:
        return '';
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.purple),
            SizedBox(width: 8),
            Text('关于 AI 教练'),
          ],
        ),
        content: const Text(
          'DeepSeek AI 智能健身教练会根据您的：\n\n'
          '• 训练目标（增肌/减脂/力量/耐力）\n'
          '• 训练频率（每周3-6次）\n'
          '• 训练经验（初级/中级/高级）\n'
          '• 偏好部位\n'
          '• 身体数据\n\n'
          '为您生成个性化的科学训练计划。',
          style: TextStyle(fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _generateAIPlan() async {
    setState(() => _isGenerating = true);

    try {
      // 获取用户ID
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('请先登录');
      }

      // 调用 AI 服务生成计划
      final plan = await _aiService.generatePersonalizedPlan(
        userId: user.id,
        goal: _selectedGoal,
        frequency: _selectedFrequency,
        experience: _selectedExperience,
        preferredParts: _selectedParts.join(','),
        currentWeight: _currentWeight,
        targetWeight: _targetWeight,
      );

      setState(() {
        _isGenerating = false;
        _generatedPlan = plan;
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

