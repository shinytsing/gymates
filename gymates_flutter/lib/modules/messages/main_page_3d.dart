import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/3d_components/index.dart';
import '../../core/animations/cartoon_3d_animations.dart' as cartoon_animations;
import '../../models/message_models.dart';
import '../../services/messages_service.dart';
import '../../services/websocket_service.dart';
import '../../shared/widgets/messages/chat_list.dart';
import '../../shared/widgets/messages/notification_center.dart';
import '../../../pages/chat/chat_3d_room_page.dart';

/// 📩 Apple Fitness+ Style Messages Page
/// 
/// Design Features:
/// - 3D tab bar (聊天/通知)
/// - 3D conversation cards
/// - 3D notification cards
/// - Unread badges
/// - Pull to refresh
/// - WebSocket real-time updates
/// - Polling fallback

class MessagesMainPage3D extends StatefulWidget {
  const MessagesMainPage3D({super.key});

  @override
  State<MessagesMainPage3D> createState() => _MessagesMainPage3DState();
}

class _MessagesMainPage3DState extends State<MessagesMainPage3D>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MessagesService _messagesService = MessagesService();
  final WebSocketService _wsService = WebSocketService();
  
  List<ChatConversation> _conversations = [];
  List<AppNotification> _notifications = [];
  bool _isLoadingChats = false;
  bool _isLoadingNotifications = false;
  UnreadCount _unreadCount = UnreadCount();
  final int _currentUserId = 1;
  
  // WebSocket 订阅
  StreamSubscription? _wsSubscription;
  Timer? _pollingTimer;

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
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _wsSubscription?.cancel();
    _wsService.disconnect();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    HapticFeedback.lightImpact();
    if (_tabController.index == 0 && _conversations.isEmpty) {
      _loadConversations();
    } else if (_tabController.index == 1 && _notifications.isEmpty) {
      _loadNotifications();
    }
  }

  /// 初始化 WebSocket 连接
  Future<void> _initWebSocket() async {
    try {
      final token = await _messagesService.getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ WebSocket 连接失败: 无有效 token');
        _startPollingFallback();
        return;
      }
      
      debugPrint('🔌 正在连接 WebSocket...');
      await _wsService.connect(token).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⏱️ WebSocket 连接超时，使用轮询降级方案');
          _startPollingFallback();
        },
      );
    
      _wsSubscription = _wsService.messageStream.listen(
        (message) {
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          debugPrint('❌ WebSocket 错误: $error');
          _startPollingFallback();
        },
        onDone: () {
          debugPrint('🔌 WebSocket 连接已关闭');
        },
      );
    } catch (e) {
      debugPrint('❌ WebSocket 初始化失败: $e');
      _startPollingFallback();
    }
  }
  
  /// 处理 WebSocket 消息
  void _handleWebSocketMessage(dynamic message) {
    if (message is Map<String, dynamic>) {
      final type = message['type'] as String?;
      
      switch (type) {
        case 'new_message':
          _handleNewMessage(message);
          break;
        case 'message_read':
          _handleMessageRead(message);
          break;
        case 'typing':
          _handleTypingStatus(message);
          break;
        case 'new_notification':
          _handleNewNotification(message);
          break;
        default:
          debugPrint('未知的消息类型: $type');
      }
    }
  }
  
  void _handleNewMessage(Map<String, dynamic> data) {
    HapticFeedback.lightImpact();
    _loadConversations(silent: true);
    _loadUnreadCount();
  }
  
  void _handleMessageRead(Map<String, dynamic> data) {
    _loadConversations(silent: true);
    _loadUnreadCount();
  }
  
  void _handleTypingStatus(Map<String, dynamic> data) {
    // Handle typing indicator
  }

  void _handleNewNotification(Map<String, dynamic> data) {
    HapticFeedback.lightImpact();
    _loadNotifications(silent: true);
    _loadUnreadCount();
  }
  
  /// 降级方案：轮询
  void _startPollingFallback() {
    debugPrint('🔄 启动轮询降级方案');
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        if (_tabController.index == 0) {
          _loadConversations(silent: true);
        } else {
          _loadNotifications(silent: true);
        }
        _loadUnreadCount();
      },
    );
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadConversations(),
      _loadNotifications(),
      _loadUnreadCount(),
    ]);
  }

  Future<void> _loadConversations({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoadingChats = true;
      });
    }

    try {
      final response = await _messagesService.getChats();
      
      if (mounted) {
        setState(() {
          _conversations = response;
          _isLoadingChats = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载聊天列表失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingChats = false;
        });
      }
    }
  }

  Future<void> _loadNotifications({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoadingNotifications = true;
      });
    }

    try {
      final response = await _messagesService.getNotifications();
      
      if (mounted) {
        setState(() {
          _notifications = response;
          _isLoadingNotifications = false;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载通知失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingNotifications = false;
        });
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _messagesService.getUnreadCount();
      
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint('❌ 加载未读数失败: $e');
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await _loadInitialData();
  }

  void _handleChatTap(ChatConversation conversation) {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final otherUser = conversation.participants.firstWhere(
            (p) => p.id != _currentUserId,
            orElse: () => conversation.participants.first,
          );
          return Chat3DRoomPage(
            recipientId: otherUser.id.toString(),
            recipientName: otherUser.name,
            recipientAvatar: otherUser.avatar,
          );
        },
      ),
    ).then((_) {
      _loadConversations();
      _loadUnreadCount();
    });
  }

  void _handleNotificationTap(AppNotification notification) {
    HapticFeedback.lightImpact();
    // TODO: 处理通知点击
    debugPrint('Notification tapped: ${notification.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppleFitnessTheme.backgroundPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppleFitnessTheme.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatsTab(),
                  _buildNotificationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return cartoon_animations.BounceInAnimation(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: EdgeInsets.all(AppleFitnessTheme.spacingL),
        decoration: BoxDecoration(
          color: AppleFitnessTheme.backgroundPrimary,
          boxShadow: AppleFitnessTheme.softShadow(elevation: 2),
          borderRadius: BorderRadius.only(
            bottomLeft: const Radius.circular(28),
            bottomRight: const Radius.circular(28),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title with gradient (from old design)
                  ShaderMask(
                    shaderCallback: (bounds) => AppleFitnessTheme.primaryGradient.createShader(bounds),
                    child: const Text(
                      '💬 消息',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Unread badge (from old design)
                  if (_unreadCount.totalMessages > 0)
                    cartoon_animations.PulseAnimation(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppleFitnessTheme.spacingM,
                          vertical: AppleFitnessTheme.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppleFitnessTheme.primaryGradient,
                          borderRadius: AppleFitnessTheme.radiusSmall,
                          boxShadow: AppleFitnessTheme.softShadow(elevation: 4),
                        ),
                        child: Text(
                          _unreadCount.totalMessages.toString(),
                          style: AppleFitnessTheme.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: AppleFitnessTheme.spacingL),
              // 3D Tab切换 (from old design)
              _build3DTabs(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DTabs() {
    return Container(
      padding: EdgeInsets.all(AppleFitnessTheme.spacingXS / 2),
      decoration: BoxDecoration(
        color: AppleFitnessTheme.backgroundSecondary,
        borderRadius: AppleFitnessTheme.radiusMedium,
      ),
      child: Row(
        children: [
          _build3DTabButton(0, '聊天', '💬', AppleFitnessTheme.primaryGradient),
          _build3DTabButton(1, '通知', '🔔', AppleFitnessTheme.purpleGradient),
        ],
      ),
    );
  }
  
  Widget _build3DTabButton(int index, String label, String emoji, LinearGradient gradient) {
    final isSelected = _tabController.index == index;
    final unreadCount = index == 0 ? _unreadCount.totalMessages : _unreadCount.totalNotifications;
    
    return Expanded(
      child: cartoon_animations.SlideInAnimation(
        direction: cartoon_animations.SlideDirection.fromBottom,
        delay: Duration(milliseconds: 100 + (index * 100)),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _tabController.animateTo(index);
          },
          child: AnimatedContainer(
            duration: AppleFitnessTheme.durationNormal,
            curve: AppleFitnessTheme.easeInOutCubic,
            padding: EdgeInsets.symmetric(vertical: AppleFitnessTheme.spacingM),
            decoration: BoxDecoration(
              gradient: isSelected ? gradient : null,
              borderRadius: AppleFitnessTheme.radiusMedium,
              boxShadow: isSelected ? AppleFitnessTheme.softShadow(elevation: 4) : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                SizedBox(width: AppleFitnessTheme.spacingXS),
                Text(
                  label,
                  style: AppleFitnessTheme.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppleFitnessTheme.textSecondary,
                  ),
                ),
                if (unreadCount > 0) ...[
                  SizedBox(width: AppleFitnessTheme.spacingXS),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppleFitnessTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildChatsTab() {
    return ChatList(
      conversations: _conversations,
      currentUserId: _currentUserId,
      onChatTap: _handleChatTap,
      onRefresh: () => _handleRefresh(),
      isLoading: _isLoadingChats,
    );
  }

  Widget _buildNotificationsTab() {
    return NotificationCenter(
      notifications: _notifications,
      onNotificationTap: _handleNotificationTap,
      onRefresh: () => _handleRefresh(),
      isLoading: _isLoadingNotifications,
    );
  }

}

