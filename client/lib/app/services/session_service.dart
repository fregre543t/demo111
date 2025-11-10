import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../data/models/user_model.dart';

class SessionService extends GetxService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'current_user';

  final GetStorage _storage = GetStorage();

  final RxnString token = RxnString();
  final Rxn<User> currentUser = Rxn<User>();

  Future<SessionService> init() async {
    await GetStorage.init();
    final storedToken = _storage.read<String?>(_tokenKey);
    if (storedToken != null && storedToken.isNotEmpty) {
      token.value = storedToken;
    }
    final storedUser = _storage.read<Map<String, dynamic>?>(_userKey);
    if (storedUser != null) {
      currentUser.value = User.fromJson(storedUser);
    }
    return this;
  }

  void setToken(String? value) {
    token.value = value;
    if (value == null) {
      _storage.remove(_tokenKey);
    } else {
      _storage.write(_tokenKey, value);
    }
  }

  void setUser(User? user) {
    currentUser.value = user;
    if (user == null) {
      _storage.remove(_userKey);
    } else {
      _storage.write(_userKey, user.toJson());
    }
  }

  void clear() {
    setToken(null);
    setUser(null);
  }
}
