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
}