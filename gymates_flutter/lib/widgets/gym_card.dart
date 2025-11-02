import 'package:flutter/material.dart';
import '../models/gym_models.dart';
import '../core/theme/gymates_colors.dart';

/// 健身房卡片组件
class GymCard extends StatelessWidget {
  final Gym gym;
  final VoidCallback? onNavigate;
  final VoidCallback? onCall;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;
  final bool isFavorite;

  const GymCard({
    super.key,
    required this.gym,
    this.onNavigate,
    this.onCall,
    this.onFavorite,
    this.onTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：名称、距离、收藏
            _buildHeader(),

            const SizedBox(height: 12),

            // 地址
            _buildAddress(),

            // 评分和标签
            if (gym.rating != null || (gym.tags != null && gym.tags!.isNotEmpty))
              _buildRatingAndTags(),

            // 电话
            if (gym.phone != null && gym.phone!.isNotEmpty) _buildPhone(),

            // 营业时间
            if (gym.openHours != null && gym.openHours!.isNotEmpty)
              _buildOpenHours(),

            const SizedBox(height: 16),

            // 操作按钮
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // 健身房图标
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: GyMatesColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fitness_center,
            color: GyMatesColors.primaryGreen,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // 名称和距离
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gym.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    color: GyMatesColors.primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gym.formattedDistance,
                    style: const TextStyle(
                      color: GyMatesColors.primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 收藏按钮
        if (onFavorite != null)
          IconButton(
            onPressed: onFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.grey[600],
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, color: Colors.grey[600], size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            gym.address,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingAndTags() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          // 评分
          if (gym.rating != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getRatingColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: _getRatingColor(),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    gym.rating!.toStringAsFixed(1),
                    style: TextStyle(
                      color: _getRatingColor(),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 标签
          if (gym.tags != null && gym.tags!.isNotEmpty)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: gym.tags!
                      .take(3)
                      .map((tag) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhone() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.phone, color: Colors.grey[600], size: 16),
          const SizedBox(width: 8),
          Text(
            gym.phone!,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenHours() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.grey[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              gym.openHours!,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // 导航按钮
        if (onNavigate != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onNavigate,
              icon: const Icon(Icons.directions, size: 18),
              label: const Text('导航'),
              style: OutlinedButton.styleFrom(
                foregroundColor: GyMatesColors.primaryGreen,
                side: const BorderSide(
                  color: GyMatesColors.primaryGreen,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        if (onNavigate != null && onCall != null) const SizedBox(width: 12),

        // 拨打电话按钮
        if (onCall != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('电话'),
              style: OutlinedButton.styleFrom(
                foregroundColor: GyMatesColors.primaryGreen,
                side: const BorderSide(
                  color: GyMatesColors.primaryGreen,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        if ((onNavigate != null || onCall != null) && onTap != null)
          const SizedBox(width: 12),

        // 详情按钮
        if (onTap != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('详情'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GyMatesColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  Color _getRatingColor() {
    if (gym.rating == null) return Colors.grey;
    if (gym.rating! >= 4.5) return const Color(0xFF4CAF50); // 绿色
    if (gym.rating! >= 4.0) return const Color(0xFF8BC34A); // 浅绿色
    if (gym.rating! >= 3.5) return const Color(0xFFFFC107); // 黄色
    return const Color(0xFFFF9800); // 橙色
  }
}

