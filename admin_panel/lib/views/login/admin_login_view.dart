import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/admin_api_service.dart';

class AdminLoginView extends StatelessWidget {
  const AdminLoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final isLoading = false.obs;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade400,
              Colors.indigo.shade400,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '管理后台',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '请使用管理员账号登录',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          labelText: '用户名',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: '密码',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Obx(() => SizedBox(
                          width: 300,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading.value
                                ? null
                                : () async {
                                    if (usernameController.text.isEmpty ||
                                        passwordController.text.isEmpty) {
                                      Get.snackbar('错误', '请填写用户名和密码');
                                      return;
                                    }

                                    try {
                                      isLoading.value = true;
                                      final apiService = Get.find<AdminApiService>();
                                      final response = await apiService.login(
                                        usernameController.text,
                                        passwordController.text,
                                      );

                                      final user = response['user'];
                                      if (user['is_admin'] != true) {
                                        Get.snackbar('错误', '您没有管理员权限');
                                        await apiService.clearToken();
                                        return;
                                      }

                                      Get.offAllNamed('/dashboard');
                                    } catch (e) {
                                      Get.snackbar('错误', '登录失败: $e');
                                    } finally {
                                      isLoading.value = false;
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('登录',
                                    style: TextStyle(fontSize: 16)),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
