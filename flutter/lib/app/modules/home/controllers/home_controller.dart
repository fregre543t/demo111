import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../models/room_model.dart';

class HomeController extends GetxController {
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
      final response = await _apiService.dio.get('/rooms');
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

  void createRoom() {
    final nameController = TextEditingController();
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('创建聊天室', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '聊天室名称',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _createRoom(value);
                    Get.back();
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        _createRoom(nameController.text);
                        Get.back();
                      }
                    },
                    child: const Text('创建'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createRoom(String name) async {
    try {
      final response = await _apiService.dio.post('/rooms', data: {
        'name': name,
        'is_public': true,
      });
      if (response.statusCode == 201) {
        loadRooms();
        Get.snackbar('成功', '聊天室创建成功');
      }
    } catch (e) {
      Get.snackbar('错误', '创建失败: $e');
    }
  }

  void enterRoom(RoomModel room) {
    Get.toNamed('/chat', arguments: room);
  }
}
