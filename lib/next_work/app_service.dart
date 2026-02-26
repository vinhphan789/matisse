import 'package:dio/dio.dart';

/// Đây là class gọi API chính
/// Tương đương NetworkManager trong iOS
class ApiService {
  // Singleton pattern (giống shared instance bên Swift)
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  late Dio dio;

  // Constructor private
  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://dev-api.matisse.ai/api', // base URL
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    /// Interceptor (giống Alamofire RequestInterceptor)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('➡️ REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ RESPONSE: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// GET method dùng chung
  Future<Response> get(String path) async {
    try {
      return await dio.get(path);
    } catch (e) {
      rethrow;
    }
  }

  /// POST method dùng chung
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
}