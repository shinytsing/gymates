import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/mate_models.dart';
import '../../services/websocket_service.dart';
import '../../core/theme/gymates_colors.dart';

/// 聊天页面
class ChatPage extends StatefulWidget {
  final MateProfile mate;
  final int chatId;

  const ChatPage({
    super.key,
    required this.mate,
    required this.chatId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final WebSocketService _wsService = WebSocketService();
  final List<ChatMessage> _messages = [];
  
  bool _isConnected = false;
  bool _isTyping = false;
  Timer? _typingTimer;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _statusSubscription;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    // 监听WebSocket状态
    _statusSubscription = _wsService.statusStream.listen((connected) {
      setState(() {
        _isConnected = connected;
      });
    });

    // 监听消息
    _messageSubscription = _wsService.messageStream.listen((wsMessage) {
      if (wsMessage.isMessage && wsMessage.from == widget.mate.id) {
        _addMessage(
          content: wsMessage.content ?? '',
          isMe: false,
          timestamp: wsMessage.timestamp,
        );
      } else if (wsMessage.isTyping && wsMessage.from == widget.mate.id) {
        setState(() {
          _isTyping = true;
        });
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 3), () {
          setState(() {
            _isTyping = false;
          });
        });
      } else if (wsMessage.isRead && wsMessage.from == widget.mate.id) {
        _markMessagesAsRead();
      }
    });

    // 加载历史消息
    _loadHistoryMessages();
  }

  void _loadHistoryMessages() {
    // TODO: 从后端加载历史消息
    // 这里先添加一些模拟数据
    setState(() {
      _messages.addAll([
        ChatMessage(
          content: '你好！我看到你也在找健身搭子',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: true,
        ),
        ChatMessage(
          content: '是的！我看到我们有很多共同点',
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
          isRead: true,
        ),
        ChatMessage(
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
    setState(() {
      _messages.add(ChatMessage(
        content: content,
        isMe: isMe,
        timestamp: timestamp,
        isRead: isRead,
      ));
    });
    _scrollToBottom();

    // 如果是收到的消息，发送已读回执
    if (!isMe) {
      _wsService.sendReadReceipt(
        toUserId: widget.mate.id,
        chatId: widget.chatId,
      );
    }
  }

  void _markMessagesAsRead() {
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || !_isConnected) return;

    // 发送消息
    _wsService.sendChatMessage(
      toUserId: widget.mate.id,
      content: content,
      chatId: widget.chatId,
    );

    // 添加到本地消息列表
    _addMessage(
      content: content,
      isMe: true,
      timestamp: DateTime.now(),
    );

    // 清空输入框
    _messageController.clear();
  }

  void _handleTyping() {
    _wsService.sendTypingStatus(toUserId: widget.mate.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 连接状态提示
          if (!_isConnected) _buildConnectionBanner(),

          // 消息列表
          Expanded(
            child: _buildMessageList(),
          ),

          // 正在输入提示
          if (_isTyping) _buildTypingIndicator(),

          // 输入框
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[900],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          // 头像
          CircleAvatar(
            radius: 20,
            backgroundColor: GyMatesColors.primaryGreen,
            backgroundImage: widget.mate.avatar != null
                ? NetworkImage(widget.mate.avatar!)
                : null,
            child: widget.mate.avatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),

          // 名字和在线状态
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mate.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.mate.isOnline ? '在线' : '离线',
                  style: TextStyle(
                    color: widget.mate.isOnline
                        ? GyMatesColors.primaryGreen
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam, color: Colors.white),
          onPressed: () {
            // TODO: 视频通话
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('视频通话功能开发中')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.white),
          onPressed: () {
            // TODO: 语音通话
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('语音通话功能开发中')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConnectionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.orange,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '正在连接...',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              '还没有消息',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '发送一条消息开始聊天吧',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showTime = index == 0 ||
            _messages[index - 1]
                    .timestamp
                    .difference(message.timestamp)
                    .inMinutes
                    .abs() >
                5;

        return Column(
          children: [
            if (showTime) _buildTimeStamp(message.timestamp),
            _buildMessageBubble(message),
          ],
        );
      },
    );
  }

  Widget _buildTimeStamp(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        _formatTimestamp(timestamp),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: message.isMe
              ? GyMatesColors.primaryGreen
              : Colors.grey[850],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isMe ? 16 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    color: message.isMe
                        ? Colors.white.withOpacity(0.7)
                        : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead
                        ? Colors.blue[300]
                        : Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            '${widget.mate.name}正在输入',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 附件按钮
            IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.grey[600]),
              onPressed: () {
                // TODO: 发送图片、文件等
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('附件功能开发中')),
                );
              },
            ),

            // 输入框
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '输入消息...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onChanged: (text) {
                    if (text.isNotEmpty) {
                      _handleTyping();
                    }
                  },
                  onSubmitted: (_) => _handleSendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 发送按钮
            IconButton(
              icon: Icon(
                Icons.send,
                color: _messageController.text.isEmpty || !_isConnected
                    ? Colors.grey[600]
                    : GyMatesColors.primaryGreen,
              ),
              onPressed: _handleSendMessage,
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
      return '${diff.inDays}天前';
    } else {
      return '${timestamp.month}月${timestamp.day}日';
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// 聊天消息模型
class ChatMessage {
  final String content;
  final bool isMe;
  final DateTime timestamp;
  bool isRead;

  ChatMessage({
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.isRead = false,
  });
}

