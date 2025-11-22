import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../screens/training/services/training_api_service.dart';

/// 🤖 AI 训练计划生成器
/// 
/// 功能：
/// 1. 收集用户信息（目标、频率、偏好）
/// 2. 调用后端 LLM 生成个性化计划
/// 3. 展示生成的训练计划
/// 4. 一键导入到"我的训练"

class AIPlanGeneratorPage extends StatefulWidget {
  const AIPlanGeneratorPage({super.key});

  @override
  State<AIPlanGeneratorPage> createState() => _AIPlanGeneratorPageState();
}

class _AIPlanGeneratorPageState extends State<AIPlanGeneratorPage>
    with TickerProviderStateMixin {
  final _trainingService = TrainingApiService();
  
  // 表单数据
  String _selectedGoal = '增肌';
  int _weeklyFrequency = 3;
  String _experience = '中级';
  final List<String> _selectedParts = ['chest', 'back'];
  double _currentWeight = 70.0;
  double _targetWeight = 75.0;
  
  // 状态
  bool _isGenerating = false;
  bool _isGenerated = false;
  Map<String, dynamic>? _generatedPlan;
  
  // 动画控制器
  late AnimationController _shimmerController;
  late AnimationController _successController;
  
  final List<String> _goals = ['增肌', '减脂', '塑形', '力量', '耐力'];
  final List<String> _experienceLevels = ['初级', '中级', '高级'];
  final Map<String, String> _muscleGroups = {
    'chest': '胸部',
    'back': '背部',
    'shoulders': '肩部',
    'arms': '手臂',
    'legs': '腿部',
    'core': '核心',
  };

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final plan = await _trainingService.generateAIPlan(
        goal: _selectedGoal,
        frequency: _weeklyFrequency,
        experience: _experience,
        preferredParts: _selectedParts.join(','),
        currentWeight: _currentWeight,
        targetWeight: _targetWeight,
      );

      setState(() {
        _generatedPlan = plan;
        _isGenerated = true;
        _isGenerating = false;
      });
      
      _successController.forward();
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✨ AI 训练计划生成成功！'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('生成失败: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _savePlanToMyTraining() async {
    if (_generatedPlan == null) return;
    
    try {
      // 计划已经在后端保存，只需要导航到训练详情
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('✅ 已导入到我的训练！'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // 返回到训练页面
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: GymatesTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: _isGenerated
                    ? _buildGeneratedPlanView()
                    : _buildFormView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🤖 AI 训练计划生成器',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '个性化智能训练方案',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('训练目标'),
          _buildGoalSelector(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('每周训练频率'),
          _buildFrequencySelector(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('训练经验'),
          _buildExperienceSelector(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('偏好训练部位'),
          _buildMuscleGroupSelector(),
          const SizedBox(height: 24),
          
          _buildSectionTitle('体重信息'),
          _buildWeightInputs(),
          const SizedBox(height: 32),
          
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _goals.map((goal) {
        final isSelected = _selectedGoal == goal;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedGoal = goal;
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? GymatesTheme.primaryGradient : null,
              color: isSelected ? null : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              goal,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '每周训练',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                onPressed: _weeklyFrequency > 1
                    ? () {
                        setState(() {
                          _weeklyFrequency--;
                        });
                        HapticFeedback.lightImpact();
                      }
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: GymatesTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_weeklyFrequency 次',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: _weeklyFrequency < 7
                    ? () {
                        setState(() {
                          _weeklyFrequency++;
                        });
                        HapticFeedback.lightImpact();
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceSelector() {
    return Row(
      children: _experienceLevels.map((level) {
        final isSelected = _experience == level;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _experience = level;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? GymatesTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMuscleGroupSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _muscleGroups.entries.map((entry) {
        final isSelected = _selectedParts.contains(entry.key);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedParts.remove(entry.key);
              } else {
                _selectedParts.add(entry.key);
              }
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? GymatesTheme.primaryGradient : null,
              color: isSelected ? null : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              entry.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildWeightInput(
            label: '当前体重',
            value: _currentWeight,
            onChanged: (value) {
              setState(() {
                _currentWeight = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.arrow_forward, color: Colors.white70),
        const SizedBox(width: 16),
        Expanded(
          child: _buildWeightInput(
            label: '目标体重',
            value: _targetWeight,
            onChanged: (value) {
              setState(() {
                _targetWeight = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeightInput({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${value.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      onChanged(value + 0.5);
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      if (value > 30) {
                        onChanged(value - 0.5);
                        HapticFeedback.lightImpact();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generatePlan,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: GymatesTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 8,
        ),
        child: _isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GymatesTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '🤖 AI 正在生成...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Text(
                '✨ 生成个性化训练计划',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildGeneratedPlanView() {
    if (_generatedPlan == null) return const SizedBox();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GymatesTheme.primaryColor.withValues(alpha: 0.1),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: GymatesTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _generatedPlan!['name'] ?? 'AI 训练计划',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: GymatesTheme.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _generatedPlan!['description'] ?? '个性化训练方案',
                        style: TextStyle(
                          fontSize: 14,
                          color: GymatesTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  '📅 每周训练计划',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GymatesTheme.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPlanSummary(),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSummary() {
    final days = (_generatedPlan!['days'] as List?) ?? [];
    final trainingDays = days.where((d) => d['is_rest_day'] != true).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            GymatesTheme.primaryColor.withValues(alpha: 0.1),
            GymatesTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GymatesTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                color: GymatesTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                '训练天数: $trainingDays 天',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.darkTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '✅ 计划已保存到数据库',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 点击下方按钮导入到"我的训练"开始使用',
            style: TextStyle(
              fontSize: 13,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _savePlanToMyTraining,
        icon: const Icon(Icons.download_done),
        label: const Text(
          '导入到我的训练',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: GymatesTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}

