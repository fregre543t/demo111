import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_controller.dart';

class UsersView extends GetView<AdminController> {
  const UsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.loadUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户管理'),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('总数: ${controller.totalUsers.value}'),
                ),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return const Center(child: Text('暂无用户'));
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  final user = controller.users[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          user['avatar'] ?? '',
                        ),
                      ),
                      title: Text(user['nickname'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@${user['username'] ?? ''}'),
                          Text(
                            '注册时间: ${_formatDate(user['created_at'])}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (user['is_online'] == true)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '在线',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (user['is_admin'] == true)
                            const Icon(Icons.admin_panel_settings,
                                color: Colors.orange),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: ListTile(
                                  leading: Icon(
                                    user['is_admin'] == true
                                        ? Icons.remove_moderator
                                        : Icons.admin_panel_settings,
                                  ),
                                  title: Text(
                                    user['is_admin'] == true
                                        ? '取消管理员'
                                        : '设为管理员',
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap: () {
                                  controller.toggleUserAdmin(
                                    user['id'],
                                    user['is_admin'] ?? false,
                                  );
                                },
                              ),
                              PopupMenuItem(
                                child: const ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('删除用户',
                                      style: TextStyle(color: Colors.red)),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap: () {
                                  _showDeleteConfirmation(context, user['id']);
                                },
                              ),
                            ],
                          ),
                        ],
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
                    controller.loadUsers(page: controller.currentPage.value - 1);
                  }
                : null,
          ),
          Obx(() => Text('第 ${controller.currentPage.value} 页')),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              controller.loadUsers(page: controller.currentPage.value + 1);
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
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return '';
    }
  }

  void _showDeleteConfirmation(BuildContext context, int userId) {
    Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这个用户吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                controller.deleteUser(userId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        ),
      );
    });
  }
}
