import 'package:get/get.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import 'auth_controller.dart';

class ChatController extends GetxController {
  final ApiService _apiService = Get.find();
  final WebSocketService _wsService = Get.find();
  final AuthController _authController = Get.find();

  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxList<Message> messages = <Message>[].obs;
  final RxList<User> onlineUsers = <User>[].obs;
  final Rx<User?> currentChatUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    loadOnlineUsers();
    getUnreadCount();
    
    // 监听WebSocket消息
    ever(_wsService.messages, (_) {
      if (currentChatUser.value != null) {
        _handleNewMessage();
      }
      loadConversations();
    });
  }

  void _handleNewMessage() {
    final newMessages = _wsService.messages
        .where((msg) =>
            (msg.fromUserId == currentChatUser.value!.id &&
                msg.toUserId == _authController.currentUser.value!.id) ||
            (msg.fromUserId == _authController.currentUser.value!.id &&
                msg.toUserId == currentChatUser.value!.id))
        .toList();
    
    for (var msg in newMessages) {
      if (!messages.any((m) => 
          m.fromUserId == msg.fromUserId && 
          m.toUserId == msg.toUserId && 
          m.content == msg.content &&
          m.createdAt.difference(msg.createdAt).abs().inSeconds < 2)) {
        messages.insert(0, msg);
      }
    }
  }

  Future<void> loadConversations() async {
    try {
      conversations.value = await _apiService.getConversations();
    } catch (e) {
      print('加载会话列表失败: $e');
    }
  }

  Future<void> loadOnlineUsers() async {
    try {
      onlineUsers.value = await _apiService.getOnlineUsers();
    } catch (e) {
      print('加载在线用户失败: $e');
    }
  }

  Future<void> loadMessages(User user) async {
    try {
      isLoading.value = true;
      currentChatUser.value = user;
      messages.value = await _apiService.getMessages(user.id);
      messages.value = messages.reversed.toList();
      
      // 标记为已读
      await _apiService.markAsRead(user.id);
      await getUnreadCount();
    } catch (e) {
      Get.snackbar('错误', '加载消息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String content) async {
    if (currentChatUser.value == null || content.trim().isEmpty) return;

    try {
      // 通过WebSocket发送
      _wsService.sendMessage(currentChatUser.value!.id, content);
      
      // 同时保存到数据库
      final message = await _apiService.sendMessage(
        currentChatUser.value!.id,
        content,
        'text',
      );
      
      // 添加到消息列表
      messages.insert(0, message);
      
      // 刷新会话列表
      loadConversations();
    } catch (e) {
      Get.snackbar('错误', '发送失败: $e');
    }
  }

  Future<void> searchUsers(String keyword) async {
    try {
      final users = await _apiService.searchUsers(keyword);
      // 可以在这里处理搜索结果
      return;
    } catch (e) {
      Get.snackbar('错误', '搜索失败: $e');
    }
  }

  Future<void> getUnreadCount() async {
    try {
      unreadCount.value = await _apiService.getUnreadCount();
    } catch (e) {
      print('获取未读数失败: $e');
    }
  }

  void startChat(User user) {
    currentChatUser.value = user;
    loadMessages(user);
  }

  bool isUserOnline(int userId) {
    return _wsService.onlineUsers.contains(userId) ||
        onlineUsers.any((u) => u.id == userId && u.isOnline);
  }
}
