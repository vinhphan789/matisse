import 'package:flutter/material.dart';
import 'package:matisse/api_endpoint/api_endpoint.dart';

import '../model/model.dart';
import '../next_work/app_service.dart';


/// ViewModel (giống ViewModel trong MVVM iOS)
/// Quản lý state + gọi API
class LanguageViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Data hiển thị ra UI
  List<LanguageModel> languages = [];

  // Loading state
  bool isLoading = false;

  // Error message
  String? error;

  /// Hàm gọi API
  Future<void> fetchLanguage() async {
    print("🔥🔥🔥 fetchLanguage CALLED");
    try {
      isLoading = true;
      notifyListeners(); // update UI

      final response = await _api.get(ApiEndpoint.languages);

      final List data = response.data;

      // Parse list JSON -> List<Model>
      languages = data.map((e) => LanguageModel.fromJson(e)).toList();

      error = null;
    } catch (e) {

      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}