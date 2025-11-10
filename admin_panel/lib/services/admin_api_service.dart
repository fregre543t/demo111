import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

class AdminApiService extends GetxService {
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

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
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

  bool get isAuthenticated => _token != null;

  // 登录
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

  // 获取仪表板统计
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _dio.get('/admin/stats');
    return response.data;
  }

  // 获取所有用户
  Future<Map<String, dynamic>> getAllUsers({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get('/admin/users', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    return response.data;
  }

  // 删除用户
  Future<void> deleteUser(int userId) async {
    await _dio.delete('/admin/users/$userId');
  }

  // 更新用户状态
  Future<void> updateUserStatus(int userId, bool isAdmin) async {
    await _dio.put('/admin/users/$userId/status', data: {
      'is_admin': isAdmin,
    });
  }

  // 获取所有消息
  Future<Map<String, dynamic>> getAllMessages({int page = 1, int pageSize = 50}) async {
    final response = await _dio.get('/admin/messages', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    return response.data;
  }

  // 删除消息
  Future<void> deleteMessage(int messageId) async {
    await _dio.delete('/admin/messages/$messageId');
  }
}
