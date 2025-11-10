import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/environment.dart';
import '../data/models/message_model.dart';
import '../services/session_service.dart';

typedef MessageHandler = void Function(Message message);

class WebSocketService extends GetxService {
  WebSocketService({SessionService? sessionService})
      : _sessionService = sessionService ?? Get.find<SessionService>();

  final SessionService _sessionService;

  final RxBool isConnected = false.obs;
  final RxBool isConnecting = false.obs;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  MessageHandler? _onMessage;

  String? _currentRoomId;

  Future<void> connect({
    String? roomId,
    MessageHandler? onMessage,
  }) async {
    final token = _sessionService.token.value;
    if (token == null || token.isEmpty) {
      throw StateError('未登录，无法连接WebSocket');
    }
    await disconnect();

    final baseUri = Uri.parse(Environment.wsBaseUrl);
    final params = Map<String, String>.from(baseUri.queryParameters);
    params['token'] = token;
    if (roomId != null && roomId.isNotEmpty) {
      params['room_id'] = roomId;
      _currentRoomId = roomId;
    } else {
      params.remove('room_id');
      _currentRoomId = null;
    }

    final uri = baseUri.replace(queryParameters: params);
    _onMessage = onMessage;

    isConnecting.value = true;
    try {
      _channel = WebSocketChannel.connect(uri);
      _subscription = _channel!.stream.listen(
        (event) {
          final payload = event is String ? jsonDecode(event) : event;
          if (payload is Map<String, dynamic>) {
            final message = Message.fromJson(payload);
            _onMessage?.call(message);
          }
        },
        onDone: () {
          isConnected.value = false;
        },
        onError: (Object error) {
          isConnected.value = false;
        },
      );
      isConnected.value = true;
    } finally {
      isConnecting.value = false;
    }
  }

  void sendChatMessage(String content) {
    if (!isConnected.value) return;
    final payload = {
      'type': 'chat_message',
      'content': content,
      if (_currentRoomId != null) 'room_id': _currentRoomId,
    };
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
