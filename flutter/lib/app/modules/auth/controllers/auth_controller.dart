import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_model.dart';
import '../../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find();
  final AuthService _authService = Get.find();

  final RxBool isLoading = false.obs;

  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = UserModel.fromJson(response.data['user']);
        _authService.setUser(user, token);
        Get.offAllNamed(AppRoutes.HOME);
        Get.snackbar('成功', '登录成功');
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String username, String email, String password, String? nickname) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'nickname': nickname,
      });

      if (response.statusCode == 201) {
        Get.snackbar('成功', '注册成功，请登录');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('错误', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
