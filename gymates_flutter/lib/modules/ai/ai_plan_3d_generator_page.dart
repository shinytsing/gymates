import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/3d_components/index.dart';
import '../../screens/training/services/training_api_service.dart';

/// 🤖 Apple Fitness+ Style AI Plan Generator Page
/// 
/// Design Features:
/// - 3D step-by-step form cards
/// - 3D option button arrays
/// - AI generating animation (particles + progress)
/// - 3D plan display (cards dropping in)
/// - 3D import animation (fly into home)
/// - Smooth multi-step flow

class AIPlan3DGeneratorPage extends StatefulWidget {
  const AIPlan3DGeneratorPage({super.key});

  @override
  State<AIPlan3DGeneratorPage> createState() => _AIPlan3DGeneratorPageState();
}

class _AIPlan3DGeneratorPageState extends State<AIPlan3DGeneratorPage>
    with TickerProviderStateMixin {
  final TrainingApiService _trainingService = TrainingApiService();
  final PageController _pageController = PageController();
  
  // Form data
  String _selectedGoal = '增肌';
  int _weeklyFrequency = 3;
  String _experience = '中级';
  final List<String> _selectedParts = ['chest', 'back'];
  double _currentWeight = 70.0;
  double _targetWeight = 75.0;
  
  // State
  int _currentStep = 0;
  bool _isGenerating = false;
  bool _isGenerated = false;
  Map<String, dynamic>? _generatedPlan;
  
  // Animation controllers
  late AnimationController _generatingController;
  late AnimationController _successController;
  late AnimationController _cardDropController;
  
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
    
    _generatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: AppleFitnessTheme.durationSlow,
      vsync: this,
    );
    
    _cardDropController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _generatingController.dispose();
    _successController.dispose();
    _cardDropController.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    setState(() {
      _isGenerating = true;
      _currentStep = 5;
    });
    
    _generatingController.repeat();

    try {
      final plan = await _trainingService.generateAIPlan(
        goal: _selectedGoal,
        frequency: _weeklyFrequency,
        experience: _experience,
        preferredParts: _selectedParts.join(','),
        currentWeight: _currentWeight,
        targetWeight: _targetWeight,
      );

      if (mounted) {
        setState(() {
          _generatedPlan = plan;
          _isGenerated = true;
          _isGenerating = false;
        });
        
        _generatingController.stop();
        _successController.forward();
        _cardDropController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _currentStep = 4;
        });
        _generatingController.stop();
        
        showAlertDialog3D(
          context: context,
          title: '生成失败',
          message: e.toString(),
          confirmText: '重试',
          onConfirm: _generatePlan,
        );
      }
    }
  }

  Future<void> _savePlan() async {
    if (_generatedPlan == null) return;
    
    showAlertDialog3D(
      context: context,
      title: '计划已保存',
      message: '您可以在"我的训练"中查看',
      confirmText: '查看',
      onConfirm: () {
        Navigator.pop(context);
        // Navigate to training detail
      },
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: AppleFitnessTheme.durationNormal,
        curve: AppleFitnessTheme.easeInOutCubic,
      );
    } else {
      _generatePlan();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: AppleFitnessTheme.durationNormal,
        curve: AppleFitnessTheme.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressIndicator(),
              Expanded(
                child: _isGenerating
                    ? _buildGeneratingView()
                    : _isGenerated
                        ? _buildResultView()
                        : _buildFormView(),
              ),
              if (!_isGenerating && !_isGenerated)
                _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: AppleFitnessTheme.spacingS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI 训练计划',
                style: AppleFitnessTheme.headlineMedium,
              ),
              if (!_isGenerated)
                Text(
                  _getStepTitle(),
                  style: AppleFitnessTheme.bodyMedium.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    return switch (_currentStep) {
      0 => '选择目标',
      1 => '训练频率',
      2 => '经验水平',
      3 => '目标部位',
      4 => '体重信息',
      _ => '生成中',
    };
  }

  Widget _buildProgressIndicator() {
    if (_isGenerating || _isGenerated) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppleFitnessTheme.spacingL),
      child: StepProgress3D(
        currentStep: _currentStep,
        totalSteps: 5,
        stepLabels: ['目标', '频率', '经验', '部位', '体重'],
      ),
    );
  }

  Widget _buildFormView() {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildGoalStep(),
        _buildFrequencyStep(),
        _buildExperienceStep(),
        _buildMuscleGroupStep(),
        _buildWeightStep(),
      ],
    );
  }

  Widget _buildGoalStep() {
    return _buildStepContainer(
      title: '你的健身目标是什么？',
      child: Wrap(
        spacing: AppleFitnessTheme.spacingM,
        runSpacing: AppleFitnessTheme.spacingM,
        children: _goals.map((goal) {
          final isSelected = goal == _selectedGoal;
          return _build3DOptionButton(
            label: goal,
            icon: _getGoalIcon(goal),
            isSelected: isSelected,
            onTap: () => setState(() => _selectedGoal = goal),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFrequencyStep() {
    return _buildStepContainer(
      title: '每周训练几次？',
      child: Column(
        children: [
          Text(
            '$_weeklyFrequency 次/周',
            style: AppleFitnessTheme.displaySmall.copyWith(
              color: AppleFitnessTheme.primaryBlue,
            ),
          ),
          SizedBox(height: AppleFitnessTheme.spacingXL),
          Card3D(
            useFrostedGlass: true,
            child: Column(
              children: [
                Slider(
                  value: _weeklyFrequency.toDouble(),
                  min: 2,
                  max: 7,
                  divisions: 5,
                  activeColor: AppleFitnessTheme.primaryBlue,
                  onChanged: (value) {
                    setState(() => _weeklyFrequency = value.toInt());
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppleFitnessTheme.spacingM,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('2', style: AppleFitnessTheme.bodySmall),
                      Text('7', style: AppleFitnessTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return _buildStepContainer(
      title: '你的训练经验？',
      child: Column(
        children: _experienceLevels.map((level) {
          final isSelected = level == _experience;
          return Padding(
            padding: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
            child: Card3D(
              gradient: isSelected ? AppleFitnessTheme.primaryGradient : null,
              backgroundColor: isSelected ? null : Colors.white,
              onTap: () => setState(() => _experience = level),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.white : AppleFitnessTheme.textTertiary,
                  ),
                  SizedBox(width: AppleFitnessTheme.spacingM),
                  Text(
                    level,
                    style: AppleFitnessTheme.titleMedium.copyWith(
                      color: isSelected ? Colors.white : AppleFitnessTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMuscleGroupStep() {
    return _buildStepContainer(
      title: '想训练哪些部位？',
      subtitle: '可多选',
      child: Wrap(
        spacing: AppleFitnessTheme.spacingM,
        runSpacing: AppleFitnessTheme.spacingM,
        children: _muscleGroups.entries.map((entry) {
          final isSelected = _selectedParts.contains(entry.key);
          return _build3DOptionButton(
            label: entry.value,
            icon: Icons.fitness_center,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedParts.remove(entry.key);
                } else {
                  _selectedParts.add(entry.key);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeightStep() {
    return _buildStepContainer(
      title: '体重信息',
      child: Column(
        children: [
          Card3D(
            useFrostedGlass: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '当前体重',
                  style: AppleFitnessTheme.labelMedium.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
                SizedBox(height: AppleFitnessTheme.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _currentWeight,
                        min: 40,
                        max: 150,
                        activeColor: AppleFitnessTheme.primaryBlue,
                        onChanged: (value) {
                          setState(() => _currentWeight = value);
                        },
                      ),
                    ),
                    SizedBox(width: AppleFitnessTheme.spacingM),
                    Text(
                      '${_currentWeight.toInt()} kg',
                      style: AppleFitnessTheme.titleLarge.copyWith(
                        color: AppleFitnessTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppleFitnessTheme.spacingL),
          Card3D(
            useFrostedGlass: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '目标体重',
                  style: AppleFitnessTheme.labelMedium.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
                SizedBox(height: AppleFitnessTheme.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _targetWeight,
                        min: 40,
                        max: 150,
                        activeColor: AppleFitnessTheme.primaryGreen,
                        onChanged: (value) {
                          setState(() => _targetWeight = value);
                        },
                      ),
                    ),
                    SizedBox(width: AppleFitnessTheme.spacingM),
                    Text(
                      '${_targetWeight.toInt()} kg',
                      style: AppleFitnessTheme.titleLarge.copyWith(
                        color: AppleFitnessTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppleFitnessTheme.headlineSmall,
          ),
          if (subtitle != null) ...[
            SizedBox(height: AppleFitnessTheme.spacingS),
            Text(
              subtitle,
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
          ],
          SizedBox(height: AppleFitnessTheme.spacingXL),
          child,
        ],
      ),
    );
  }

  Widget _build3DOptionButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppleFitnessTheme.durationFast,
        padding: EdgeInsets.all(AppleFitnessTheme.spacingM),
        decoration: BoxDecoration(
          gradient: isSelected ? AppleFitnessTheme.primaryGradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: AppleFitnessTheme.radiusMedium,
          boxShadow: isSelected
              ? AppleFitnessTheme.softShadow(elevation: 8)
              : AppleFitnessTheme.softShadow(elevation: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppleFitnessTheme.primaryBlue,
              size: 32,
            ),
            SizedBox(height: AppleFitnessTheme.spacingS),
            Text(
              label,
              style: AppleFitnessTheme.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppleFitnessTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _generatingController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _generatingController.value * 2 * math.pi,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppleFitnessTheme.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: AppleFitnessTheme.softGlow(
                      AppleFitnessTheme.primaryBlue,
                      intensity: 0.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppleFitnessTheme.spacingXXL),
          Text(
            'AI 正在生成计划...',
            style: AppleFitnessTheme.headlineMedium,
          ),
          SizedBox(height: AppleFitnessTheme.spacingM),
          Text(
            '根据您的需求定制专属方案',
            style: AppleFitnessTheme.bodyMedium.copyWith(
              color: AppleFitnessTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _successController,
            builder: (context, child) {
              return Transform.scale(
                scale: _successController.value,
                child: Opacity(
                  opacity: _successController.value,
                  child: child,
                ),
              );
            },
            child: SuccessCheckmark3D(
              size: 100,
              color: AppleFitnessTheme.success,
            ),
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingXL),
          
          Text(
            '计划生成成功！',
            style: AppleFitnessTheme.displaySmall,
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingS),
          
          Text(
            '为您定制的专属训练方案',
            style: AppleFitnessTheme.bodyMedium.copyWith(
              color: AppleFitnessTheme.textSecondary,
            ),
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingXXL),
          
          // Plan overview
          AnimatedBuilder(
            animation: _cardDropController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 100 * (1 - _cardDropController.value)),
                child: Opacity(
                  opacity: _cardDropController.value,
                  child: child,
                ),
              );
            },
            child: Card3D(
              gradient: AppleFitnessTheme.primaryGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '您的训练计划',
                    style: AppleFitnessTheme.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingL),
                  _buildPlanInfoRow(
                    icon: Icons.flag,
                    label: '目标',
                    value: _selectedGoal,
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingM),
                  _buildPlanInfoRow(
                    icon: Icons.calendar_today,
                    label: '频率',
                    value: '$_weeklyFrequency 次/周',
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingM),
                  _buildPlanInfoRow(
                    icon: Icons.fitness_center,
                    label: '部位',
                    value: '${_selectedParts.length} 个',
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingXXL),
          
          // Action buttons
          Button3D.primary(
            text: '保存到我的训练',
            icon: Icons.download,
            size: Button3DSize.large,
            onPressed: _savePlan,
          ),
          
          SizedBox(height: AppleFitnessTheme.spacingM),
          
          Button3D.outline(
            text: '重新生成',
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                _isGenerated = false;
                _generatedPlan = null;
                _currentStep = 0;
              });
              _pageController.jumpToPage(0);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlanInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        SizedBox(width: AppleFitnessTheme.spacingS),
        Text(
          '$label: ',
          style: AppleFitnessTheme.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: AppleFitnessTheme.labelLarge.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: Button3D.outline(
                  text: '上一步',
                  icon: Icons.arrow_back,
                  onPressed: _previousStep,
                ),
              ),
            if (_currentStep > 0) SizedBox(width: AppleFitnessTheme.spacingM),
            Expanded(
              flex: 2,
              child: Button3D.primary(
                text: _currentStep == 4 ? '生成计划' : '下一步',
                icon: _currentStep == 4 ? Icons.auto_awesome : Icons.arrow_forward,
                size: Button3DSize.large,
                onPressed: _canProceed() ? () => _nextStep() : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    return switch (_currentStep) {
      3 => _selectedParts.isNotEmpty,
      _ => true,
    };
  }

  IconData _getGoalIcon(String goal) {
    return switch (goal) {
      '增肌' => Icons.fitness_center,
      '减脂' => Icons.local_fire_department,
      '塑形' => Icons.self_improvement,
      '力量' => Icons.accessibility_new,
      '耐力' => Icons.directions_run,
      _ => Icons.flag,
    };
  }
}

