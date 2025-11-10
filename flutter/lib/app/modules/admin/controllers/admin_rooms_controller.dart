import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../models/room_model.dart';

class AdminRoomsController extends GetxController {
  final ApiService _apiService = Get.find();
  final RxList<RoomModel> rooms = <RoomModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRooms();
  }

  Future<void> loadRooms() async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('/admin/rooms');
      if (response.statusCode == 200) {
        rooms.value = (response.data as List)
            .map((json) => RoomModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      Get.snackbar('错误', '加载聊天室失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRoom(int roomId) async {
    try {
      final response = await _apiService.dio.delete('/admin/rooms/$roomId');
      if (response.statusCode == 200) {
        Get.snackbar('成功', '删除成功');
        loadRooms();
      }
    } catch (e) {
      Get.snackbar('错误', '删除失败: $e');
    }
  }
}
