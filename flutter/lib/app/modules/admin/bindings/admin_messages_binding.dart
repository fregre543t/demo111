import 'package:get/get.dart';
import 'admin_messages_controller.dart';

class AdminMessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminMessagesController());
  }
}
