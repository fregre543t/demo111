import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../controllers/admin_controller.dart';

class AdminLoginView extends StatefulWidget {
  const AdminLoginView({super.key});

  @override
  State<AdminLoginView> createState() => _AdminLoginViewState();
}

class _AdminLoginViewState extends State<AdminLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final RxBool _obscure = true.obs;
  late final AdminController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminController>();
    if (_controller.isAuthenticated) {
      Future.microtask(() => Get.offAllNamed(Routes.adminDashboard));
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await _controller.login(_passwordController.text);
    if (success) {
      Get.offAllNamed(Routes.adminDashboard);
    } else if (_controller.error.value.isNotEmpty) {
      Get.snackbar(
        '管理员登录失败',
        _controller.error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('管理员登录')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: '管理员密码',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _obscure.toggle,
                        ),
                      ),
                      obscureText: _obscure.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入密码';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => ElevatedButton(
                      onPressed: _controller.isLoading.value ? null : _submit,
                      child: _controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('登录后台'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed(Routes.login),
                    child: const Text('返回用户登录'),
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
