import 'package:flutter/material.dart';
import '../models/mate_models.dart';
import '../core/theme/gymates_colors.dart';

/// 筛选面板组件
class FilterPanel extends StatefulWidget {
  final MateFilterOptions initialFilters;
  final Function(MateFilterOptions) onApply;
  final VoidCallback? onReset;

  const FilterPanel({
    super.key,
    required this.initialFilters,
    required this.onApply,
    this.onReset,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  late MateFilterOptions _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 顶部拖动条
          _buildDragHandle(),

          // 标题和重置按钮
          _buildHeader(),

          // 筛选选项
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 距离筛选
                  _buildDistanceFilter(),

                  const SizedBox(height: 24),

                  // 性别筛选
                  _buildGenderFilter(),

                  const SizedBox(height: 24),

                  // 经验等级筛选
                  _buildExperienceFilter(),

                  const SizedBox(height: 24),

                  // 健身目标筛选
                  _buildGoalsFilter(),

                  const SizedBox(height: 24),

                  // 训练类型筛选
                  _buildTrainingTypesFilter(),

                  const SizedBox(height: 24),

                  // 偏好时间筛选
                  _buildPreferredTimeFilter(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 底部按钮
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '筛选条件',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _filters = MateFilterOptions();
              });
              widget.onReset?.call();
            },
            child: const Text(
              '重置',
              style: TextStyle(
                color: GyMatesColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '搜索范围',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              _getDistanceLabel(_filters.maxDistance),
              style: TextStyle(
                fontSize: 14,
                color: GyMatesColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: GyMatesColors.primaryGreen,
            inactiveTrackColor: Colors.grey[800],
            thumbColor: GyMatesColors.primaryGreen,
            overlayColor: GyMatesColors.primaryGreen.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _filters.maxDistance.toDouble(),
            min: 1000,
            max: 50000,
            divisions: 49,
            onChanged: (value) {
              setState(() {
                _filters = _filters.copyWith(maxDistance: value.toInt());
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '性别',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildChipOption(
              label: '不限',
              isSelected: _filters.gender == null || _filters.gender!.isEmpty,
              onTap: () {
                setState(() {
                  _filters = _filters.copyWith(gender: '');
                });
              },
            ),
            const SizedBox(width: 8),
            _buildChipOption(
              label: '男',
              isSelected: _filters.gender == 'male',
              onTap: () {
                setState(() {
                  _filters = _filters.copyWith(gender: 'male');
                });
              },
            ),
            const SizedBox(width: 8),
            _buildChipOption(
              label: '女',
              isSelected: _filters.gender == 'female',
              onTap: () {
                setState(() {
                  _filters = _filters.copyWith(gender: 'female');
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExperienceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '经验等级',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChipOption(
              label: '不限',
              isSelected:
                  _filters.experience == null || _filters.experience!.isEmpty,
              onTap: () {
                setState(() {
                  _filters = _filters.copyWith(experience: '');
                });
              },
            ),
            ...ExperienceLevels.all.map(
              (level) => _buildChipOption(
                label: level,
                isSelected: _filters.experience == level,
                onTap: () {
                  setState(() {
                    _filters = _filters.copyWith(experience: level);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalsFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '健身目标',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FitnessGoals.all.map(
            (goal) {
              final isSelected = _filters.goals.contains(goal);
              return _buildChipOption(
                label: goal,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    final goals = List<String>.from(_filters.goals);
                    if (isSelected) {
                      goals.remove(goal);
                    } else {
                      goals.add(goal);
                    }
                    _filters = _filters.copyWith(goals: goals);
                  });
                },
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildTrainingTypesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练类型',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TrainingTypes.all.map(
            (type) {
              final isSelected = _filters.trainingTypes.contains(type);
              return _buildChipOption(
                label: type,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    final types = List<String>.from(_filters.trainingTypes);
                    if (isSelected) {
                      types.remove(type);
                    } else {
                      types.add(type);
                    }
                    _filters = _filters.copyWith(trainingTypes: types);
                  });
                },
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildPreferredTimeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '偏好时间',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChipOption(
              label: '不限',
              isSelected: _filters.preferredTime == null ||
                  _filters.preferredTime!.isEmpty,
              onTap: () {
                setState(() {
                  _filters = _filters.copyWith(preferredTime: '');
                });
              },
            ),
            ...PreferredTimes.all.map(
              (time) => _buildChipOption(
                label: time,
                isSelected: _filters.preferredTime == time,
                onTap: () {
                  setState(() {
                    _filters = _filters.copyWith(preferredTime: time);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChipOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? GyMatesColors.primaryGreen
              : Colors.grey[850],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? GyMatesColors.primaryGreen
                : Colors.grey[700]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[400],
                  side: BorderSide(color: Colors.grey[700]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_filters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GyMatesColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('应用筛选'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDistanceLabel(int meters) {
    if (meters < 1000) {
      return '$meters米';
    } else {
      final km = meters / 1000;
      if (km >= 10) {
        return '${km.toStringAsFixed(0)}公里';
      } else {
        return '${km.toStringAsFixed(1)}公里';
      }
    }
  }
}

