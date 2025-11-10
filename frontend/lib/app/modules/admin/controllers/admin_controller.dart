import 'package:get/get.dart';

import '../../../data/models/room.dart';
import '../../../data/models/user.dart';
import '../../../data/providers/api_client.dart';
import '../../../services/storage_service.dart';

class AdminController extends GetxController {
  AdminController(this._storage);

  final StorageService _storage;
  final ApiClient _api = ApiClient();

  final RxnString token = RxnString();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<User> users = <User>[].obs;
  final RxList<Room> rooms = <Room>[].obs;

  bool get isAuthenticated => token.value != null;

  @override
  void onInit() {
    super.onInit();
    _hydrate();
  }

  void _hydrate() {
    final savedToken = _storage.readAdminToken();
    if (savedToken != null) {
      token.value = savedToken;
      _api.updateAdminToken(savedToken);
      refreshData();
    }
  }

  Future<bool> login(String password) async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await _api.adminLogin(password);
      final value = result['token'] as String?;
      if (value == null) {
        error.value = '登录失败，响应异常';
        return false;
      }
      token.value = value;
      _api.updateAdminToken(value);
      await _storage.writeAdminToken(value);
      await refreshData();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    if (!isAuthenticated) {
      users.clear();
      rooms.clear();
      return;
    }
    await Future.wait([_loadUsers(), _loadRooms()]);
  }

  Future<void> _loadUsers() async {
    try {
      users.assignAll(await _api.adminListUsers());
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> _loadRooms() async {
    try {
      rooms.assignAll(await _api.adminListRooms());
    } catch (e) {
      error.value = e.toString();
    }
  }

  Future<void> toggleUser(String userId, bool disabled) async {
    await _api.adminToggleUser(userId, disabled);
    await _loadUsers();
  }

  Future<void> createRoom(String name, String description) async {
    await _api.adminCreateRoom(name, description);
    await _loadRooms();
  }

  Future<void> updateRoom(
    String roomId,
    String name,
    String description,
    bool active,
  ) async {
    await _api.adminUpdateRoom(roomId, name, description, active);
    await _loadRooms();
  }

  Future<void> deleteRoom(String roomId) async {
    await _api.adminDeleteRoom(roomId);
    await _loadRooms();
  }

  Future<void> logout() async {
    token.value = null;
    _api.updateAdminToken(null);
    await _storage.writeAdminToken(null);
    users.clear();
    rooms.clear();
  }
}
