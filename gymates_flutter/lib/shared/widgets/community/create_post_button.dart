import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/gymates_theme.dart';

/// ➕ CreatePostButton - 浮动发帖按钮组件
/// 
/// 功能：
/// - 点击展开发帖选项（图片/视频/文字）
/// - 现代化悬浮按钮设计
/// - 支持动画展开
class CreatePostButton extends StatefulWidget {
  final Function(String type) onCreatePost;

  const CreatePostButton({
    super.key,
    required this.onCreatePost,
  });

  @override
  State<CreatePostButton> createState() => _CreatePostButtonState();
}

class _CreatePostButtonState extends State<CreatePostButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45度旋转 (45/360 = 0.125)
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleCreatePost(String type) {
    HapticFeedback.lightImpact();
    _toggleExpanded();
    widget.onCreatePost(type);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // 遮罩层
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),

        // 选项按钮
        Positioned(
          right: 16,
          bottom: 80,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOptionButton(
                  icon: Icons.videocam_outlined,
                  label: '视频',
                  color: const Color(0xFFEF4444),
                  onTap: () => _handleCreatePost('video'),
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  icon: Icons.image_outlined,
                  label: '图片',
                  color: const Color(0xFF3B82F6),
                  onTap: () => _handleCreatePost('image'),
                ),
                const SizedBox(height: 12),
                _buildOptionButton(
                  icon: Icons.edit_outlined,
                  label: '文字',
                  color: const Color(0xFF10B981),
                  onTap: () => _handleCreatePost('text'),
                ),
              ],
            ),
          ),
        ),

        // 主按钮
        Positioned(
          right: 16,
          bottom: 16,
          child: GestureDetector(
            onTap: _toggleExpanded,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GymatesTheme.primaryColor,
                          GymatesTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GymatesTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

