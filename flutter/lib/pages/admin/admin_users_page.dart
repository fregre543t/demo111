import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/controllers/admin_controller.dart';
import 'package:chat_app/models/user_model.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    // 加载用户列表
    controller.loadUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('用户管理'),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.users.isEmpty) {
          return const Center(child: Text('暂无用户'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadUsers(),
          child: ListView.builder(
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return _buildUserCard(user, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildUserCard(UserModel user, AdminController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isOnline ? Colors.green : Colors.grey,
          child: Text(user.username[0].toUpperCase()),
        ),
        title: Text(user.username),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('邮箱: ${user.email}'),
            Text('注册时间: ${DateFormat('yyyy-MM-dd HH:mm').format(user.createdAt)}'),
            Row(
              children: [
                Icon(
                  user.isOnline ? Icons.circle : Icons.circle_outlined,
                  size: 12,
                  color: user.isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 5),
                Text(
                  user.isOnline ? '在线' : '离线',
                  style: TextStyle(
                    color: user.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: const Text('确认删除'),
                content: Text('确定要删除用户 ${user.username} 吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      controller.deleteUser(user.id);
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
