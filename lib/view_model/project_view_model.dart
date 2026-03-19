import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../api_endpoint/api_endpoint.dart';
import '../extension/loading.dart';
import '../model/project_model.dart';
import '../next_work/app_service.dart';

class ProjectViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  // --- State ---
  List<ProjectModel> myProjects = [];
  List<ProjectModel> sharedProjects = [];

  bool isLoading = false;
  bool isShoHUD = false;
  bool hasFetched = false;
  bool isLoadingMore = false;

  String? errorMessage;
  int totalCount = 0;

  // --- Pagination riêng cho từng tab ---
  int _myOffset = 0;
  int _sharedOffset = 0;
  bool _myHasMore = true;
  bool _sharedHasMore = true;
  bool _currentShared = false;

  static const int _limit = 10;

  // --- Getters --- UI chỉ cần dùng 2 cái này
  List<ProjectModel> get projects => _currentShared ? sharedProjects : myProjects;
  bool get hasMore => _currentShared ? _sharedHasMore : _myHasMore;

  // --- Public Methods ---

  Future<void> fetchProjects({
    String search = '',
    bool deletedCases = false,
    bool shared = false,
  }) async {
    _currentShared = shared;

    if (shared) {
      _sharedOffset = 0;
      _sharedHasMore = true;
      // ✅ Chỉ fetch nếu chưa có data
      if (sharedProjects.isNotEmpty) {
        notifyListeners();
        return;
      }
    } else {
      _myOffset = 0;
      _myHasMore = true;
      // ✅ Chỉ fetch nếu chưa có data
      if (myProjects.isNotEmpty) {
        notifyListeners();
        return;
      }
    }

    errorMessage = null;
    isLoading = true;
    LoadingService().show();
    notifyListeners();

    await _loadProjects(search: search, deletedCases: deletedCases, shared: shared);
    hasFetched = true;
  }

  Future<void> refreshProjects({
    String search = '',
    bool shared = false,
  }) async {
    _currentShared = shared;
    isShoHUD = true;
    notifyListeners();

    if (shared) {
      _sharedOffset = 0;
      _sharedHasMore = true;
    } else {
      _myOffset = 0;
      _myHasMore = true;
    }

    errorMessage = null;

    await _loadProjects(search: search, deletedCases: false, shared: shared);

    isShoHUD = false;
    notifyListeners();
  }

  Future<void> loadMore({
    String search = '',
    bool deletedCases = false,
    bool shared = false,
  }) async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    await _loadProjects(search: search, deletedCases: deletedCases, shared: shared);
  }

  // --- Private Methods ---

  Future<void> _loadProjects({
    required String search,
    required bool deletedCases,
    required bool shared,
  }) async {
    try {
      final offset = shared ? _sharedOffset : _myOffset; // ✅ offset đúng tab

      final response = await _api.get(
        ApiEndpoint.projects,
        queryParams: {
          'shared': shared,
          'limit': _limit,
          'offset': offset,
          'search': search,
          'deleted_cases': deletedCases,
        },
      );

      final paginated = PaginatedProjects.fromJson(response.data);

      // Cộng dồn vào đúng list
      if (shared) {
        sharedProjects.addAll(paginated.results);
        _sharedOffset += paginated.results.length;
        _sharedHasMore = paginated.next != null;
      } else {
        myProjects.addAll(paginated.results);
        _myOffset += paginated.results.length;
        _myHasMore = paginated.next != null;
      }

      totalCount = paginated.count;
      errorMessage = null;
    } on DioException catch (e) {
      print('❌ ERROR: ${e.response?.data}');
      errorMessage = _handleDioError(e);
    } catch (e) {
      errorMessage = 'Có lỗi xảy ra: $e';
    } finally {
      isLoading = false;
      isLoadingMore = false;
      LoadingService().hide();
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
        if (status == 401) return 'Phiên đăng nhập hết hạn';
        if (status == 403) return 'Không có quyền truy cập';
        if (status == 404) return 'Không tìm thấy dữ liệu';
        return 'Lỗi server ($status)';
      case DioExceptionType.connectionError:
        return 'Không có kết nối mạng';
      default:
        return 'Lỗi không xác định';
    }
  }
}