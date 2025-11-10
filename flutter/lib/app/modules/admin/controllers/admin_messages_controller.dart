import 'package:get/get.dart';
import '../../../services/api_service.dart';
import '../../../models/message_model.dart';

class AdminMessagesController extends GetxController {
  final ApiService _apiService = Get.find();
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadMessages();
  }

  Future<void> loadMessages({int page = 1}) async {
    try {
      isLoading.value = true;
      final response = await _apiService.dio.get('/admin/messages', queryParameters: {
        'page': page,
        'page_size': 50,
      });

      if (response.statusCode == 200) {
        messages.value = (response.data['messages'] as List)
            .map((json) => MessageModel.fromJson(json))
            .toList();
        currentPage.value = response.data['page'] ?? 1;
        totalPages.value = (response.data['total'] / 50).ceil();
      }
    } catch (e) {
      Get.snackbar('错误', '加载消息失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.dio.delete('/admin/messages/$messageId');
      if (response.statusCode == 200) {
        Get.snackbar('成功', '删除成功');
        loadMessages(page: currentPage.value);
      }
    } catch (e) {
      Get.snackbar('错误', '删除失败: $e');
    }
  }
}
