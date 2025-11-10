import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../chat/chat_view.dart';

class HomeView extends GetView<ChatController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天'),
        actions: [
          Obx(() {
            final count = controller.unreadCount.value;
            return count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.person_search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.person),
                  title: Text('个人资料'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  // TODO: 跳转到个人资料页面
                },
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('退出登录'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  authController.logout();
                },
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.conversations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无聊天', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadConversations,
          child: ListView.builder(
            itemCount: controller.conversations.length,
            itemBuilder: (context, index) {
              final conversation = controller.conversations[index];
              return ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        conversation.avatar,
                      ),
                    ),
                    if (conversation.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(conversation.nickname)),
                    Text(
                      _formatTime(conversation.lastTime),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  conversation.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: conversation.unreadCount > 0
                    ? Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          conversation.unreadCount > 99
                              ? '99+'
                              : conversation.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Get.to(() => ChatView(
                        userId: conversation.userId,
                        nickname: conversation.nickname,
                        avatar: conversation.avatar,
                      ));
                },
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showOnlineUsersDialog(context);
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(time);
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM-dd').format(time);
    }
  }

  void _showSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索用户'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: '输入用户名或昵称',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                controller.searchUsers(searchController.text);
                Get.back();
              }
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  void _showOnlineUsersDialog(BuildContext context) {
    controller.loadOnlineUsers();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('在线用户'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: controller.onlineUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.onlineUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user.avatar),
                    ),
                    title: Text(user.nickname),
                    subtitle: Text('@${user.username}'),
                    onTap: () {
                      Get.back();
                      Get.to(() => ChatView(
                            userId: user.id,
                            nickname: user.nickname,
                            avatar: user.avatar,
                          ));
                    },
                  );
                },
              )),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
