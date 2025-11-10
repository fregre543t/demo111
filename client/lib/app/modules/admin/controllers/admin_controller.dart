import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/room_model.dart';
import '../../../data/models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../services/session_service.dart';

class AdminController extends GetxController {
  AdminController({
    ApiService? apiService,
    SessionService? sessionService,
  })  : _apiService = apiService ?? Get.find<ApiService>(),
        _sessionService = sessionService ?? Get.find<SessionService>();

  final ApiService _apiService;
  final SessionService _sessionService;

  final RxList<User> users = <User>[].obs;
  final RxList<Room> rooms = <Room>[].obs;
  final RxBool isLoadingUsers = false.obs;
  final RxBool isLoadingRooms = false.obs;

  final TextEditingController roomNameController = TextEditingController();

  bool get hasAdminAccess => _sessionService.currentUser.value?.role == 'admin';

  @override
  void onReady() {
    super.onReady();
    _guardAccess();
    if (hasAdminAccess) {
      fetchUsers();
      fetchRooms();
    }
  }

  void _guardAccess() {
    if (!hasAdminAccess) {
      Get.snackbar('提示', '只有管理员可以访问后台管理');
      Get.back();
    }
  }

  Future<void> fetchUsers() async {
    if (!hasAdminAccess) return;
    try {
      isLoadingUsers.value = true;
      final result = await _apiService.fetchUsers();
      users.assignAll(result);
    } catch (error) {
      Get.snackbar('错误', '获取用户列表失败：$error');
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> fetchRooms() async {
    if (!hasAdminAccess) return;
    try {
      isLoadingRooms.value = true;
      final result = await _apiService.fetchRooms();
      rooms.assignAll(result);
    } catch (error) {
      Get.snackbar('错误', '获取房间列表失败：$error');
    } finally {
      isLoadingRooms.value = false;
    }
  }

  Future<void> createRoom() async {
    if (!hasAdminAccess) {
      Get.snackbar('提示', '只有管理员可以创建房间');
      return;
    }
    final name = roomNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('提示', '房间名称不能为空');
      return;
    }
    try {
      final room = await _apiService.createRoom(name);
      rooms.add(room);
      roomNameController.clear();
      Get.snackbar('成功', '房间创建成功');
    } catch (error) {
      Get.snackbar('错误', '创建房间失败：$error');
    }
  }

  @override
  void onClose() {
    roomNameController.dispose();
    super.onClose();
  }
}
