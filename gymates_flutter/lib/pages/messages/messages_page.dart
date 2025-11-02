import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';
import '../../models/message_models.dart';
import '../../services/messages_service.dart';
import '../../services/websocket_service.dart';
import '../../shared/widgets/messages/chat_list.dart';
import '../../shared/widgets/messages/notification_center.dart';
import '../../theme/gymates_theme.dart';
import 'chat_room_page.dart';

/// 📩 消息页面 - 增强版聊天UI
/// 
/// 功能特性：
/// - 双标签页：聊天 / 通知（圆润Tab设计）
/// - 实时聊天列表（气泡样式）
/// - 通知中心（分类卡片）
/// - 未读消息徽章
/// - 下拉刷新 + WebSocket 实时通信
/// - Glassmorphism 设计风格

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MessagesService _messagesService = MessagesService();
  final WebSocketService _wsService = WebSocketService();

  // 数据
  List<ChatConversation> _conversations = [];
  List<AppNotification> _notifications = [];
  UnreadCount _unreadCount = UnreadCount();

  // 状态
  bool _isLoadingChats = false;
  bool _isLoadingNotifications = false;
  final int _currentUserId = 1; // TODO: 从用户认证服务获取
  
  // WebSocket 订阅
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadInitialData();
    _initWebSocket();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wsSubscription?.cancel();
    _wsService.disconnect();
    super.dispose();
  }
  
  /// 初始化 WebSocket 连接
  Future<void> _initWebSocket() async {
    try {
      // 从存储中获取真实 token
      final token = await _messagesService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        await _wsService.connect(token);
    
    // 监听 WebSocket 消息
    _wsSubscription = _wsService.messageStream.listen((message) {
      _handleWebSocketMessage(message);
    });
      } else {
        debugPrint('WebSocket 连接失败: 无有效 token');
      }
    } catch (e) {
      debugPrint('WebSocket 连接失败: $e');
    }
  }
  
  /// 处理 WebSocket 消息
  void _handleWebSocketMessage(WebSocketMessage message) {
    switch (message.type) {
      case 'new_message':
        if (message.data != null) {
          // TODO: 实现新消息处理
          debugPrint('收到新消息: ${message.data}');
        }
        break;
      case 'notification':
        if (message.data != null) {
          // TODO: 实现通知处理
          debugPrint('收到通知: ${message.data}');
        }
        break;
      case 'message_read':
        if (message.data != null) {
          _handleMessageRead(message.data!);
        }
        break;
      case 'online_status':
        if (message.data != null) {
          _handleOnlineStatus(message.data!);
        }
        break;
      default:
        debugPrint('未处理的 WebSocket 消息类型: ${message.type}');
    }
  }
  
  /// 处理新消息
  void _handleNewMessage(ChatMessage message) {
    setState(() {
      // 更新聊天列表中的最后消息
      final index = _conversations.indexWhere((c) => c.id == message.chatId);
      if (index != -1) {
        final conv = _conversations[index];
        _conversations[index] = ChatConversation(
          id: conv.id,
          participants: conv.participants,
          lastMessage: message,
          unreadCount: message.senderId != _currentUserId 
              ? conv.unreadCount + 1 
              : conv.unreadCount,
          createdAt: conv.createdAt,
          updatedAt: DateTime.now(),
          chatType: conv.chatType,
        );
        
        // 将该聊天移到列表顶部
        final updatedConv = _conversations.removeAt(index);
        _conversations.insert(0, updatedConv);
      }
      
      // 更新未读数量
      if (message.senderId != _currentUserId) {
        _unreadCount = UnreadCount(
          totalMessages: _unreadCount.totalMessages + 1,
          totalNotifications: _unreadCount.totalNotifications,
          byChatId: {
            ..._unreadCount.byChatId,
            message.chatId: (_unreadCount.byChatId[message.chatId] ?? 0) + 1,
          },
        );
      }
    });
    
    // 显示通知（如果不在当前聊天室）
    if (message.senderId != _currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${message.sender?.name ?? '新消息'}: ${message.content}'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF6366F1),
          action: SnackBarAction(
            label: '查看',
            textColor: Colors.white,
            onPressed: () {
              final conv = _conversations.firstWhere((c) => c.id == message.chatId);
              _onChatTap(conv);
            },
          ),
        ),
      );
    }
  }
  
  /// 处理新通知
  void _handleNewNotification(AppNotification notification) {
    setState(() {
      _notifications.insert(0, notification);
      _unreadCount = UnreadCount(
        totalMessages: _unreadCount.totalMessages,
        totalNotifications: _unreadCount.totalNotifications + 1,
        byChatId: _unreadCount.byChatId,
      );
    });
    
    // 显示通知提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${notification.getIcon()} ${notification.title}'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }
  
  /// 处理消息已读
  void _handleMessageRead(Map<String, dynamic> data) {
    final chatId = data['chat_id'] as int?;
    if (chatId != null) {
      setState(() {
        final index = _conversations.indexWhere((c) => c.id == chatId);
        if (index != -1) {
          final conv = _conversations[index];
          _conversations[index] = ChatConversation(
            id: conv.id,
            participants: conv.participants,
            lastMessage: conv.lastMessage,
            unreadCount: 0,
            createdAt: conv.createdAt,
            updatedAt: conv.updatedAt,
            chatType: conv.chatType,
          );
        }
      });
    }
  }
  
  /// 处理在线状态更新
  void _handleOnlineStatus(Map<String, dynamic> data) {
    final userId = data['user_id'] as int?;
    final isOnline = data['is_online'] as bool? ?? false;
    
    if (userId != null) {
      setState(() {
        for (var i = 0; i < _conversations.length; i++) {
          final conv = _conversations[i];
          final updatedParticipants = conv.participants.map((p) {
            if (p.id == userId) {
              return ChatUser(
                id: p.id,
                name: p.name,
                avatar: p.avatar,
                bio: p.bio,
                isOnline: isOnline,
                lastSeen: isOnline ? null : DateTime.now().toIso8601String(),
              );
            }
            return p;
          }).toList();
          
          _conversations[i] = ChatConversation(
            id: conv.id,
            participants: updatedParticipants,
            lastMessage: conv.lastMessage,
            unreadCount: conv.unreadCount,
            createdAt: conv.createdAt,
            updatedAt: conv.updatedAt,
            chatType: conv.chatType,
          );
        }
      });
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadChats(),
      _loadNotifications(),
      _loadUnreadCount(),
    ]);
  }

  Future<void> _loadChats() async {
    setState(() => _isLoadingChats = true);
    try {
      final chats = await _messagesService.getChats();
      setState(() {
        _conversations = chats;
        _isLoadingChats = false;
      });
    } catch (e) {
      setState(() => _isLoadingChats = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载聊天失败: $e')),
        );
      }
    }
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoadingNotifications = true);
    try {
      final notifications = await _messagesService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoadingNotifications = false;
      });
    } catch (e) {
      setState(() => _isLoadingNotifications = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载通知失败: $e')),
        );
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _messagesService.getUnreadCount();
      setState(() => _unreadCount = count);
    } catch (e) {
      print('加载未读数量失败: $e');
    }
  }

  Future<void> _onChatTap(ChatConversation conversation) async {
    HapticFeedback.lightImpact();
    
    // 导航到聊天室
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomPage(
          conversation: conversation,
          currentUserId: _currentUserId,
        ),
      ),
    );

    // 返回后刷新列表
    if (result == true) {
      _loadChats();
      _loadUnreadCount();
    }
  }

  void _onNotificationTap(AppNotification notification) {
    HapticFeedback.lightImpact();
    
    // 标记为已读
    _messagesService.markNotificationAsRead(notification.id);
    
    // 更新本地状态
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: notification.id,
          title: notification.title,
          content: notification.content,
          type: notification.type,
          isRead: true,
          createdAt: notification.createdAt,
          data: notification.data,
        );
      }
    });

    // TODO: 根据通知类型导航到相应页面
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('查看 ${notification.title}'),
        backgroundColor: const Color(0xFF6366F1),
      ),
    );
  }

  Future<void> _onMarkAllNotificationsRead() async {
    HapticFeedback.mediumImpact();
    try {
      await _messagesService.markAllNotificationsAsRead();
      setState(() {
        _notifications = _notifications.map((n) {
          return AppNotification(
            id: n.id,
            title: n.title,
            content: n.content,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
            data: n.data,
          );
        }).toList();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('已全部标记为已读'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _onNewChat() {
    HapticFeedback.lightImpact();
    // TODO: 打开创建新聊天对话框
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewChatBottomSheet(
        onUserSelected: (userId) async {
          try {
            final chat = await _messagesService.createChat(
              CreateChatRequest(participantIds: [userId]),
            );
            Navigator.pop(context);
            _onChatTap(chat);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('创建聊天失败: $e')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymatesTheme.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildGlassHeader(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatList(),
                  _buildNotificationList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 玻璃态Header
  Widget _buildGlassHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GymatesTheme.radius20),
        boxShadow: GymatesTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GymatesTheme.radius20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(GymatesTheme.radius20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // 标题行
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: GymatesTheme.socialGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.message_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '消息',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: GymatesTheme.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      // 未读计数徽章和搜索按钮
                      Row(
                        children: [
                          if ((_unreadCount.totalMessages + _unreadCount.totalNotifications) > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                gradient: GymatesTheme.energyGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: GymatesTheme.accentCoral.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${_unreadCount.totalMessages + _unreadCount.totalNotifications}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.search_rounded),
                            color: GymatesTheme.primaryColor,
                            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: 实现搜索功能
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('搜索功能开发中'),
                  backgroundColor: GymatesTheme.primaryColor,
                ),
              );
            },
          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Tab切换
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF6F7FB), Color(0xFFEAEAEA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(GymatesTheme.radius16),
                  ),
                  child: Row(
                    children: [
                      _buildMsgTabButton(
                        0,
                        '聊天',
                        Icons.chat_bubble_rounded,
                        _unreadCount.totalMessages,
                      ),
                      _buildMsgTabButton(
                        1,
                        '通知',
                        Icons.notifications_rounded,
                        _unreadCount.totalNotifications,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMsgTabButton(int index, String label, IconData icon, int count) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _tabController.index = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? GymatesTheme.primaryGradient : null,
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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : GymatesTheme.lightTextSecondary,
                  ),
                  if (count > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: GymatesTheme.accentCoral,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : GymatesTheme.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildChatList() {
    return ChatList(
      conversations: _conversations,
      currentUserId: _currentUserId,
      onChatTap: _onChatTap,
      onRefresh: _loadChats,
      isLoading: _isLoadingChats,
    );
  }
  
  Widget _buildNotificationList() {
    return NotificationCenter(
      notifications: _notifications,
      onNotificationTap: _onNotificationTap,
      onRefresh: _loadNotifications,
      onMarkAllRead: _onMarkAllNotificationsRead,
      isLoading: _isLoadingNotifications,
    );
  }
}

/// 新建聊天底部弹窗
class _NewChatBottomSheet extends StatefulWidget {
  final Function(int userId) onUserSelected;

  const _NewChatBottomSheet({required this.onUserSelected});

  @override
  State<_NewChatBottomSheet> createState() => _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends State<_NewChatBottomSheet> {
  final MessagesService _messagesService = MessagesService();
  final TextEditingController _searchController = TextEditingController();
  List<ChatUser> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final users = await _messagesService.searchUsers(query);
      setState(() {
        _searchResults = users;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  '新建聊天',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // 搜索框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索用户...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6366F1)),
                ),
              ),
              onChanged: _searchUsers,
            ),
          ),
          // 搜索结果
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  )
                : _searchResults.isEmpty
                    ? const Center(
                        child: Text(
                          '搜索用户开始聊天',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final user = _searchResults[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatar.isNotEmpty
                                  ? NetworkImage(user.avatar)
                                  : null,
                              child: user.avatar.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(user.name),
                            subtitle: user.bio != null ? Text(user.bio!) : null,
                            onTap: () => widget.onUserSelected(user.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

