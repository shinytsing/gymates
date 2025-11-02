import 'package:flutter/material.dart';
import '../models/mate_models.dart';
import '../core/theme/gymates_colors.dart';

/// 搭子卡片组件
class PartnerCard extends StatefulWidget {
  final MateProfile mate;
  final VoidCallback? onLike;
  final VoidCallback? onPass;
  final VoidCallback? onMessage;
  final VoidCallback? onTap;

  const PartnerCard({
    super.key,
    required this.mate,
    this.onLike,
    this.onPass,
    this.onMessage,
    this.onTap,
  });

  @override
  State<PartnerCard> createState() => _PartnerCardState();
}

class _PartnerCardState extends State<PartnerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey[800]!,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头像和基本信息
              _buildHeader(),

              // 个人简介
              if (widget.mate.bio != null && widget.mate.bio!.isNotEmpty)
                _buildBio(),

              // 标签
              _buildTags(),

              // 匹配信息
              _buildMatchInfo(),

              // 操作按钮
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 头像
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getMatchScoreColor(),
                width: 3,
              ),
              image: widget.mate.avatar != null
                  ? DecorationImage(
                      image: NetworkImage(widget.mate.avatar!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.mate.avatar == null
                ? Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey[600],
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // 基本信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 名字和在线状态
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.mate.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.mate.isOnline) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                // 年龄、性别、经验
                Row(
                  children: [
                    if (widget.mate.age != null) ...[
                      Icon(Icons.cake, color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.mate.age}岁',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.mate.gender != null) ...[
                      Icon(
                        widget.mate.gender == 'male' ? Icons.male : Icons.female,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.mate.gender == 'male' ? '男' : '女',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (widget.mate.experience != null) ...[
                      Icon(Icons.fitness_center,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.mate.experience!,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                // 位置和距离
                if (widget.mate.location != null) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.grey[600], size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.mate.location!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: GyMatesColors.primaryGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.mate.formattedDistance,
                          style: const TextStyle(
                            color: GyMatesColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // 匹配度标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getMatchScoreColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '${widget.mate.matchScore}%',
                  style: TextStyle(
                    color: _getMatchScoreColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '匹配',
                  style: TextStyle(
                    color: _getMatchScoreColor(),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBio() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.mate.bio!,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 14,
          height: 1.5,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTags() {
    final tags = <String>[];

    if (widget.mate.goal != null) tags.add(widget.mate.goal!);
    if (widget.mate.trainingTypes != null) {
      tags.addAll(widget.mate.trainingTypes!.take(2));
    }
    if (widget.mate.preferredTime != null) tags.add(widget.mate.preferredTime!);

    if (tags.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) => _buildTag(tag)).toList(),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMatchInfo() {
    final hasCommonInfo =
        widget.mate.commonGoals.isNotEmpty || widget.mate.commonTypes.isNotEmpty;

    if (!hasCommonInfo) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.mate.commonGoals.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.flag, color: GyMatesColors.primaryGreen, size: 16),
                const SizedBox(width: 8),
                Text(
                  '共同目标: ${widget.mate.commonGoals.join(', ')}',
                  style: const TextStyle(
                    color: GyMatesColors.primaryGreen,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          if (widget.mate.commonTypes.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.fitness_center,
                    color: GyMatesColors.primaryGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '共同训练: ${widget.mate.commonTypes.join(', ')}',
                    style: const TextStyle(
                      color: GyMatesColors.primaryGreen,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 跳过按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onPass,
              icon: const Icon(Icons.close, size: 20),
              label: const Text('跳过'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[400],
                side: BorderSide(color: Colors.grey[700]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 发消息按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onMessage,
              icon: const Icon(Icons.message_outlined, size: 20),
              label: const Text('消息'),
              style: OutlinedButton.styleFrom(
                foregroundColor: GyMatesColors.primaryGreen,
                side: const BorderSide(color: GyMatesColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 喜欢按钮
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onLike,
              icon: const Icon(Icons.favorite, size: 20),
              label: const Text('喜欢'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GyMatesColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchScoreColor() {
    if (widget.mate.matchScore >= 80) {
      return const Color(0xFF4CAF50); // 绿色
    } else if (widget.mate.matchScore >= 60) {
      return const Color(0xFF8BC34A); // 浅绿色
    } else if (widget.mate.matchScore >= 40) {
      return const Color(0xFFFFC107); // 黄色
    }
    return Colors.grey; // 灰色
  }
}

