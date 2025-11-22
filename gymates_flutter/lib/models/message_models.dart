/// 📩 消息模块数据模型
/// 
/// 包含聊天、消息、通知等相关数据结构
library;

class ChatUser {
  final int id;
  final String name;
  final String avatar;
  final String? bio;
  final bool isOnline;
  final String? lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatar,
    this.bio,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      bio: json['bio']?.toString(),
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      lastSeen: json['last_seen']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'is_online': isOnline,
      'last_seen': lastSeen,
    };
  }
}

class ChatConversation {
  final int id;
  final List<ChatUser> participants;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String chatType; // 'private', 'group', 'trainer'

  ChatConversation({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.chatType = 'private',
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    // Safely parse participants
    List<ChatUser> participantsList = [];
    if (json['participants'] != null && json['participants'] is List) {
      try {
        participantsList = (json['participants'] as List)
            .whereType<Map<String, dynamic>>()
            .map((p) => ChatUser.fromJson(p))
            .toList();
      } catch (e) {
        print('Error parsing participants: $e');
      }
    }

    return ChatConversation(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      participants: participantsList,
      lastMessage: json['last_message'] != null && json['last_message'] is Map
          ? ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] is int ? json['unread_count'] : (int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      chatType: json['chat_type']?.toString() ?? 'private',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants.map((p) => p.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'chat_type': chatType,
    };
  }

  // 获取聊天标题（对于私聊显示对方名字，群聊显示参与者名字）
  String getChatTitle(int currentUserId) {
    if (chatType == 'private' && participants.length == 2) {
      return participants.firstWhere((p) => p.id != currentUserId).name;
    }
    return participants.map((p) => p.name).join(', ');
  }

  // 获取聊天头像
  String getChatAvatar(int currentUserId) {
    if (chatType == 'private' && participants.length == 2) {
      return participants.firstWhere((p) => p.id != currentUserId).avatar;
    }
    return participants.first.avatar;
  }
}

class ChatMessage {
  final int id;
  final int chatId;
  final int senderId;
  final ChatUser? sender;
  final String content;
  final String type; // 'text', 'image', 'audio', 'video', 'location', 'training_plan'
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata; // 用于存储额外数据（如图片URL、位置坐标等）

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    this.sender,
    required this.content,
    this.type = 'text',
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      chatId: json['chat_id'] is int ? json['chat_id'] : (int.tryParse(json['chat_id']?.toString() ?? '0') ?? 0),
      senderId: json['sender_id'] is int ? json['sender_id'] : (int.tryParse(json['sender_id']?.toString() ?? '0') ?? 0),
      sender: json['sender'] != null && json['sender'] is Map
          ? ChatUser.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? '') ?? DateTime.now(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'sender': sender?.toJson(),
      'content': content,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  // 判断是否是当前用户发送的消息
  bool isMine(int currentUserId) {
    return senderId == currentUserId;
  }
}

class AppNotification {
  final int id;
  final String title;
  final String content;
  final String type; // 'system', 'social', 'challenge', 'reward', 'like', 'comment', 'follow', 'invite'
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data; // 额外数据（如相关用户ID、帖子ID等）

  AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'system',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'data': data,
    };
  }

  // 获取通知图标
  String getIcon() {
    switch (type) {
      case 'like':
        return '❤️';
      case 'comment':
        return '💬';
      case 'follow':
        return '👤';
      case 'invite':
        return '🤝';
      case 'challenge':
        return '🏆';
      case 'reward':
        return '🎁';
      default:
        return '🔔';
    }
  }

  // 获取通知分类（用于分组显示）
  String getCategory() {
    if (type == 'system' || type == 'challenge' || type == 'reward') {
      return 'system';
    }
    return 'social';
  }
}

class UnreadCount {
  final int totalMessages;
  final int totalNotifications;
  final Map<int, int> byChatId;

  UnreadCount({
    this.totalMessages = 0,
    this.totalNotifications = 0,
    this.byChatId = const {},
  });

  factory UnreadCount.fromJson(Map<String, dynamic> json) {
    return UnreadCount(
      totalMessages: json['total_messages'] ?? 0,
      totalNotifications: json['total_notifications'] ?? 0,
      byChatId: Map<int, int>.from(json['by_chat_id'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_messages': totalMessages,
      'total_notifications': totalNotifications,
      'by_chat_id': byChatId,
    };
  }
}

class SendMessageRequest {
  final String content;
  final String type;
  final Map<String, dynamic>? metadata;

  SendMessageRequest({
    required this.content,
    this.type = 'text',
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type,
      'metadata': metadata,
    };
  }
}

class CreateChatRequest {
  final List<int> participantIds;

  CreateChatRequest({required this.participantIds});

  Map<String, dynamic> toJson() {
    return {
      'participant_ids': participantIds,
    };
  }
}

