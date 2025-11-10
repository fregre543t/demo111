import 'package:get/get.dart';

import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import ../modules/auth/views/auth_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.admin,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
  ];
}
