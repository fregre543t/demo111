import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find();
  final WebSocketService _wsService = Get.find();
  
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuth();
  }

  Future<void> checkAuth() async {
    if (_apiService.isAuthenticated) {
      try {
        final user = await _apiService.getProfile();
        currentUser.value = user;
        
        // 连接WebSocket
        if (_apiService.token != null) {
          _wsService.connect(_apiService.token!);
        }
      } catch (e) {
        print('获取用户信息失败: $e');
        await logout();
      }
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      final response = await _apiService.login(username, password);
      
      if (response['user'] != null) {
        currentUser.value = User.fromJson(response['user']);
        
        // 连接WebSocket
        if (_apiService.token != null) {
          _wsService.connect(_apiService.token!);
        }
        
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('错误', '登录失败: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String username, String password, String nickname) async {
    try {
      isLoading.value = true;
      await _apiService.register(username, password, nickname);
      
      // 注册成功后自动登录
      return await login(username, password);
    } catch (e) {
      Get.snackbar('错误', '注册失败: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    _wsService.disconnect();
    await _apiService.clearToken();
    currentUser.value = null;
    Get.offAllNamed('/login');
  }

  Future<void> updateProfile(String nickname, String avatar) async {
    try {
      isLoading.value = true;
      await _apiService.updateProfile(nickname, avatar);
      
      // 更新本地用户信息
      if (currentUser.value != null) {
        currentUser.value = currentUser.value!.copyWith(
          nickname: nickname,
          avatar: avatar,
        );
      }
      
      Get.snackbar('成功', '资料更新成功');
    } catch (e) {
      Get.snackbar('错误', '更新失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool get isAuthenticated => currentUser.value != null;
}
