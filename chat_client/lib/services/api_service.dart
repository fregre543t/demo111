import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/message.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'http://localhost:8080/api';
  late Dio _dio;
  String? _token;

  @override
  void onInit() {
    super.onInit();
    _initDio();
    _loadToken();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ));

    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token过期，清除并跳转到登录页
          clearToken();
          Get.offAllNamed('/login');
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // 认证相关
  Future<Map<String, dynamic>> register(String username, String password, String nickname) async {
    final response = await _dio.post('/register', data: {
      'username': username,
      'password': password,
      'nickname': nickname,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post('/login', data: {
      'username': username,
      'password': password,
    });
    
    if (response.data['token'] != null) {
      await saveToken(response.data['token']);
    }
    
    return response.data;
  }

  // 用户相关
  Future<User> getProfile() async {
    final response = await _dio.get('/profile');
    return User.fromJson(response.data);
  }

  Future<void> updateProfile(String nickname, String avatar) async {
    await _dio.put('/profile', data: {
      'nickname': nickname,
      'avatar': avatar,
    });
  }

  Future<List<User>> getUsers({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get('/users', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    
    final users = (response.data['users'] as List)
        .map((json) => User.fromJson(json))
        .toList();
    return users;
  }

  Future<List<User>> searchUsers(String keyword) async {
    final response = await _dio.get('/users/search', queryParameters: {
      'keyword': keyword,
    });
    
    final users = (response.data['users'] as List)
        .map((json) => User.fromJson(json))
        .toList();
    return users;
  }

  Future<List<User>> getOnlineUsers() async {
    final response = await _dio.get('/users/online/list');
    final users = (response.data['online_users'] as List)
        .map((json) => User.fromJson(json))
        .toList();
    return users;
  }

  // 消息相关
  Future<Message> sendMessage(int toUserId, String content, String messageType) async {
    final response = await _dio.post('/messages', data: {
      'to_user_id': toUserId,
      'content': content,
      'message_type': messageType,
    });
    return Message.fromJson(response.data['data']);
  }

  Future<List<Message>> getMessages(int userId, {int page = 1, int pageSize = 50}) async {
    final response = await _dio.get('/messages/$userId', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    
    final messages = (response.data['messages'] as List)
        .map((json) => Message.fromJson(json))
        .toList();
    return messages;
  }

  Future<List<Conversation>> getConversations() async {
    final response = await _dio.get('/conversations');
    final conversations = (response.data['conversations'] as List)
        .map((json) => Conversation.fromJson(json))
        .toList();
    return conversations;
  }

  Future<void> markAsRead(int userId) async {
    await _dio.put('/messages/$userId/read');
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/messages/unread/count');
    return response.data['unread_count'] ?? 0;
  }
}
