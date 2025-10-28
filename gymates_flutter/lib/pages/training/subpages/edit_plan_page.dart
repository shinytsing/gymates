import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/gymates_theme.dart';
import '../models/workout.dart';

/// 🏋️‍♀️ 编辑计划页 - EditPlanPage
/// 
/// 功能包括：
/// 1. 上方Tab切换：肌群（胸、背、腿、核心、全身）
/// 2. 中间动作列表（每个动作带+号按钮）
/// 3. 下方显示当前已选动作（可编辑组数、次数、重量）
/// 4. 点击添加动作 → 添加到计划
/// 5. 点击保存 → 更新WorkoutPlan模型并返回上级页面
/// 6. AI推荐按钮 → 自动填充推荐动作组合

class EditPlanPage extends StatefulWidget {
  final TodayWorkoutPlan? existingPlan;
  final Function(TodayWorkoutPlan)? onPlanSaved;

  const EditPlanPage({
    super.key,
    this.existingPlan,
    this.onPlanSaved,
  });

  @override
  State<EditPlanPage> createState() => _EditPlanPageState();
}

class _EditPlanPageState extends State<EditPlanPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 肌群分类
  final List<MuscleGroup> _muscleGroups = [
    MuscleGroup(name: '胸部', icon: Icons.fitness_center, color: const Color(0xFFEF4444)),
    MuscleGroup(name: '背部', icon: Icons.fitness_center, color: const Color(0xFF10B981)),
    MuscleGroup(name: '腿部', icon: Icons.fitness_center, color: const Color(0xFF6366F1)),
    MuscleGroup(name: '核心', icon: Icons.fitness_center, color: const Color(0xFFF59E0B)),
    MuscleGroup(name: '全身', icon: Icons.fitness_center, color: const Color(0xFF8B5CF6)),
  ];

  // 当前选中的肌群
  int _selectedMuscleGroupIndex = 0;
  
  // 当前计划中的动作
  List<WorkoutExercise> _selectedExercises = [];
  
  // 所有可用的动作库
  List<WorkoutExercise> _allExercises = [];
  
  // 计划信息
  String _planTitle = '我的训练计划';
  final String _planDescription = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _muscleGroups.length, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _initializeData();
    _animationController.forward();
  }

  void _initializeData() {
    // 初始化动作库
    _allExercises = _generateExerciseLibrary();
    
    // 如果有现有计划，加载它
    if (widget.existingPlan != null) {
      _selectedExercises = List.from(widget.existingPlan!.exercises);
      _planTitle = widget.existingPlan!.title;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
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
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _muscleGroups.map((group) => _buildMuscleGroupContent(group)).toList(),
              ),
            ),
            _buildSelectedExercises(),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                  '编辑训练计划',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '选择动作，制定专属训练计划',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          // AI推荐按钮
          GestureDetector(
            onTap: _showAIRecommendations,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: GymatesTheme.primaryColor,
        unselectedLabelColor: const Color(0xFF6B7280),
        tabs: _muscleGroups.map((group) => Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(group.icon, size: 16),
              const SizedBox(width: 4),
              Text(group.name),
            ],
          ),
        )).toList(),
        onTap: (index) {
          setState(() {
            _selectedMuscleGroupIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildMuscleGroupContent(MuscleGroup group) {
    final exercises = _allExercises.where((exercise) => 
      exercise.muscleGroup?.toLowerCase().contains(group.name.toLowerCase()) ?? false
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 肌群介绍
          _buildMuscleGroupIntro(group),
          
          const SizedBox(height: 16),
          
          // 动作列表
          _buildExerciseList(exercises),
          
          const SizedBox(height: 100), // 底部安全区域
        ],
      ),
    );
  }

  Widget _buildMuscleGroupIntro(MuscleGroup group) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            group.color.withValues(alpha: 0.1),
            group.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: group.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: group.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              group.icon,
              color: group.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: group.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getMuscleGroupDescription(group.name),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(List<WorkoutExercise> exercises) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '推荐动作 (${exercises.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ...exercises.map((exercise) => _buildExerciseItem(exercise)),
      ],
    );
  }

  Widget _buildExerciseItem(WorkoutExercise exercise) {
    final isSelected = _selectedExercises.any((e) => e.id == exercise.id);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected 
                    ? GymatesTheme.primaryColor.withValues(alpha: 0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                      ? GymatesTheme.primaryColor
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 动作图标
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? GymatesTheme.primaryColor
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 动作信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? GymatesTheme.primaryColor
                                : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${exercise.sets}组 × ${exercise.reps}次 × ${exercise.weight}kg',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        if (exercise.muscleGroup != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            exercise.muscleGroup!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 添加按钮
                  GestureDetector(
                    onTap: () => _toggleExercise(exercise),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF10B981)
                            : GymatesTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        isSelected ? Icons.check : Icons.add,
                        color: Colors.white,
                        size: 20,
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

  Widget _buildSelectedExercises() {
    if (_selectedExercises.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '已选动作 (${_selectedExercises.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: _clearAllExercises,
                child: const Text(
                  '清空',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._selectedExercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return _buildSelectedExerciseItem(exercise, index);
          }),
        ],
      ),
    );
  }

  Widget _buildSelectedExerciseItem(WorkoutExercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 序号
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: GymatesTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 动作信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildParameterChip('组数', '${exercise.sets}', () => _editExerciseParameter(exercise, 'sets')),
                    const SizedBox(width: 8),
                    _buildParameterChip('次数', '${exercise.reps}', () => _editExerciseParameter(exercise, 'reps')),
                    const SizedBox(width: 8),
                    _buildParameterChip('重量', '${exercise.weight}kg', () => _editExerciseParameter(exercise, 'weight')),
                  ],
                ),
              ],
            ),
          ),
          // 删除按钮
          GestureDetector(
            onTap: () => _removeExercise(exercise),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFFEF4444),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterChip(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GymatesTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          '$label: $value',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6366F1),
            fontWeight: FontWeight.w500,
          ),
        ),
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
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('取消'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _selectedExercises.isNotEmpty ? _savePlan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedExercises.isNotEmpty 
                    ? GymatesTheme.primaryColor
                    : const Color(0xFFE5E7EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '保存计划 (${_selectedExercises.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 方法实现
  void _toggleExercise(WorkoutExercise exercise) {
    HapticFeedback.lightImpact();
    
    setState(() {
      if (_selectedExercises.any((e) => e.id == exercise.id)) {
        _selectedExercises.removeWhere((e) => e.id == exercise.id);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  void _removeExercise(WorkoutExercise exercise) {
    HapticFeedback.lightImpact();
    
    setState(() {
      _selectedExercises.removeWhere((e) => e.id == exercise.id);
    });
  }

  void _clearAllExercises() {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('清空动作'),
        content: const Text('确定要清空所有已选动作吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedExercises.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _editExerciseParameter(WorkoutExercise exercise, String parameter) {
    final controller = TextEditingController();
    int currentValue = 0;
    String title = '';
    
    switch (parameter) {
      case 'sets':
        currentValue = exercise.sets;
        title = '组数';
        break;
      case 'reps':
        currentValue = exercise.reps;
        title = '次数';
        break;
      case 'weight':
        currentValue = exercise.weight.toInt();
        title = '重量';
        break;
    }
    
    controller.text = currentValue.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('编辑$title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '请输入$title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                setState(() {
                  final index = _selectedExercises.indexWhere((e) => e.id == exercise.id);
                  if (index != -1) {
                    switch (parameter) {
                      case 'sets':
                        _selectedExercises[index] = _selectedExercises[index].copyWith(sets: value);
                        break;
                      case 'reps':
                        _selectedExercises[index] = _selectedExercises[index].copyWith(reps: value);
                        break;
                      case 'weight':
                        _selectedExercises[index] = _selectedExercises[index].copyWith(weight: value.toDouble());
                        break;
                    }
                  }
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GymatesTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _showAIRecommendations() {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Color(0xFF6366F1),
            ),
            SizedBox(width: 8),
            Text('AI智能推荐'),
          ],
        ),
        content: const Text(
          'AI将根据你的健身目标、训练经验和身体状况，为你推荐最适合的动作组合。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyAIRecommendations();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('开始推荐'),
          ),
        ],
      ),
    );
  }

  void _applyAIRecommendations() {
    // 模拟AI推荐
    final recommendedExercises = _allExercises.take(5).toList();
    
    setState(() {
      _selectedExercises = recommendedExercises;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI推荐动作已添加'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _savePlan() {
    if (_selectedExercises.isEmpty) return;
    
    HapticFeedback.lightImpact();
    
    final plan = TodayWorkoutPlan(
      id: widget.existingPlan?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _planTitle,
      exercises: _selectedExercises,
    );
    
    widget.onPlanSaved?.call(plan);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('训练计划已保存'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }

  String _getMuscleGroupDescription(String muscleGroup) {
    switch (muscleGroup) {
      case '胸部':
        return '主要训练胸大肌、胸小肌，提升胸部力量和形态';
      case '背部':
        return '主要训练背阔肌、斜方肌，改善体态和背部力量';
      case '腿部':
        return '主要训练股四头肌、股二头肌，增强下肢力量';
      case '核心':
        return '主要训练腹肌、腰肌，提升核心稳定性';
      case '全身':
        return '全身性训练动作，提升整体协调性和力量';
      default:
        return '综合性训练动作';
    }
  }

  List<WorkoutExercise> _generateExerciseLibrary() {
    return [
      // 胸部动作
      WorkoutExercise(
        id: 'chest_1',
        name: '俯卧撑',
        sets: 3,
        reps: 15,
        restSeconds: 60,
        weight: 0,
        muscleGroup: '胸部',
        videoUrl: 'https://example.com/pushup.mp4',
      ),
      WorkoutExercise(
        id: 'chest_2',
        name: '哑铃卧推',
        sets: 4,
        reps: 12,
        restSeconds: 90,
        weight: 20,
        muscleGroup: '胸部',
        videoUrl: 'https://example.com/bench_press.mp4',
      ),
      WorkoutExercise(
        id: 'chest_3',
        name: '飞鸟',
        sets: 3,
        reps: 15,
        restSeconds: 60,
        weight: 15,
        muscleGroup: '胸部',
        videoUrl: 'https://example.com/fly.mp4',
      ),
      
      // 背部动作
      WorkoutExercise(
        id: 'back_1',
        name: '引体向上',
        sets: 3,
        reps: 8,
        restSeconds: 90,
        weight: 0,
        muscleGroup: '背部',
        videoUrl: 'https://example.com/pullup.mp4',
      ),
      WorkoutExercise(
        id: 'back_2',
        name: '划船',
        sets: 4,
        reps: 12,
        restSeconds: 75,
        weight: 25,
        muscleGroup: '背部',
        videoUrl: 'https://example.com/row.mp4',
      ),
      WorkoutExercise(
        id: 'back_3',
        name: '硬拉',
        sets: 3,
        reps: 8,
        restSeconds: 120,
        weight: 40,
        muscleGroup: '背部',
        videoUrl: 'https://example.com/deadlift.mp4',
      ),
      
      // 腿部动作
      WorkoutExercise(
        id: 'leg_1',
        name: '深蹲',
        sets: 4,
        reps: 15,
        restSeconds: 90,
        weight: 0,
        muscleGroup: '腿部',
        videoUrl: 'https://example.com/squat.mp4',
      ),
      WorkoutExercise(
        id: 'leg_2',
        name: '弓步蹲',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        weight: 0,
        muscleGroup: '腿部',
        videoUrl: 'https://example.com/lunge.mp4',
      ),
      WorkoutExercise(
        id: 'leg_3',
        name: '保加利亚分腿蹲',
        sets: 3,
        reps: 10,
        restSeconds: 75,
        weight: 0,
        muscleGroup: '腿部',
        videoUrl: 'https://example.com/bulgarian_split.mp4',
      ),
      
      // 核心动作
      WorkoutExercise(
        id: 'core_1',
        name: '平板支撑',
        sets: 3,
        reps: 30,
        restSeconds: 60,
        weight: 0,
        muscleGroup: '核心',
        videoUrl: 'https://example.com/plank.mp4',
      ),
      WorkoutExercise(
        id: 'core_2',
        name: '卷腹',
        sets: 3,
        reps: 20,
        restSeconds: 45,
        weight: 0,
        muscleGroup: '核心',
        videoUrl: 'https://example.com/crunch.mp4',
      ),
      WorkoutExercise(
        id: 'core_3',
        name: '俄罗斯转体',
        sets: 3,
        reps: 20,
        restSeconds: 45,
        weight: 0,
        muscleGroup: '核心',
        videoUrl: 'https://example.com/russian_twist.mp4',
      ),
      
      // 全身动作
      WorkoutExercise(
        id: 'full_1',
        name: '波比跳',
        sets: 3,
        reps: 10,
        restSeconds: 60,
        weight: 0,
        muscleGroup: '全身',
        videoUrl: 'https://example.com/burpee.mp4',
      ),
      WorkoutExercise(
        id: 'full_2',
        name: '登山者',
        sets: 3,
        reps: 20,
        restSeconds: 45,
        weight: 0,
        muscleGroup: '全身',
        videoUrl: 'https://example.com/mountain_climber.mp4',
      ),
      WorkoutExercise(
        id: 'full_3',
        name: '开合跳',
        sets: 3,
        reps: 30,
        restSeconds: 30,
        weight: 0,
        muscleGroup: '全身',
        videoUrl: 'https://example.com/jumping_jack.mp4',
      ),
    ];
  }
}

class MuscleGroup {
  final String name;
  final IconData icon;
  final Color color;

  MuscleGroup({
    required this.name,
    required this.icon,
    required this.color,
  });
}
