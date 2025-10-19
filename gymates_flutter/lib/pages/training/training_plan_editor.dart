import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';
import '../../../animations/gymates_animations.dart';
import '../../../shared/models/mock_data.dart';
import '../../../services/exercise_api_service.dart';
import '../../../services/training_plan_sync_service.dart';

/// 🏋️‍♀️ 编辑训练计划页面 - EditTrainingPlanPage
///
/// 功能特性：
/// - 一周7天训练计划编辑
/// - 训练部位选择和动作管理
/// - 实时数据保存和同步
/// - 流畅的动画和交互

class EditTrainingPlanPage extends StatefulWidget {
  final MockTrainingPlan? existingPlan;

  const EditTrainingPlanPage({
    super.key,
    this.existingPlan,
  });

  @override
  State<EditTrainingPlanPage> createState() => _EditTrainingPlanPageState();
}

class _EditTrainingPlanPageState extends State<EditTrainingPlanPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  EditTrainingPlan? _trainingPlan;
  int _selectedDayIndex = 0;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePlan();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializePlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.existingPlan != null) {
        // 转换现有计划
        _trainingPlan = _convertFromMockPlan(widget.existingPlan!);
      } else {
        // 创建新计划
        _trainingPlan = _createNewPlan();
      }
    } catch (e) {
      print('初始化训练计划失败: $e');
      _trainingPlan = _createNewPlan();
    }

    setState(() {
      _isLoading = false;
    });
  }

  EditTrainingPlan _convertFromMockPlan(MockTrainingPlan mockPlan) {
    final days = <TrainingDay>[];
    
    // 创建7天的训练计划
    for (int i = 0; i < 7; i++) {
      final dayName = WeekDays.dayNames[i];
      final parts = <TrainingPart>[];
      
      // 如果是第一天，添加现有动作
      if (i == 0 && mockPlan.exerciseDetails.isNotEmpty) {
        final exercises = mockPlan.exerciseDetails.map((exercise) {
          return Exercise(
            id: exercise.id,
            name: exercise.name,
            description: exercise.description,
            muscleGroup: exercise.muscleGroup,
            sets: exercise.sets,
            reps: exercise.reps,
            weight: exercise.weight,
            restSeconds: exercise.restTime,
            notes: exercise.notes,
            order: 0,
          );
        }).toList();

        // 按肌肉群分组
        final muscleGroups = <String, List<Exercise>>{};
        for (final exercise in exercises) {
          if (!muscleGroups.containsKey(exercise.muscleGroup)) {
            muscleGroups[exercise.muscleGroup] = [];
          }
          muscleGroups[exercise.muscleGroup]!.add(exercise);
        }

        // 为每个肌肉群创建训练部位
        int order = 0;
        for (final entry in muscleGroups.entries) {
          parts.add(TrainingPart(
            id: 'part_${i}_${entry.key}',
            muscleGroup: entry.key,
            muscleGroupName: MuscleGroups.groups[entry.key] ?? '未知部位',
            exercises: entry.value,
            order: order++,
          ));
        }
      }

      days.add(TrainingDay(
        id: 'day_$i',
        dayOfWeek: i + 1,
        dayName: dayName,
        parts: parts,
        isRestDay: parts.isEmpty,
      ));
    }

    return EditTrainingPlan(
      id: mockPlan.id,
      name: mockPlan.title,
      description: mockPlan.description,
      days: days,
      createdAt: mockPlan.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  EditTrainingPlan _createNewPlan() {
    final days = <TrainingDay>[];
    
    for (int i = 0; i < 7; i++) {
      days.add(TrainingDay(
        id: 'day_$i',
        dayOfWeek: i + 1,
        dayName: WeekDays.dayNames[i],
        parts: [],
        isRestDay: true,
      ));
    }

    return EditTrainingPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '我的训练计划',
      description: '个性化训练计划',
      days: days,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _trainingPlan == null) {
      return Scaffold(
        backgroundColor: GymatesTheme.lightBackground,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildWeeklySwitcher(),
            Expanded(
              child: _buildContent(),
            ),
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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1F2937)),
            onPressed: () {
              HapticFeedback.lightImpact();
              if (_hasChanges) {
                _showSaveDialog();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  '编辑训练计划',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  _trainingPlan?.name ?? '我的训练计划',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '有未保存的更改',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklySwitcher() {
    if (_trainingPlan == null) {
      return const SizedBox.shrink();
    }
    
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: (_trainingPlan?.days.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isSelected = index == _selectedDayIndex;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedDayIndex = index;
                    _fadeController.reset();
                    _slideController.reset();
                    _fadeController.forward();
                    _slideController.forward();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day.dayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (day.isRestDay)
                        const Icon(
                          Icons.bed,
                          size: 16,
                          color: Color(0xFF6B7280),
                        )
                      else
                        Text(
                          '${day.totalExercises} 动作',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList()) ?? [],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_trainingPlan == null || _selectedDayIndex >= _trainingPlan!.days.length) {
      return const Center(
        child: Text('数据加载中...'),
      );
    }
    
    final selectedDay = _trainingPlan?.days[_selectedDayIndex];
    
    if (selectedDay == null) {
      return const Center(
        child: Text('数据加载中...'),
      );
    }
    
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDayHeader(selectedDay),
                  const SizedBox(height: 16),
                  if (selectedDay.isRestDay)
                    _buildRestDayCard()
                  else
                    _buildTrainingParts(selectedDay),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayHeader(TrainingDay day) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${day.dayName}训练计划',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            day.isRestDay ? '今天休息，好好放松一下吧！' : '共${day.totalExercises}个动作，预计${day.totalDuration}分钟',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestDayCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.bed,
            size: 48,
            color: Color(0xFF6B7280),
          ),
          const SizedBox(height: 16),
          const Text(
            '休息日',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '今天没有训练计划，好好休息恢复体力！',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _toggleRestDay(_trainingPlan?.days[_selectedDayIndex]),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('开始训练'),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingParts(TrainingDay day) {
    return Column(
      children: [
        // 复制前一天计划按钮
        if (_selectedDayIndex > 0)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            child: OutlinedButton.icon(
              onPressed: _copyPreviousDay,
              icon: const Icon(Icons.copy, size: 20),
              label: const Text('复制前一天计划'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
                side: const BorderSide(color: Color(0xFF6366F1)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        
        // 训练部位列表
        ...day.parts.map((part) => _buildTrainingPartCard(part)).toList(),
        
        // 添加训练部位按钮
        _buildAddTrainingPartButton(day),
      ],
    );
  }

  Widget _buildTrainingPartCard(TrainingPart part) {
    final partColor = MuscleGroups.colors[part.muscleGroup] ?? const Color(0xFF6366F1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 部位头部
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: partColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    MuscleGroups.icons[part.muscleGroup] ?? '💪',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    part.muscleGroupName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: partColor,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    HapticFeedback.lightImpact();
                    if (value == 'add_exercise') {
                      _addExerciseToPart(part);
                    } else if (value == 'copy_part') {
                      _copyPart(part);
                    } else if (value == 'delete_part') {
                      _showDeletePartDialog(part);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_exercise',
                      child: Text('添加动作'),
                    ),
                    const PopupMenuItem(
                      value: 'copy_part',
                      child: Text('复制此部位'),
                    ),
                    const PopupMenuItem(
                      value: 'delete_part',
                      child: Text('删除此部位'),
                    ),
                  ],
                  icon: Icon(Icons.more_vert, color: partColor),
                ),
              ],
            ),
          ),
          
          // 动作列表
          ...part.exercises.map((exercise) => _buildExerciseItem(exercise, partColor)).toList(),
          
          // 添加动作按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _addExerciseToPart(part),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('添加动作'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: partColor,
                  side: BorderSide(color: partColor, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(Exercise exercise, Color partColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: exercise.isCompleted ? const Color(0xFF6B7280) : const Color(0xFF1F2937),
                    decoration: exercise.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Color(0xFF6B7280)),
                onPressed: () => _editExercise(exercise),
              ),
              Checkbox(
                value: exercise.isCompleted,
                onChanged: (bool? value) {
                  HapticFeedback.lightImpact();
                  setState(() {
                    final updatedExercise = exercise.copyWith(
                      isCompleted: value,
                      completedAt: value == true ? DateTime.now() : null,
                    );
                    _updateExerciseInPlan(exercise, updatedExercise);
                    _hasChanges = true;
                  });
                },
                activeColor: partColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildInfoChip('${exercise.sets}组', Icons.repeat, partColor),
              _buildInfoChip('${exercise.reps}次', Icons.fitness_center, partColor),
              _buildInfoChip('${exercise.weight}kg', Icons.scale, partColor),
              _buildInfoChip('${exercise.restSeconds}秒', Icons.timer, partColor),
            ],
          ),
          if (exercise.notes != null && exercise.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '备注: ${exercise.notes}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTrainingPartButton(TrainingDay day) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _addTrainingPart(day),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('添加训练部位'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6366F1),
          side: const BorderSide(color: Color(0xFF6366F1)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    if (_trainingPlan == null) {
      return const SizedBox.shrink();
    }
    
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
                _copyPreviousDay();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('复制前一天'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _hasChanges ? _savePlan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChanges ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
                foregroundColor: _hasChanges ? Colors.white : const Color(0xFF9CA3AF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('保存计划'),
            ),
          ),
        ],
      ),
    );
  }

  // 事件处理方法
  void _toggleRestDay(TrainingDay? day) {
    if (day == null || _trainingPlan == null) return;
    
    setState(() {
      final dayIndex = _trainingPlan!.days.indexOf(day);
      _trainingPlan = _trainingPlan!.copyWith(
        days: _trainingPlan!.days.map((d) {
          if (d.id == day.id) {
            return d.copyWith(isRestDay: !d.isRestDay);
          }
          return d;
        }).toList(),
      );
      _hasChanges = true;
    });
  }

  void _addTrainingPart(TrainingDay day) async {
    if (_trainingPlan == null) return;
    
    final muscleGroup = await _showMuscleGroupSelector();
    if (muscleGroup != null) {
      setState(() {
        final newPart = TrainingPart(
          id: 'part_${DateTime.now().millisecondsSinceEpoch}',
          muscleGroup: muscleGroup,
          muscleGroupName: MuscleGroups.groups[muscleGroup] ?? '未知部位',
          exercises: [],
          order: day.parts.length,
        );

        final dayIndex = _trainingPlan!.days.indexOf(day);
        final updatedDays = List<TrainingDay>.from(_trainingPlan!.days);
        updatedDays[dayIndex] = day.copyWith(
          parts: [...day.parts, newPart],
          isRestDay: false,
        );
        
        _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        _hasChanges = true;
      });
    }
  }

  void _addExerciseToPart(TrainingPart part) async {
    if (_trainingPlan == null) return;
    
    final exercise = await _showExerciseSelectionDialog(part.muscleGroup);
    if (exercise != null) {
      setState(() {
        final newExercise = Exercise(
          id: exercise.id,
          name: exercise.name,
          description: exercise.description,
          muscleGroup: exercise.muscleGroup,
          sets: exercise.sets,
          reps: exercise.reps,
          weight: exercise.weight,
          restSeconds: exercise.restTime,
          notes: exercise.notes,
          order: part.exercises.length,
        );

        final dayIndex = _trainingPlan!.days.indexWhere(
          (day) => day.parts.any((p) => p.id == part.id),
        );
        
        if (dayIndex != -1) {
          final updatedDays = List<TrainingDay>.from(_trainingPlan!.days);
          final day = updatedDays[dayIndex];
          final partIndex = day.parts.indexWhere((p) => p.id == part.id);
          
          if (partIndex != -1) {
            final updatedParts = List<TrainingPart>.from(day.parts);
            updatedParts[partIndex] = part.copyWith(
              exercises: [...part.exercises, newExercise],
            );
            updatedDays[dayIndex] = day.copyWith(parts: updatedParts);
            _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
            _hasChanges = true;
          }
        }
      });
    }
  }

  void _editExercise(Exercise exercise) async {
    if (_trainingPlan == null) return;
    
    final editedExercise = await _showExerciseEditDialog(exercise);
    if (editedExercise != null) {
      setState(() {
        _updateExerciseInPlan(exercise, editedExercise);
        _hasChanges = true;
      });
    }
  }

  void _deleteExercise(TrainingPart part, Exercise exercise) {
    if (_trainingPlan == null) return;
    
    setState(() {
      final dayIndex = _trainingPlan!.days.indexWhere(
        (day) => day.parts.any((p) => p.id == part.id),
      );
      
      if (dayIndex != -1) {
        final updatedDays = List<TrainingDay>.from(_trainingPlan!.days);
        final day = updatedDays[dayIndex];
        final partIndex = day.parts.indexWhere((p) => p.id == part.id);

        if (partIndex != -1) {
          final updatedParts = List<TrainingPart>.from(day.parts);
          updatedParts[partIndex] = part.copyWith(
            exercises: part.exercises.where((e) => e.id != exercise.id).toList(),
          );
          updatedDays[dayIndex] = day.copyWith(parts: updatedParts);
          _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
          _hasChanges = true;
        }
      }
    });
  }

  void _deletePart(TrainingPart part) {
    if (_trainingPlan == null) return;
    
    setState(() {
      final dayIndex = _trainingPlan!.days.indexWhere(
        (day) => day.parts.any((p) => p.id == part.id),
      );
      
      if (dayIndex != -1) {
        final updatedDays = List<TrainingDay>.from(_trainingPlan!.days);
        final day = updatedDays[dayIndex];
        final updatedParts = day.parts.where((p) => p.id != part.id).toList();
        updatedDays[dayIndex] = day.copyWith(parts: updatedParts);
        _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        _hasChanges = true;
      }
    });
  }

  void _copyPart(TrainingPart part) {
    if (_trainingPlan == null) return;
    
    // 复制到当前天
    final currentDay = _trainingPlan!.days[_selectedDayIndex];
    final copiedPart = TrainingPart(
      id: 'part_${DateTime.now().millisecondsSinceEpoch}',
      muscleGroup: part.muscleGroup,
      muscleGroupName: part.muscleGroupName,
      exercises: part.exercises.map((exercise) => Exercise(
        id: 'exercise_${DateTime.now().millisecondsSinceEpoch}_${exercise.order}',
        name: exercise.name,
        description: exercise.description,
        muscleGroup: exercise.muscleGroup,
        sets: exercise.sets,
        reps: exercise.reps,
        weight: exercise.weight,
        restSeconds: exercise.restSeconds,
        notes: exercise.notes,
        isCompleted: exercise.isCompleted,
        completedAt: exercise.completedAt,
        order: exercise.order,
      )).toList(),
      order: part.order,
    );

    setState(() {
      final updatedDays = List<TrainingDay>.from(_trainingPlan!.days);
      updatedDays[_selectedDayIndex] = currentDay.copyWith(
        parts: [...currentDay.parts, copiedPart],
        isRestDay: false,
      );
      
      _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
      _hasChanges = true;
    });
  }

  void _copyPreviousDay() {
    if (_trainingPlan == null || _selectedDayIndex <= 0) return;
    
    if (_selectedDayIndex > 0) {
      final previousDay = _trainingPlan!.days[_selectedDayIndex - 1];
      final currentDay = _trainingPlan!.days[_selectedDayIndex];
      
      final copiedParts = previousDay.parts.map((part) => TrainingPart(
        id: 'part_${DateTime.now().millisecondsSinceEpoch}_${part.order}',
        muscleGroup: part.muscleGroup,
        muscleGroupName: part.muscleGroupName,
        exercises: part.exercises.map((exercise) => Exercise(
          id: 'exercise_${DateTime.now().millisecondsSinceEpoch}_${exercise.order}',
          name: exercise.name,
          description: exercise.description,
          muscleGroup: exercise.muscleGroup,
          sets: exercise.sets,
          reps: exercise.reps,
          weight: exercise.weight,
          restSeconds: exercise.restSeconds,
          notes: exercise.notes,
          isCompleted: exercise.isCompleted,
          completedAt: exercise.completedAt,
          order: exercise.order,
        )).toList(),
        order: part.order,
      )).toList();

      setState(() {
        final updatedDays = List<TrainingDay>.from(_trainingPlan!.days);
        updatedDays[_selectedDayIndex] = currentDay.copyWith(
          parts: copiedParts,
          isRestDay: copiedParts.isEmpty,
        );
        
        _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        _hasChanges = true;
      });
    }
  }

  void _updateExerciseInPlan(Exercise oldExercise, Exercise newExercise) {
    if (_trainingPlan == null) return;
    
    final dayIndex = _trainingPlan!.days.indexWhere(
      (day) => day.parts.any((part) => part.exercises.any((e) => e.id == oldExercise.id)),
    );
    
    if (dayIndex != -1) {
      final updatedDays = List<TrainingDay>.from(_trainingPlan!.days);
      final day = updatedDays[dayIndex];
      final partIndex = day.parts.indexWhere(
        (part) => part.exercises.any((e) => e.id == oldExercise.id),
      );
      
      if (partIndex != -1) {
        final part = day.parts[partIndex];
        final exerciseIndex = part.exercises.indexWhere((e) => e.id == oldExercise.id);
        
        if (exerciseIndex != -1) {
          final updatedExercises = List<Exercise>.from(part.exercises);
          updatedExercises[exerciseIndex] = newExercise;
          
          final updatedParts = List<TrainingPart>.from(day.parts);
          updatedParts[partIndex] = part.copyWith(exercises: updatedExercises);
          updatedDays[dayIndex] = day.copyWith(parts: updatedParts);
          _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        }
      }
    }
  }

  // 对话框方法
  Future<String?> _showMuscleGroupSelector() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择训练部位'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...MuscleGroups.groups.entries.map((entry) {
              return ListTile(
                leading: Text(
                  MuscleGroups.icons[entry.key] ?? '💪',
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(entry.value),
                onTap: () {
                  Navigator.pop(context, entry.key);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<Exercise?> _showExerciseEditDialog(Exercise exercise) async {
    return showDialog<Exercise>(
      context: context,
      builder: (context) => _ExerciseEditDialog(exercise: exercise),
    );
  }

  Future<MockExercise?> _showExerciseSelectionDialog(String muscleGroup) async {
    return showDialog<MockExercise>(
      context: context,
      builder: (context) => _ExerciseSelectionDialog(muscleGroup: muscleGroup),
    );
  }

  void _showDeletePartDialog(TrainingPart part) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除训练部位'),
        content: Text('确定要删除"${part.muscleGroupName}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePart(part);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showDeleteExerciseDialog(Exercise exercise, TrainingPart part) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除动作'),
        content: Text('确定要删除"${exercise.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteExercise(part, exercise);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('保存更改'),
        content: const Text('您有未保存的更改，是否要保存？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('不保存'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _savePlan();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlan() async {
    if (_trainingPlan == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // 将EditTrainingPlan转换为API格式
      final planData = {
        'id': _trainingPlan!.id,
        'name': _trainingPlan!.name,
        'description': _trainingPlan!.description,
        'days': _trainingPlan!.days.map((day) => {
          'id': day.id,
          'dayOfWeek': day.dayOfWeek,
          'dayName': day.dayName,
          'isRestDay': day.isRestDay,
          'notes': day.notes,
          'parts': day.parts.map((part) => {
            'id': part.id,
            'muscleGroup': part.muscleGroup,
            'muscleGroupName': part.muscleGroupName,
            'order': part.order,
            'exercises': part.exercises.map((exercise) => {
              'id': exercise.id,
              'name': exercise.name,
              'description': exercise.description,
              'muscleGroup': exercise.muscleGroup,
              'sets': exercise.sets,
              'reps': exercise.reps,
              'weight': exercise.weight,
              'restSeconds': exercise.restSeconds,
              'notes': exercise.notes,
              'isCompleted': exercise.isCompleted,
              'completedAt': exercise.completedAt?.toIso8601String(),
              'order': exercise.order,
            }).toList(),
          }).toList(),
        }).toList(),
        'createdAt': _trainingPlan!.createdAt.toIso8601String(),
        'updatedAt': _trainingPlan!.updatedAt.toIso8601String(),
      };

      // 调用API保存训练计划
      final success = await TrainingPlanSyncService.saveTrainingPlan(planData);
      
      if (success) {
        setState(() {
          _hasChanges = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('训练计划保存成功！'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API保存失败，请检查网络连接。'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }
}

/// 🏋️‍♀️ 动作编辑对话框 - ExerciseEditDialog
class _ExerciseEditDialog extends StatefulWidget {
  final Exercise exercise;

  const _ExerciseEditDialog({required this.exercise});

  @override
  State<_ExerciseEditDialog> createState() => _ExerciseEditDialogState();
}

class _ExerciseEditDialogState extends State<_ExerciseEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _restController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise.name);
    _setsController = TextEditingController(text: widget.exercise.sets.toString());
    _repsController = TextEditingController(text: widget.exercise.reps.toString());
    _weightController = TextEditingController(text: widget.exercise.weight.toString());
    _restController = TextEditingController(text: widget.exercise.restSeconds.toString());
    _notesController = TextEditingController(text: widget.exercise.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _restController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '编辑动作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '动作名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '组数',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '次数',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '重量 (kg)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _restController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '休息时间 (秒)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '备注',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('保存'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveExercise() {
    final sets = int.tryParse(_setsController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;
    final restSeconds = int.tryParse(_restController.text) ?? 0;

    final updatedExercise = widget.exercise.copyWith(
      name: _nameController.text.trim(),
      sets: sets,
      reps: reps,
      weight: weight,
      restSeconds: restSeconds,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    Navigator.pop(context, updatedExercise);
  }
}

/// 🏋️‍♀️ 动作选择对话框 - ExerciseSelectionDialog
class _ExerciseSelectionDialog extends StatefulWidget {
  final String muscleGroup;

  const _ExerciseSelectionDialog({required this.muscleGroup});

  @override
  State<_ExerciseSelectionDialog> createState() => _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState extends State<_ExerciseSelectionDialog> {
  List<MockExercise> _exercises = [];
  bool _isLoading = true;
  String _searchQuery = '';
  List<MockExercise> _filteredExercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final exercises = await ExerciseApiService.searchExercises(
        muscleGroup: widget.muscleGroup,
        query: _searchQuery,
      );
      setState(() {
        _exercises = exercises;
        _filteredExercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to load exercises from API: $e');
      setState(() {
        _exercises = MockDataProvider.exercises
            .where((e) => e.muscleGroup == widget.muscleGroup)
            .toList();
        _filteredExercises = _exercises;
        _isLoading = false;
      });
    }
  }

  void _filterExercises(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredExercises = _exercises;
      } else {
        _filteredExercises = _exercises.where((exercise) {
          return exercise.name.toLowerCase().contains(query.toLowerCase()) ||
                 exercise.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '选择动作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '搜索动作',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterExercises,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _filteredExercises[index];
                    return ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: Text(exercise.name),
                      subtitle: Text('${exercise.sets}组 x ${exercise.reps}次 | ${exercise.weight}kg | 休息${exercise.restTime}秒'),
                      onTap: () => Navigator.pop(context, exercise),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}