import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../../app/routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find();

  @override
  void onInit() {
    super.onInit();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (_authService.isAuthenticated.value) {
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
