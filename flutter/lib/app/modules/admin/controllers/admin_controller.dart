import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';

class AdminController extends GetxController {
  void navigateToUsers() {
    Get.toNamed(AppRoutes.ADMIN_USERS);
  }

  void navigateToMessages() {
    Get.toNamed(AppRoutes.ADMIN_MESSAGES);
  }

  void navigateToRooms() {
    Get.toNamed(AppRoutes.ADMIN_ROOMS);
  }

  void navigateToStats() {
    Get.toNamed(AppRoutes.ADMIN_STATS);
  }
}
