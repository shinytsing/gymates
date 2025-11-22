import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import '../../../services/training_plan_sync_service.dart';

/// 🎯 选择训练动作页面 - SelectWorkoutPage
/// 
/// 允许用户浏览和选择训练动作，创建自定义训练计划

class SelectWorkoutPage extends StatefulWidget {
  const SelectWorkoutPage({super.key});

  @override
  State<SelectWorkoutPage> createState() => _SelectWorkoutPageState();
}

class _SelectWorkoutPageState extends State<SelectWorkoutPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allExercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  String _selectedMuscleGroup = '全部';
  bool _isLoading = true;
  
  final List<String> _muscleGroups = [
    '全部',
    '胸部',
    '背部',
    '肩部',
    '手臂',
    '腿部',
    '核心',
    '有氧',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(_filterExercises);
  }
  
  @override
  void dispose() {
    _searchController.removeListener(_filterExercises);
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    
    try {
      final exercises = await TrainingPlanSyncService.getExercises();
      setState(() {
        _allExercises = exercises;
        _filteredExercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ 加载动作失败: $e');
      setState(() => _isLoading = false);
    }
  }
  
  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        final matchesSearch = query.isEmpty || 
            exercise['name']?.toString().toLowerCase().contains(query) == true;
        
        final matchesMuscleGroup = _selectedMuscleGroup == '全部' ||
            exercise['muscleGroup']?.toString() == _selectedMuscleGroup;
        
        return matchesSearch && matchesMuscleGroup;
      }).toList();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: GymatesTheme.lightTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '选择训练动作',
          style: TextStyle(
            color: GymatesTheme.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildMuscleGroupFilters(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(child: _buildExerciseList()),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索动作...',
          prefixIcon: Icon(Icons.search, color: GymatesTheme.lightTextSecondary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
  
  Widget _buildMuscleGroupFilters() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _muscleGroups.length,
        itemBuilder: (context, index) {
          final muscleGroup = _muscleGroups[index];
          final isSelected = _selectedMuscleGroup == muscleGroup;
          
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedMuscleGroup = muscleGroup;
                _filterExercises();
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? GymatesTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? GymatesTheme.primaryColor : const Color(0xFFE5E7EB),
                ),
              ),
              child: Center(
                child: Text(
                  muscleGroup,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : GymatesTheme.lightTextPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildExerciseList() {
    if (_filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: GymatesTheme.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              '未找到匹配的动作',
              style: TextStyle(
                fontSize: 16,
                color: GymatesTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }
  
  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: GymatesTheme.getCardShadow(false),
      ),
      child: InkWell(
        onTap: () => _selectExercise(exercise),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  exercise['imageUrl'] ?? 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: GymatesTheme.primaryColor.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.fitness_center,
                        color: GymatesTheme.primaryColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['name'] ?? '未知动作',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise['muscleGroup'] ?? '全身',
                      style: const TextStyle(
                        fontSize: 13,
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.add_circle_outline,
                color: GymatesTheme.primaryColor,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _selectExercise(Map<String, dynamic> exercise) {
    HapticFeedback.lightImpact();
    
    // 显示动作详情对话框
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildExerciseDetailSheet(exercise),
    );
  }
  
  Widget _buildExerciseDetailSheet(Map<String, dynamic> exercise) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  exercise['imageUrl'] ?? 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=100',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['name'] ?? '未知动作',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GymatesTheme.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise['muscleGroup'] ?? '全身',
                      style: const TextStyle(
                        fontSize: 14,
                        color: GymatesTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '训练参数',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildExerciseParameter('组数', '3组'),
          _buildExerciseParameter('次数', '12次'),
          _buildExerciseParameter('休息', '60秒'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: 添加到今日训练计划
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GymatesTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '添加到训练计划',
                style: TextStyle(
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
  
  Widget _buildExerciseParameter(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: GymatesTheme.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: GymatesTheme.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

