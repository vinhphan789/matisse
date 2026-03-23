// ============================================================
// FILE 2: lib/view_model/project_view_model.dart
// ✅ Chỉ thêm phần sort LOCAL — không thay đổi gì liên quan đến API
// ============================================================

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:matisse/home/sort_project.dart';

import '../api_endpoint/api_endpoint.dart';
import '../extension/loading.dart';
import '../model/project_model.dart';
import '../next_work/app_service.dart';

class ProjectViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  // --- State gốc — KHÔNG đổi ---
  List<ProjectModel> myProjects = [];
  List<ProjectModel> sharedProjects = [];

  bool isLoading = false;
  bool isShoHUD = false;
  bool hasFetched = false;
  bool isLoadingMore = false;

  String? errorMessage;
  int totalCount = 0;

  int _myOffset = 0;
  int _sharedOffset = 0;
  bool _myHasMore = true;
  bool _sharedHasMore = true;
  bool _currentShared = false;

  static const int _limit = 10;

  // ✅ THÊM MỚI: lưu sort hiện tại, mặc định là createdAt tăng dần
  SortProject currentSort = const SortProject(field: SortField.createdAt);

  // ============================================================
  // ✅ THÊM MỚI: getter trả về list đã được sort
  // UI sẽ dùng sortedProjects thay vì projects trực tiếp
  // ============================================================
  List<ProjectModel> get sortedProjects {
    // Lấy list gốc (my hoặc shared tuỳ tab đang chọn)
    final list = List<ProjectModel>.from(
      _currentShared ? sharedProjects : myProjects,
    );

    list.sort((a, b) {
      int compare;

      switch (currentSort.field) {
        case SortField.name:
        // So sánh tên A-Z (không phân biệt hoa thường)
          compare = (a.name).toLowerCase().compareTo((b.name).toLowerCase());
          break;

        case SortField.createdAt:
        // So sánh ngày tạo
        // createdTs là String dạng "2026-01-09T10:00:00Z"
        // DateTime.parse để chuyển thành DateTime rồi so sánh
          final aDate = DateTime.tryParse(a.createdTs ?? '') ?? DateTime(0);
          final bDate = DateTime.tryParse(b.createdTs ?? '') ?? DateTime(0);
          compare = aDate.compareTo(bDate);
          break;

        case SortField.lastModifiedAt:
        // So sánh ngày sửa cuối
          final aDate = DateTime.tryParse(a.updatedTs ?? '') ?? DateTime(0);
          final bDate = DateTime.tryParse(b.updatedTs ?? '') ?? DateTime(0);
          compare = aDate.compareTo(bDate);
          break;

        case SortField.status:
        // So sánh status A-Z
          compare = (a.status ?? '').compareTo(b.status ?? '');
          break;
      }

      // Nếu descending thì đảo ngược kết quả so sánh
      return currentSort.order == SortOrder.ascending ? compare : -compare;
    });

    return list;
  }

  // --- Getter cũ — GIỮ NGUYÊN để không break code khác ---
  List<ProjectModel> get projects => _currentShared ? sharedProjects : myProjects;
  bool get hasMore => _currentShared ? _sharedHasMore : _myHasMore;

  // ✅ THÊM MỚI: hàm UI gọi khi user chọn sort
  // Chỉ cập nhật currentSort rồi notifyListeners để UI rebuild
  // KHÔNG gọi API, KHÔNG fetch lại gì cả
  void applySort(SortProject sort) {
    currentSort = sort;
    notifyListeners(); // ViewModel thông báo cho UI rebuild với list đã sort mới
  }

  // --- Tất cả hàm bên dưới GIỮ NGUYÊN 100% ---

  Future<void> fetchProjects({
    String search = '',
    bool deletedCases = false,
    bool shared = false,
  }) async {
    _currentShared = shared;

    if (shared) {
      _sharedOffset = 0;
      _sharedHasMore = true;
      if (sharedProjects.isNotEmpty) {
        notifyListeners();
        return;
      }
    } else {
      _myOffset = 0;
      _myHasMore = true;
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

  Future<void> _loadProjects({
    required String search,
    required bool deletedCases,
    required bool shared,
  }) async {
    try {
      final offset = shared ? _sharedOffset : _myOffset;

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