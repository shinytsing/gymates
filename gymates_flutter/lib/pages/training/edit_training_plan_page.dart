import 'package:flutter/material.dart';
import '../../shared/models/edit_training_plan_models.dart' as models;
import '../../shared/models/mock_data.dart';
import '../../services/training_plan_sync_service.dart';
import 'widgets/exercise_selection_dialog.dart';

class EditTrainingPlanPage extends StatefulWidget {
  final models.EditTrainingPlan? existingPlan;
  final String? planId;
  final int? userId;

  const EditTrainingPlanPage({
    super.key,
    this.existingPlan,
    this.planId,
    this.userId,
  });

  @override
  _EditTrainingPlanPageState createState() => _EditTrainingPlanPageState();
}

class _EditTrainingPlanPageState extends State<EditTrainingPlanPage> {
  late models.EditTrainingPlan _trainingPlan;
  bool _isLoading = false;
  String _cycleTime = 'Week';

  @override
  void initState() {
    super.initState();
    _initializeTrainingPlan();
  }

  void _initializeTrainingPlan() {
    if (widget.existingPlan != null) {
      _trainingPlan = widget.existingPlan!;
    } else {
      _trainingPlan = models.EditTrainingPlan(
        id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
        name: '新训练计划',
        description: '',
        days: _createDefaultDays(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  List<models.TrainingDay> _createDefaultDays() {
    return models.WeekDays.dayNames.asMap().entries.map((entry) {
      final index = entry.key;
      final dayName = entry.value;
      return models.TrainingDay(
        id: 'day_$dayName',
        dayOfWeek: index + 1,
        dayName: dayName,
        parts: [],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('编辑训练计划'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePlan,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPlanInfo(),
                  const SizedBox(height: 24),
                  _buildDaysList(),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: TextEditingController(text: _trainingPlan.name),
            decoration: const InputDecoration(
              labelText: '计划名称',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _trainingPlan = _trainingPlan.copyWith(name: value);
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: _trainingPlan.description ?? ''),
            decoration: const InputDecoration(
              labelText: '计划描述',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _trainingPlan = _trainingPlan.copyWith(description: value);
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _cycleTime,
            decoration: const InputDecoration(
              labelText: '循环时间',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Week', child: Text('周')),
              DropdownMenuItem(value: 'Month', child: Text('月')),
              DropdownMenuItem(value: 'Year', child: Text('年')),
              DropdownMenuItem(value: 'Permanent', child: Text('永久')),
            ],
            onChanged: (value) {
              setState(() {
                _cycleTime = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaysList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练安排',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ..._trainingPlan.days.map((day) => _buildDayCard(day)),
      ],
    );
  }

  Widget _buildDayCard(models.TrainingDay day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Text(
                  day.dayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _addTrainingPart(day),
                  icon: const Icon(Icons.add, color: Colors.blue),
                  tooltip: '添加训练部位',
                ),
              ],
            ),
          ),
          if (day.parts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: const Center(
                child: Text(
                  '暂无训练安排',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...day.parts.map((part) => _buildPartCard(part, day)),
        ],
      ),
    );
  }

  Widget _buildPartCard(models.TrainingPart part, models.TrainingDay day) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                part.muscleGroupName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _addExerciseToPart(part),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                tooltip: '添加动作',
              ),
              IconButton(
                onPressed: () => _deletePart(part, day),
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                tooltip: '删除部位',
              ),
            ],
          ),
          if (part.exercises.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '暂无动作',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...part.exercises.map((exercise) => _buildExerciseCard(exercise, part)),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(models.Exercise exercise, models.TrainingPart part) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${exercise.sets}组 x ${exercise.reps}次',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editExercise(exercise),
            icon: const Icon(Icons.edit, size: 18),
            tooltip: '编辑动作',
          ),
          IconButton(
            onPressed: () => _deleteExercise(part, exercise),
            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
            tooltip: '删除动作',
          ),
        ],
      ),
    );
  }

  void _addTrainingPart(models.TrainingDay day) async {
    final muscleGroup = await _showMuscleGroupSelection();
    if (muscleGroup != null) {
      final newPart = models.TrainingPart(
        id: 'part_${DateTime.now().millisecondsSinceEpoch}',
        muscleGroup: muscleGroup,
        muscleGroupName: models.MuscleGroups.groups[muscleGroup]!,
        exercises: [],
        order: day.parts.length,
      );

      setState(() {
        final updatedDays = _trainingPlan.days.map((d) {
          if (d.id == day.id) {
            return d.copyWith(parts: [...d.parts, newPart]);
          }
          return d;
        }).toList();
        _trainingPlan = _trainingPlan.copyWith(days: updatedDays);
      });
    }
  }

  void _addExerciseToPart(models.TrainingPart part) async {
    final exercise = await _showExerciseSelectionDialog(part.muscleGroup);
    if (exercise != null) {
      final newExercise = models.Exercise(
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

      setState(() {
        final updatedDays = _trainingPlan.days.map((day) {
          final updatedParts = day.parts.map((p) {
            if (p.id == part.id) {
              return p.copyWith(exercises: [...p.exercises, newExercise]);
            }
            return p;
          }).toList();
          return day.copyWith(parts: updatedParts);
        }).toList();
        _trainingPlan = _trainingPlan.copyWith(days: updatedDays);
      });
    }
  }

  void _editExercise(models.Exercise exercise) async {
    // 简单的编辑对话框
    final controller = TextEditingController(text: exercise.name);
    final setsController = TextEditingController(text: exercise.sets.toString());
    final repsController = TextEditingController(text: exercise.reps.toString());

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑动作'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: '动作名称'),
            ),
            TextField(
              controller: setsController,
              decoration: const InputDecoration(labelText: '组数'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(labelText: '次数'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, {
              'name': controller.text,
              'sets': int.tryParse(setsController.text) ?? exercise.sets,
              'reps': int.tryParse(repsController.text) ?? exercise.reps,
            }),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        final updatedDays = _trainingPlan.days.map((day) {
          final updatedParts = day.parts.map((part) {
            final updatedExercises = part.exercises.map((e) {
              if (e.id == exercise.id) {
                return e.copyWith(
                  name: result['name'],
                  sets: result['sets'],
                  reps: result['reps'],
                );
              }
              return e;
            }).toList();
            return part.copyWith(exercises: updatedExercises);
          }).toList();
          return day.copyWith(parts: updatedParts);
        }).toList();
        _trainingPlan = _trainingPlan.copyWith(days: updatedDays);
      });
    }
  }

  void _deleteExercise(models.TrainingPart part, models.Exercise exercise) {
    setState(() {
      final updatedDays = _trainingPlan.days.map((day) {
        final updatedParts = day.parts.map((p) {
          if (p.id == part.id) {
            return p.copyWith(
              exercises: p.exercises.where((e) => e.id != exercise.id).toList(),
            );
          }
          return p;
        }).toList();
        return day.copyWith(parts: updatedParts);
      }).toList();
      _trainingPlan = _trainingPlan.copyWith(days: updatedDays);
    });
  }

  void _deletePart(models.TrainingPart part, models.TrainingDay day) {
    setState(() {
      final updatedDays = _trainingPlan.days.map((d) {
        if (d.id == day.id) {
          return d.copyWith(
            parts: d.parts.where((p) => p.id != part.id).toList(),
          );
        }
        return d;
      }).toList();
      _trainingPlan = _trainingPlan.copyWith(days: updatedDays);
    });
  }

  Future<String?> _showMuscleGroupSelection() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择训练部位'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: models.MuscleGroups.groups.entries.map((entry) {
            return ListTile(
              leading: Text(models.MuscleGroups.icons[entry.key]!),
              title: Text(entry.value),
              onTap: () => Navigator.pop(context, entry.key),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<MockExercise?> _showExerciseSelectionDialog(String muscleGroup) async {
    return showDialog<MockExercise>(
      context: context,
      builder: (context) => ExerciseSelectionDialog(
        muscleGroup: muscleGroup,
        onExerciseSelected: (exercise) {
          Navigator.pop(context, exercise);
        },
      ),
    );
  }

  void _savePlan() async {
    if (_trainingPlan.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入计划名称')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final planData = _convertToWeeklyPlanFormat();
      final success = await TrainingPlanSyncService.saveTrainingPlan(planData);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _convertToWeeklyPlanFormat() {
    return {
      'name': _trainingPlan.name,
      'description': _trainingPlan.description ?? '',
      'cycle_time': _cycleTime,
      'days': _trainingPlan.days.map((day) => {
        'day': _getEnglishDayName(day.dayName),
        'parts': day.parts.map((part) => {
          'muscle_group': part.muscleGroup,
          'muscle_group_name': part.muscleGroupName,
          'exercises': part.exercises.map((exercise) => {
            'name': exercise.name,
            'description': exercise.description,
            'muscle_group': exercise.muscleGroup,
            'sets': exercise.sets,
            'reps': exercise.reps,
            'weight': exercise.weight,
            'rest_seconds': exercise.restSeconds,
            'notes': exercise.notes,
          }).toList(),
        }).toList(),
      }).toList(),
    };
  }

  String _getEnglishDayName(String chineseDayName) {
    const dayMap = {
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
}
