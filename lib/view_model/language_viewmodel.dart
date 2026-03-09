import 'package:flutter/material.dart';
import 'package:matisse/api_endpoint/api_endpoint.dart';
import 'package:matisse/extension/loading.dart';

import '../model/language_model.dart';
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
    LoadingService().show();
    print("🔥🔥🔥 fetchLanguage CALLED");
    try {
      final response = await _api.get(ApiEndpoint.languages);
      final List data = response.data;

      // Parse list JSON -> List<Model>
      languages = data.map((e) => LanguageModel.fromJson(e)).toList();

      error = null;
    } catch (e) {

      LoadingService().hide();
      error = e.toString();
    } finally {
      isLoading = false;
      LoadingService().hide();
      notifyListeners();
    }
  }
}


