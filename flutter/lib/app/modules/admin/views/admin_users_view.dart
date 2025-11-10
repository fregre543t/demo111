import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_users_controller.dart';

class AdminUsersView extends GetView<AdminUsersController> {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户管理'),
        centerTitle: true,
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
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.nickname?.isNotEmpty == true
                          ? user.nickname![0].toUpperCase()
                          : user.username[0].toUpperCase()),
                    ),
                    title: Text(user.nickname ?? user.username),
                    subtitle: Text('@${user.username}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.isAdmin)
                          const Chip(
                            label: Text('管理员'),
                            backgroundColor: Colors.orange,
                            labelStyle: TextStyle(fontSize: 10),
                          ),
                        if (!user.isActive)
                          const Chip(
                            label: Text('已禁用'),
                            backgroundColor: Colors.red,
                            labelStyle: TextStyle(fontSize: 10),
                          ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('编辑'),
                              onTap: () => _showEditDialog(context, user),
                            ),
                            PopupMenuItem(
                              child: const Text('删除'),
                              onTap: () => _confirmDelete(context, user.id),
                            ),
                          ],
                        ),
                      ],
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
                          ? () => controller.loadUsers(page: controller.currentPage.value - 1)
                          : null,
                    ),
                    Text('${controller.currentPage.value} / ${controller.totalPages.value}'),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: controller.currentPage.value < controller.totalPages.value
                          ? () => controller.loadUsers(page: controller.currentPage.value + 1)
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

  void _showEditDialog(BuildContext context, user) {
    final nicknameController = TextEditingController(text: user.nickname);
    bool isAdmin = user.isAdmin;
    bool isActive = user.isActive;

    Get.dialog(
      Dialog(
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('编辑用户', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nicknameController,
                  decoration: const InputDecoration(labelText: '昵称'),
                ),
                CheckboxListTile(
                  title: const Text('管理员'),
                  value: isAdmin,
                  onChanged: (value) => setState(() => isAdmin = value ?? false),
                ),
                CheckboxListTile(
                  title: const Text('激活'),
                  value: isActive,
                  onChanged: (value) => setState(() => isActive = value ?? false),
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
                        controller.updateUser(
                          user.id,
                          nickname: nicknameController.text,
                          isAdmin: isAdmin,
                          isActive: isActive,
                        );
                        Get.back();
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int userId) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个用户吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteUser(userId);
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
