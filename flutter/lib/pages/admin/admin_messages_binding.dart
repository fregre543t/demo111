import 'package:get/get.dart';
import 'package:chat_app/controllers/admin_controller.dart';

class AdminMessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminController());
  }
}
