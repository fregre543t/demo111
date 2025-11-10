import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  final _storage = GetStorage();

  // 用户Token
  String? getToken() => _storage.read('token');
  Future<void> saveToken(String token) => _storage.write('token', token);
  Future<void> removeToken() => _storage.remove('token');

  // 用户信息
  Map<String, dynamic>? getUser() => _storage.read('user');
  Future<void> saveUser(Map<String, dynamic> user) => _storage.write('user', user);
  Future<void> removeUser() => _storage.remove('user');

  // 管理员Token
  String? getAdminToken() => _storage.read('admin_token');
  Future<void> saveAdminToken(String token) => _storage.write('admin_token', token);
  Future<void> removeAdminToken() => _storage.remove('admin_token');

  // 清除所有数据
  Future<void> clearAll() async {
    await _storage.erase();
  }
}
