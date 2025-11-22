import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../models/message_models.dart';
import '../../../services/messages_service.dart';

/// 💬 聊天室页面
/// 
/// 功能：
/// - 显示聊天消息历史
/// - 发送文本、图片、语音、视频消息
/// - 发送位置和训练计划
/// - 语音/视频通话入口
/// - 实时消息更新

class ChatRoomPage extends StatefulWidget {
  final ChatConversation conversation;
  final int currentUserId;

  const ChatRoomPage({
    super.key,
    required this.conversation,
    required this.currentUserId,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final MessagesService _messagesService = MessagesService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _markAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _messagesService.getMessages(widget.conversation.id);
      setState(() {
        _messages = messages.reversed.toList(); // 最新消息在底部
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载消息失败: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead() async {
    try {
      await _messagesService.markAsRead(widget.conversation.id);
    } catch (e) {
      print('标记已读失败: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendTextMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    HapticFeedback.lightImpact();
    _messageController.clear();

    setState(() => _isSending = true);
    try {
      final message = await _messagesService.sendMessage(
        widget.conversation.id,
        SendMessageRequest(content: content, type: 'text'),
      );
      
      setState(() {
        _messages.add(message);
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败: $e')),
        );
      }
    }
  }

  Future<void> _sendImageMessage() async {
    HapticFeedback.lightImpact();
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isSending = true);
      final message = await _messagesService.sendImageMessage(
        widget.conversation.id,
        image.path,
      );
      
      setState(() {
        _messages.add(message);
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送图片失败: $e')),
        );
      }
    }
  }

  void _showMoreOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoreOptionsBottomSheet(
        onImageTap: () {
          Navigator.pop(context);
          _sendImageMessage();
        },
        onCameraTap: () async {
          Navigator.pop(context);
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );
          if (image != null) {
            setState(() => _isSending = true);
            try {
              final message = await _messagesService.sendImageMessage(
                widget.conversation.id,
                image.path,
              );
              setState(() {
                _messages.add(message);
                _isSending = false;
              });
              _scrollToBottom();
            } catch (e) {
              setState(() => _isSending = false);
            }
          }
        },
        onLocationTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('位置分享功能开发中'),
              backgroundColor: Color(0xFF6366F1),
            ),
          );
        },
        onTrainingPlanTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('训练计划分享功能开发中'),
              backgroundColor: Color(0xFF6366F1),
            ),
          );
        },
      ),
    );
  }

  void _onVoiceCall() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('语音通话'),
        content: const Text('确定要发起语音通话吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('语音通话功能开发中'),
                  backgroundColor: Color(0xFF6366F1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _onVideoCall() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('视频通话'),
        content: const Text('确定要发起视频通话吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('视频通话功能开发中'),
                  backgroundColor: Color(0xFF6366F1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatTitle = widget.conversation.getChatTitle(widget.currentUserId);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context, true);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: widget.conversation
                      .getChatAvatar(widget.currentUserId)
                      .isNotEmpty
                  ? NetworkImage(
                      widget.conversation.getChatAvatar(widget.currentUserId))
                  : null,
              child: widget.conversation
                      .getChatAvatar(widget.currentUserId)
                      .isEmpty
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.conversation.chatType == 'private' &&
                      widget.conversation.participants.length == 2)
                    Text(
                      widget.conversation.participants
                              .firstWhere((p) => p.id != widget.currentUserId)
                              .isOnline
                          ? '在线'
                          : '离线',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.conversation.participants
                                .firstWhere((p) => p.id != widget.currentUserId)
                                .isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF6366F1)),
            onPressed: _onVoiceCall,
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFF6366F1)),
            onPressed: _onVideoCall,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF6366F1)),
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: 显示更多选项
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 消息列表
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                size: 40,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '开始聊天吧！',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _MessageBubble(
                            message: _messages[index],
                            isMine: _messages[index]
                                .isMine(widget.currentUserId),
                            showAvatar: index == 0 ||
                                _messages[index].senderId !=
                                    _messages[index - 1].senderId,
                          );
                        },
                      ),
          ),
          // 输入框
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF6366F1),
                    ),
                    onPressed: _showMoreOptions,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: '输入消息...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF6366F1)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF6366F1),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _sendTextMessage,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 消息气泡组件
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.showAvatar = true,
  });

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case 'image':
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message.metadata?['image_url'] ?? '',
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                color: const Color(0xFFE5E7EB),
                child: const Icon(Icons.broken_image, size: 48),
              );
            },
          ),
        );
      case 'audio':
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_outline, size: 32),
              const SizedBox(width: 8),
              Text(message.metadata?['duration'] ?? '0:00'),
            ],
          ),
        );
      case 'video':
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.play_circle_filled, size: 32),
              const SizedBox(width: 8),
              const Text('视频消息'),
            ],
          ),
        );
      case 'location':
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, size: 24),
              const SizedBox(width: 8),
              const Text('位置分享'),
            ],
          ),
        );
      case 'training_plan':
        return Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fitness_center, size: 24),
              const SizedBox(width: 8),
              const Text('训练计划'),
            ],
          ),
        );
      default:
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 15,
            color: isMine ? Colors.white : const Color(0xFF1F2937),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMine) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: message.sender?.avatar.isNotEmpty == true
                    ? NetworkImage(message.sender!.avatar)
                    : null,
                child: message.sender?.avatar.isEmpty == true
                    ? const Icon(Icons.person, size: 16)
                    : null,
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMine
                        ? const Color(0xFF6366F1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildMessageContent(),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          if (isMine) ...[
            const SizedBox(width: 8),
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: message.sender?.avatar.isNotEmpty == true
                    ? NetworkImage(message.sender!.avatar)
                    : null,
                child: message.sender?.avatar.isEmpty == true
                    ? const Icon(Icons.person, size: 16)
                    : null,
              )
            else
              const SizedBox(width: 32),
          ],
        ],
      ),
    );
  }
}

/// 更多选项底部弹窗
class _MoreOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onImageTap;
  final VoidCallback onCameraTap;
  final VoidCallback onLocationTap;
  final VoidCallback onTrainingPlanTap;

  const _MoreOptionsBottomSheet({
    required this.onImageTap,
    required this.onCameraTap,
    required this.onLocationTap,
    required this.onTrainingPlanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _OptionButton(
                    icon: Icons.photo_library,
                    label: '相册',
                    color: const Color(0xFF6366F1),
                    onTap: onImageTap,
                  ),
                  _OptionButton(
                    icon: Icons.camera_alt,
                    label: '拍照',
                    color: const Color(0xFF10B981),
                    onTap: onCameraTap,
                  ),
                  _OptionButton(
                    icon: Icons.location_on,
                    label: '位置',
                    color: const Color(0xFFEF4444),
                    onTap: onLocationTap,
                  ),
                  _OptionButton(
                    icon: Icons.fitness_center,
                    label: '训练计划',
                    color: const Color(0xFFF59E0B),
                    onTap: onTrainingPlanTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

