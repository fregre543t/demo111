import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  final _storage = GetStorage();

  // Token
  String? getToken() => _storage.read('token');
  Future<void> setToken(String token) => _storage.write('token', token);
  Future<void> removeToken() => _storage.remove('token');

  // User
  Map<String, dynamic>? getUser() => _storage.read('user');
  Future<void> setUser(Map<String, dynamic> user) => _storage.write('user', user);
  Future<void> removeUser() => _storage.remove('user');

  // 清除所有数据
  Future<void> clearAll() async {
    await removeToken();
    await removeUser();
  }
}
