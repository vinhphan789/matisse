import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../api_endpoint/api_endpoint.dart';
import '../model/language_model.dart';
import '../model/profile_model.dart';
import '../next_work/app_service.dart';
import '../user_storage.dart';

/// ViewModel cho màn Login
/// Giống ViewModel + ObservableObject bên iOS
class LoginViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool noSubscription = false;

  /// Đang loading
  bool isLoading = false;

  /// Lỗi — null nghĩa là không có lỗi
  String? errorMessage;

  /// Login thành công
  bool isLoggedIn = false;

  // --- Config Auth0 ---
  // Giống Info.plist bên iOS — sau này chuyển vào file config riêng

  // static const String _clientId = 'LCFF8h1w7pJM1jLGuzLkdkhuv35cLER3';
  // static const String _audience = 'https://devil.eu.auth0.com/api/v2/';
  // static const String _loginBaseUrl = 'https://devil.eu.auth0.com';
  // static const String _realm = 'Username-Password-Authentication';
  // static const String _scope = 'openid profile email offline_access';


  // ✅ Đổi sang product. userName: Marat@matisse.ai    pass: Matisse-123!
  static const String _clientId = 'hUuaFX9ML6qRUjGT2PCAI0lUHYSKLbP7';
  static const String _audience = 'https://dev-pie59pyu.eu.auth0.com/api/v2/';
  static const String _loginBaseUrl = 'https://dev-pie59pyu.eu.auth0.com';
  static const String _realm = 'Username-Password-Authentication';
  static const String _scope = 'openid profile email offline_access';

  // --- Public Methods ---

  /// Gọi API login
  /// Sau khi thành công tự động lưu token vào ApiService
  Future<void> login({
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    noSubscription = false;

    notifyListeners();

    try {
      // Bước 1: Lấy token từ Auth0
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

      final loginData = LoginModel.fromJson(response.data);
      final sessionId = const Uuid().v4().toLowerCase();

      // // Lưu credentials trước
      _api.saveCredentials(
        token: loginData.idToken,
        session: sessionId,
      );
      await UserStorage.shared.saveToken(loginData.idToken, sessionId);

      // ✅ Bước 2: Clear session CŨ trước
      try {
        await _api.get(ApiEndpoint.clearSession);
        print('✅ Session cleared');
      } catch (e) {
        print('⚠️ Clear session failed (bỏ qua): $e');
        // Không throw — vẫn tiếp tục
      }

// ✅ Bước 3: Gọi profile SAU KHI đã clear
      final profileResponse = await _api.get(ApiEndpoint.profile);
      final profile = ProfileModel.fromJson(profileResponse.data);

      // Lưu xuống user default.
      await UserStorage.shared.saveProfile(profile);
      print('✅ Profile fetched');

      // ✅ Kiểm tra subscription
      if (profile.subscriptions.isEmpty) {
        noSubscription = true;
        isLoggedIn = false; // Không cho vào app
        return; // Dừng lại, không set isLoggedIn = true
      }

      isLoggedIn = true;
      noSubscription = false;
      errorMessage = null;

    } on DioException catch (e) {
      print('❌ LOGIN ERROR: ${e.response?.statusCode} - ${e.response?.data}');
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
    UserStorage.shared.clearProfile();
    isLoggedIn = false;
    noSubscription = false; // ✅ reset flag subscription
    errorMessage = null;    // ✅ reset error
    UserStorage.shared.clearEmail();
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
        final data = e.response?.data;

        // Auth0 trả 403 cho cả sai mật khẩu lẫn account bị block
        if (status == 401 || status == 403) {
          final error = data is Map ? data['error'] : null;
          final description = data is Map ? data['error_description'] : null;

          if (error == 'invalid_grant') {
            return 'Email hoặc mật khẩu không đúng';
          }
          if (error == 'unauthorized_client' || description?.contains('blocked') == true) {
            return 'Tài khoản đã bị khóa';
          }
          return 'Không có quyền truy cập';
        }

        return 'Lỗi server ($status)';
      case DioExceptionType.connectionError:
        return 'Không có kết nối mạng';
      default:
        return 'Lỗi không xác định';
    }
  }
}