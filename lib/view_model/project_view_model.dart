// ============================================================
// FILE 2: lib/view_model/project_view_model.dart
// ✅ Thay đổi so với code cũ:
//   1. fetchProjects: thêm forceReload để search luôn gọi API
//   2. isLoading indicator: chỉ show khi list hiện tại RỖNG
//   3. Search UX mượt: KHÔNG xoá list cũ khi đang fetch,
//      chỉ thay thế bằng list mới khi API trả về kết quả
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

  // sort hiện tại, mặc định là createdAt tăng dần
  SortProject currentSort = const SortProject(field: SortField.createdAt);

  // ============================================================
  // getter trả về list đã được sort
  // ============================================================
  List<ProjectModel> get sortedProjects {
    final list = List<ProjectModel>.from(
      _currentShared ? sharedProjects : myProjects,
    );

    list.sort((a, b) {
      int compare;
      switch (currentSort.field) {
        case SortField.name:
          compare = (a.name).toLowerCase().compareTo((b.name).toLowerCase());
          break;
        case SortField.createdAt:
          final aDate = DateTime.tryParse(a.createdTs ?? '') ?? DateTime(0);
          final bDate = DateTime.tryParse(b.createdTs ?? '') ?? DateTime(0);
          compare = aDate.compareTo(bDate);
          break;
        case SortField.lastModifiedAt:
          final aDate = DateTime.tryParse(a.updatedTs ?? '') ?? DateTime(0);
          final bDate = DateTime.tryParse(b.updatedTs ?? '') ?? DateTime(0);
          compare = aDate.compareTo(bDate);
          break;
        case SortField.status:
          compare = (a.status ?? '').compareTo(b.status ?? '');
          break;
      }
      return currentSort.order == SortOrder.ascending ? compare : -compare;
    });

    return list;
  }

  List<ProjectModel> get projects => _currentShared ? sharedProjects : myProjects;
  bool get hasMore => _currentShared ? _sharedHasMore : _myHasMore;

  void applySort(SortProject sort) {
    currentSort = sort;
    notifyListeners();
  }

  // ============================================================
  // ✅ [ĐÃ SỬA] fetchProjects
  //
  // Thay đổi:
  //   1. Thêm [forceReload] để search luôn bypass guard isNotEmpty
  //   2. ✅ Chỉ show LoadingIndicator khi list hiện tại RỖNG
  //      → Nếu list đang có data (search lại) → không show spinner
  //        để tránh màn hình bị giật/trống trong lúc chờ API
  //   3. ✅ KHÔNG xoá list cũ trước khi fetch
  //      → List cũ vẫn hiển thị trong lúc đang gọi API
  //      → Khi API trả về → _loadProjects sẽ THAY THẾ bằng list mới
  // ============================================================
  Future<void> fetchProjects({
    String search = '',
    bool deletedCases = false,
    bool shared = false,
    bool forceReload = false,
  }) async {
    _currentShared = shared;

    if (shared) {
      _sharedOffset = 0;
      _sharedHasMore = true;
      if (sharedProjects.isNotEmpty && !forceReload) {
        notifyListeners();
        return;
      }
    } else {
      _myOffset = 0;
      _myHasMore = true;
      if (myProjects.isNotEmpty && !forceReload) {
        notifyListeners();
        return;
      }
    }

    errorMessage = null;
    isLoading = true;

    // ✅ Chỉ show HUD spinner khi list đang rỗng
    // → Nếu list có data rồi (đang search lại) thì giữ nguyên UI,
    //   không show spinner để tránh màn hình bị trắng/giật
    final currentList = shared ? sharedProjects : myProjects;
    if (currentList.isEmpty) {
      LoadingService().show();
    }

    notifyListeners();

    // ✅ Truyền isReplace: true khi forceReload
    // → _loadProjects sẽ THAY THẾ list thay vì addAll
    await _loadProjects(
      search: search,
      deletedCases: deletedCases,
      shared: shared,
      isReplace: forceReload,
    );
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

    // refresh luôn replace list cũ
    await _loadProjects(search: search, deletedCases: false, shared: shared, isReplace: true);
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

    // loadMore luôn append (isReplace: false)
    await _loadProjects(search: search, deletedCases: deletedCases, shared: shared, isReplace: false);
  }

  // ============================================================
  // ✅ [ĐÃ SỬA] _loadProjects: thêm tham số [isReplace]
  //
  //   isReplace = false (mặc định): addAll — dùng cho load lần đầu & loadMore
  //   isReplace = true            : gán thẳng list mới — dùng cho search & refresh
  //     → List cũ chỉ bị xoá SAU KHI có kết quả mới từ API
  //     → Trong lúc đang fetch, list cũ vẫn hiển thị bình thường
  // ============================================================
  Future<void> _loadProjects({
    required String search,
    required bool deletedCases,
    required bool shared,
    bool isReplace = false,
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
        if (isReplace) {
          // ✅ Chỉ thay thế khi API đã trả về kết quả
          // → Không có khoảnh khắc màn hình trống
          sharedProjects = paginated.results;
        } else {
          sharedProjects.addAll(paginated.results);
        }
        _sharedOffset = isReplace
            ? paginated.results.length      // reset offset về độ dài list mới
            : _sharedOffset + paginated.results.length;
        _sharedHasMore = paginated.next != null;
      } else {
        if (isReplace) {
          // ✅ Chỉ thay thế khi API đã trả về kết quả
          myProjects = paginated.results;
        } else {
          myProjects.addAll(paginated.results);
        }
        _myOffset = isReplace
            ? paginated.results.length
            : _myOffset + paginated.results.length;
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