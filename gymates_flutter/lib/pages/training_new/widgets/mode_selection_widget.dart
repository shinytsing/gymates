import 'package:flutter/material.dart';

/// 模式选择组件（普通模式 vs AI教练模式）
class ModeSelectionWidget extends StatelessWidget {
  final bool isAIMode;
  final ValueChanged<bool> onModeChange;

  const ModeSelectionWidget({
    super.key,
    required this.isAIMode,
    required this.onModeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              icon: Icons.fitness_center,
              label: '普通模式',
              isSelected: !isAIMode,
              onTap: () => onModeChange(false),
            ),
          ),
          Expanded(
            child: _buildModeButton(
              icon: Icons.auto_awesome,
              label: 'AI教练',
              isSelected: isAIMode,
              onTap: () => onModeChange(true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Colors.white
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

