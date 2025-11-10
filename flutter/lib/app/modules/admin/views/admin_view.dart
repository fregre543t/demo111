import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../../../../app/routes/app_routes.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('后台管理'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        children: [
          _buildMenuCard(
            context,
            '用户管理',
            Icons.people,
            Colors.blue,
            controller.navigateToUsers,
          ),
          _buildMenuCard(
            context,
            '消息管理',
            Icons.message,
            Colors.green,
            controller.navigateToMessages,
          ),
          _buildMenuCard(
            context,
            '聊天室管理',
            Icons.chat_bubble,
            Colors.orange,
            controller.navigateToRooms,
          ),
          _buildMenuCard(
            context,
            '数据统计',
            Icons.bar_chart,
            Colors.purple,
            controller.navigateToStats,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
