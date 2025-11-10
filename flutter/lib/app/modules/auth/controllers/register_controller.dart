import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterController extends GetxController {
  final AuthController _authController = Get.find();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nicknameController = TextEditingController();

  void register() {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      Get.snackbar('错误', '请填写必填项');
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar('错误', '密码长度至少6位');
      return;
    }

    _authController.register(
      usernameController.text,
      emailController.text,
      passwordController.text,
      nicknameController.text.isEmpty ? null : nicknameController.text,
    );
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nicknameController.dispose();
    super.onClose();
  }
}
