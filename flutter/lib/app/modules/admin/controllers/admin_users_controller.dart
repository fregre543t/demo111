import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../models/user_model.dart';

class AdminUsersController extends GetxController {
  final ApiService _apiService = Get.find();
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers({int page = 1}) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('/admin/users', queryParameters: {
        'page': page,
        'page_size': 20,
      });

      if (response.statusCode == 200) {
        users.value = (response.data['users'] as List)
            .map((json) => UserModel.fromJson(json))
            .toList();
        currentPage.value = response.data['page'] ?? 1;
        totalPages.value = (response.data['total'] / 20).ceil();
      }
    } catch (e) {
      Get.snackbar('错误', '加载用户失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateUser(int userId, {String? nickname, bool? isAdmin, bool? isActive}) async {
    try {
      final data = <String, dynamic>{};
      if (nickname != null) data['nickname'] = nickname;
      if (isAdmin != null) data['is_admin'] = isAdmin;
      if (isActive != null) data['is_active'] = isActive;

      final response = await _apiService.dio.put('/admin/users/$userId', data: data);
      if (response.statusCode == 200) {
        Get.snackbar('成功', '更新成功');
        loadUsers(page: currentPage.value);
      }
    } catch (e) {
      Get.snackbar('错误', '更新失败: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final response = await _apiService.dio.delete('/admin/users/$userId');
      if (response.statusCode == 200) {
        Get.snackbar('成功', '删除成功');
        loadUsers(page: currentPage.value);
      }
    } catch (e) {
      Get.snackbar('错误', '删除失败: $e');
    }
  }
}
