import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/config/smart_api_config.dart';

/// WebSocket服务
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _statusController = StreamController<bool>.broadcast();
  bool _isConnected = false;
  String? _token;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  /// 消息流
  Stream<WebSocketMessage> get messageStream => _messageController.stream;

  /// 连接状态流
  Stream<bool> get statusStream => _statusController.stream;

  /// 是否已连接
  bool get isConnected => _isConnected;

  /// 连接WebSocket
  Future<void> connect(String token) async {
    if (_isConnected) {
      print('WebSocket already connected');
      return;
    }

    _token = token;
    _reconnectAttempts = 0;
    await _establishConnection();
  }

  /// 建立连接
  Future<void> _establishConnection() async {
    try {
      final wsUrl = SmartApiConfig.webSocketUrl;
      final uri = Uri.parse('$wsUrl/ws/connect?token=$_token');

      print('Connecting to WebSocket: $uri');

      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onDone: () {
          print('WebSocket connection closed');
          _handleDisconnection(false);
        },
        onError: (error) {
          print('WebSocket error: $error');
          // 检查是否是401认证错误
          final shouldRetry = !error.toString().contains('401');
          _handleDisconnection(shouldRetry);
        },
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      _statusController.add(true);
      print('WebSocket connected successfully');
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      // 检查是否是401认证错误
      final shouldRetry = !e.toString().contains('401');
      _handleDisconnection(shouldRetry);
    }
  }

  /// 处理断开连接
  void _handleDisconnection([bool shouldRetry = true]) {
    _isConnected = false;
    _statusController.add(false);

    // 如果不应该重试（如401错误），则直接返回
    if (!shouldRetry) {
      print('WebSocket disconnected (authentication failed, not retrying)');
      return;
    }

    // 尝试重连
    if (_reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      final delay = Duration(seconds: _reconnectAttempts * 2);
      print('Reconnecting in ${delay.inSeconds} seconds (attempt $_reconnectAttempts)');

      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        if (_token != null) {
          _establishConnection();
        }
      });
    } else {
      print('Max reconnect attempts reached');
    }
  }

  /// 处理接收到的消息
  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String);
      final message = WebSocketMessage.fromJson(json);
      _messageController.add(message);
    } catch (e) {
      print('Failed to parse WebSocket message: $e');
    }
  }

  /// 发送原始消息（用于 WebRTC 信令等）
  void send(Map<String, dynamic> data) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected');
      return;
    }

    try {
      _channel!.sink.add(jsonEncode(data));
    } catch (e) {
      print('Failed to send data: $e');
    }
  }

  /// 发送消息
  void sendMessage({
    required String type,
    required int to,
    String? content,
    Map<String, dynamic>? data,
    int? chatId,
  }) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected');
      return;
    }

    final message = {
      'type': type,
      'to': to,
      if (content != null) 'content': content,
      if (data != null) 'data': data,
      if (chatId != null) 'chat_id': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      _channel!.sink.add(jsonEncode(message));
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  /// 发送聊天消息
  void sendChatMessage({
    required int toUserId,
    required String content,
    required int chatId,
  }) {
    sendMessage(
      type: 'message',
      to: toUserId,
      content: content,
      chatId: chatId,
    );
  }

  /// 发送正在输入状态
  void sendTypingStatus({required int toUserId}) {
    sendMessage(
      type: 'typing',
      to: toUserId,
    );
  }

  /// 发送已读回执
  void sendReadReceipt({
    required int toUserId,
    required int chatId,
  }) {
    sendMessage(
      type: 'read',
      to: toUserId,
      chatId: chatId,
    );
  }

  /// 断开连接
  void disconnect() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _token = null;
    _statusController.add(false);
    print('WebSocket disconnected');
  }

  /// 释放资源
  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}

/// WebSocket消息
class WebSocketMessage {
  final String type;
  final int from;
  final int? to;
  final int? chatId;
  final String? content;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  WebSocketMessage({
    required this.type,
    required this.from,
    this.to,
    this.chatId,
    this.content,
    this.data,
    required this.timestamp,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] as String,
      from: json['from'] as int,
      to: json['to'] as int?,
      chatId: json['chat_id'] as int?,
      content: json['content'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'from': from,
      if (to != null) 'to': to,
      if (chatId != null) 'chat_id': chatId,
      if (content != null) 'content': content,
      if (data != null) 'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get isMessage => type == 'message';
  bool get isTyping => type == 'typing';
  bool get isRead => type == 'read';
  bool get isUserStatus => type == 'user_status';
  bool get isNotification => type == 'notification';
  bool get isMateRequest => type == 'mate_request';
}
