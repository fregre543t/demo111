import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: controller.usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final authController = Get.find<AuthController>();
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value
                      ? null
                      : controller.login,
                  child: authController.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('登录'),
                ),
              );
            }),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed('/register'),
              child: const Text('还没有账号？立即注册'),
            ),
          ],
        ),
      ),
    );
  }
}
