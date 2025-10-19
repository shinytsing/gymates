import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/gymates_theme.dart';
import '../../animations/gymates_animations.dart';
import '../../shared/models/edit_training_plan_models.dart' as models;
import '../../services/exercise_api_service.dart';
import '../../services/training_plan_sync_service.dart';
import 'widgets/weekly_view_switcher.dart';
import 'widgets/training_part_card.dart';
import 'widgets/exercise_edit_dialog.dart';
import 'widgets/exercise_selection_dialog.dart';

/// 🏋️‍♀️ 编辑训练计划页面 - models.EditTrainingPlanPage
/// 
/// 功能特性：
/// - 一周7天训练计划编辑
/// - 训练部位选择和动作管理
/// - 实时数据保存和同步
/// - 流畅的动画和交互

class models.EditTrainingPlanPage extends StatefulWidget {
  final models.models.EditTrainingPlan? existingPlan;
  final String? planId; // 新增：支持从API加载现有计划
  final int? userId; // 新增：用户ID

  const models.EditTrainingPlanPage({
    super.key,
    this.existingPlan,
    this.planId,
    this.userId,
  });

  @override
  State<models.EditTrainingPlanPage> createState() => _models.EditTrainingPlanPageState();
}

class _models.EditTrainingPlanPageState extends State<models.EditTrainingPlanPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  models.EditTrainingPlan? _trainingPlan;
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
      if (widget.userId != null) {
        // 从新API加载用户训练计划
        final planData = await TrainingPlanSyncService.getUserTrainingPlan(widget.userId!);
        if (planData != null) {
          _trainingPlan = _convertFromApiPlan(planData);
        } else {
          _trainingPlan = _createNewPlan();
        }
      } else if (widget.planId != null) {
        // 从API加载现有计划
        _trainingPlan = await TrainingPlanSyncService.getWeeklyTrainingPlan(widget.planId!);
        if (_trainingPlan == null) {
          // 如果API加载失败，创建新计划
          _trainingPlan = _createNewPlan();
        }
      } else if (widget.existingPlan != null) {
        // 转换现有Mock计划
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

  /// 从API数据转换为models.EditTrainingPlan
  models.EditTrainingPlan _convertFromApiPlan(Map<String, dynamic> planData) {
    final days = <models.TrainingDay>[];
    
    if (planData['days'] != null) {
      final daysData = planData['days'] as List;
      for (final dayData in daysData) {
        final parts = <models.TrainingPart>[];
        
        if (dayData['parts'] != null) {
          final partsData = dayData['parts'] as List;
          for (final partData in partsData) {
            final exercises = <models.Exercise>[];
            
            if (partData['exercises'] != null) {
              final exercisesData = partData['exercises'] as List;
              for (final exerciseData in exercisesData) {
                exercises.add(models.Exercise(
                  id: exerciseData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: exerciseData['name'] ?? '',
                  description: exerciseData['description'] ?? '',
                  muscleGroup: exerciseData['muscle_group'] ?? '',
                  sets: exerciseData['sets'] ?? 3,
                  reps: exerciseData['reps'] ?? 10,
                  weight: exerciseData['weight']?.toDouble() ?? 0.0,
                  restSeconds: exerciseData['rest_seconds'] ?? exerciseData['rest_time'] * 60 ?? 60,
                  notes: exerciseData['notes'] ?? '',
                  order: exerciseData['order'] ?? 0,
                ));
              }
            }
            
            parts.add(models.TrainingPart(
              id: partData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
              muscleGroup: partData['muscle_group'] ?? '',
              muscleGroupName: partData['muscle_group_name'] ?? '',
              exercises: exercises,
              order: partData['order'] ?? 0,
            ));
          }
        }
        
        days.add(models.TrainingDay(
          id: dayData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          dayOfWeek: dayData['day_of_week'] ?? 1,
          dayName: dayData['day_name'] ?? '',
          parts: parts,
          isRestDay: dayData['is_rest_day'] ?? parts.isEmpty,
          notes: dayData['notes'],
        ));
      }
    }
    
    // 如果API返回的天数不足7天，补充完整
    while (days.length < 7) {
      final dayIndex = days.length;
      days.add(models.TrainingDay(
        id: 'day_$dayIndex',
        dayOfWeek: dayIndex + 1,
        dayName: WeekDays.dayNames[dayIndex],
        parts: [],
        isRestDay: true,
      ));
    }

    return models.EditTrainingPlan(
      id: planData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: planData['name'] ?? '我的训练计划',
      description: planData['description'] ?? '',
      days: days,
      createdAt: planData['created_at'] != null ? DateTime.parse(planData['created_at']) : DateTime.now(),
      updatedAt: planData['updated_at'] != null ? DateTime.parse(planData['updated_at']) : DateTime.now(),
    );
  }

  models.EditTrainingPlan _createNewPlan() {
    final days = <models.TrainingDay>[];
    
    for (int i = 0; i < 7; i++) {
      days.add(models.TrainingDay(
        id: 'day_$i',
        dayOfWeek: i + 1,
        dayName: WeekDays.dayNames[i],
        parts: [],
        isRestDay: true,
      ));
    }

    return models.EditTrainingPlan(
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: GymatesTheme.lightBackground,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
        ),
      );
    }

    if (_trainingPlan == null) {
      return Scaffold(
        backgroundColor: GymatesTheme.lightBackground,
        body: const Center(
          child: Text('加载失败，请重试'),
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
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (_hasChanges) {
                _showSaveDialog();
              } else {
                Navigator.pop(context);
              }
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
                  _trainingPlan!.name,
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
                '未保存',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklySwitcher() {
    return WeeklyViewSwitcher(
      selectedDayIndex: _selectedDayIndex,
      onDaySelected: (index) {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedDayIndex = index;
        });
      },
      trainingDays: _trainingPlan!.days,
    );
  }

  Widget _buildContent() {
    final selectedDay = _trainingPlan!.days[_selectedDayIndex];
    
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
                    _buildmodels.TrainingParts(selectedDay),
                  const SizedBox(height: 16),
                  _buildAddPartButton(selectedDay),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayHeader(models.TrainingDay day) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.dayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  day.isRestDay ? '休息日' : '${day.totalmodels.Exercises}个动作 • ${day.totalDuration}分钟',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (!day.isRestDay)
            GestureDetector(
              onTap: () => _toggleRestDay(day),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '设为休息日',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.hotel,
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
            '今天是休息日，让身体充分恢复',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _toggleRestDay(_trainingPlan!.days[_selectedDayIndex]),
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

  Widget _buildmodels.TrainingParts(models.TrainingDay day) {
    if (day.parts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.fitness_center,
              size: 48,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            const Text(
              '还没有训练内容',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '添加训练部位开始制定计划',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: day.parts.map((part) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: models.TrainingPartCard(
            trainingPart: part,
            onEditmodels.Exercise: (exercise) => _editmodels.Exercise(exercise),
            onDeletemodels.Exercise: (exercise) => _deletemodels.Exercise(part, exercise),
            onAddmodels.Exercise: () => _addmodels.ExerciseToPart(part),
            onDeletePart: () => _deletePart(part),
            onCopyPart: () => _copyPart(part),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddPartButton(models.TrainingDay day) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _addmodels.TrainingPart(day),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6366F1),
          side: const BorderSide(color: Color(0xFF6366F1)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('添加训练部位'),
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
                _copyPreviousDay();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('复制前一天'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAIRecommendations();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                side: const BorderSide(color: Color(0xFF8B5CF6)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('AI推荐'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _hasChanges ? _savePlan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
  void _toggleRestDay(models.TrainingDay day) {
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

  void _addmodels.TrainingPart(models.TrainingDay day) async {
    final muscleGroup = await _showMuscleGroupSelector();
    if (muscleGroup != null) {
      setState(() {
        final newPart = models.TrainingPart(
          id: 'part_${DateTime.now().millisecondsSinceEpoch}',
          muscleGroup: muscleGroup,
          muscleGroupName: models.MuscleGroups.groups[muscleGroup]!,
          exercises: [],
          order: day.parts.length,
        );

        final dayIndex = _trainingPlan!.days.indexOf(day);
        final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
        updatedDays[dayIndex] = day.copyWith(
          parts: [...day.parts, newPart],
          isRestDay: false,
        );

        _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        _hasChanges = true;
      });
    }
  }

  void _addmodels.ExerciseToPart(models.TrainingPart part) async {
    final exercise = await _showmodels.ExerciseSelectionDialog(part.muscleGroup);
    if (exercise != null) {
      setState(() {
        final newmodels.Exercise = models.Exercise(
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
          final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
          final day = updatedDays[dayIndex];
          final partIndex = day.parts.indexWhere((p) => p.id == part.id);
          
          if (partIndex != -1) {
            final updatedParts = List<models.TrainingPart>.from(day.parts);
            updatedParts[partIndex] = part.copyWith(
              exercises: [...part.exercises, newmodels.Exercise],
            );
            
            updatedDays[dayIndex] = day.copyWith(parts: updatedParts);
            _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
            _hasChanges = true;
          }
        }
      });
    }
  }

  void _editmodels.Exercise(models.Exercise exercise) async {
    final editedmodels.Exercise = await _showmodels.ExerciseEditDialog(exercise);
    if (editedmodels.Exercise != null) {
      setState(() {
        _updatemodels.ExerciseInPlan(exercise, editedmodels.Exercise);
        _hasChanges = true;
      });
    }
  }

  void _deletemodels.Exercise(models.TrainingPart part, models.Exercise exercise) {
    setState(() {
      final dayIndex = _trainingPlan!.days.indexWhere(
        (day) => day.parts.any((p) => p.id == part.id),
      );
      
      if (dayIndex != -1) {
        final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
        final day = updatedDays[dayIndex];
        final partIndex = day.parts.indexWhere((p) => p.id == part.id);
        
        if (partIndex != -1) {
          final updatedParts = List<models.TrainingPart>.from(day.parts);
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

  void _deletePart(models.TrainingPart part) {
    setState(() {
      final dayIndex = _trainingPlan!.days.indexWhere(
        (day) => day.parts.any((p) => p.id == part.id),
      );
      
      if (dayIndex != -1) {
        final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
        final day = updatedDays[dayIndex];
        final updatedParts = day.parts.where((p) => p.id != part.id).toList();
        
        updatedDays[dayIndex] = day.copyWith(
          parts: updatedParts,
          isRestDay: updatedParts.isEmpty,
        );
        
        _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        _hasChanges = true;
      }
    });
  }

  void _copyPart(models.TrainingPart part) {
    // 复制到当前天
    final currentDay = _trainingPlan!.days[_selectedDayIndex];
    final copiedPart = part.copyWith(
      id: 'part_${DateTime.now().millisecondsSinceEpoch}',
      exercises: part.exercises.map((exercise) => exercise.copyWith(
        id: 'exercise_${DateTime.now().millisecondsSinceEpoch}_${exercise.order}',
      )).toList(),
    );

    setState(() {
      final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
      updatedDays[_selectedDayIndex] = currentDay.copyWith(
        parts: [...currentDay.parts, copiedPart],
        isRestDay: false,
      );
      
      _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
      _hasChanges = true;
    });
  }

  void _copyPreviousDay() {
    if (_selectedDayIndex > 0) {
      final previousDay = _trainingPlan!.days[_selectedDayIndex - 1];
      final currentDay = _trainingPlan!.days[_selectedDayIndex];
      
      final copiedParts = previousDay.parts.map((part) => part.copyWith(
        id: 'part_${DateTime.now().millisecondsSinceEpoch}_${part.order}',
        exercises: part.exercises.map((exercise) => exercise.copyWith(
          id: 'exercise_${DateTime.now().millisecondsSinceEpoch}_${exercise.order}',
        )).toList(),
      )).toList();

      setState(() {
        final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
        updatedDays[_selectedDayIndex] = currentDay.copyWith(
          parts: copiedParts,
          isRestDay: copiedParts.isEmpty,
        );
        
        _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        _hasChanges = true;
      });
    }
  }

  void _updatemodels.ExerciseInPlan(models.Exercise oldmodels.Exercise, models.Exercise newmodels.Exercise) {
    final dayIndex = _trainingPlan!.days.indexWhere(
      (day) => day.parts.any((part) => part.exercises.any((e) => e.id == oldmodels.Exercise.id)),
    );
    
    if (dayIndex != -1) {
      final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
      final day = updatedDays[dayIndex];
      final partIndex = day.parts.indexWhere(
        (part) => part.exercises.any((e) => e.id == oldmodels.Exercise.id),
      );
      
      if (partIndex != -1) {
        final updatedParts = List<models.TrainingPart>.from(day.parts);
        final part = updatedParts[partIndex];
        final exerciseIndex = part.exercises.indexWhere((e) => e.id == oldmodels.Exercise.id);
        
        if (exerciseIndex != -1) {
          final updatedmodels.Exercises = List<models.Exercise>.from(part.exercises);
          updatedmodels.Exercises[exerciseIndex] = newmodels.Exercise;
          
          updatedParts[partIndex] = part.copyWith(exercises: updatedmodels.Exercises);
          updatedDays[dayIndex] = day.copyWith(parts: updatedParts);
          _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        }
      }
    }
  }

  Future<String?> _showMuscleGroupSelector() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '选择训练部位',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            ...models.MuscleGroups.groups.entries.map((entry) {
              return ListTile(
                leading: Text(
                  models.MuscleGroups.icons[entry.key]!,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(entry.value),
                onTap: () {
                  Navigator.pop(context, entry.key);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<models.Exercise?> _showmodels.ExerciseEditDialog(models.Exercise exercise) async {
    return showDialog<models.Exercise>(
      context: context,
      builder: (context) => models.ExerciseEditDialog(exercise: exercise),
    );
  }

  Future<Mockmodels.Exercise?> _showmodels.ExerciseSelectionDialog(String muscleGroup) async {
    return showDialog<Mockmodels.Exercise>(
      context: context,
      builder: (context) => models.ExerciseSelectionDialog(muscleGroup: muscleGroup),
    );
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('未保存的更改'),
        content: const Text('您有未保存的更改，是否要保存？'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('不保存'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _savePlan();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      
      if (widget.userId != null) {
        // 使用新API接口保存
        final planData = _convertToApiFormat();
        success = await TrainingPlanSyncService.updateUserTrainingPlan(widget.userId!, planData);
      } else if (widget.planId != null) {
        // 更新现有计划
        success = await TrainingPlanSyncService.updateWeeklyTrainingPlan(
          widget.planId!, 
          _trainingPlan!
        );
      } else {
        // 创建新计划
        success = await TrainingPlanSyncService.saveWeeklyTrainingPlan(_trainingPlan!);
      }
      
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
        throw Exception('保存失败');
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

  /// 转换为API格式
  List<Map<String, dynamic>> _convertToApiFormat() {
    final planData = <Map<String, dynamic>>[];
    
    for (final day in _trainingPlan!.days) {
      final dayData = <String, dynamic>{
        'day': _getEnglishDayName(day.dayName),
        'parts': <Map<String, dynamic>>[],
      };
      
      for (final part in day.parts) {
        final partData = <String, dynamic>{
          'part_name': part.muscleGroupName,
          'exercises': <Map<String, dynamic>>[],
        };
        
        for (final exercise in part.exercises) {
          partData['exercises'].add({
            'name': exercise.name,
            'sets': exercise.sets,
            'reps': exercise.reps,
            'weight': exercise.weight,
            'rest_seconds': exercise.restSeconds,
            'notes': exercise.notes ?? '',
            'description': exercise.description,
          });
        }
        
        dayData['parts'].add(partData);
      }
      
      planData.add(dayData);
    }
    
    return planData;
  }

  /// 获取英文天名
  String _getEnglishDayName(String chineseDayName) {
    final dayMap = {
      '周一': 'Monday',
      '周二': 'Tuesday', 
      '周三': 'Wednesday',
      '周四': 'Thursday',
      '周五': 'Friday',
      '周六': 'Saturday',
      '周日': 'Sunday',
    };
    return dayMap[chineseDayName] ?? 'Monday';
  }

  /// 显示AI推荐对话框
  void _showAIRecommendations() async {
    if (widget.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('需要用户ID才能使用AI推荐功能'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    final currentDay = _trainingPlan!.days[_selectedDayIndex];
    final dayName = _getEnglishDayName(currentDay.dayName);

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
        ),
      ),
    );

    try {
      // 调用新的AI推荐API
      final recommendationData = await TrainingPlanSyncService.getAIRecommendation(
        widget.userId!,
        dayName,
      );

      // 关闭加载对话框
      Navigator.pop(context);

      if (recommendationData != null && recommendationData['parts'] != null) {
        // 显示推荐结果
        _showRecommendationResults(recommendationData);
      } else {
        // 显示无推荐结果
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('暂无推荐动作，请稍后再试'),
            backgroundColor: Color(0xFFF59E0B),
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI推荐失败: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  /// 显示推荐结果
  void _showRecommendationResults(Map<String, dynamic> recommendationData) {
    final parts = recommendationData['parts'] as List;
    final mode = recommendationData['mode'] ?? '三分化';
    final target = recommendationData['target'] ?? '增肌';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI推荐 - $mode',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '目标：$target',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: parts.length,
                itemBuilder: (context, partIndex) {
                  final part = parts[partIndex];
                  final partName = part['part_name'] ?? '';
                  final exercises = part['exercises'] as List;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                models.MuscleGroups.icons[getMuscleGroupKey(partName)] ?? '💪',
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                partName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...exercises.map<Widget>((exercise) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: models.MuscleGroups.colors[getMuscleGroupKey(partName)]?.withOpacity(0.1),
                              child: Text(
                                '${exercise['sets']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),
                            title: Text(
                              exercise['name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            subtitle: Text(
                              '${exercise['sets']}组 × ${exercise['reps']}次 • ${exercise['weight']}kg • 休息${exercise['rest_seconds']}秒',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _addRecommendedmodels.Exercise(exercise, partName);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('添加'),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6B7280),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('关闭'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加推荐的动作到当前训练部位
  void _addRecommendedmodels.Exercise(Map<String, dynamic> exerciseData, String partName) {
    final currentDay = _trainingPlan!.days[_selectedDayIndex];
    final muscleGroupKey = getMuscleGroupKey(partName);
    
    // 查找或创建对应的训练部位
    models.TrainingPart? targetPart;
    for (final part in currentDay.parts) {
      if (part.muscleGroup == muscleGroupKey) {
        targetPart = part;
        break;
      }
    }

    if (targetPart == null) {
      // 创建新的训练部位
      final newPart = models.TrainingPart(
        id: 'part_${DateTime.now().millisecondsSinceEpoch}',
        muscleGroup: muscleGroupKey,
        muscleGroupName: partName,
        exercises: [],
        order: currentDay.parts.length,
      );

      setState(() {
        final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
        updatedDays[_selectedDayIndex] = currentDay.copyWith(
          parts: [...currentDay.parts, newPart],
          isRestDay: false,
        );
        _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
        _hasChanges = true;
      });

      targetPart = newPart;
    }

    // 添加推荐的动作
    final newmodels.Exercise = models.Exercise(
      id: 'exercise_${DateTime.now().millisecondsSinceEpoch}',
      name: exerciseData['name'] ?? '',
      description: exerciseData['description'] ?? '',
      muscleGroup: muscleGroupKey,
      sets: exerciseData['sets'] ?? 3,
      reps: exerciseData['reps'] ?? 12,
      weight: exerciseData['weight']?.toDouble() ?? 0.0,
      restSeconds: exerciseData['rest_seconds'] ?? 60,
      notes: exerciseData['notes'] ?? '',
      order: targetPart.exercises.length,
    );

    setState(() {
      final dayIndex = _trainingPlan!.days.indexWhere(
        (day) => day.parts.any((p) => p.id == targetPart!.id),
      );
      
      if (dayIndex != -1) {
        final updatedDays = List<models.TrainingDay>.from(_trainingPlan!.days);
        final day = updatedDays[dayIndex];
        final partIndex = day.parts.indexWhere((p) => p.id == targetPart!.id);
        
        if (partIndex != -1) {
          final updatedParts = List<models.TrainingPart>.from(day.parts);
          updatedParts[partIndex] = targetPart!.copyWith(
            exercises: [...targetPart!.exercises, newmodels.Exercise],
          );
          
          updatedDays[dayIndex] = day.copyWith(parts: updatedParts);
          _trainingPlan = _trainingPlan!.copyWith(days: updatedDays);
          _hasChanges = true;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已添加 ${newmodels.Exercise.name} 到 $partName'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  /// 获取肌群键值
  String getMuscleGroupKey(String partName) {
    final partMap = {
      'Chest': 'chest',
      'Back': 'back',
      'Legs': 'legs',
      'Shoulders': 'shoulders',
      'Arms': 'arms',
      'Core': 'core',
    };
    return partMap[partName] ?? 'chest';
  }
}
