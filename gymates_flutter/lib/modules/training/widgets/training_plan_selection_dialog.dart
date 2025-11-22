import 'package:flutter/material.dart';
import '../../../services/training_plan_sync_service.dart';

/// 🏋️‍♀️ 训练计划选择对话框
/// 
/// 允许用户选择要编辑的训练计划
class TrainingPlanSelectionDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onPlanSelected;

  const TrainingPlanSelectionDialog({
    super.key,
    required this.onPlanSelected,
  });

  @override
  State<TrainingPlanSelectionDialog> createState() => _TrainingPlanSelectionDialogState();
}

class _TrainingPlanSelectionDialogState extends State<TrainingPlanSelectionDialog> {
  List<Map<String, dynamic>> _plans = [];
  bool _isLoading = true;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _loadTrainingPlans();
  }

  Future<void> _loadTrainingPlans() async {
    try {
      final plans = await TrainingPlanSyncService.getUserTrainingPlans();
      setState(() {
        _plans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载训练计划失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                const Icon(
                  Icons.fitness_center,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  '选择训练计划',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // 加载状态
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
              )
            else if (_plans.isEmpty)
              _buildEmptyState()
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _plans.length,
                  itemBuilder: (context, index) {
                    final plan = _plans[index];
                    final isSelected = _selectedPlanId == plan['id']?.toString();
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPlanId = plan['id']?.toString();
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF6366F1)
                                    : const Color(0xFFE5E7EB),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // 选择指示器
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected 
                                          ? const Color(0xFF6366F1)
                                          : const Color(0xFFD1D5DB),
                                      width: 2,
                                    ),
                                    color: isSelected 
                                        ? const Color(0xFF6366F1)
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 12,
                                        )
                                      : null,
                                ),
                                
                                const SizedBox(width: 16),
                                
                                // 计划信息
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan['name'] ?? '未命名训练计划',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected 
                                              ? const Color(0xFF6366F1)
                                              : const Color(0xFF1F2937),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 4),
                                      
                                      Text(
                                        plan['description'] ?? '暂无描述',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected 
                                              ? const Color(0xFF6366F1).withValues(alpha: 0.8)
                                              : const Color(0xFF6B7280),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // 计划统计
                                      Row(
                                        children: [
                                          _buildPlanStat(
                                            Icons.calendar_today,
                                            '${_getDaysCount(plan)} 天',
                                          ),
                                          const SizedBox(width: 16),
                                          _buildPlanStat(
                                            Icons.fitness_center,
                                            '${_getExercisesCount(plan)} 动作',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 编辑按钮
                                IconButton(
                                  onPressed: () {
                                    widget.onPlanSelected(plan);
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 20),
            
            // 底部按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '取消',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedPlanId != null
                        ? () {
                            final selectedPlan = _plans.firstWhere(
                              (plan) => plan['id']?.toString() == _selectedPlanId,
                            );
                            widget.onPlanSelected(selectedPlan);
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '编辑计划',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无训练计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先创建一个训练计划',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  int _getDaysCount(Map<String, dynamic> plan) {
    if (plan['days'] != null) {
      final days = plan['days'] as List?;
      return days?.length ?? 0;
    }
    return 0;
  }

  int _getExercisesCount(Map<String, dynamic> plan) {
    int count = 0;
    if (plan['days'] != null) {
      final days = plan['days'] as List?;
      if (days != null) {
        for (final day in days) {
          if (day is Map<String, dynamic> && day['parts'] != null) {
            final parts = day['parts'] as List?;
            if (parts != null) {
              for (final part in parts) {
                if (part is Map<String, dynamic> && part['exercises'] != null) {
                  final exercises = part['exercises'] as List?;
                  count += exercises?.length ?? 0;
                }
              }
            }
          }
        }
      }
    }
    return count;
  }
}
