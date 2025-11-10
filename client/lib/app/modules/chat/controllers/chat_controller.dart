import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/message_model.dart';
import '../../../data/models/room_model.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../../services/session_service.dart';
import '../../../services/websocket_service.dart';

class ChatController extends GetxController {
  ChatController({
    ApiService? apiService,
    SessionService? sessionService,
    WebSocketService? webSocketService,
  })  : _apiService = apiService ?? Get.find<ApiService>(),
        _sessionService = sessionService ?? Get.find<SessionService>(),
        _webSocketService = webSocketService ?? Get.find<WebSocketService>();

  final ApiService _apiService;
  final SessionService _sessionService;
  final WebSocketService _webSocketService;

  final RxList<Message> messages = <Message>[].obs;
  final RxList<Room> rooms = <Room>[].obs;
  final Rx<Room?> selectedRoom = Rx<Room?>(null);
  final RxBool isLoadingHistory = false.obs;
  final RxBool isSending = false.obs;

  final TextEditingController messageController = TextEditingController();

  final Set<String> _messageIds = <String>{};

  User? get currentUser => _sessionService.currentUser.value;
  bool get isAdmin => currentUser?.role == 'admin';

  @override
  void onReady() {
    super.onReady();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadRooms();
    await _loadMessages();
    await _connectSocket();
  }

  Future<void> _loadRooms() async {
    try {
      if (isAdmin) {
        final result = await _apiService.fetchRooms();
        rooms.assignAll(result);
      } else {
        rooms.assignAll([
          Room(
            id: 'default',
            name: '公共大厅',
            createdAt: DateTime.now(),
          ),
        ]);
      }
      selectedRoom.value = rooms.isNotEmpty ? rooms.first : null;
    } catch (error) {
      Get.snackbar('提示', '加载房间失败：$error');
      if (rooms.isEmpty) {
        rooms.assignAll([
          Room(
            id: 'default',
            name: '公共大厅',
            createdAt: DateTime.now(),
          ),
        ]);
        selectedRoom.value = rooms.first;
      }
    }
  }

  Future<void> _loadMessages() async {
    if (selectedRoom.value == null) return;
    try {
      isLoadingHistory.value = true;
      final result = await _apiService.fetchMessages(
        roomId: selectedRoom.value?.id,
      );
      _messageIds
        ..clear()
        ..addAll(result.map((message) => message.id));
      messages.assignAll(result);
    } catch (error) {
      Get.snackbar('提示', '加载聊天记录失败：$error');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> _connectSocket() async {
    try {
      await _webSocketService.connect(
        roomId: selectedRoom.value?.id,
        onMessage: _handleIncomingMessage,
      );
    } catch (error) {
      Get.snackbar('提示', '连接实时通道失败：$error');
    }
  }

  void _handleIncomingMessage(Message message) {
    if (message.id.isEmpty || _messageIds.contains(message.id)) {
      return;
    }
    _messageIds.add(message.id);
    messages.add(message);
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) {
      return;
    }
    try {
      isSending.value = true;
      _webSocketService.sendChatMessage(content);
      messageController.clear();
    } catch (error) {
      Get.snackbar('错误', '发送失败：$error');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> switchRoom(Room room) async {
    if (room.id == selectedRoom.value?.id) return;
    selectedRoom.value = room;
    messages.clear();
    _messageIds.clear();
    await _loadMessages();
    await _connectSocket();
  }

  Future<void> refreshMessages() async {
    await _loadMessages();
  }

  void goToAdmin() {
    if (isAdmin) {
      Get.toNamed(AppRoutes.admin);
    } else {
      Get.snackbar('提示', '只有管理员可以访问后台');
    }
  }

  void logout() {
    _sessionService.clear();
    _webSocketService.disconnect();
    Get.offAllNamed(AppRoutes.auth);
  }

  @override
  void onClose() {
    messageController.dispose();
    _webSocketService.disconnect();
    super.onClose();
  }
}
