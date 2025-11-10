import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/controllers/admin_controller.dart';
import 'package:chat_app/routes/app_routes.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    // 加载统计数据
    controller.loadStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理后台'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    '管理后台',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('仪表板'),
              onTap: () {
                Get.back();
                Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('用户管理'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.ADMIN_USERS);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('消息管理'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.ADMIN_MESSAGES);
              },
            ),
          ],
        ),
      ),
      body: Obx(() => RefreshIndicator(
        onRefresh: () async {
          await controller.loadStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '统计信息',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '总用户数',
                      controller.stats['total_users']?.toString() ?? '0',
                      Icons.people,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      '在线用户',
                      controller.stats['online_users']?.toString() ?? '0',
                      Icons.person,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _buildStatCard(
                '总消息数',
                controller.stats['total_messages']?.toString() ?? '0',
                Icons.message,
                Colors.orange,
                fullWidth: true,
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.ADMIN_USERS),
                      icon: const Icon(Icons.people),
                      label: const Text('用户管理'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.ADMIN_MESSAGES),
                      icon: const Icon(Icons.message),
                      label: const Text('消息管理'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 30),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
