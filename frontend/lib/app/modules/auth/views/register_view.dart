import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late final AuthController _authController;
  final RxBool _obscure = true.obs;
  final RxBool _confirmObscure = true.obs;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final success = await _authController.register(
      _usernameController.text.trim(),
      _passwordController.text,
    );
    if (success) {
      Get.offAllNamed(Routes.home);
    } else if (_authController.error.value.isNotEmpty) {
      Get.snackbar(
        '注册失败',
        _authController.error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
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
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: '用户名'),
                    validator: (value) {
                      if (value == null || value.trim().length < 3) {
                        return '用户名至少 3 个字符';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: '密码',
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
                        if (value == null || value.length < 6) {
                          return '密码至少 6 位';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => TextFormField(
                      controller: _confirmController,
                      decoration: InputDecoration(
                        labelText: '确认密码',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmObscure.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _confirmObscure.toggle,
                        ),
                      ),
                      obscureText: _confirmObscure.value,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return '两次密码不一致';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => ElevatedButton(
                      onPressed: _authController.isLoading.value
                          ? null
                          : _submit,
                      child: _authController.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('注册'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('已有账号？去登录'),
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
