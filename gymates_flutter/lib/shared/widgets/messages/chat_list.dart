import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/message_models.dart';

/// 📋 聊天列表组件
/// 
/// 显示所有聊天会话的列表

class ChatList extends StatelessWidget {
  final List<ChatConversation> conversations;
  final int currentUserId;
  final Function(ChatConversation) onChatTap;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const ChatList({
    super.key,
    required this.conversations,
    required this.currentUserId,
    required this.onChatTap,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      );
    }

    if (conversations.isEmpty) {
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
                Icons.chat_bubble_outline,
                size: 50,
                color: Color(0xFF6366F1),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '暂无聊天',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '开始与你的健身伙伴聊天吧！',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      color: const Color(0xFF6366F1),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          return _ChatListItem(
            conversation: conversations[index],
            currentUserId: currentUserId,
            onTap: () => onChatTap(conversations[index]),
          );
        },
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatConversation conversation;
  final int currentUserId;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.conversation,
    required this.currentUserId,
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
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM-dd').format(time);
    }
  }

  String _getLastMessagePreview() {
    if (conversation.lastMessage == null) {
      return '开始聊天吧';
    }

    final message = conversation.lastMessage!;
    switch (message.type) {
      case 'image':
        return '[图片]';
      case 'audio':
        return '[语音]';
      case 'video':
        return '[视频]';
      case 'location':
        return '[位置]';
      case 'training_plan':
        return '[训练计划]';
      default:
        return message.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatTitle = conversation.getChatTitle(currentUserId);
    final chatAvatar = conversation.getChatAvatar(currentUserId);
    final lastMessagePreview = _getLastMessagePreview();
    final hasUnread = conversation.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread ? const Color(0xFF6366F1).withOpacity(0.05) : Colors.transparent,
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
            // 头像
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFE5E7EB),
                  backgroundImage: chatAvatar.isNotEmpty
                      ? NetworkImage(chatAvatar)
                      : null,
                  child: chatAvatar.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 28,
                          color: Color(0xFF9CA3AF),
                        )
                      : null,
                ),
                // 在线状态指示器
                if (conversation.chatType == 'private' &&
                    conversation.participants.length == 2)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: conversation.participants
                                .firstWhere((p) => p.id != currentUserId)
                                .isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // 聊天信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conversation.lastMessage != null
                            ? _formatTime(conversation.lastMessage!.createdAt)
                            : _formatTime(conversation.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: hasUnread
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF9CA3AF),
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessagePreview,
                          style: TextStyle(
                            fontSize: 14,
                            color: hasUnread
                                ? const Color(0xFF4B5563)
                                : const Color(0xFF9CA3AF),
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            conversation.unreadCount > 99
                                ? '99+'
                                : '${conversation.unreadCount}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
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

