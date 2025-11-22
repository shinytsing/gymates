/// 🎯 AI训练计划生成页面
library;

import 'package:flutter/material.dart';
import '../../services/ai_training_service.dart';
import '../../services/unified_auth_service.dart';

class GeneratePlanScreen extends StatefulWidget {
  const GeneratePlanScreen({super.key});

  @override
  State<GeneratePlanScreen> createState() => _GeneratePlanScreenState();
}

class _GeneratePlanScreenState extends State<GeneratePlanScreen> {
  final AITrainingService _aiService = AITrainingService();
  final UnifiedAuthService _authService = UnifiedAuthService();

  // 表单数据
  String _selectedGoal = '增肌';
  int _selectedFrequency = 3;
  String _selectedExperience = '中级';
  final Set<String> _selectedParts = {};
  
  double? _currentWeight;
  double? _targetWeight;
  String? _gender;
  int? _age;
  double? _height;

  bool _isGenerating = false;
  TrainingPlan? _generatedPlan;

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
        title: const Text('AI智能训练计划'),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: _generatedPlan == null
          ? _buildConfigurationForm()
          : _buildGeneratedPlan(),
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

  /// 头部
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
            'AI智能训练计划生成',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '根据您的目标和身体状况\n为您定制专属训练计划',
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getFrequencyDescription(_selectedFrequency),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
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
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '身高 (cm)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _height = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '年龄',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _age = int.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ],
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
          onPressed: _isGenerating ? null : _generatePlan,
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
            _isGenerating ? '正在生成中...' : '一键生成训练计划',
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

  /// 生成的训练计划展示
  Widget _buildGeneratedPlan() {
    if (_generatedPlan == null) return const SizedBox();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSuccessHeader(),
          const SizedBox(height: 16),
          _buildPlanOverview(),
          const SizedBox(height: 16),
          _buildWeeklySchedule(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 成功头部
  Widget _buildSuccessHeader() {
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
            '训练计划生成成功！',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _generatedPlan!.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 计划概览
  Widget _buildPlanOverview() {
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
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '计划概览',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _generatedPlan!.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('训练天数', '${_getTrainingDaysCount()}天/周', Colors.purple),
                _buildStatItem('总动作数', '${_getTotalExercisesCount()}个', Colors.orange),
                _buildStatItem('预计时长', '${_getEstimatedDuration()}分钟', Colors.green),
              ],
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
                Icon(Icons.calendar_month, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  '每周训练安排',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._generatedPlan!.days.map((day) => _buildDayCard(day)),
          ],
        ),
      ),
    );
  }

  /// 训练日卡片
  Widget _buildDayCard(TrainingDay day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: day.isRestDay ? Colors.grey[100] : Colors.purple[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: day.isRestDay ? Colors.grey[300]! : Colors.purple[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                day.isRestDay ? Icons.hotel : Icons.fitness_center,
                color: day.isRestDay ? Colors.grey : Colors.purple,
              ),
              const SizedBox(width: 8),
              Text(
                _getDayNameInChinese(day.dayName),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (day.isRestDay)
                Chip(
                  label: const Text('休息日', style: TextStyle(fontSize: 12)),
                  backgroundColor: Colors.grey[300],
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          if (!day.isRestDay && day.parts.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...day.parts.map((part) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${part.muscleGroupName} (${part.exercises.length}个动作)',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )),
          ],
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
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, _generatedPlan);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('开始使用此计划', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _generatedPlan = null;
                  _isGenerating = false;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重新生成', style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple,
                side: const BorderSide(color: Colors.purple, width: 2),
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

  /// 统计项
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 生成训练计划
  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('请先登录');
      }

      final plan = await _aiService.generatePersonalizedPlan(
        userId: user.id,
        goal: _selectedGoal,
        frequency: _selectedFrequency,
        experience: _selectedExperience,
        preferredParts: _selectedParts.join(','),
        currentWeight: _currentWeight,
        targetWeight: _targetWeight,
        gender: _gender,
        age: _age,
        height: _height,
      );

      setState(() {
        _generatedPlan = plan;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 训练计划生成成功！'),
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

  /// 辅助方法
  String _getFrequencyDescription(int frequency) {
    switch (frequency) {
      case 3:
        return '适合初学者';
      case 4:
        return '标准训练';
      case 5:
        return '进阶训练';
      case 6:
        return '高强度训练';
      default:
        return '';
    }
  }

  String _getDayNameInChinese(String dayName) {
    const Map<String, String> dayMap = {
      'Monday': '周一',
      'Tuesday': '周二',
      'Wednesday': '周三',
      'Thursday': '周四',
      'Friday': '周五',
      'Saturday': '周六',
      'Sunday': '周日',
    };
    return dayMap[dayName] ?? dayName;
  }

  int _getTrainingDaysCount() {
    return _generatedPlan!.days.where((d) => !d.isRestDay).length;
  }

  int _getTotalExercisesCount() {
    int count = 0;
    for (var day in _generatedPlan!.days) {
      for (var part in day.parts) {
        count += part.exercises.length;
      }
    }
    return count;
  }

  int _getEstimatedDuration() {
    // 估算每个动作平均5分钟
    return _getTotalExercisesCount() * 5;
  }
}

