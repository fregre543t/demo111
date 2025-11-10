import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';
import '../../../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find();
  final AuthService _authService = Get.find();
  final RxBool isLoading = false.obs;
  final nicknameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    nicknameController.text = _authService.currentUser.value?.nickname ?? '';
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.put('/user/profile', data: {
        'nickname': nicknameController.text,
      });

      if (response.statusCode == 200) {
        // 更新本地用户信息
        final user = _authService.currentUser.value;
        if (user != null) {
          final updatedUser = UserModel(
            id: user.id,
            username: user.username,
            email: user.email,
            nickname: nicknameController.text,
            avatar: user.avatar,
            isAdmin: user.isAdmin,
            createdAt: user.createdAt,
          );
          _authService.updateUser(updatedUser);
        }
        Get.snackbar('成功', '更新成功');
      }
    } catch (e) {
      Get.snackbar('错误', '更新失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authService.logout();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  @override
  void onClose() {
    nicknameController.dispose();
    super.onClose();
  }
}
