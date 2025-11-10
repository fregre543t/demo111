import 'package:get/get.dart';
import 'package:chat_app/services/api_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/routes/app_routes.dart';

class AuthController extends GetxController {
  final StorageService _storage = Get.find();
  final RxBool isLoading = false.obs;

  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await ApiService.login(username, password);
      
      if (response.containsKey('error')) {
        Get.snackbar('错误', response['error']);
      } else {
        await _storage.saveToken(response['token']);
        await _storage.saveUser(response['user']);
        Get.offAllNamed(AppRoutes.CHAT);
      }
    } catch (e) {
      Get.snackbar('错误', '登录失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String username, String password, String email) async {
    try {
      isLoading.value = true;
      final response = await ApiService.register(username, password, email);
      
      if (response.containsKey('error')) {
        Get.snackbar('错误', response['error']);
      } else {
        await _storage.saveToken(response['token']);
        await _storage.saveUser(response['user']);
        Get.offAllNamed(AppRoutes.CHAT);
      }
    } catch (e) {
      Get.snackbar('错误', '注册失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _storage.removeToken();
    _storage.removeUser();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
