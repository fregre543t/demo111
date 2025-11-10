import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_rooms_controller.dart';

class AdminRoomsView extends GetView<AdminRoomsController> {
  const AdminRoomsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天室管理'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.rooms.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.rooms.isEmpty) {
          return const Center(child: Text('暂无聊天室'));
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
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, room.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, int roomId) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个聊天室吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteRoom(roomId);
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
