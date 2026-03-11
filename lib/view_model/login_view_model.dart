import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../api_endpoint/api_endpoint.dart';
import '../model/language_model.dart';
import '../next_work/app_service.dart';

/// ViewModel cho màn Login
/// Giống ViewModel + ObservableObject bên iOS
class LoginViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  // --- State ---

  /// Đang loading
  bool isLoading = false;

  /// Lỗi — null nghĩa là không có lỗi
  String? errorMessage;

  /// Login thành công
  bool isLoggedIn = false;

  // --- Config Auth0 ---
  // Giống Info.plist bên iOS — sau này chuyển vào file config riêng
  static const String _clientId = 'LCFF8h1w7pJM1jLGuzLkdkhuv35cLER3';
  static const String _audience = 'https://devil.eu.auth0.com/api/v2/';
  static const String _realm = 'Username-Password-Authentication';
  static const String _scope = 'openid profile email offline_access';
  static const String _loginBaseUrl = 'https://devil.eu.auth0.com';

  // --- Public Methods ---

  /// Gọi API login
  /// Sau khi thành công tự động lưu token vào ApiService
  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.postFullUrl(
        '$_loginBaseUrl${ApiEndpoint.login}',
        data: {
          'grant_type': 'http://auth0.com/oauth/grant-type/password-realm',
          'username': email,
          'password': password,
          'realm': _realm,
          'scope': _scope,
          'audience': _audience,
          'client_id': _clientId,
        },
      );

      // Parse response JSON -> LoginModel
      final loginData = LoginModel.fromJson(response.data);
    // Tạo sessionId local bằng UUID — giống bên iOS
// Format: UUID không có dấu "-", viết thường
    final sessionId = const Uuid().v4().toLowerCase();
      print('🔑 SessionId: $sessionId'); // 👈 Thêm dòng này
// Lưu token + sessionId vào ApiService
    _api.saveCredentials(
    token: loginData.idToken,
    session: sessionId,
    );
      print('🔑 FULL idToken: ${loginData.idToken}');
      isLoggedIn = true;
      errorMessage = null;

    } on DioException catch (e) {
      print('❌ LOGIN ERROR STATUS: ${e.response?.statusCode}');
      print('❌ LOGIN ERROR BODY: ${e.response?.data}'); //
      errorMessage = _handleDioError(e);
    } catch (e) {
      errorMessage = 'Có lỗi xảy ra: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Logout — xoá token
  void logout() {
    _api.clearCredentials();
    isLoggedIn = false;
    notifyListeners();
  }

  /// Xử lý lỗi Dio thành message thân thiện
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá chậm, vui lòng thử lại';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) return 'Email hoặc mật khẩu không đúng';
        if (status == 403) return 'Tài khoản không có quyền truy cập';
        return 'Lỗi server ($status)';
      case DioExceptionType.connectionError:
        return 'Không có kết nối mạng';
      default:
        return 'Lỗi không xác định';
    }
  }
}