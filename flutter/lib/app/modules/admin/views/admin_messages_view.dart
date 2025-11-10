import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_messages_controller.dart';

class AdminMessagesView extends GetView<AdminMessagesController> {
  const AdminMessagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息管理'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.messages.isEmpty) {
          return const Center(child: Text('暂无消息'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(message.user?.nickname?.isNotEmpty == true
                          ? message.user!.nickname![0].toUpperCase()
                          : message.user?.username[0].toUpperCase() ?? '?'),
                    ),
                    title: Text(message.user?.nickname ?? message.user?.username ?? '未知用户'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.content),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('yyyy-MM-dd HH:mm:ss').format(
                            message.createdAt ?? DateTime.now(),
                          ),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, message.id),
                    ),
                  );
                },
              ),
            ),
            if (controller.totalPages.value > 1)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: controller.currentPage.value > 1
                          ? () => controller.loadMessages(page: controller.currentPage.value - 1)
                          : null,
                    ),
                    Text('${controller.currentPage.value} / ${controller.totalPages.value}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: controller.currentPage.value < controller.totalPages.value
                          ? () => controller.loadMessages(page: controller.currentPage.value + 1)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, int messageId) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条消息吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteMessage(messageId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
