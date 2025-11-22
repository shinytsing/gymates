import 'package:flutter/material.dart';
import '../../../shared/models/edit_training_plan_models.dart';
import '../../../services/exercise_api_service.dart';

/// 🏋️‍♀️ 动作选择对话框 - ExerciseSelectionDialog
/// 
/// 根据身体部位选择训练动作
class ExerciseSelectionDialog extends StatefulWidget {
  final String muscleGroup;
  final Function(Exercise) onExerciseSelected;

  const ExerciseSelectionDialog({
    super.key,
    required this.muscleGroup,
    required this.onExerciseSelected,
  });

  @override
  State<ExerciseSelectionDialog> createState() => _ExerciseSelectionDialogState();
}

class _ExerciseSelectionDialogState extends State<ExerciseSelectionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedDifficulty = 'all';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadExercises();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await ExerciseApiService.searchExercisesByMuscleGroup(widget.muscleGroup);
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载动作失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredExercises {
    return _exercises.where((exercise) {
      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final name = exercise['name']?.toString().toLowerCase() ?? '';
        if (!name.contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      // 难度过滤
      if (_selectedDifficulty != 'all') {
        final difficulty = exercise['difficulty']?.toString() ?? '';
        if (difficulty != _selectedDifficulty) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  String _getMuscleGroupName(String muscleGroup) {
    switch (muscleGroup) {
      case 'chest': return '胸部';
      case 'back': return '背部';
      case 'legs': return '腿部';
      case 'shoulders': return '肩部';
      case 'arms': return '手臂';
      case 'core': return '核心';
      default: return muscleGroup;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner': return Colors.green;
      case 'intermediate': return Colors.orange;
      case 'advanced': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getDifficultyName(String difficulty) {
    switch (difficulty) {
      case 'beginner': return '初级';
      case 'intermediate': return '中级';
      case 'advanced': return '高级';
      default: return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '选择${_getMuscleGroupName(widget.muscleGroup)}动作',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        Text(
                          '共 ${_exercises.length} 个动作可选',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 搜索和过滤栏
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 搜索框
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '搜索动作名称...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 难度过滤
                  Row(
                    children: [
                      Text(
                        '难度: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildDifficultyChip('all', '全部'),
                              const SizedBox(width: 8),
                              _buildDifficultyChip('beginner', '初级'),
                              const SizedBox(width: 8),
                              _buildDifficultyChip('intermediate', '中级'),
                              const SizedBox(width: 8),
                              _buildDifficultyChip('advanced', '高级'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // 动作列表
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filteredExercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '没有找到匹配的动作',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredExercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _filteredExercises[index];
                            return _buildExerciseCard(exercise);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty, String label) {
    final isSelected = _selectedDifficulty == difficulty;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade100 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final name = exercise['name']?.toString() ?? '';
    final description = exercise['description']?.toString() ?? '';
    final difficulty = exercise['difficulty']?.toString() ?? 'intermediate';
    final equipment = exercise['equipment']?.toString() ?? '';
    final sets = exercise['sets'] ?? 3;
    final reps = exercise['reps'] ?? 10;
    final weight = exercise['weight'] ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 创建Exercise对象
            final selectedExercise = Exercise(
              id: exercise['id']?.toString() ?? '',
              name: name,
              description: description,
              muscleGroup: widget.muscleGroup,
              sets: sets,
              reps: reps,
              weight: weight.toDouble(),
              restSeconds: exercise['rest_seconds'] ?? 90,
              notes: exercise['notes']?.toString(),
              isCompleted: false,
              completedAt: null,
              order: 0,
            );
            
            widget.onExerciseSelected(selectedExercise);
            Navigator.of(context).pop();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 动作图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: _getDifficultyColor(difficulty),
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
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // 难度标签
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(difficulty).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getDifficultyName(difficulty),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getDifficultyColor(difficulty),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 器械标签
                          if (equipment.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                equipment,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // 组数次数
                          Text(
                            '$sets组 × $reps次',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 选择按钮
                Icon(
                  Icons.add_circle_outline,
                  color: Colors.blue.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
