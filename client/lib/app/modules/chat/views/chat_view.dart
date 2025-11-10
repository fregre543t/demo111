import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/room_model.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm:ss');

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final roomName = controller.selectedRoom.value?.name ?? '聊天室';
          return Text(roomName);
        }),
        actions: [
          Obx(() {
            final currentUser = controller.currentUser;
            return currentUser == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Chip(
                      avatar: const Icon(Icons.person, size: 16),
                      label: Text(currentUser.username),
                    ),
                  );
          }),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'admin':
                  controller.goToAdmin();
                  break;
                case 'logout':
                  controller.logout();
                  break;
                case 'reload':
                  controller.refreshMessages();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reload',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('刷新消息'),
                ),
              ),
              const PopupMenuItem(
                value: 'admin',
                child: ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('后台管理'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('退出登录'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRoomSelector(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingHistory.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.messages.isEmpty) {
                return const Center(child: Text('还没有消息，快来发送第一条吧！'));
              }
              return ListView.builder(
                reverse: false,
                padding: const EdgeInsets.all(12),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMine = controller.currentUser?.id != null &&
                      msg.senderId == controller.currentUser!.id;
                  return Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMine
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            if (!isMine)
                              Text(
                                '发送者: ${msg.senderId}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                            if (!isMine) const SizedBox(height: 4),
                          Text(
                            msg.content,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateFormat.format(msg.createdAt.toLocal()),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildRoomSelector() {
    return Obx(() {
      final rooms = controller.rooms;
      if (rooms.length <= 1) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Icon(Icons.forum),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<Room>(
                value: rooms.contains(controller.selectedRoom.value)
                    ? controller.selectedRoom.value
                    : null,
                isExpanded: true,
                onChanged: (room) {
                  if (room != null) {
                    controller.switchRoom(room);
                  }
                },
                items: rooms
                    .map(
                      (room) => DropdownMenuItem(
                        value: room,
                        child: Text(room.name),
                      ),
                    )
                    .toList(),
                hint: const Text('选择房间'),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInputBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Obx(() {
          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.messageController,
                  decoration: const InputDecoration(
                    hintText: '输入消息...',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: controller.isSending.value
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send),
                color: Theme.of(context).colorScheme.primary,
                onPressed:
                    controller.isSending.value ? null : controller.sendMessage,
              ),
            ],
          );
        }),
      ),
    );
  }
}
