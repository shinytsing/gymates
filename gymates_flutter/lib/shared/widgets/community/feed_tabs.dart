import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';

/// 🔖 FeedTabs - 社区内容流顶部Tab导航组件
/// 
/// 功能：
/// - 三个Tab：推荐 / 附近动态 / 健身房活动
/// - 支持切换动画和触觉反馈
/// - Glassmorphism 设计风格
class FeedTabs extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChange;

  const FeedTabs({
    super.key,
    required this.activeTab,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'recommend', 'label': '推荐', 'icon': Icons.explore_outlined},
      {'id': 'nearby', 'label': '附近动态', 'icon': Icons.location_on_outlined},
      {'id': 'gym', 'label': '健身房活动', 'icon': Icons.fitness_center_outlined},
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF6F7FB), Color(0xFFEAEAEA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(GymatesTheme.radius16),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = activeTab == tab['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onTabChange(tab['id'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? GymatesTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(GymatesTheme.radius12),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: GymatesTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : GymatesTheme.lightTextSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        tab['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : GymatesTheme.lightTextSecondary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

