import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/3d_components/index.dart';
import '../pages/today_page_3d.dart';

/// 📋 Apple Fitness+ Style Training Plan Detail Page
class TrainingPlan3DDetailPage extends StatefulWidget {
  final String planId;
  final List<TodayExercise> exercises;

  const TrainingPlan3DDetailPage({
    super.key,
    required this.planId,
    required this.exercises,
  });

  @override
  State<TrainingPlan3DDetailPage> createState() => _TrainingPlan3DDetailPageState();
}

class _TrainingPlan3DDetailPageState extends State<TrainingPlan3DDetailPage> {
  late List<TodayExercise> _exercises;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.exercises);
  }

  Future<void> _savePlan() async {
    HapticFeedback.mediumImpact();
    try {
      // TODO: Save plan to backend
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('计划已保存'),
              ],
            ),
            backgroundColor: AppleFitnessTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppleFitnessTheme.radiusMedium,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text('保存失败: $e')),
              ],
            ),
            backgroundColor: AppleFitnessTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppleFitnessTheme.radiusMedium,
            ),
          ),
        );
      }
    }
  }

  void _editExercise(int index) {
    HapticFeedback.lightImpact();
    final exercise = _exercises[index];
    showModal3D(
      context: context,
      child: _buildEditExerciseSheet(exercise, index),
    );
  }

  Widget _buildEditExerciseSheet(TodayExercise exercise, int index) {
    int sets = exercise.sets;
    int reps = exercise.reps;
    int restSeconds = 60; // Default rest seconds

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
          decoration: BoxDecoration(
            color: AppleFitnessTheme.backgroundPrimary,
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingL),
                decoration: BoxDecoration(
                  color: AppleFitnessTheme.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                '编辑动作',
                style: AppleFitnessTheme.titleLarge,
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              Card3D(
                useFrostedGlass: true,
                child: Column(
                  children: [
                    ListTile(
                      title: Text('组数', style: AppleFitnessTheme.bodyMedium),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setModalState(() {
                                if (sets > 1) sets--;
                              });
                            },
                          ),
                          Text(
                            '$sets',
                            style: AppleFitnessTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setModalState(() => sets++);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: AppleFitnessTheme.spacingL),
                    ListTile(
                      title: Text('次数', style: AppleFitnessTheme.bodyMedium),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setModalState(() {
                                if (reps > 1) reps--;
                              });
                            },
                          ),
                          Text(
                            '$reps',
                            style: AppleFitnessTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setModalState(() => reps++);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(height: AppleFitnessTheme.spacingL),
                    ListTile(
                      title: Text('休息时间', style: AppleFitnessTheme.bodyMedium),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setModalState(() {
                                if (restSeconds > 0) restSeconds -= 10;
                              });
                            },
                          ),
                          Text(
                            '$restSeconds秒',
                            style: AppleFitnessTheme.titleMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setModalState(() => restSeconds += 10);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              Row(
                children: [
                  Expanded(
                    child: Button3D.outline(
                      text: '取消',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  SizedBox(width: AppleFitnessTheme.spacingM),
                  Expanded(
                    child: Button3D.primary(
                      text: '保存',
                      onPressed: () {
                        setState(() {
                          _exercises[index] = TodayExercise(
                            name: exercise.name,
                            sets: sets,
                            reps: reps,
                            muscleGroup: exercise.muscleGroup,
                          );
                          _hasChanges = true;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  void _deleteExercise(int index) {
    HapticFeedback.mediumImpact();
    showAlertDialog3D(
      context: context,
      title: '确认删除',
      message: '确定要删除 ${_exercises[index].name} 吗？',
      confirmText: '删除',
      cancelText: '取消',
      onConfirm: () {
        setState(() {
          _exercises.removeAt(index);
          _hasChanges = true;
        });
      },
    );
  }

  void _addExercise() {
    HapticFeedback.lightImpact();
    // TODO: Navigate to exercise library
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('请从动作库选择动作'),
        backgroundColor: AppleFitnessTheme.primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasChanges) {
              showAlertDialog3D(
                context: context,
                title: '未保存的更改',
                message: '您有未保存的更改，确定要离开吗？',
                confirmText: '离开',
                cancelText: '取消',
                onConfirm: () => Navigator.pop(context),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          '训练计划',
          style: AppleFitnessTheme.titleLarge,
        ),
        actions: [
          if (_hasChanges)
            Padding(
              padding: EdgeInsets.only(right: AppleFitnessTheme.spacingM),
              child: Button3D.primary(
                text: '保存',
                icon: Icons.save,
                onPressed: _savePlan,
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _savePlan,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: _exercises.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        return StaggeredAnimation3D(
                          index: index,
                          child: _buildExerciseCard(_exercises[index], index),
                        );
                      },
                    ),
            ),
            if (_exercises.isNotEmpty)
              Container(
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
                  child: Button3D.outline(
                    text: '添加动作',
                    icon: Icons.add,
                    onPressed: _addExercise,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppleFitnessTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              '计划为空',
              style: AppleFitnessTheme.headlineSmall,
            ),
            SizedBox(height: AppleFitnessTheme.spacingS),
            Text(
              '添加动作开始训练',
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingXL),
            Button3D.primary(
              text: '添加动作',
              icon: Icons.add,
              onPressed: _addExercise,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(TodayExercise exercise, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppleFitnessTheme.spacingM),
      child: Card3D(
        useFrostedGlass: true,
        onTap: () {
          // TODO: Navigate to exercise detail
        },
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppleFitnessTheme.primaryGradient,
                borderRadius: AppleFitnessTheme.radiusSmall,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppleFitnessTheme.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppleFitnessTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: AppleFitnessTheme.titleMedium,
                  ),
                  SizedBox(height: AppleFitnessTheme.spacingXS),
                  Text(
                    '${exercise.sets}组 × ${exercise.reps}次',
                    style: AppleFitnessTheme.bodySmall.copyWith(
                      color: AppleFitnessTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit, color: AppleFitnessTheme.primaryBlue),
              onPressed: () => _editExercise(index),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppleFitnessTheme.error),
              onPressed: () => _deleteExercise(index),
            ),
          ],
        ),
      ),
    );
  }
}

