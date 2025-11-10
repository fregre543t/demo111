import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../services/api_service.dart';
import '../../../services/session_service.dart';

class AuthController extends GetxController {
  AuthController({
    ApiService? apiService,
    SessionService? sessionService,
  })  : _apiService = apiService ?? Get.find<ApiService>(),
        _sessionService = sessionService ?? Get.find<SessionService>();

  final ApiService _apiService;
  final SessionService _sessionService;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoginMode = true.obs;

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (username.isEmpty || password.isEmpty) {
      errorMessage.value = '用户名和密码不能为空';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (isLoginMode.value) {
        await _apiService.login(username, password);
      } else {
        await _apiService.register(username, password);
        await _apiService.login(username, password);
      }

      Get.offAllNamed(AppRoutes.chat);
    } catch (error) {
      errorMessage.value = '操作失败：$error';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    errorMessage.value = '';
  }

  void logout() {
    _sessionService.clear();
    Get.offAllNamed(AppRoutes.auth);
  }

  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入用户名';
    }
    if (value.length < 3) {
      return '用户名至少3个字符';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码至少6个字符';
    }
    return null;
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
