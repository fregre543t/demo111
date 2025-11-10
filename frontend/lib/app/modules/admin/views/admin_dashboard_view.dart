import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/room.dart';
import '../../../routes/app_routes.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView>
    with SingleTickerProviderStateMixin {
  late final AdminController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdminController>();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.refreshData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('后台管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '用户'),
            Tab(text: '房间'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => Get.offAllNamed(Routes.home),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _controller.logout();
              Get.offAllNamed(Routes.adminLogin);
            },
          ),
        ],
      ),
      body: Obx(
        () => TabBarView(
          controller: _tabController,
          children: [_buildUserTab(), _buildRoomTab()],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          if (_tabController.index == 1) {
            return FloatingActionButton(
              onPressed: () => _showRoomDialog(context),
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUserTab() {
    if (_controller.users.isEmpty) {
      return const Center(child: Text('暂无用户数据'));
    }
    return ListView.builder(
      itemCount: _controller.users.length,
      itemBuilder: (context, index) {
        final user = _controller.users[index];
        return SwitchListTile(
          title: Text(user.username),
          subtitle: Text('状态：${user.disabled ? '禁用' : '正常'}'),
          value: !user.disabled,
          onChanged: (value) => _controller.toggleUser(user.id, !value),
        );
      },
    );
  }

  Widget _buildRoomTab() {
    if (_controller.rooms.isEmpty) {
      return const Center(child: Text('暂无房间'));
    }
    return ListView.builder(
      itemCount: _controller.rooms.length,
      itemBuilder: (context, index) {
        final room = _controller.rooms[index];
        return ListTile(
          title: Text(room.name),
          subtitle: Text(room.description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: room.active,
                onChanged: (value) => _controller.updateRoom(
                  room.id,
                  room.name,
                  room.description,
                  value,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showRoomDialog(context, room: room),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDeleteRoom(context, room),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRoomDialog(BuildContext context, {Room? room}) async {
    final nameController = TextEditingController(text: room?.name ?? '');
    final descController = TextEditingController(text: room?.description ?? '');
    final active = ValueNotifier<bool>(room?.active ?? true);

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(room == null ? '创建房间' : '编辑房间'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '房间名称'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入房间名称';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: '描述'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入描述';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: active,
                  builder: (context, value, _) {
                    return SwitchListTile(
                      value: value,
                      onChanged: (newValue) => active.value = newValue,
                      title: const Text('启用'),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('取消')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                if (room == null) {
                  await _controller.createRoom(
                    nameController.text.trim(),
                    descController.text.trim(),
                  );
                } else {
                  await _controller.updateRoom(
                    room.id,
                    nameController.text.trim(),
                    descController.text.trim(),
                    active.value,
                  );
                }
                if (context.mounted) Get.back();
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    nameController.dispose();
    descController.dispose();
    active.dispose();
  }

  Future<void> _confirmDeleteRoom(BuildContext context, Room room) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除房间'),
          content: Text('确认删除房间「${room.name}」吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      await _controller.deleteRoom(room.id);
    }
  }
}
