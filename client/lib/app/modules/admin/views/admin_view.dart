import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('后台管理'),
        actions: [
          IconButton(
            onPressed: () {
              controller.fetchUsers();
              controller.fetchRooms();
            },
            icon: const Icon(Icons.refresh),
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: '用户管理'),
                Tab(text: '房间管理'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _UserTab(controller: controller, dateFormat: dateFormat),
                  _RoomTab(controller: controller, dateFormat: dateFormat),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateRoomDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('创建房间'),
      ),
    );
  }

  Future<void> _showCreateRoomDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('创建新房间'),
          content: TextField(
            controller: controller.roomNameController,
            decoration: const InputDecoration(
              hintText: '请输入房间名称',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.roomNameController.clear();
                Get.back();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                await controller.createRoom();
                Get.back();
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }
}

class _UserTab extends StatelessWidget {
  const _UserTab({
    required this.controller,
    required this.dateFormat,
  });

  final AdminController controller;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingUsers.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.users.isEmpty) {
        return const Center(child: Text('暂无用户数据'));
      }
      return ListView.builder(
        itemCount: controller.users.length,
        itemBuilder: (context, index) {
          final user = controller.users[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.username),
            subtitle: Text(
              '角色: ${user.role}\n注册时间: ${dateFormat.format(user.createdAt.toLocal())}',
            ),
            trailing: Text(user.id),
            isThreeLine: true,
          );
        },
      );
    });
  }
}

class _RoomTab extends StatelessWidget {
  const _RoomTab({
    required this.controller,
    required this.dateFormat,
  });

  final AdminController controller;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRooms.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.rooms.isEmpty) {
        return const Center(child: Text('暂无房间数据'));
      }
      return ListView.builder(
        itemCount: controller.rooms.length,
        itemBuilder: (context, index) {
          final room = controller.rooms[index];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.forum)),
            title: Text(room.name),
            subtitle: Text(
              '创建时间: ${dateFormat.format(room.createdAt.toLocal())}',
            ),
            trailing: Text(room.id),
          );
        },
      );
    });
  }
}
