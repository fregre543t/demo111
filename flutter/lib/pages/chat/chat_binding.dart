import 'package:get/get.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/controllers/auth_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => AuthController());
  }
}
