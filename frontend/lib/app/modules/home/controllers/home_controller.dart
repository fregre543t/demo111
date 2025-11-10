import 'package:get/get.dart';

import '../../../data/models/room.dart';
import '../../../data/providers/api_client.dart';
import '../../auth/controllers/auth_controller.dart';

class HomeController extends GetxController {
  final ApiClient _api = ApiClient();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Room> rooms = <Room>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    if (!_authController.isAuthenticated) {
      rooms.clear();
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      rooms.assignAll(await _api.listRooms());
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
