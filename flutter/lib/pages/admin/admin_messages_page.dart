import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/controllers/admin_controller.dart';
import 'package:chat_app/models/message_model.dart';

class AdminMessagesPage extends StatelessWidget {
  const AdminMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    // 加载消息列表
    controller.loadMessages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息管理'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.messages.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.messages.isEmpty) {
          return const Center(child: Text('暂无消息'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadMessages(),
          child: ListView.builder(
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              final message = controller.messages[index];
              return _buildMessageCard(message, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildMessageCard(MessageModel message, AdminController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(message.username[0].toUpperCase()),
        ),
        title: Text(message.username),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(message.content),
            const SizedBox(height: 5),
            Text(
              DateFormat('yyyy-MM-dd HH:mm:ss').format(message.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: const Text('确认删除'),
                content: const Text('确定要删除这条消息吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      controller.deleteMessage(message.id);
                    },
                    child: const Text('删除', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
