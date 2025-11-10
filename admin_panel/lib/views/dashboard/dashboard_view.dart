import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../users/users_view.dart';
import '../messages/messages_view.dart';

class DashboardView extends GetView<AdminController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理后台'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadDashboardStats,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    '管理面板',
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('用户管理'),
              onTap: () {
                Get.back();
                Get.to(() => const UsersView());
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('消息管理'),
              onTap: () {
                Get.back();
                Get.to(() => const MessagesView());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('退出登录'),
              onTap: () {
                Get.find<AdminController>()._apiService.clearToken();
                Get.offAllNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.stats.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = controller.stats;

        return RefreshIndicator(
          onRefresh: controller.loadDashboardStats,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '数据统计',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      '总用户数',
                      stats['total_users']?.toString() ?? '0',
                      Icons.people,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      '总消息数',
                      stats['total_messages']?.toString() ?? '0',
                      Icons.message,
                      Colors.green,
                    ),
                    _buildStatCard(
                      '在线用户',
                      stats['online_users']?.toString() ?? '0',
                      Icons.online_prediction,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      '今日新增',
                      stats['today_new_users']?.toString() ?? '0',
                      Icons.person_add,
                      Colors.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '今日统计',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.message_outlined),
                          title: const Text('今日消息数'),
                          trailing: Text(
                            stats['today_messages']?.toString() ?? '0',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.person_add_outlined),
                          title: const Text('今日新增用户'),
                          trailing: Text(
                            stats['today_new_users']?.toString() ?? '0',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
