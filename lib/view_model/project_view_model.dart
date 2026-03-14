import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../api_endpoint/api_endpoint.dart';
import '../extension/loading.dart';
import '../model/project_model.dart';
import '../next_work/app_service.dart';

/// ViewModel cho màn Projects
/// Giống ViewModel + ObservableObject bên iOS
/// Kế thừa ChangeNotifier — giống @Published bên Swift
class ProjectViewModel extends ChangeNotifier {
  final ApiService _api = ApiService();

  // --- State ---

  /// Danh sách project hiển thị ra UI
  List<ProjectModel> projects = [];

  /// Đang loading lần đầu
  bool isLoading = false;
  bool isShoHUD = false; // 👈 Thêm biến này
  bool hasFetched = false;
  /// Đang load thêm trang tiếp (pagination)
  bool isLoadingMore = false;

  /// Lỗi — null nghĩa là không có lỗi
  String? errorMessage;

  /// Tổng số project từ API (dùng để hiển thị "194 projects")
  int totalCount = 0;

  /// Còn data để load tiếp không
  bool hasMore = true;

  // --- Pagination (private) ---
  int _currentOffset = 0;
  static const int _limit = 10;

  // --- Public Methods ---

  /// Fetch lần đầu — gọi khi màn hình init
  /// Giống viewDidLoad bên iOS
  Future<void> fetchProjects({
    String search = '',
    bool deletedCases = false,
    bool shared = false,
  }) async {
    // Reset toàn bộ state về ban đầu
    _currentOffset = 0;
    projects = [];
    hasMore = true;
    errorMessage = null;

    isLoading = true;
    // notifyListeners(); // Báo UI hiển thị loading
    LoadingService().show();

    await _loadProjects(
      search: search,
      deletedCases: deletedCases,
      shared: shared,
    );

    hasFetched = true;
  }

  /// Kéo làm mới — không show loading toàn màn hình
  Future<void> refreshProjects({
    String search = '',
    bool shared = false,
  }) async {
    isShoHUD = true; // 👈 KHÔNG set isLoading = true
    notifyListeners();

    _currentOffset = 0;

    hasMore = true;
    errorMessage = null;

    await _loadProjects(
      search: search,
      deletedCases: false,
      shared: shared,
    );

    isShoHUD = false;
    notifyListeners();
  }

  /// Load thêm trang tiếp — gọi khi user scroll xuống cuối list
  Future<void> loadMore({
    String search = '',
    bool deletedCases = false,
    bool shared = false,
  }) async {
    // Không load nếu đang loading hoặc hết data
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners(); // Báo UI hiển thị spinner ở cuối list

    await _loadProjects(
      search: search,
      deletedCases: deletedCases,
      shared: shared,
    );
  }

  // --- Private Methods ---

  /// Hàm gọi API thực sự
  /// Tách private để fetchProjects và loadMore đều dùng chung
  Future<void> _loadProjects({
    required String search,
    required bool deletedCases,
    required bool shared,
  }) async {
    try {
      final response = await _api.get(
        ApiEndpoint.projects,
        queryParams: {
          'shared': shared,
          'limit': _limit,
          'offset': _currentOffset,
          'search': search,
          'deleted_cases': deletedCases,
        },
      );
      print('📦 RESPONSE DATA: ${response.data}'); // 👈 Thêm dòng này
      // Parse response JSON -> PaginatedProjects
      final paginated = PaginatedProjects.fromJson(response.data);

      // Cộng dồn vào list — không replace (để support load more)
      projects.addAll(paginated.results);

      // Lưu tổng số để hiển thị UI
      totalCount = paginated.count;

      // Cập nhật offset cho lần load tiếp
      _currentOffset += paginated.results.length;

      // next == null nghĩa là đã hết data
      hasMore = paginated.next != null;

      errorMessage = null;
    } on DioException catch (e) {
      print('❌ 403 BODY: ${e.response?.data}'); // 👈 thêm dòng này
      // Lỗi từ Dio (network, timeout, 4xx, 5xx)
      errorMessage = _handleDioError(e);
    } catch (e) {
      // Lỗi khác (parse JSON, v.v.)
      errorMessage = 'Có lỗi xảy ra: $e';
    } finally {
      // Dù thành công hay thất bại đều tắt loading
      isLoading = false;
      LoadingService().hide();
      isLoadingMore = false;
      notifyListeners(); // Báo UI cập nhật
    }
  }

  /// Xử lý lỗi Dio thành message thân thiện
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
