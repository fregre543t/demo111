import 'package:get/get.dart';
import 'package:chat_app/services/api_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/routes/app_routes.dart';

class AdminController extends GetxController {
  final StorageService _storage = Get.find();
  final RxBool isLoading = false.obs;
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<MessageModel> messages = <MessageModel>[].obs;

  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await ApiService.adminLogin(username, password);
      
      if (response.containsKey('error')) {
        Get.snackbar('错误', response['error']);
      } else {
        await _storage.saveAdminToken(response['token']);
        Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
      }
    } catch (e) {
      Get.snackbar('错误', '登录失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      final data = await ApiService.adminGetStats();
      stats.value = data;
    } catch (e) {
      print('加载统计信息失败: $e');
    }
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final userList = await ApiService.adminGetAllUsers();
      users.value = userList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('错误', '加载用户失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      final response = await ApiService.adminDeleteUser(userId);
      if (response.containsKey('error')) {
        Get.snackbar('错误', response['error']);
      } else {
        Get.snackbar('成功', '用户删除成功');
        await loadUsers();
      }
    } catch (e) {
      Get.snackbar('错误', '删除用户失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages() async {
    try {
      isLoading.value = true;
      final messageList = await ApiService.adminGetAllMessages();
      messages.value = messageList.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      Get.snackbar('错误', '加载消息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      isLoading.value = true;
      final response = await ApiService.adminDeleteMessage(messageId);
      if (response.containsKey('error')) {
        Get.snackbar('错误', response['error']);
      } else {
        Get.snackbar('成功', '消息删除成功');
        await loadMessages();
      }
    } catch (e) {
      Get.snackbar('错误', '删除消息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _storage.removeAdminToken();
    Get.offAllNamed(AppRoutes.ADMIN_LOGIN);
  }
}
