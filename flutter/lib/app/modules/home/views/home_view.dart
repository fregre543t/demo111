import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../services/auth_service.dart';
import '../../../../app/routes/app_routes.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天室'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Get.toNamed(AppRoutes.PROFILE),
          ),
          if (authService.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Get.toNamed(AppRoutes.ADMIN),
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.rooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('暂无聊天室'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.createRoom,
                  child: const Text('创建聊天室'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadRooms,
          child: ListView.builder(
            itemCount: controller.rooms.length,
            itemBuilder: (context, index) {
              final room = controller.rooms[index];
              return ListTile(
                leading: const Icon(Icons.chat_bubble_outline),
                title: Text(room.name),
                subtitle: room.description != null ? Text(room.description!) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => controller.enterRoom(room),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.createRoom,
        child: const Icon(Icons.add),
      ),
    );
  }
}
