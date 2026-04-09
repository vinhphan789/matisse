

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matisse/extension/loading.dart';
import '../../../api_endpoint/api_endpoint.dart';
import '../model/forgot_password_model.dart';
import '../next_work/app_service.dart';


class ForgotPasswordViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  // --- State ---
  bool isLoading = false;
  String? errorMessage;
  bool isEmailSent = false;

  // --- Auth0 Config (dùng lại từ LoginViewModel) ---
  static const String _clientId = 'hUuaFX9ML6qRUjGT2PCAI0lUHYSKLbP7';
  static const String _loginBaseUrl = 'https://dev-pie59pyu.eu.auth0.com';
  static const String _connection = 'Username-Password-Authentication';

  /// Gọi Auth0 reset password
  /// Auth0 sẽ tự gửi email chứa link đặt lại mật khẩu
  Future<void> sendResetEmail({required String email}) async {
    isLoading = true;
    errorMessage = null;
    isEmailSent = false;
    notifyListeners();

    try {
      final response = await _api.postFullUrl(
        '$_loginBaseUrl${ApiEndpoint.forgotPassword}',
        data: {
          'client_id': _clientId,
          'email': email,
          'connection': _connection,
        },
      );

      // Auth0 trả về plain text: "We've just sent you an email to reset your password."
      final result = ForgotPasswordModel.fromString(response.data.toString());
      print('✅ Reset email sent: ${result.message}');

      isEmailSent = true;
      errorMessage = null;

    } on DioException catch (e) {
      print('❌ FORGOT PASSWORD ERROR: ${e.response?.statusCode} - ${e.response?.data}');
      errorMessage = _handleDioError(e);
    } catch (e) {
      errorMessage = 'Có lỗi xảy ra: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối quá chậm, vui lòng thử lại';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 400) return 'Email không hợp lệ hoặc không tồn tại';
        if (status == 429) return 'Gửi quá nhiều lần, vui lòng thử lại sau';
        return 'Lỗi server ($status)';
      case DioExceptionType.connectionError:
        return 'Không có kết nối mạng';
      default:
        return 'Lỗi không xác định';
    }
  }
}