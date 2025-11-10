import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../../services/session_service.dart';

class SplashController extends GetxController {
  SplashController({
    SessionService? sessionService,
    ApiService? apiService,
  })  : _sessionService = sessionService ?? Get.find<SessionService>(),
        _apiService = apiService ?? Get.find<ApiService>();

  final SessionService _sessionService;
  final ApiService _apiService;

  final RxString status = '正在初始化...'.obs;

  @override
  void onReady() {
    super.onReady();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      status.value = '正在检查登录状态...';
      if (_sessionService.token.value != null) {
        await _apiService.fetchMe();
        Get.offAllNamed(AppRoutes.chat);
      } else {
        Get.offAllNamed(AppRoutes.auth);
      }
    } catch (error) {
      status.value = '初始化失败: $error';
      await Future<void>.delayed(const Duration(seconds: 1));
      Get.offAllNamed(AppRoutes.auth);
    }
  }
}
