import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('聊天室 - ${auth.user.value?.username ?? ''}')),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Get.toNamed(Routes.adminDashboard),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              Get.offAllNamed(Routes.login);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('加载失败：${controller.error.value}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchRooms,
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
        if (controller.rooms.isEmpty) {
          return const Center(child: Text('暂无可用房间'));
        }
        return RefreshIndicator(
          onRefresh: controller.fetchRooms,
          child: ListView.builder(
            itemCount: controller.rooms.length,
            itemBuilder: (context, index) {
              final room = controller.rooms[index];
              return ListTile(
                title: Text(room.name),
                subtitle: Text(room.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.toNamed(
                  Routes.chat,
                  parameters: {'roomId': room.id},
                  arguments: room,
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.fetchRooms,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
