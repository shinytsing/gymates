import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';
import '../../../animations/gymates_animations.dart';
import '../../../shared/models/mock_data.dart';

/// 🏋️‍♀️ 训练模式选择组件 - TrainingModeSelection
/// 
/// 基于Figma设计的训练模式选择界面
/// 支持五分化、三分化、推拉训练等模式选择
/// 包含智能推荐和详细说明

class TrainingModeSelection extends StatefulWidget {
  final Function(MockTrainingMode) onModeSelected;
  final MockUser? userProfile;

  const TrainingModeSelection({
    super.key,
    required this.onModeSelected,
    this.userProfile,
  });

  @override
  State<TrainingModeSelection> createState() => _TrainingModeSelectionState();
}

class _TrainingModeSelectionState extends State<TrainingModeSelection>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardAnimationController;
  late AnimationController _recommendationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _cardAnimation;
  late Animation<double> _recommendationAnimation;

  MockTrainingMode? _selectedMode;
  List<MockTrainingMode> _recommendedModes = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _generateRecommendations();
  }

  void _initializeAnimations() {
    // 头部动画控制器
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 卡片动画控制器
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 推荐动画控制器
    _recommendationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 头部动画
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 卡片动画
    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // 推荐动画
    _recommendationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _recommendationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始头部动画
    _headerAnimationController.forward();
    
    // 延迟开始卡片动画
    await Future.delayed(const Duration(milliseconds: 200));
    _cardAnimationController.forward();
    
    // 延迟开始推荐动画
    await Future.delayed(const Duration(milliseconds: 400));
    _recommendationController.forward();
  }

  void _generateRecommendations() {
    // 基于用户数据生成推荐
    final userExperience = widget.userProfile?.experience ?? '中级';
    final userGoal = widget.userProfile?.goal ?? '增肌';
    
    _recommendedModes = MockDataProvider.trainingModes.where((mode) {
      if (userExperience == '初级' && mode.difficulty == '初级') return true;
      if (userExperience == '中级' && ['初级', '中级'].contains(mode.difficulty)) return true;
      if (userExperience == '高级') return true;
      return false;
    }).toList();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardAnimationController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 头部区域
            _buildHeader(),
            
            // 内容区域
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 智能推荐区域
                    _buildRecommendationSection(),
                    
                    const SizedBox(height: 24),
                    
                    // 所有训练模式
                    _buildAllModesSection(),
                    
                    const SizedBox(height: 100), // 底部边距
                  ],
                ),
              ),
            ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 返回按钮和标题
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          size: 24,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '选择训练模式',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: GymatesTheme.lightTextPrimary,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '选择最适合你的训练方式',
                              style: TextStyle(
                                fontSize: 14,
                                color: GymatesTheme.lightTextSecondary,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationSection() {
    return AnimatedBuilder(
      animation: _recommendationAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _recommendationAnimation.value)),
          child: Opacity(
            opacity: _recommendationAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI智能推荐',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '基于你的训练经验：${widget.userProfile?.experience ?? '中级'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 推荐模式列表
                  ..._recommendedModes.take(2).map((mode) {
                    return _buildRecommendedModeCard(mode);
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendedModeCard(MockTrainingMode mode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            mode.icon,
            style: const TextStyle(fontSize: 24),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  mode.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedMode = mode;
              });
              widget.onModeSelected(mode);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '选择',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllModesSection() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _cardAnimation.value)),
          child: Opacity(
            opacity: _cardAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '所有训练模式',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 训练模式网格
                ...MockDataProvider.trainingModes.map((mode) {
                  return _buildModeCard(mode);
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeCard(MockTrainingMode mode) {
    final isSelected = _selectedMode?.id == mode.id;
    final isRecommended = mode.isRecommended;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedMode = mode;
          });
          widget.onModeSelected(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
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
              // 头部信息
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(int.parse(mode.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        mode.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              mode.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            if (isRecommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '推荐',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mode.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6366F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 详细信息
              Row(
                children: [
                  _buildInfoChip('难度', mode.difficulty, Icons.speed),
                  const SizedBox(width: 8),
                  _buildInfoChip('适合', mode.suitableFor, Icons.person),
                  const SizedBox(width: 8),
                  _buildInfoChip('${mode.weeklyFrequency}次/周', '', Icons.calendar_today),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 目标肌群
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mode.targetMuscles.map((muscle) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(int.parse(mode.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(int.parse(mode.color.substring(1), radix: 16) + 0xFF000000).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      muscle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(int.parse(mode.color.substring(1), radix: 16) + 0xFF000000),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 12),
              
              // 优势列表
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mode.benefits.map((benefit) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(int.parse(mode.color.substring(1), radix: 16) + 0xFF000000),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          benefit,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            value.isEmpty ? label : '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
