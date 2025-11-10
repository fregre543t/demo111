import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../services/websocket_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/room_model.dart';
import '../../../models/message_model.dart';

class ChatController extends GetxController {
  final ApiService _apiService = Get.find();
  final WebSocketService _wsService = Get.find();
  final AuthService _authService = Get.find();
  
  late RoomModel room;
  final messageController = TextEditingController();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnected = false.obs;
  StreamSubscription? _messageSubscription;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    room = Get.arguments as RoomModel;
    _initChat();
  }

  void _initChat() async {
    // 连接WebSocket
    _wsService.connect();
    isConnected.value = _wsService.isConnected.value;
    
    // 监听连接状态
    _wsService.isConnected.listen((connected) {
      isConnected.value = connected;
      if (connected) {
        // 加入聊天室
        _wsService.sendMessage({
          'type': 'join',
          'room_id': room.id,
        });
      }
    });

    // 监听消息
    _messageSubscription = _wsService.messageStream.listen((data) {
      if (data['type'] == 'message' && data['room_id'] == room.id) {
        if (data['message'] != null) {
          final message = MessageModel.fromJson(data['message']);
          messages.add(message);
          _scrollToBottom();
        }
      }
    });

    // 加载历史消息
    await loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('/rooms/${room.id}/messages');
      if (response.statusCode == 200) {
        messages.value = (response.data as List)
            .map((json) => MessageModel.fromJson(json))
            .toList();
        _scrollToBottom();
      }
    } catch (e) {
      Get.snackbar('错误', '加载消息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    if (!isConnected.value) {
      Get.snackbar('错误', 'WebSocket未连接');
      return;
    }

    _wsService.sendMessage({
      'type': 'message',
      'room_id': room.id,
      'content': messageController.text.trim(),
    });

    messageController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    _wsService.sendMessage({
      'type': 'leave',
      'room_id': room.id,
    });
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
