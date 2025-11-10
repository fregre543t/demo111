import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 根据平台选择不同的baseUrl
  // Android模拟器使用10.0.2.2，iOS模拟器和Web使用localhost
  static String get baseUrl {
    // 可以通过环境变量或配置来设置
    // 默认使用localhost，Android需要改为10.0.2.2
    return 'http://localhost:8080';
  }
  
  // 用户登录
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // 用户注册
  static Future<Map<String, dynamic>> register(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
      }),
    );
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // 获取用户列表
  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users'));
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['users'] ?? [];
  }

  // 获取消息列表
  static Future<List<dynamic>> getMessages({int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/messages?limit=$limit'),
    );
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['messages'] ?? [];
  }

  // 管理员登录
  static Future<Map<String, dynamic>> adminLogin(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // 获取所有用户（管理员）
  static Future<List<dynamic>> adminGetAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/users'));
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['users'] ?? [];
  }

  // 删除用户（管理员）
  static Future<Map<String, dynamic>> adminDeleteUser(String userId) async {
    final response = await http.delete(Uri.parse('$baseUrl/admin/users/$userId'));
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // 获取所有消息（管理员）
  static Future<List<dynamic>> adminGetAllMessages() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/messages'));
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['messages'] ?? [];
  }

  // 删除消息（管理员）
  static Future<Map<String, dynamic>> adminDeleteMessage(String messageId) async {
    final response = await http.delete(Uri.parse('$baseUrl/admin/messages/$messageId'));
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // 获取统计信息（管理员）
  static Future<Map<String, dynamic>> adminGetStats() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/stats'));
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
