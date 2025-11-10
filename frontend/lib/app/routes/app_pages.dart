import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bindings/admin_binding.dart';
import '../bindings/chat_binding.dart';
import '../bindings/home_binding.dart';
import '../modules/admin/controllers/admin_controller.dart';
import '../modules/admin/views/admin_dashboard_view.dart';
import '../modules/admin/views/admin_login_view.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/home/views/home_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = <GetPage>[
    GetPage(name: Routes.splash, page: () => const SplashView()),
    GetPage(name: Routes.login, page: () => const LoginView()),
    GetPage(name: Routes.register, page: () => const RegisterView()),
    GetPage(
      name: Routes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
      middlewares: [AuthGuard()],
    ),
    GetPage(
      name: Routes.adminLogin,
      page: () => const AdminLoginView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.adminDashboard,
      page: () => const AdminDashboardView(),
      binding: AdminBinding(),
      middlewares: [AdminGuard()],
    ),
  ];
}

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.isAuthenticated) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}

class AdminGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    AdminController? admin;
    if (Get.isRegistered<AdminController>()) {
      admin = Get.find<AdminController>();
    }
    if (admin == null || !admin.isAuthenticated) {
      return const RouteSettings(name: Routes.adminLogin);
    }
    return null;
  }
}
