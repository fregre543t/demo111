import 'package:get/get.dart';
import '../../../services/api_service.dart';

class AdminStatsController extends GetxController {
  final ApiService _apiService = Get.find();
  final RxBool isLoading = false.obs;
  final RxInt userCount = 0.obs;
  final RxInt messageCount = 0.obs;
  final RxInt roomCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('/admin/stats');
      if (response.statusCode == 200) {
        userCount.value = response.data['users'] ?? 0;
        messageCount.value = response.data['messages'] ?? 0;
        roomCount.value = response.data['rooms'] ?? 0;
      }
    } catch (e) {
      Get.snackbar('错误', '加载统计失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
