import 'package:get/get.dart';
import 'storage_service.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  final StorageService _storage = Get.find();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isAuthenticated = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  void _loadUser() {
    final userData = _storage.getUser();
    final token = _storage.getToken();
    
    if (userData != null && token != null) {
      currentUser.value = UserModel.fromJson(userData);
      isAuthenticated.value = true;
    }
  }

  void setUser(UserModel user, String token) {
    currentUser.value = user;
    isAuthenticated.value = true;
    _storage.setUser(user.toJson());
    _storage.setToken(token);
  }

  void updateUser(UserModel user) {
    currentUser.value = user;
    _storage.setUser(user.toJson());
  }

  void logout() {
    currentUser.value = null;
    isAuthenticated.value = false;
    _storage.clearAll();
  }

  bool get isAdmin => currentUser.value?.isAdmin ?? false;
}
