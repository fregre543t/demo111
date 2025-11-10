import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/login_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/bindings/register_binding.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/admin/bindings/admin_users_binding.dart';
import '../modules/admin/views/admin_users_view.dart';
import '../modules/admin/bindings/admin_messages_binding.dart';
import '../modules/admin/views/admin_messages_view.dart';
import '../modules/admin/bindings/admin_rooms_binding.dart';
import '../modules/admin/views/admin_rooms_view.dart';
import '../modules/admin/bindings/admin_stats_binding.dart';
import '../modules/admin/views/admin_stats_view.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.CHAT,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_USERS,
      page: () => const AdminUsersView(),
      binding: AdminUsersBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_MESSAGES,
      page: () => const AdminMessagesView(),
      binding: AdminMessagesBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_ROOMS,
      page: () => const AdminRoomsView(),
      binding: AdminRoomsBinding(),
    ),
    GetPage(
      name: AppRoutes.ADMIN_STATS,
      page: () => const AdminStatsView(),
      binding: AdminStatsBinding(),
    ),
  ];
}
