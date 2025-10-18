import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';
import '../../../animations/gymates_animations.dart';
import '../../../shared/models/mock_data.dart';
import '../../../services/exercise_api_service.dart';

/// 🏋️‍♀️ 训练计划编辑页面 - TrainingPlanEditor
/// 
/// 基于Figma设计的训练计划编辑界面
/// 支持拖拽排序、动作编辑、重量记录等功能

class TrainingPlanEditor extends StatefulWidget {
  final MockTrainingPlan? trainingPlan;
  final MockTrainingMode trainingMode;

  const TrainingPlanEditor({
    super.key,
    this.trainingPlan,
    required this.trainingMode,
  });

  @override
  State<TrainingPlanEditor> createState() => _TrainingPlanEditorState();
}

class _TrainingPlanEditorState extends State<TrainingPlanEditor>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _contentAnimation;

  List<MockExercise> _exercises = [];
  List<MockExercise> _filteredExercises = [];
  String _planName = '';
  String _planDescription = '';
  int _estimatedDuration = 60;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _initializePlan();
  }

  void _initializeAnimations() {
    // 头部动画控制器
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 内容动画控制器
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    // 内容动画
    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() async {
    // 开始头部动画
    _headerAnimationController.forward();
    
    // 延迟开始内容动画
    await Future.delayed(const Duration(milliseconds: 200));
    _contentAnimationController.forward();
  }

  void _filterExercises(String query) async {
    setState(() {
      _searchQuery = query;
    });
    
    if (query.isEmpty) {
      setState(() {
        _filteredExercises = List.from(_exercises);
      });
    } else {
      // 使用API搜索
      try {
        final searchResults = await ExerciseApiService.searchExercises(query: query);
        setState(() {
          _filteredExercises = searchResults;
        });
      } catch (e) {
        // 如果API失败，使用本地搜索
        setState(() {
          _filteredExercises = _exercises.where((exercise) {
            return exercise.name.toLowerCase().contains(query.toLowerCase()) ||
                   exercise.muscleGroup.toLowerCase().contains(query.toLowerCase()) ||
                   exercise.description.toLowerCase().contains(query.toLowerCase());
          }).toList();
        });
      }
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _filteredExercises = List.from(_exercises);
      }
    });
  }

  void _initializePlan() async {
    if (widget.trainingPlan != null) {
      _planName = widget.trainingPlan!.title;
      _planDescription = widget.trainingPlan!.description;
      _exercises = List.from(widget.trainingPlan!.exerciseDetails);
    } else {
      _planName = '${widget.trainingMode.name}计划';
      _planDescription = widget.trainingMode.description;
      // 使用API获取训练动作数据
      try {
        _exercises = await ExerciseApiService.getAllExercises();
      } catch (e) {
        print('Failed to load exercises from API: $e');
        _exercises = List.from(MockDataProvider.exercises);
      }
    }
    _filteredExercises = List.from(_exercises);
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
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
              child: _buildContent(),
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
              child: Row(
                children: [
                  // 返回按钮
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
                  
                  // 标题
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '编辑训练计划',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: GymatesTheme.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.trainingMode.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: GymatesTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 保存按钮
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _savePlan();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '保存',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 计划基本信息
                  _buildPlanInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // 动作列表
                  _buildExerciseList(),
                  
                  const SizedBox(height: 24),
                  
                  // 添加动作按钮
                  _buildAddExerciseButton(),
                  
                  const SizedBox(height: 100), // 底部边距
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            '计划信息',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 计划名称
          TextField(
            controller: TextEditingController(text: _planName),
            decoration: const InputDecoration(
              labelText: '计划名称',
              hintText: '输入训练计划名称',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _planName = value;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 计划描述
          TextField(
            controller: TextEditingController(text: _planDescription),
            decoration: const InputDecoration(
              labelText: '计划描述',
              hintText: '描述这个训练计划',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              _planDescription = value;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 训练信息
          Row(
            children: [
              Expanded(
                child: _buildInfoCard('训练模式', widget.trainingMode.name, Icons.fitness_center),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard('目标肌群', '${widget.trainingMode.targetMuscles.length}个', Icons.sports_gymnastics),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6366F1),
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '训练动作',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${_filteredExercises.length}个动作',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleSearch,
                    child: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // 搜索框
          if (_isSearching) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: TextField(
                onChanged: _filterExercises,
                decoration: const InputDecoration(
                  hintText: '搜索动作名称、肌群或描述...',
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 动作列表
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredExercises.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _exercises.removeAt(oldIndex);
                _exercises.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final exercise = _filteredExercises[index];
              return _buildExerciseItem(exercise, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(MockExercise exercise, int index) {
    return Container(
      key: ValueKey(exercise.id),
      margin: const EdgeInsets.only(bottom: 12),
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
          // 拖拽手柄
          Icon(
            Icons.drag_handle,
            color: const Color(0xFF6B7280),
            size: 20,
          ),
          
          const SizedBox(width: 12),
          
          // 动作图片
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(exercise.imageUrl),
                fit: BoxFit.cover,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise.muscleGroup,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _buildExerciseInfoChip('${exercise.sets}组', Icons.repeat),
                    _buildExerciseInfoChip('${exercise.reps}次', Icons.fitness_center),
                    _buildExerciseInfoChip('${exercise.weight}kg', Icons.scale),
                  ],
                ),
              ],
            ),
          ),
          
          // 编辑按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _editExercise(exercise, index);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.edit,
                color: Color(0xFF6366F1),
                size: 16,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // 删除按钮
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _removeExercise(index);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete,
                color: Color(0xFFEF4444),
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddExerciseButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _addExercise();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6366F1),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
              color: Color(0xFF6366F1),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              '添加动作',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editExercise(MockExercise exercise, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('编辑 ${exercise.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: exercise.sets.toString()),
              decoration: const InputDecoration(labelText: '组数'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // 更新组数
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: exercise.reps.toString()),
              decoration: const InputDecoration(labelText: '次数'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // 更新次数
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: exercise.weight.toString()),
              decoration: const InputDecoration(labelText: '重量 (kg)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // 更新重量
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 保存修改
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _removeExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除动作'),
        content: const Text('确定要删除这个动作吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _exercises.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _addExercise() {
    // 显示动作选择页面
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择动作',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: MockDataProvider.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = MockDataProvider.exercises[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(exercise.imageUrl),
                    ),
                    title: Text(exercise.name),
                    subtitle: Text(exercise.muscleGroup),
                    onTap: () {
                      setState(() {
                        _exercises.add(exercise);
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePlan() {
    // 保存训练计划
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('训练计划已保存'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
    Navigator.of(context).pop();
  }
}
