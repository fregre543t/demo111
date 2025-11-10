import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'storage_service.dart';

class WebSocketService extends GetxService {
  final StorageService _storage = Get.find();
  WebSocketChannel? _channel;
  final RxBool isConnected = false.obs;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect() {
    if (_channel != null && isConnected.value) {
      return;
    }

    final token = _storage.getToken();
    if (token == null) {
      Get.snackbar('错误', '未登录');
      return;
    }

    try {
      // WebSocket连接需要认证，通过查询参数或Header传递token
      // 由于web_socket_channel的限制，我们通过查询参数传递
      final uri = Uri.parse('ws://localhost:8080/api/ws?token=$token');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          try {
            final message = jsonDecode(data);
            _messageController.add(message);
          } catch (e) {
            print('解析消息错误: $e');
          }
        },
        onError: (error) {
          isConnected.value = false;
          Get.snackbar('错误', 'WebSocket连接错误: $error');
        },
        onDone: () {
          isConnected.value = false;
        },
      );

      isConnected.value = true;
    } catch (e) {
      Get.snackbar('错误', '连接失败: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    isConnected.value = false;
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null && isConnected.value) {
      _channel!.sink.add(jsonEncode(message));
    } else {
      Get.snackbar('错误', 'WebSocket未连接');
    }
  }

  @override
  void onClose() {
    disconnect();
    _messageController.close();
    super.onClose();
  }
}
