import 'package:flutter/material.dart';
import 'package:gymates_flutter/core/theme/gymates_theme.dart';

/// 🚀 快捷操作区域 - QuickActionSection
/// 
/// 提供快速入口：一键开始、我的计划、最近训练、自定义训练

class QuickActionSection extends StatelessWidget {
  final Function(String) onActionTap;
  
  const QuickActionSection({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快捷操作',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GymatesTheme.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildActionGrid(context),
      ],
    );
  }
  
  Widget _buildActionGrid(BuildContext context) {
    final actions = [
      _ActionItem(
        title: '一键开始',
        subtitle: '快速开始训练',
        icon: Icons.bolt,
        color: Colors.blue,
        onTap: () => onActionTap('quick_start'),
      ),
      _ActionItem(
        title: '我的计划',
        subtitle: '查看训练计划',
        icon: Icons.calendar_today,
        color: Colors.purple,
        onTap: () => onActionTap('my_plan'),
      ),
      _ActionItem(
        title: '最近训练',
        subtitle: '查看训练记录',
        icon: Icons.history,
        color: Colors.green,
        onTap: () => onActionTap('recent'),
      ),
      _ActionItem(
        title: '自定义训练',
        subtitle: '选择部位动作',
        icon: Icons.tune,
        color: Colors.orange,
        onTap: () => onActionTap('custom'),
      ),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) => _buildActionCard(actions[index]),
    );
  }
  
  Widget _buildActionCard(_ActionItem action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: GymatesTheme.getCardShadow(false),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: GymatesTheme.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: GymatesTheme.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

