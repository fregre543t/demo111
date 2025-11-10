import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/routes/app_routes.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _controller.isLoading.value
                    ? null
                    : () {
                        _controller.login(
                          _usernameController.text,
                          _passwordController.text,
                        );
                      },
                child: _controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('登录'),
              ),
            )),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.REGISTER),
              child: const Text('还没有账号？立即注册'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.ADMIN_LOGIN),
              child: const Text('管理员登录'),
            ),
          ],
        ),
      ),
    );
  }
}
