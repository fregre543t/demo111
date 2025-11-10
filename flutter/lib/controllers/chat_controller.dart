import 'package:get/get.dart';
import 'package:chat_app/services/websocket_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/services/api_service.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';

class ChatController extends GetxController {
  final WebSocketService _wsService = Get.put(WebSocketService());
  final StorageService _storage = Get.find();
  
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxString currentUserId = ''.obs;
  final RxString currentUsername = ''.obs;
  final RxString messageText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    _loadMessages();
    _loadUsers();
  }

  void _loadUserInfo() {
    final user = _storage.getUser();
    if (user != null) {
      currentUserId.value = user['id'] ?? '';
      currentUsername.value = user['username'] ?? '';
      _connectWebSocket();
    }
  }

  void _connectWebSocket() {
    if (currentUserId.value.isNotEmpty) {
      _wsService.connect(currentUserId.value);
      // 监听WebSocket消息
      ever(_wsService.messages, (List<MessageModel> newMessages) {
        messages.assignAll(newMessages);
      });
    }
  }

  Future<void> _loadMessages() async {
    try {
      final messageList = await ApiService.getMessages();
      messages.value = messageList.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      print('加载消息失败: $e');
    }
  }

  Future<void> _loadUsers() async {
    try {
      final userList = await ApiService.getUsers();
      users.value = userList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('加载用户失败: $e');
    }
  }

  void sendMessage() {
    if (messageText.value.trim().isEmpty) return;
    
    _wsService.sendMessage(messageText.value.trim());
    messageText.value = '';
  }

  void updateMessageText(String text) {
    messageText.value = text;
  }

  @override
  void onClose() {
    _wsService.disconnect();
    super.onClose();
  }
}
