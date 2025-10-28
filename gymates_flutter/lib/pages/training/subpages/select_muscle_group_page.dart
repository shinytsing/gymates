import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';
import 'select_workout_page.dart';

/// 💪 选择训练部位页面 - SelectMuscleGroupPage
/// 
/// 允许用户按肌群筛选训练动作

class SelectMuscleGroupPage extends StatefulWidget {
  const SelectMuscleGroupPage({super.key});

  @override
  State<SelectMuscleGroupPage> createState() => _SelectMuscleGroupPageState();
}

class _SelectMuscleGroupPageState extends State<SelectMuscleGroupPage> {
  String? _selectedMuscleGroup;
  
  final List<_MuscleGroup> _muscleGroups = [
    const _MuscleGroup(name: '胸部', icon: Icons.accessibility_new, color: Colors.blue),
    const _MuscleGroup(name: '背部', icon: Icons.wb_sunny, color: Colors.orange),
    const _MuscleGroup(name: '肩部', icon: Icons.scatter_plot, color: Colors.purple),
    const _MuscleGroup(name: '手臂', icon: Icons.schedule, color: Colors.red),
    const _MuscleGroup(name: '腿部', icon: Icons.directions_walk, color: Colors.green),
    const _MuscleGroup(name: '核心', icon: Icons.center_focus_strong, color: Colors.pink),
    const _MuscleGroup(name: '有氧', icon: Icons.directions_run, color: Colors.teal),
    const _MuscleGroup(name: '全身', icon: Icons.apps, color: Colors.indigo),
  ];

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
          '选择训练部位',
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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _muscleGroups.length,
              itemBuilder: (context, index) {
                return _buildMuscleGroupCard(_muscleGroups[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
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
  
  Widget _buildMuscleGroupCard(_MuscleGroup group) {
    final isSelected = _selectedMuscleGroup == group.name;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedMuscleGroup = group.name;
        });
        
        // 导航到动作选择页面
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SelectWorkoutPage(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? group.color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? group.color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? null : GymatesTheme.getCardShadow(false),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: group.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                group.icon,
                color: group.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              group.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? group.color : GymatesTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleGroup {
  final String name;
  final IconData icon;
  final Color color;

  const _MuscleGroup({
    required this.name,
    required this.icon,
    required this.color,
  });
}

