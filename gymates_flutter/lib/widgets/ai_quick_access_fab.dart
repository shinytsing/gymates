import 'package:flutter/material.dart';
import '../core/theme/gymates_colors.dart';
import '../pages/ai_chat_page.dart';
import '../pages/gym_search_page.dart';

/// AI 快速访问浮动按钮
class AIQuickAccessFAB extends StatefulWidget {
  const AIQuickAccessFAB({super.key});

  @override
  State<AIQuickAccessFAB> createState() => _AIQuickAccessFABState();
}

class _AIQuickAccessFABState extends State<AIQuickAccessFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // 背景遮罩
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

        // 按钮组
        Positioned(
          right: 16,
          bottom: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AI 教练按钮
              ScaleTransition(
                scale: _expandAnimation,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: _buildActionButton(
                    icon: Icons.psychology,
                    label: 'AI 教练',
                    color: GyMatesColors.primaryGreen,
                    onTap: () {
                      _toggleExpanded();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AIChatPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // 找健身房按钮
              ScaleTransition(
                scale: _expandAnimation,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: _buildActionButton(
                    icon: Icons.location_on,
                    label: '找健身房',
                    color: Colors.purple,
                    onTap: () {
                      _toggleExpanded();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GymSearchPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),

        // 主按钮
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            backgroundColor: GyMatesColors.primaryGreen,
            onPressed: _toggleExpanded,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: _isExpanded ? 0.125 : 0,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          mini: true,
          backgroundColor: color,
          onPressed: onTap,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

