import 'package:get/get.dart';

import '../modules/admin/controllers/admin_controller.dart';
import '../services/storage_service.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminController>()) {
      Get.put<AdminController>(
        AdminController(Get.find<StorageService>()),
        permanent: true,
      );
    }
  }
}
