import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final StorageService _storage = Get.find();
  
  static const String baseUrl = 'http://localhost:8080/api';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // 添加请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token过期，清除登录信息
          _storage.clearAll();
          Get.offAllNamed('/login');
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}
