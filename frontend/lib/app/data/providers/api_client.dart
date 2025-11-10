import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../models/message.dart';
import '../models/room.dart';
import '../models/user.dart';

class ApiClient {
  ApiClient._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          contentType: 'application/json',
        ),
      );

  final Dio _dio;
  String? _token;
  String? _adminToken;

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  void updateToken(String? token) {
    _token = token;
  }

  void updateAdminToken(String? token) {
    _adminToken = token;
  }

  Options _options({bool isAdmin = false}) {
    final headers = <String, dynamic>{};
    final token = isAdmin ? _adminToken : _token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return Options(headers: headers);
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {'username': username, 'password': password},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );
    return response.data ?? {};
  }

  Future<void> logout() async {
    await _dio.post('/api/auth/logout', options: _options());
  }

  Future<List<Room>> listRooms() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/rooms',
      options: _options(),
    );
    final rooms = response.data?['rooms'] as List<dynamic>? ?? [];
    return rooms.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ChatMessage>> fetchMessages(String roomId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/rooms/$roomId/messages',
      options: _options(),
    );
    final messages = response.data?['messages'] as List<dynamic>? ?? [];
    return messages
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> adminLogin(String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/admin/login',
      data: {'password': password},
    );
    return response.data ?? {};
  }

  Future<List<User>> adminListUsers() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/admin/users',
      options: _options(isAdmin: true),
    );
    final users = response.data?['users'] as List<dynamic>? ?? [];
    return users.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Room>> adminListRooms() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/admin/rooms',
      options: _options(isAdmin: true),
    );
    final rooms = response.data?['rooms'] as List<dynamic>? ?? [];
    return rooms.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> adminToggleUser(String userId, bool disabled) async {
    await _dio.patch(
      '/api/admin/users/$userId/status',
      data: {'disabled': disabled},
      options: _options(isAdmin: true),
    );
  }

  Future<Room> adminCreateRoom(String name, String description) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/admin/rooms',
      data: {'name': name, 'description': description},
      options: _options(isAdmin: true),
    );
    final room = response.data?['room'] as Map<String, dynamic>? ?? {};
    return Room.fromJson(room);
  }

  Future<Room> adminUpdateRoom(
    String roomId,
    String name,
    String description,
    bool active,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/admin/rooms/$roomId',
      data: {'name': name, 'description': description, 'active': active},
      options: _options(isAdmin: true),
    );
    final room = response.data?['room'] as Map<String, dynamic>? ?? {};
    return Room.fromJson(room);
  }

  Future<void> adminDeleteRoom(String roomId) async {
    await _dio.delete(
      '/api/admin/rooms/$roomId',
      options: _options(isAdmin: true),
    );
  }
}
