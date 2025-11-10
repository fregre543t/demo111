import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../config/app_config.dart';
import '../../../data/models/message.dart';
import '../../../data/providers/api_client.dart';
import '../../auth/controllers/auth_controller.dart';

class ChatController extends GetxController {
  ChatController(this.roomId);

  final String roomId;
  final ApiClient _api = ApiClient();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnected = false.obs;
  final RxString error = ''.obs;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    connect();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    error.value = '';
    try {
      messages.assignAll(await _api.fetchMessages(roomId));
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void connect() {
    final token = _authController.token.value;
    if (token == null) {
      error.value = '未登录，无法连接';
      return;
    }
    final wsUrl = AppConfig.buildWsUrl(roomId, token);
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    isConnected.value = true;
    _subscription = _channel!.stream.listen(
      (event) {
        try {
          final payload = event is String
              ? event
              : String.fromCharCodes(event as List<int>);
          final data = jsonDecode(payload) as Map<String, dynamic>;
          messages.add(ChatMessage.fromJson(data));
        } catch (_) {}
      },
      onError: (Object e) {
        error.value = e.toString();
        isConnected.value = false;
      },
      onDone: () {
        isConnected.value = false;
      },
    );
  }

  void sendMessage(String content) {
    if (content.trim().isEmpty || _channel == null) {
      return;
    }
    final payload = jsonEncode({'type': 'message', 'content': content});
    _channel!.sink.add(payload);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _channel?.sink.close();
    super.onClose();
  }
}
