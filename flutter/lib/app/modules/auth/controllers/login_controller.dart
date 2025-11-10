import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginController extends GetxController {
  final AuthController _authController = Get.find();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void login() {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('错误', '请输入用户名和密码');
      return;
    }
    _authController.login(usernameController.text, passwordController.text);
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
