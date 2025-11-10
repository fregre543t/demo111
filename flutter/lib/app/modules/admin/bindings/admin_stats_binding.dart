import 'package:get/get.dart';
import 'admin_stats_controller.dart';

class AdminStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AdminStatsController());
  }
}
