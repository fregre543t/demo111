import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.isLoginMode.value ? '登录' : '注册'),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: controller.usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.validateUsername,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: controller.passwordController,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: controller.validatePassword,
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => ElevatedButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (controller.formKey.currentState?.validate() ??
                                  false) {
                                controller.submit(
                                  username:
                                      controller.usernameController.text.trim(),
                                  password:
                                      controller.passwordController.text.trim(),
                                );
                              }
                            },
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        controller.isLoginMode.value ? '登录' : '注册并登录',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final message = controller.errorMessage.value;
                    if (message.isEmpty) return const SizedBox.shrink();
                    return Text(
                      message,
                      style: const TextStyle(color: Colors.redAccent),
                    );
                  }),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: controller.toggleMode,
                    child: Obx(
                      () => Text(
                        controller.isLoginMode.value
                            ? '没有账号？点击注册'
                            : '已有账号？前往登录',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
