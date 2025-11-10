import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/controllers/admin_controller.dart';
import 'package:chat_app/routes/app_routes.dart';

class AdminLoginPage extends StatelessWidget {
  const AdminLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    final AdminController controller = Get.put(AdminController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理员登录'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '管理员用户名',
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
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        controller.login(
                          _usernameController.text,
                          _passwordController.text,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('登录'),
              ),
            )),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
              child: const Text('返回用户登录'),
            ),
          ],
        ),
      ),
    );
  }
}
