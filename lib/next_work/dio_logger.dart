import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

// 🍎 Swift/UIKit: Tương đương với một class URLSessionDelegate hoặc
// Alamofire EventMonitor — nơi bạn "hook" vào mọi request/response.
//
// 🐦 Flutter/Dio: Interceptor là middleware, giống như một "layer" nằm giữa
// app và network. Dio cho phép add nhiều interceptor theo thứ tự.

class DioLogger extends Interceptor {
  // 🍎 Swift: Giống `static let shared` — dùng const constructor để tái sử dụng.
  // 🐦 Flutter: const constructor = compile-time constant, nhẹ hơn.
  const DioLogger();

  // ─────────────────────────────────────────
  // 📤 REQUEST
  // 🍎 Swift/Alamofire: func requestDidFinish(_ request: Request)
  // 🐦 Flutter/Dio: override onRequest — gọi trước khi request được gửi đi
  // ─────────────────────────────────────────
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 🍎 Swift: print("➡️ [\(method)] \(url)")
    // 🐦 Flutter: debugPrint tương đương NSLog, tự cắt chuỗi dài
    debugPrint('');
    debugPrint('┌─────────────────────────────────────────');
    debugPrint('│ ➡️  REQUEST');
    debugPrint('│ 🔗 [${options.method}] ${options.path}');

    // 🍎 Swift: request.allHTTPHeaderFields?.forEach { print($0) }
    // 🐦 Flutter: Map.forEach — tương tự Dictionary.forEach trong Swift
    if (options.headers.isNotEmpty) {
      debugPrint('│ 📋 HEADERS:');
      options.headers.forEach((key, value) {
        // Ẩn token để log không quá dài (giống cách Proxyman filter)
        final display = key.toLowerCase() == 'authorization'
            ? '${(value as String).substring(0, 20)}...[truncated]'
            : value;
        debugPrint('│    $key: $display');
      });
    }

    // 🍎 Swift: if let body = request.httpBody, let json = try? JSONSerialization.jsonObject(...)
    // 🐦 Flutter: request body nằm trong options.data, có thể là Map, String, FormData
    if (options.data != null) {
      debugPrint('│ 📦 BODY:');
      debugPrint(_prettyJson(options.data));
    }

    // 🍎 Swift: urlComponents.queryItems
    // 🐦 Flutter: options.queryParameters là Map<String, dynamic>
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│ 🔍 QUERY PARAMS:');
      debugPrint(_prettyJson(options.queryParameters));
    }

    debugPrint('└─────────────────────────────────────────');

    // 🍎 Swift: completion handler / không làm gì = cho request đi tiếp
    // 🐦 Flutter: PHẢI gọi handler.next() để request không bị block
    handler.next(options);
  }

  // ─────────────────────────────────────────
  // 📥 RESPONSE
  // 🍎 Swift/Alamofire: func requestDidFinish(_ request: Request) với response
  // 🐦 Flutter/Dio: override onResponse — gọi khi nhận được response thành công (2xx)
  // ─────────────────────────────────────────
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('');
    debugPrint('┌─────────────────────────────────────────');
    debugPrint('│ ✅ RESPONSE [${response.statusCode}]: ${response.requestOptions.path}');

    // 🍎 Swift: response.allHeaderFields
    // 🐦 Flutter: response.headers là Headers object, dùng .map để convert
    debugPrint('│ ⏱ Duration: có thể đo bằng Stopwatch (xem ghi chú cuối)');

    // 🍎 Swift: JSONSerialization.jsonObject(with: data, options: .prettyPrinted)
    // 🐦 Flutter: response.data đã được Dio tự decode nếu responseType = json
    if (response.data != null) {
      debugPrint('│ 📦 RESPONSE DATA:');
      // Chia nhỏ log vì Android logcat giới hạn ~4000 ký tự/dòng
      // 🍎 Swift: os_log không bị giới hạn, nhưng Android logcat thì có
      _printLongString(_prettyJson(response.data), clean: true);
    }

    debugPrint('└─────────────────────────────────────────');

    // 🍎 Swift: gọi completion(.success(response))
    // 🐦 Flutter: PHẢI gọi handler.next() để data tiếp tục về caller
    handler.next(response);
  }

  // ─────────────────────────────────────────
  // ❌ ERROR
  // 🍎 Swift/Alamofire: func request(_ request: Request, didFailWithError error: Error)
  // 🐦 Flutter/Dio: override onError — gọi khi có lỗi (4xx, 5xx, timeout, no internet...)
  // ─────────────────────────────────────────
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('');
    debugPrint('┌─────────────────────────────────────────');
    debugPrint('│ ❌ ERROR [${err.response?.statusCode ?? 'NO_CODE'}]: ${err.requestOptions.path}');
    debugPrint('│ 💬 Message: ${err.message}');

    // 🍎 Swift: switch error { case .sessionTaskFailed: ... }
    // 🐦 Flutter: DioExceptionType enum tương tự URLError.Code trong Swift
    debugPrint('│ 🏷  Type: ${err.type.name}');
    //   connectionTimeout  ≈ URLError.timedOut
    //   receiveTimeout     ≈ URLError.timedOut
    //   badResponse        ≈ HTTPURLResponse statusCode không hợp lệ
    //   cancel             ≈ URLError.cancelled
    //   unknown            ≈ URLError.unknown

    if (err.response?.data != null) {
      debugPrint('│ 📦 ERROR BODY:');
      _printLongString(_prettyJson(err.response!.data));
    }

    debugPrint('└─────────────────────────────────────────');

    // 🍎 Swift: gọi completion(.failure(error))
    // 🐦 Flutter: handler.next(err) để lỗi tiếp tục về caller
    //             handler.resolve(response) nếu muốn "chuyển" lỗi thành success (dùng cho refresh token)
    //             handler.reject(err) để dừng chain và throw ngay
    handler.next(err);
  }

  // ─────────────────────────────────────────
  // 🛠 HELPERS
  // ─────────────────────────────────────────

  /// Format bất kỳ object nào thành JSON đẹp (pretty print)
  /// 🍎 Swift: JSONSerialization + String(data:encoding:) + options .prettyPrinted
  /// 🐦 Flutter: jsonEncode (dart:convert) + JsonEncoder.withIndent
  String _prettyJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  '); // 2-space indent
      // Nếu data là String (ví dụ raw JSON), decode trước rồi encode lại
      final object = data is String ? jsonDecode(data) : data;
      return encoder.convert(object);
    } catch (_) {
      // Không phải JSON (ví dụ FormData, binary) → toString()
      return data.toString();
    }
  }

  /// Android logcat giới hạn ~4000 ký tự mỗi dòng.
  /// Hàm này chia nhỏ chuỗi dài thành nhiều dòng 800 ký tự.
  /// 🍎 Swift/Xcode console: không cần workaround này vì Xcode hiển thị đủ.
  /// 🐦 Flutter/Android Studio: cần thiết để không bị cắt log.
  void _printLongString(String text, {bool clean = false}) {
    const chunkSize = 800;
    for (var i = 0; i < text.length; i += chunkSize) {
      final end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      final chunk = text.substring(i, end);

      // clean: true → TUYỆT ĐỐI không có bất kỳ prefix nào
      // 🍎 Swift: print(chunk) — đơn giản vì Xcode không giới hạn
      // 🐦 Flutter: debugPrint(chunk) — không thêm gì vào trước/sau chunk
      debugPrint(clean ? chunk : '│  $chunk');
    }
  }
}