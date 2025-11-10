import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_stats_controller.dart';

class AdminStatsView extends GetView<AdminStatsController> {
  const AdminStatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadStats,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadStats,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildStatCard(
                context,
                '用户总数',
                controller.userCount.value.toString(),
                Icons.people,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                context,
                '消息总数',
                controller.messageCount.value.toString(),
                Icons.message,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                context,
                '聊天室总数',
                controller.roomCount.value.toString(),
                Icons.chat_bubble,
                Colors.orange,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
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
            ),
          ],
        ),
      ),
    );
  }
}
