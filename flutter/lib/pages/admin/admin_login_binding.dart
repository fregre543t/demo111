import 'package:get/get.dart';
import 'package:chat_app/controllers/admin_controller.dart';

class AdminLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminController());
  }
}
