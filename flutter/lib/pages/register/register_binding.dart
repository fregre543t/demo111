import 'package:get/get.dart';
import 'package:chat_app/controllers/auth_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}
