// user_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/profile_model.dart';


// 🍎 Swift: UserDefaults.standard — singleton, lưu key-value
// 🐦 Flutter: SharedPreferences — tương đương, async, cũng key-value
//             Phải add vào pubspec.yaml: shared_preferences: ^2.2.0

class UserStorage {
  // 🍎 Swift: static let shared = UserStorage()
  // 🐦 Flutter: tương tự — dùng static instance
  static final UserStorage shared = UserStorage._();
  UserStorage._();

  static const _keyProfile = 'user_profile';
  static const _keyEmail = 'user_email';
  String? email;

  // user_storage.dart
  static const _keyToken = 'access_token';
  static const _keySession = 'session_id';

  String? token;
  String? sessionId;

  Future<void> saveToken(String token, String session) async {
    this.token = token;
    this.sessionId = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keySession, session);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_keyToken);
    sessionId = prefs.getString(_keySession);
  }

  Future<void> loadEmail() async {
    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString(_keyEmail);
  }

  Future<void> clearToken() async {
    token = null;
    sessionId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keySession);
  }

  // 🍎 Swift: UserDefaults.standard.set(try? JSONEncoder().encode(profile), forKey: "profile")
  // 🐦 Flutter: SharedPreferences không lưu được Object trực tiếp
  //             → phải convert sang JSON String trước
  Future<void> saveProfile(ProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString(_keyProfile, jsonString);
  }

  // 🍎 Swift: UserDefaults.standard.data(forKey: "profile").flatMap { try? JSONDecoder().decode(...) }
  // 🐦 Flutter: đọc String → decode JSON → fromJson
  Future<ProfileModel?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyProfile);
    if (jsonString == null) return null;
    return ProfileModel.fromJson(jsonDecode(jsonString));
  }

  // 🍎 Swift: UserDefaults.standard.removeObject(forKey: "profile")
  // 🐦 Flutter: prefs.remove(key)
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProfile);
  }

  // ── Email ─────────────────────────────────────────────
  Future<void> saveEmail(String value) async {
    email = value; // 👈 cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, value);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
  }

  // user_storage.dart
  bool isTokenValid() {
    if (token == null) return false;
    try {
      // JWT gồm 3 phần: header.payload.signature
      final parts = token!.split('.');
      if (parts.length != 3) return false;

      // Decode phần payload (base64)
      String payload = parts[1];
      // Padding base64 cho đúng độ dài
      payload += '=' * (4 - payload.length % 4);
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);

      // Lấy exp (Unix timestamp)
      final exp = json['exp'];
      if (exp == null) return false;

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isBefore(expDate);
    } catch (e) {
      print('❌ Token decode error: $e');
      return false;
    }
  }
}