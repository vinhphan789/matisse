// profile_view_model.dart
//
// 🍎 Swift: class ProfileViewModel: ObservableObject
// 🐦 Flutter: class ProfileViewModel extends ChangeNotifier

import 'package:flutter/material.dart';
import '../model/profile_model.dart';
import '../user_storage.dart';


class ProfileViewModel extends ChangeNotifier {
  // 🍎 Swift: @Published var profile: ProfileModel?
  // 🐦 Flutter: biến thường + notifyListeners()
  ProfileModel? profile;

  // 🍎 Swift: init() { Task { await loadProfile() } }
  // 🐦 Flutter: gọi thẳng trong constructor
  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    profile = await UserStorage.shared.getProfile();
    notifyListeners();
  }
}