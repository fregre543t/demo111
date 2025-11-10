import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chat_app/models/message_model.dart';

class WebSocketService extends GetxService {
  WebSocketChannel? _channel;
  final RxBool isConnected = false.obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  // 连接WebSocket
  void connect(String userId) {
    try {
      final uri = Uri.parse('ws://localhost:8080/ws?user_id=$userId');
      _channel = WebSocketChannel.connect(uri);
      isConnected.value = true;

      // 监听消息
      _channel!.stream.listen(
        (data) {
          try {
            final messageData = jsonDecode(data);
            final message = MessageModel.fromJson(messageData);
            messages.add(message);
          } catch (e) {
            print('解析消息失败: $e');
          }
        },
        onError: (error) {
          print('WebSocket错误: $error');
          isConnected.value = false;
        },
        onDone: () {
          print('WebSocket连接关闭');
          isConnected.value = false;
        },
      );
    } catch (e) {
      print('WebSocket连接失败: $e');
      isConnected.value = false;
    }
  }

  // 发送消息
  void sendMessage(String content, {String type = 'text'}) {
    if (_channel != null && isConnected.value) {
      final message = {
        'content': content,
        'type': type,
      };
      _channel!.sink.add(jsonEncode(message));
    }
  }

  // 断开连接
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
