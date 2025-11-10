import 'package:get/get.dart';

import '../../../data/models/user.dart';
import '../../../data/providers/api_client.dart';
import '../../../services/storage_service.dart';

class AuthController extends GetxController {
  AuthController(this._storage);

  final StorageService _storage;
  final ApiClient _api = ApiClient();

  final Rxn<User> user = Rxn<User>();
  final RxnString token = RxnString();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  bool get isAuthenticated => token.value != null;

  @override
  void onInit() {
    super.onInit();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final savedToken = _storage.readToken();
    final savedUser = _storage.readUser();
    if (savedToken != null && savedUser != null) {
      token.value = savedToken;
      user.value = User.fromJson(savedUser);
      _api.updateToken(savedToken);
    }
  }

  Future<bool> register(String username, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _api.register(username, password);
      final tokenValue = result['token'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;
      if (tokenValue == null || userData == null) {
        error.value = '注册失败，响应异常';
        return false;
      }
      final newUser = User.fromJson(userData);
      await _persistSession(tokenValue, newUser);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _api.login(username, password);
      final tokenValue = result['token'] as String?;
      final userData = result['user'] as Map<String, dynamic>?;
      if (tokenValue == null || userData == null) {
        error.value = '登录失败，响应异常';
        return false;
      }
      final newUser = User.fromJson(userData);
      await _persistSession(tokenValue, newUser);
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      if (token.value != null) {
        await _api.logout();
      }
    } finally {
      token.value = null;
      user.value = null;
      _api.updateToken(null);
      await _storage.writeToken(null);
      await _storage.writeUser(null);
    }
  }

  Future<void> _persistSession(String tokenValue, User newUser) async {
    token.value = tokenValue;
    user.value = newUser;
    _api.updateToken(tokenValue);
    await _storage.writeToken(tokenValue);
    await _storage.writeUser(newUser.toJson());
  }
}
