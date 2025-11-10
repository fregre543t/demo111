import 'package:get/get.dart';
import '../services/admin_api_service.dart';

class AdminController extends GetxController {
  final AdminApiService _apiService = Get.find();

  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;
  final RxList users = [].obs;
  final RxList messages = [].obs;
  final RxBool isLoading = false.obs;
  final RxInt totalUsers = 0.obs;
  final RxInt totalMessages = 0.obs;
  final RxInt currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    try {
      isLoading.value = true;
      stats.value = await _apiService.getDashboardStats();
    } catch (e) {
      Get.snackbar('错误', '加载统计数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUsers({int page = 1}) async {
    try {
      isLoading.value = true;
      currentPage.value = page;
      final response = await _apiService.getAllUsers(page: page);
      users.value = response['users'] ?? [];
      totalUsers.value = response['total'] ?? 0;
    } catch (e) {
      Get.snackbar('错误', '加载用户列表失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMessages({int page = 1}) async {
    try {
      isLoading.value = true;
      currentPage.value = page;
      final response = await _apiService.getAllMessages(page: page);
      messages.value = response['messages'] ?? [];
      totalMessages.value = response['total'] ?? 0;
    } catch (e) {
      Get.snackbar('错误', '加载消息列表失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _apiService.deleteUser(userId);
      Get.snackbar('成功', '用户已删除');
      loadUsers(page: currentPage.value);
      loadDashboardStats();
    } catch (e) {
      Get.snackbar('错误', '删除用户失败: $e');
    }
  }

  Future<void> toggleUserAdmin(int userId, bool isAdmin) async {
    try {
      await _apiService.updateUserStatus(userId, !isAdmin);
      Get.snackbar('成功', '用户权限已更新');
      loadUsers(page: currentPage.value);
    } catch (e) {
      Get.snackbar('错误', '更新失败: $e');
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await _apiService.deleteMessage(messageId);
      Get.snackbar('成功', '消息已删除');
      loadMessages(page: currentPage.value);
      loadDashboardStats();
    } catch (e) {
      Get.snackbar('错误', '删除消息失败: $e');
    }
  }
}
