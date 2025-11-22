import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/3d_components/index.dart';
import '../../services/websocket_service.dart';

/// 💬 Apple Fitness+ Style Chat Room Page
/// 
/// Design Features:
/// - 3D message bubbles (scale animation)
/// - 3D input bar (floating bottom)
/// - Typing indicator animation
/// - Message send animation (fly up)
/// - Read receipt indicator
/// - Smooth scroll animations

class Chat3DRoomPage extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String? recipientAvatar;

  const Chat3DRoomPage({
    super.key,
    required this.recipientId,
    required this.recipientName,
    this.recipientAvatar,
  });

  @override
  State<Chat3DRoomPage> createState() => _Chat3DRoomPageState();
}

class _Chat3DRoomPageState extends State<Chat3DRoomPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final WebSocketService _wsService = WebSocketService();
  final List<ChatMessage3D> _messages = [];
  
  bool _isConnected = false;
  bool _isTyping = false;
  bool _isRecipientTyping = false;
  Timer? _typingTimer;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _statusSubscription;
  
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;

  @override
  void initState() {
    super.initState();
    
    _sendButtonController = AnimationController(
      duration: AppleFitnessTheme.durationFast,
      vsync: this,
    );
    
    _sendButtonScale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _sendButtonController,
        curve: AppleFitnessTheme.easeInOutCubic,
      ),
    );
    
    _initializeChat();
    
    _messageController.addListener(() {
      if (!mounted) return;
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _isTyping) {
        setState(() => _isTyping = hasText);
        if (hasText) {
          final recipientIdInt = int.tryParse(widget.recipientId) ?? 0;
          if (recipientIdInt > 0) {
            _wsService.sendTypingStatus(toUserId: recipientIdInt);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    // Listen to WebSocket status
    _statusSubscription = _wsService.statusStream.listen((connected) {
      if (mounted) {
        setState(() => _isConnected = connected);
      }
    });

    // Listen to messages
    _messageSubscription = _wsService.messageStream.listen((wsMessage) {
      if (!mounted) return;
      
      // Convert recipientId to int for comparison
      final recipientIdInt = int.tryParse(widget.recipientId) ?? 0;
      if (recipientIdInt == 0) return; // Invalid recipient ID
      
      if (wsMessage.isMessage && wsMessage.from == recipientIdInt) {
        _addMessage(
          content: wsMessage.content ?? '',
          isMe: false,
          timestamp: wsMessage.timestamp,
        );
      } else if (wsMessage.isTyping && wsMessage.from == recipientIdInt) {
        if (mounted) {
          setState(() => _isRecipientTyping = true);
        }
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => _isRecipientTyping = false);
          }
        });
      } else if (wsMessage.isRead && wsMessage.from == recipientIdInt) {
        if (mounted) {
          _markMessagesAsRead();
        }
      }
    });

    // Load history messages
    _loadHistoryMessages();
  }

  void _loadHistoryMessages() {
    // TODO: Load from backend
    if (!mounted) return;
    setState(() {
      _messages.addAll([
        ChatMessage3D(
          id: '1',
          content: '你好！我看到你也在找健身搭子',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: true,
        ),
        ChatMessage3D(
          id: '2',
          content: '是的！我看到我们有很多共同点',
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
          isRead: true,
        ),
        ChatMessage3D(
          id: '3',
          content: '要不我们约个时间一起训练？',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
          isRead: true,
        ),
      ]);
    });
    _scrollToBottom();
  }

  void _addMessage({
    required String content,
    required bool isMe,
    required DateTime timestamp,
    bool isRead = false,
  }) {
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage3D(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        isMe: isMe,
        timestamp: timestamp,
        isRead: isRead,
      ));
    });
    _scrollToBottom();

    // Send read receipt for received messages
    if (!isMe) {
      final recipientIdInt = int.tryParse(widget.recipientId) ?? 0;
      if (recipientIdInt > 0) {
        _wsService.sendReadReceipt(
          toUserId: recipientIdInt,
          chatId: 0, // TODO: Use actual chat ID
        );
      }
    }
  }

  void _markMessagesAsRead() {
    if (!mounted) return;
    setState(() {
      for (var message in _messages) {
        if (message.isMe && !message.isRead) {
          message.isRead = true;
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppleFitnessTheme.durationNormal,
          curve: AppleFitnessTheme.easeInOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Animate send button
    await _sendButtonController.forward();
    _sendButtonController.reverse();

    // Add message locally
    _addMessage(
      content: text,
      isMe: true,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Clear input
    _messageController.clear();

    // Send via WebSocket
    final recipientIdInt = int.tryParse(widget.recipientId) ?? 0;
    if (recipientIdInt > 0) {
      _wsService.sendMessage(
        type: 'message',
        to: recipientIdInt,
        content: text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            if (_isRecipientTyping)
              _buildTypingIndicator(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppleFitnessTheme.primaryGradient,
            ),
            child: widget.recipientAvatar != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.recipientAvatar!),
                  )
                : const Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: AppleFitnessTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipientName,
                  style: AppleFitnessTheme.titleMedium,
                ),
                Text(
                  _isConnected ? '在线' : '离线',
                  style: AppleFitnessTheme.bodySmall.copyWith(
                    color: _isConnected
                        ? AppleFitnessTheme.success
                        : AppleFitnessTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showTimestamp = index == 0 ||
            _messages[index - 1]
                    .timestamp
                    .difference(message.timestamp)
                    .inMinutes
                    .abs() >
                5;

        return Column(
          children: [
            if (showTimestamp)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppleFitnessTheme.spacingM,
                ),
                child: Text(
                  _formatTimestamp(message.timestamp),
                  style: AppleFitnessTheme.bodySmall.copyWith(
                    color: AppleFitnessTheme.textSecondary,
                  ),
                ),
              ),
            FadeIn3D(
              delay: Duration(milliseconds: index * 50),
              child: _buildMessageBubble(message),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage3D message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(bottom: AppleFitnessTheme.spacingS),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Card3D(
              gradient: message.isMe
                  ? AppleFitnessTheme.primaryGradient
                  : null,
              backgroundColor: message.isMe
                  ? null
                  : AppleFitnessTheme.backgroundSecondary,
              elevation: 4,
              child: Text(
                message.content,
                style: AppleFitnessTheme.bodyMedium.copyWith(
                  color: message.isMe
                      ? Colors.white
                      : AppleFitnessTheme.textPrimary,
                ),
              ),
            ),
            if (message.isMe)
              Padding(
                padding: EdgeInsets.only(top: AppleFitnessTheme.spacingXS),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message.isRead)
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: AppleFitnessTheme.primaryBlue,
                      )
                    else
                      Icon(
                        Icons.done,
                        size: 14,
                        color: AppleFitnessTheme.textTertiary,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      _formatMessageTime(message.timestamp),
                      style: AppleFitnessTheme.bodySmall.copyWith(
                        color: AppleFitnessTheme.textSecondary,
                        fontSize: 11,
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Card3D(
          backgroundColor: AppleFitnessTheme.backgroundSecondary,
          elevation: 4,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0),
              SizedBox(width: AppleFitnessTheme.spacingXS),
              _buildDot(1),
              SizedBox(width: AppleFitnessTheme.spacingXS),
              _buildDot(2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final offset = (value + index * 0.33) % 1.0;
        final scale = 0.5 + (0.5 * (1 - (offset - 0.5).abs() * 2));
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppleFitnessTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppleFitnessTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppleFitnessTheme.spacingL),
            Text(
              '开始对话',
              style: AppleFitnessTheme.headlineSmall,
            ),
            SizedBox(height: AppleFitnessTheme.spacingS),
            Text(
              '发送第一条消息吧',
              style: AppleFitnessTheme.bodyMedium.copyWith(
                color: AppleFitnessTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Input3D(
                controller: _messageController,
                hint: '输入消息...',
                maxLines: 4,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: AppleFitnessTheme.spacingM),
            AnimatedBuilder(
              animation: _sendButtonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sendButtonScale.value,
                  child: child,
                );
              },
              child: Button3D(
                icon: Icons.send,
                backgroundColor: _isTyping
                    ? AppleFitnessTheme.primaryBlue
                    : AppleFitnessTheme.backgroundSecondary,
                foregroundColor: _isTyping
                    ? Colors.white
                    : AppleFitnessTheme.textTertiary,
                enableGlow: _isTyping,
                onPressed: _isTyping ? _sendMessage : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays == 0) {
      return '今天 ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return '昨天 ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return '${weekdays[timestamp.weekday - 1]} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month}月${timestamp.day}日 ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _showMoreOptions() {
    if (!mounted) return;
    showActionSheet3D(
      context: context,
      title: '聊天选项',
      options: [
        ActionSheetOption(
          text: '清空聊天记录',
          value: 'clear',
          icon: Icons.delete_sweep,
        ),
        ActionSheetOption(
          text: '屏蔽此人',
          value: 'block',
          icon: Icons.block,
        ),
        ActionSheetOption(
          text: '举报',
          value: 'report',
          icon: Icons.report,
          isDestructive: true,
        ),
      ],
      cancelOption: ActionSheetOption(
        text: '取消',
        value: 'cancel',
      ),
    );
  }
}

/// Chat message model for 3D chat
class ChatMessage3D {
  final String id;
  final String content;
  final bool isMe;
  final DateTime timestamp;
  bool isRead;

  ChatMessage3D({
    required this.id,
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.isRead = false,
  });
}

