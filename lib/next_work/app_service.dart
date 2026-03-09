import 'package:dio/dio.dart';

/// NetworkManager — Singleton, dùng chung toàn app
/// Giống URLSession/Alamofire Session bên iOS
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;

  // Token lưu in-memory — sau này có thể chuyển sang SecureStorage
  String? _accessToken;
  String? _sessionId;

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://app-api.matisse.ai/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'platform': 'mobile',
          'Accept-Language': 'en',        // 👈 Thêm dòng này
          'Accept-Encoding': 'br;q=1.0, gzip;q=0.9, deflate;q=0.8', // 👈 Thêm dòng này
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        // Chạy TRƯỚC mỗi request — gắn token vào header
        // Giống RequestInterceptor.adapt() bên Alamofire
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          if (_sessionId != null) {
            options.headers['session'] = _sessionId;
          }
          print('➡️ REQUEST: ${options.method} ${options.uri}');
          print('   Headers: ${options.headers}'); // 👈 Thêm dòng này

          final token = options.headers['Authorization'] ?? 'NO TOKEN';
          print('🔑 Token length: ${token.toString().length}');
          print('🔑 Token start: ${token.toString().substring(0, 50)}');
          return handler.next(options);
        },

        onResponse: (response, handler) {
          print('✅ RESPONSE [${response.statusCode}]: ${response.requestOptions.path}');
          return handler.next(response);
        },

        onError: (error, handler) {
          print('❌ ERROR [${error.response?.statusCode}]: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // --- Token Management ---

  /// Lưu token sau khi login thành công
  void saveCredentials({required String token, String? session}) {
    _accessToken = token;
    _sessionId = session;
    print('🔑 Credentials saved');
  }

  /// Xoá token khi logout
  void clearCredentials() {
    _accessToken = null;
    _sessionId = null;
  }

  // --- HTTP Methods ---

  /// GET — queryParams là các tham số trên URL
  /// Ví dụ: get('/v4/cases/', queryParams: {'limit': 10, 'offset': 0})
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    return await dio.get(path, queryParameters: queryParams);
  }

  /// POST — data là body request
  Future<Response> post(String path, {dynamic data}) async {
    return await dio.post(path, data: data);
  }

  /// PUT
  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  /// DELETE
  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}