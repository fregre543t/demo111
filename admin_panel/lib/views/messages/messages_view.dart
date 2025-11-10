import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';

class MessagesView extends GetView<AdminController> {
  const MessagesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.loadMessages();

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息管理'),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('总数: ${controller.totalMessages.value}'),
                ),
              )),
        ],
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
                  final fromUser = message['from_user'] ?? {};
                  final toUser = message['to_user'] ?? {};

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${fromUser['nickname'] ?? ''} → ${toUser['nickname'] ?? ''}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            _formatDate(message['created_at']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            message['content'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getMessageTypeColor(
                                      message['message_type']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getMessageTypeText(message['message_type']),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (message['is_read'] == true)
                                const Icon(Icons.done_all,
                                    size: 16, color: Colors.blue)
                              else
                                const Icon(Icons.done,
                                    size: 16, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showDeleteConfirmation(context, message['id']);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            _buildPagination(),
          ],
        );
      }),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.currentPage.value > 1
                ? () {
                    controller.loadMessages(
                        page: controller.currentPage.value - 1);
                  }
                : null,
          ),
          Obx(() => Text('第 ${controller.currentPage.value} 页')),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              controller.loadMessages(page: controller.currentPage.value + 1);
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MM-dd HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }

  Color _getMessageTypeColor(String? type) {
    switch (type) {
      case 'text':
        return Colors.blue;
      case 'image':
        return Colors.green;
      case 'file':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getMessageTypeText(String? type) {
    switch (type) {
      case 'text':
        return '文本';
      case 'image':
        return '图片';
      case 'file':
        return '文件';
      default:
        return '未知';
    }
  }

  void _showDeleteConfirmation(BuildContext context, int messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条消息吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteMessage(messageId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
