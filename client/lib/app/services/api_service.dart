import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../config/environment.dart';
import '../data/models/message_model.dart';
import '../data/models/room_model.dart';
import '../data/models/user_model.dart';

import 'session_service.dart';

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService extends GetxService {
  ApiService({
    http.Client? client,
    SessionService? sessionService,
  })  : _client = client ?? http.Client(),
        _sessionService = sessionService ?? Get.find<SessionService>();

  final http.Client _client;
  final SessionService _sessionService;

  Future<ApiService> init() async {
    return this;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final uri = Uri.parse('${Environment.apiBaseUrl}$path');
    if (query == null) {
      return uri;
    }
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...query.map((key, value) => MapEntry(key, value.toString())),
    });
  }

  Map<String, String> _headers({bool withAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = _sessionService.token.value;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<User> register(String username, String password) async {
    final response = await _client.post(
      _uri('/api/auth/register'),
      headers: _headers(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<User> login(String username, String password) async {
    final response = await _client.post(
      _uri('/api/auth/login'),
      headers: _headers(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final token = data['token'] as String?;
    if (token == null) {
      throw ApiException(500, 'Token missing in response');
    }
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    _sessionService
      ..setToken(token)
      ..setUser(user);
    return user;
  }

  Future<User> fetchMe() async {
    final response = await _client.get(
      _uri('/api/me'),
      headers: _headers(withAuth: true),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final user = User.fromJson(data);
    _sessionService.setUser(user);
    return user;
  }

  Future<List<Message>> fetchMessages({
    String? roomId,
    int limit = 50,
  }) async {
    final response = await _client.get(
      _uri('/api/messages', {
        if (roomId != null) 'room_id': roomId,
        'limit': limit,
      }),
      headers: _headers(withAuth: true),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final messages = data['messages'] as List<dynamic>? ?? [];
    return messages
        .map((json) => Message.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<User>> fetchUsers() async {
    final response = await _client.get(
      _uri('/api/admin/users'),
      headers: _headers(withAuth: true),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final users = data['users'] as List<dynamic>? ?? [];
    return users
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Room>> fetchRooms() async {
    final response = await _client.get(
      _uri('/api/admin/rooms'),
      headers: _headers(withAuth: true),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rooms = data['rooms'] as List<dynamic>? ?? [];
    return rooms
        .map((json) => Room.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Room> createRoom(String name) async {
    final response = await _client.post(
      _uri('/api/admin/rooms'),
      headers: _headers(withAuth: true),
      body: jsonEncode({'name': name}),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Room.fromJson(data);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(
      response.statusCode,
      response.body.isEmpty ? '请求失败' : response.body,
    );
  }
}
