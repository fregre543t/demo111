import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message.dart';
import 'api_service.dart';

class WebSocketService extends GetxService {
  static const String wsUrl = 'ws://localhost:8080/api/ws';
  
  WebSocketChannel? _channel;
  final _messageController = <Message>[].obs;
  final _onlineUsers = <int>[].obs;
  final _isConnected = false.obs;

  List<Message> get messages => _messageController;
  List<int> get onlineUsers => _onlineUsers;
  bool get isConnected => _isConnected.value;

  void connect(String token) {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$wsUrl?token=$token'),
      );

      _isConnected.value = true;
      
      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          print('WebSocket错误: $error');
          _isConnected.value = false;
        },
        onDone: () {
          print('WebSocket连接关闭');
          _isConnected.value = false;
          _reconnect(token);
        },
      );

      print('WebSocket连接成功');
    } catch (e) {
      print('WebSocket连接失败: $e');
      _isConnected.value = false;
    }
  }

  void _reconnect(String token) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!_isConnected.value) {
        print('尝试重新连接WebSocket...');
        connect(token);
      }
    });
  }

  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data);
      final type = json['type'];

      switch (type) {
        case 'message':
          final message = Message(
            fromUserId: json['from_user_id'],
            toUserId: json['to_user_id'],
            content: json['content'],
            messageType: json['message_type'] ?? 'text',
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              json['timestamp'] * 1000,
            ),
          );
          _messageController.add(message);
          break;
          
        case 'online':
          final userId = json['from_user_id'];
          if (!_onlineUsers.contains(userId)) {
            _onlineUsers.add(userId);
          }
          break;
          
        case 'offline':
          final userId = json['from_user_id'];
          _onlineUsers.remove(userId);
          break;
          
        case 'typing':
          // 处理正在输入状态
          break;
      }
    } catch (e) {
      print('处理WebSocket消息失败: $e');
    }
  }

  void sendMessage(int toUserId, String content, {String type = 'message'}) {
    if (_channel == null || !_isConnected.value) {
      print('WebSocket未连接');
      return;
    }

    final message = {
      'type': type,
      'to_user_id': toUserId,
      'content': content,
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    };

    _channel!.sink.add(jsonEncode(message));
  }

  void sendTyping(int toUserId) {
    sendMessage(toUserId, '', type: 'typing');
  }

  void clearMessages() {
    _messageController.clear();
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
