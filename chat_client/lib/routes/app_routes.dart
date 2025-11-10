import 'package:get/get.dart';
import '../views/login/login_view.dart';
import '../views/login/register_view.dart';
import '../views/home/home_view.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';

  static final routes = [
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AuthController());
      }),
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChatController());
      }),
    ),
  ];
}
