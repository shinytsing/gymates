/// ✏️ 训练计划编辑器页面 (支持左滑右滑添加运动)
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/exercise_model.dart';
import 'models/training_plan_model.dart';
import 'providers/training_provider.dart';
import 'widgets/swipeable_exercise_card.dart';
import 'widgets/exercise_card.dart';

class TrainingPlanEditorScreen extends StatefulWidget {
  final TrainingPlan? existingPlan;

  const TrainingPlanEditorScreen({
    super.key,
    this.existingPlan,
  });

  @override
  State<TrainingPlanEditorScreen> createState() => _TrainingPlanEditorScreenState();
}

class _TrainingPlanEditorScreenState extends State<TrainingPlanEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _difficulty = 'beginner';
  String _goal = 'strength';
  List<PlanExercise> _selectedExercises = [];
  int _currentExerciseIndex = 0;
  bool _isSwipeMode = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    if (widget.existingPlan != null) {
      _nameController.text = widget.existingPlan!.name;
      _descriptionController.text = widget.existingPlan!.description;
      _difficulty = widget.existingPlan!.difficulty;
      _goal = widget.existingPlan!.goal;
      _selectedExercises = List.from(widget.existingPlan!.exercises);
    }
  }

  Future<void> _loadData() async {
    final provider = context.read<TrainingProvider>();
    await provider.fetchExercises();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.existingPlan == null ? '创建训练计划' : '编辑训练计划'),
        actions: [
          if (_isSwipeMode)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => setState(() => _isSwipeMode = false),
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePlan,
          ),
        ],
      ),
      body: _isSwipeMode ? _buildSwipeMode() : _buildNormalMode(),
      floatingActionButton: !_isSwipeMode
          ? FloatingActionButton.extended(
              onPressed: _enterSwipeMode,
              icon: const Icon(Icons.swipe),
              label: const Text('滑动添加运动'),
            )
          : null,
    );
  }

  Widget _buildNormalMode() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 基本信息表单
          _buildPlanInfoForm(),
          const SizedBox(height: 16),
          // 已选运动列表
          _buildSelectedExercisesList(),
          const SizedBox(height: 16),
          // 计划统计
          _buildPlanStatistics(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildPlanInfoForm() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '基本信息',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // 计划名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '计划名称',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入计划名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 计划描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '计划描述',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // 难度选择
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(
                  labelText: '难度',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.signal_cellular_alt),
                ),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('初级')),
                  DropdownMenuItem(value: 'intermediate', child: Text('中级')),
                  DropdownMenuItem(value: 'advanced', child: Text('高级')),
                ],
                onChanged: (value) => setState(() => _difficulty = value!),
              ),
              const SizedBox(height: 16),
              // 目标选择
              DropdownButtonFormField<String>(
                value: _goal,
                decoration: const InputDecoration(
                  labelText: '训练目标',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.emoji_events),
                ),
                items: const [
                  DropdownMenuItem(value: 'strength', child: Text('增强力量')),
                  DropdownMenuItem(value: 'muscle', child: Text('增肌')),
                  DropdownMenuItem(value: 'endurance', child: Text('耐力')),
                  DropdownMenuItem(value: 'weight_loss', child: Text('减脂')),
                  DropdownMenuItem(value: 'flexibility', child: Text('柔韧性')),
                ],
                onChanged: (value) => setState(() => _goal = value!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedExercisesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '训练项目',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${_selectedExercises.length} 个运动',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_selectedExercises.isEmpty)
          _buildEmptyExercisesView()
        else
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _reorderExercises,
            children: _selectedExercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return Dismissible(
                key: Key(exercise.exerciseId),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _removeExercise(index),
                child: PlanExerciseCard(
                  planExercise: exercise,
                  onEdit: () => _editExercise(index),
                  onDelete: () => _confirmRemoveExercise(index),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyExercisesView() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '还没有添加运动',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮开始添加',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStatistics() {
    final totalDuration = _selectedExercises.fold(0, (sum, ex) => sum + ex.totalDuration) ~/ 60;
    final totalCalories = _selectedExercises.fold(0, (sum, ex) => sum + ex.totalCalories);

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '计划预估',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.timer,
                    '$totalDuration 分钟',
                    '预计时长',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.local_fire_department,
                    '$totalCalories 卡',
                    '预计消耗',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ==================== 滑动模式 ====================

  Widget _buildSwipeMode() {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingExercises) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('没有更多运动了'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _isSwipeMode = false),
                  child: const Text('返回编辑'),
                ),
              ],
            ),
          );
        }

        if (_currentExerciseIndex >= provider.exercises.length) {
          return _buildAllExercisesReviewed();
        }

        final exercise = provider.exercises[_currentExerciseIndex];

        return Stack(
          children: [
            // 背景提示
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Icon(Icons.arrow_back, size: 48, color: Colors.red[200]),
                            const SizedBox(height: 8),
                            Text(
                              '← 左滑跳过',
                              style: TextStyle(color: Colors.red[200]),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(Icons.arrow_forward, size: 48, color: Colors.green[200]),
                            const SizedBox(height: 8),
                            Text(
                              '右滑添加 →',
                              style: TextStyle(color: Colors.green[200]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 可滑动的运动卡片
            SwipeableExerciseCard(
              exercise: exercise,
              onSwipeLeft: _skipExercise,
              onSwipeRight: () => _addExerciseFromSwipe(exercise),
              onTap: () {
                // TODO: 显示运动详情
              },
            ),
            // 进度指示器
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentExerciseIndex + 1} / ${provider.exercises.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAllExercisesReviewed() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              '所有运动已浏览完毕',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '已添加 ${_selectedExercises.length} 个运动',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => setState(() => _isSwipeMode = false),
              icon: const Icon(Icons.edit),
              label: const Text('继续编辑计划'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 方法 ====================

  void _enterSwipeMode() {
    setState(() {
      _isSwipeMode = true;
      _currentExerciseIndex = 0;
    });
  }

  void _skipExercise() {
    setState(() {
      _currentExerciseIndex++;
    });
  }

  void _addExerciseFromSwipe(Exercise exercise) {
    _showExerciseConfigDialog(exercise).then((planExercise) {
      if (planExercise != null) {
        setState(() {
          _selectedExercises.add(planExercise);
          _currentExerciseIndex++;
        });
      }
    });
  }

  Future<PlanExercise?> _showExerciseConfigDialog(Exercise exercise) async {
    int sets = 3;
    int reps = 10;
    double? weight;
    int? duration;
    int restTime = 60;
    String? notes;

    return showDialog<PlanExercise>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('配置 ${exercise.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 组数
                ListTile(
                  leading: const Icon(Icons.repeat),
                  title: const Text('组数'),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: sets.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) => sets = int.tryParse(value) ?? sets,
                    ),
                  ),
                ),
                // 次数
                ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: const Text('次数/组'),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: reps.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) => reps = int.tryParse(value) ?? reps,
                    ),
                  ),
                ),
                // 重量 (可选)
                ListTile(
                  leading: const Icon(Icons.monitor_weight),
                  title: const Text('重量 (kg)'),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: '可选'),
                      onChanged: (value) => weight = double.tryParse(value),
                    ),
                  ),
                ),
                // 休息时间
                ListTile(
                  leading: const Icon(Icons.hourglass_empty),
                  title: const Text('休息时间 (秒)'),
                  trailing: SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: restTime.toString(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onChanged: (value) => restTime = int.tryParse(value) ?? restTime,
                    ),
                  ),
                ),
                // 备注
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: '备注 (可选)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => notes = value.isEmpty ? null : value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final planExercise = PlanExercise(
                  exerciseId: exercise.id,
                  exercise: exercise,
                  sets: sets,
                  reps: reps,
                  weight: weight,
                  duration: duration,
                  restTime: restTime,
                  order: _selectedExercises.length + 1,
                  notes: notes,
                );
                Navigator.pop(context, planExercise);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final exercise = _selectedExercises.removeAt(oldIndex);
      _selectedExercises.insert(newIndex, exercise);
      
      // 更新顺序
      for (int i = 0; i < _selectedExercises.length; i++) {
        _selectedExercises[i] = _selectedExercises[i].copyWith(order: i + 1);
      }
    });
  }

  void _editExercise(int index) async {
    final exercise = _selectedExercises[index];
    final result = await _showExerciseConfigDialog(exercise.exercise);
    
    if (result != null) {
      setState(() {
        _selectedExercises[index] = result.copyWith(order: exercise.order);
      });
    }
  }

  void _confirmRemoveExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除运动'),
        content: Text('确定要删除 ${_selectedExercises[index].exercise.name} 吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeExercise(index);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
      // 更新顺序
      for (int i = 0; i < _selectedExercises.length; i++) {
        _selectedExercises[i] = _selectedExercises[i].copyWith(order: i + 1);
      }
    });
  }

  void _savePlan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少添加一个运动')),
      );
      return;
    }

    try {
      final provider = context.read<TrainingProvider>();
      
      final plan = TrainingPlan(
        id: widget.existingPlan?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        userId: '', // Will be set by provider
        exercises: _selectedExercises,
        difficulty: _difficulty,
        goal: _goal,
        isAIGenerated: false,
        isPublic: false,
        createdAt: widget.existingPlan?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.existingPlan == null) {
        await provider.createTrainingPlan(plan);
      } else {
        await provider.updateTrainingPlan(plan);
      }

      if (mounted) {
        Navigator.pop(context, plan.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}

