import 'package:get/get.dart';
import 'admin_rooms_controller.dart';

class AdminRoomsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminRoomsController());
  }
}
