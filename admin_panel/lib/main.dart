import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/admin_api_service.dart';
import 'controllers/admin_controller.dart';
import 'views/login/admin_login_view.dart';
import 'views/dashboard/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  await Get.putAsync(() async => AdminApiService());
  Get.put(AdminController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '聊天应用管理后台',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const AdminLoginView(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardView(),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
