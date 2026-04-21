// ============================================================
// FILE 1: lib/view_model/trash_view_model.dart
//
// ViewModel quản lý toàn bộ state cho Trash screen.
// Pattern giống ProjectViewModel nhưng chỉ làm việc với
// các project đã bị xoá (trashed projects).
// ============================================================

import 'package:flutter/material.dart';
import '../model/project_model.dart';
import '../home/sort_project.dart'; // ✅ Reuse SortProject từ projects

// ============================================================
// TrashViewModel extends ChangeNotifier
// → Dùng với Provider, UI sẽ tự rebuild khi notifyListeners()
// ============================================================
class TrashViewModel extends ChangeNotifier {

  // ─────────────────────────────────────────────
  // STATE: danh sách project trong thùng rác
  // ─────────────────────────────────────────────
  List<ProjectModel> _trashedProjects = [];
  List<ProjectModel> get trashedProjects => _trashedProjects;

  // ─────────────────────────────────────────────
  // STATE: sort hiện tại (default: Last modified, descending)
  // ─────────────────────────────────────────────
  SortProject _currentSort = SortProject(
    field: SortField.lastModifiedAt,
    order: SortOrder.descending,
  );
  SortProject get currentSort => _currentSort;

  // ─────────────────────────────────────────────
  // STATE: danh sách đã được sort để hiển thị lên UI
  // Getter này tính toán mỗi khi được gọi
  // → Không cần lưu thêm biến, luôn đồng bộ với _currentSort
  // ─────────────────────────────────────────────
  List<ProjectModel> get sortedProjects {
    final list = List<ProjectModel>.from(_trashedProjects);

    list.sort((a, b) {
      int compare;
      switch (_currentSort.field) {
        case SortField.name:
          compare = (a.name).compareTo(b.name);
          break;
        case SortField.createdAt:
          compare = (a.createdTs ?? '').compareTo(b.createdTs ?? '');
          break;
        case SortField.lastModifiedAt:
          compare = (a.updatedTs ?? '').compareTo(b.updatedTs ?? '');
          break;
        case SortField.status:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
      // Nếu descending → đảo ngược kết quả
      return _currentSort.order == SortOrder.ascending ? compare : -compare;
    });

    return list;
  }

  // ─────────────────────────────────────────────
  // STATE: loading / error / pagination
  // ─────────────────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ─────────────────────────────────────────────
  // Trang hiện tại (dùng cho load more / pagination)
  // ─────────────────────────────────────────────
  int _currentPage = 1;

  // ============================================================
  // STEP 1: Fetch danh sách trashed projects từ API
  //
  // Params:
  //   search     → từ khoá tìm kiếm (có thể rỗng)
  //   forceReload → bỏ qua guard "đã có data", luôn gọi API
  //                 Dùng khi user thay đổi search keyword
  // ============================================================
  Future<void> fetchTrashedProjects({
    String search = '',
    bool forceReload = false,
  }) async {
    // Guard: nếu đang load hoặc đã có data mà không force → bỏ qua
    if (_isLoading) return;
    if (_trashedProjects.isNotEmpty && !forceReload) return;

    // Reset state về đầu
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _trashedProjects = [];
    notifyListeners(); // → UI hiển thị loading indicator

    try {
      // ✅ TODO: Thay dòng dưới bằng API call thực tế của bạn
      // Ví dụ: final result = await ProjectRepository().fetchTrashed(
      //   page: 1,
      //   search: search,
      // );
      // _trashedProjects = result.items;
      // _hasMore = result.hasMore;

      // ── Giả lập API delay (xoá khi tích hợp thật) ──
      await Future.delayed(const Duration(milliseconds: 800));
      _trashedProjects = []; // ← thay bằng data từ API
      _hasMore = false;
      // ────────────────────────────────────────────────

      _hasFetched = true;
    } catch (e) {
      // Lưu lỗi để UI hiển thị nút "Thử lại"
      _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.\n${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners(); // → UI rebuild với data mới hoặc lỗi
    }
  }

  // ============================================================
  // STEP 2: Load thêm trang tiếp theo (pagination / infinite scroll)
  //
  // Gọi khi user scroll gần cuối list
  // ============================================================
  Future<void> loadMore({String search = ''}) async {
    // Guard: chỉ load more khi còn data và không đang load
    if (!_hasMore || _isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners(); // → UI hiển thị loading spinner ở cuối list

    try {
      _currentPage++;

      // ✅ TODO: Thay bằng API call thực tế
      // final result = await ProjectRepository().fetchTrashed(
      //   page: _currentPage,
      //   search: search,
      // );
      // _trashedProjects.addAll(result.items);
      // _hasMore = result.hasMore;

      await Future.delayed(const Duration(milliseconds: 600)); // xoá khi tích hợp thật
    } catch (e) {
      // Không hiển thị lỗi full screen khi load more thất bại
      // → Chỉ log, user có thể scroll lại để trigger load more
      debugPrint('❌ TrashVM loadMore error: $e');
      _currentPage--; // rollback page nếu thất bại
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ============================================================
  // STEP 3: Refresh (pull-to-refresh)
  //
  // Reset về trang 1, fetch lại từ đầu
  // ============================================================
  Future<void> refreshProjects({String search = ''}) async {
    await fetchTrashedProjects(search: search, forceReload: true);
  }

  // ============================================================
  // STEP 4: Áp dụng sort local
  //
  // KHÔNG gọi API — chỉ sort list đang có trong memory.
  // sortedProjects getter sẽ tự tính lại → UI rebuild qua notifyListeners
  // ============================================================
  void applySort(SortProject newSort) {
    _currentSort = newSort;
    notifyListeners(); // → UI rebuild với thứ tự mới
  }

  // ============================================================
  // STEP 5: Restore project (khôi phục từ thùng rác)
  //
  // Gọi API restore, nếu thành công → xoá khỏi local list
  // ============================================================
  Future<void> restoreProject(ProjectModel project) async {
    try {
      // ✅ TODO: Thay bằng API call thực tế
      // await ProjectRepository().restore(projectId: project.id);

      // Xoá project ra khỏi list local (không cần fetch lại toàn bộ)
      _trashedProjects.removeWhere((p) => p.id == project.id);
      notifyListeners(); // → UI tự update, project biến mất khỏi list
    } catch (e) {
      debugPrint('❌ TrashVM restore error: $e');
      rethrow; // ném lỗi lên UI để hiển thị snackbar
    }
  }

  // ============================================================
  // STEP 6: Xoá vĩnh viễn (permanent delete)
  //
  // Gọi API delete, nếu thành công → xoá khỏi local list
  // ============================================================
  Future<void> permanentlyDelete(ProjectModel project) async {
    try {
      // ✅ TODO: Thay bằng API call thực tế
      // await ProjectRepository().permanentDelete(projectId: project.id);

      _trashedProjects.removeWhere((p) => p.id == project.id);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ TrashVM permanentDelete error: $e');
      rethrow;
    }
  }
}