import 'package:get/get.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/pages/splash/splash_binding.dart';
import 'package:chat_app/pages/splash/splash_page.dart';
import 'package:chat_app/pages/login/login_binding.dart';
import 'package:chat_app/pages/login/login_page.dart';
import 'package:chat_app/pages/register/register_binding.dart';
import 'package:chat_app/pages/register/register_page.dart';
import 'package:chat_app/pages/chat/chat_binding.dart';
import 'package:chat_app/pages/chat/chat_page.dart';
import 'package:chat_app/pages/admin/admin_login_binding.dart';
import 'package:chat_app/pages/admin/admin_login_page.dart';
import 'package:chat_app/pages/admin/admin_dashboard_binding.dart';
import 'package:chat_app/pages/admin/admin_dashboard_page.dart';
import 'package:chat_app/pages/admin/admin_users_binding.dart';
import 'package:chat_app/pages/admin/admin_users_page.dart';
import 'package:chat_app/pages/admin/admin_messages_binding.dart';
import 'package:chat_app/pages/admin/admin_messages_page.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.CHAT,
      page: () => const ChatPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_LOGIN,
      page: () => const AdminLoginPage(),
      binding: AdminLoginBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardPage(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_USERS,
      page: () => const AdminUsersPage(),
      binding: AdminUsersBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_MESSAGES,
      page: () => const AdminMessagesPage(),
      binding: AdminMessagesBinding(),
    ),
  ];
}
