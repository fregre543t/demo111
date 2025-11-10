import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  static const _tokenKey = 'token';
  static const _userKey = 'user';
  static const _adminTokenKey = 'admin_token';

  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  String? readToken() => _box.read<String>(_tokenKey);

  Future<void> writeToken(String? token) async {
    if (token == null) {
      await _box.remove(_tokenKey);
    } else {
      await _box.write(_tokenKey, token);
    }
  }

  Map<String, dynamic>? readUser() => _box.read<Map<String, dynamic>>(_userKey);

  Future<void> writeUser(Map<String, dynamic>? data) async {
    if (data == null) {
      await _box.remove(_userKey);
    } else {
      await _box.write(_userKey, data);
    }
  }

  String? readAdminToken() => _box.read<String>(_adminTokenKey);

  Future<void> writeAdminToken(String? token) async {
    if (token == null) {
      await _box.remove(_adminTokenKey);
    } else {
      await _box.write(_adminTokenKey, token);
    }
  }
}
