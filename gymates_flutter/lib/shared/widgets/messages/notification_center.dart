import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/message_models.dart';

/// 🔔 通知中心组件
/// 
/// 显示系统通知和社交通知

class NotificationCenter extends StatelessWidget {
  final List<AppNotification> notifications;
  final Function(AppNotification) onNotificationTap;
  final VoidCallback? onRefresh;
  final VoidCallback? onMarkAllRead;
  final bool isLoading;

  const NotificationCenter({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
    this.onRefresh,
    this.onMarkAllRead,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none,
                size: 50,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '暂无通知',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '你的通知将会显示在这里',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    // 按分类分组通知
    final systemNotifications = notifications
        .where((n) => n.getCategory() == 'system')
        .toList();
    final socialNotifications = notifications
        .where((n) => n.getCategory() == 'social')
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      color: const Color(0xFF6366F1),
      child: CustomScrollView(
        slivers: [
          // 标记全部已读按钮
          if (notifications.any((n) => !n.isRead))
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onMarkAllRead,
                      icon: const Icon(
                        Icons.done_all,
                        size: 18,
                        color: Color(0xFF6366F1),
                      ),
                      label: const Text(
                        '全部已读',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // 系统通知
          if (systemNotifications.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  '系统通知',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _NotificationItem(
                    notification: systemNotifications[index],
                    onTap: () => onNotificationTap(systemNotifications[index]),
                  );
                },
                childCount: systemNotifications.length,
              ),
            ),
          ],
          
          // 社交通知
          if (socialNotifications.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '社交通知',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _NotificationItem(
                    notification: socialNotifications[index],
                    onTap: () => onNotificationTap(socialNotifications[index]),
                  );
                },
                childCount: socialNotifications.length,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM-dd HH:mm').format(time);
    }
  }

  Color _getTypeColor() {
    switch (notification.type) {
      case 'like':
        return const Color(0xFFEF4444);
      case 'comment':
        return const Color(0xFF3B82F6);
      case 'follow':
        return const Color(0xFF8B5CF6);
      case 'invite':
        return const Color(0xFF10B981);
      case 'challenge':
        return const Color(0xFFF59E0B);
      case 'reward':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'invite':
        return Icons.group_add;
      case 'challenge':
        return Icons.emoji_events;
      case 'reward':
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : const Color(0xFF6366F1).withOpacity(0.05),
          border: const Border(
            bottom: BorderSide(
              color: Color(0xFFE5E7EB),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(),
                color: _getTypeColor(),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // 通知内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: notification.isRead
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF4B5563),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

