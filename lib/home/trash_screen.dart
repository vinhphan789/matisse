// ============================================================
// FILE 2: lib/home/trash_screen.dart
//
// UI cho màn hình Trash (thùng rác).
// Structure giống ProjectsScreen nhưng:
//   ✅ KHÔNG có tab bar (MY PROJECTS / SHARED)
//   ✅ KHÔNG có nút NEW
//   ✅ Popup menu có Restore + Delete Permanently (thay vì Share/Duplicate...)
//   ✅ Dùng TrashViewModel thay vì ProjectViewModel
//   ✅ Reuse SortProject, SortBottomSheet pattern giống projects_screen
// ============================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/extension/string.dart';
import 'package:matisse/home/sort_project.dart';
import 'package:provider/provider.dart';

import '../router/app_spacing.dart';
import '../login/language.dart';
import '../login/main.dart';
import '../login/profile.dart';
import '../model/project_model.dart';
import '../popup/logout_popup.dart';
import '../user_guide/user_guide.dart';
import '../user_storage.dart';
import '../view_model/login_view_model.dart';
import '../view_model/profile_view_model.dart';
import '../view_model/trash_view_model.dart'; // ✅ Import TrashViewModel
import 'avata_popup.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  // ─────────────────────────────────────────────
  // Controllers & state
  // ─────────────────────────────────────────────
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TrashViewModel vm; // ViewModel riêng cho Trash
  final ProfileViewModel profileVM = ProfileViewModel();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  String? _email;

  // Debounce search — giống projects_screen
  DateTime? _lastSearchTime;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadEmail();

    // ✅ Lấy TrashViewModel từ Provider
    vm = context.read<TrashViewModel>();

    // Fetch data lần đầu khi màn hình mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.trashedProjects.isEmpty) {
        vm.fetchTrashedProjects();
      }
    });

    // ─────────────────────────────────────────────
    // Infinite scroll: theo dõi vị trí scroll
    // Khi gần cuối list → gọi loadMore()
    // ─────────────────────────────────────────────
    _scrollController.addListener(() {
      final position = _scrollController.position;
      final isNearBottom = position.pixels >= position.maxScrollExtent - 200;

      if (isNearBottom) {
        final vm = context.read<TrashViewModel>();
        if (vm.hasMore && !vm.isLoadingMore && !vm.isLoading) {
          vm.loadMore(search: _searchQuery);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Future<void> _loadEmail() async {
    final value = await UserStorage.shared.getEmail();
    setState(() => _email = value);
  }

  // ─────────────────────────────────────────────
  // Debounce search: chờ 800ms sau lần gõ cuối mới gọi API
  // Tránh spam API khi user gõ liên tục
  // ─────────────────────────────────────────────
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);

    _lastSearchTime = DateTime.now();
    final capturedTime = _lastSearchTime;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (capturedTime == _lastSearchTime) {
        // Đủ 800ms không có lần gõ mới → gọi API
        context.read<TrashViewModel>().fetchTrashedProjects(
          search: value,
          forceReload: true,
        );
      }
    });
  }

  // Mở Sort bottom sheet — reuse _TrashSortBottomSheet bên dưới
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => _TrashSortBottomSheet(
        currentSort: vm.currentSort,
        onSortChanged: (newSort) {
          // Sort local, không gọi API
          vm.applySort(newSort);
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Restore project → gọi VM → hiển thị kết quả bằng SnackBar
  // ─────────────────────────────────────────────
  Future<void> _onRestore(ProjectModel project) async {
    Navigator.pop(context); // Đóng popup menu nếu đang mở
    try {
      await vm.restoreProject(project);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${project.name}" đã được khôi phục.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Khôi phục thất bại. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // Permanent delete → hỏi xác nhận trước khi xoá
  // ─────────────────────────────────────────────
  Future<void> _onPermanentDelete(ProjectModel project) async {
    Navigator.pop(context); // Đóng popup menu

    // Hiện dialog xác nhận — tránh xoá nhầm
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2E),
        title: const Text(
          'Xoá vĩnh viễn?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '"${project.name}" sẽ bị xoá vĩnh viễn và không thể khôi phục.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await vm.permanentlyDelete(project);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑 "${project.name}" đã bị xoá vĩnh viễn.'),
          backgroundColor: Colors.grey[800],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Xoá thất bại. Vui lòng thử lại.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorApp.blackMain1E1E1E,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),  // ① Search bar (không có nút NEW)
          _buildSortLabel(),  // ② Sort label (tap để đổi sort)
          Expanded(
            child: _buildProjectList(), // ③ Danh sách project
          ),
        ],
        // ✅ Không có _buildTabBar() vì Trash không có tab MY/SHARED
      ),
    );
  }

  // ============================================================
  // APPBAR
  // Title là "Trash" thay vì "Projects"
  // Không có nút NEW
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      // Back button (vì TrashScreen được push từ màn hình khác)
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: SetupTextWidget(
        titleLabel: "Trash",
        font: FontApp.robotoMedium,
        textColor: Colors.white,
        fontSize: 24,
      ),
      actions: [
        // Avatar popup — giữ nguyên như ProjectsScreen
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AvatarPopupButton(
            userName: profileVM.profile?.name.getName() ?? "",
            userEmail: _email ?? "Email",
            avatarInitials: profileVM.profile?.name.getAbbName() ?? "",
            avatarColor: ColorApp.bruBackgroundCE93D8,
            onMyProjects: () {},
            onMyProfile: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyProfileScreen(profile: profileVM)),
              );
            },
            onWebshop: () {},
            onLanguage: () {
              Navigator.push(context, CupertinoPageRoute(builder: (_) => LanguagePage()));
            },
            onUserGuide: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserGuideScreen()),
              );
            },
            onLogout: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                barrierColor: Colors.black.withOpacity(0.6),
                builder: (_) => const LogoutAlertDialog(),
              );
              if (confirmed == true) {
                context.read<LoginViewModel>().logout();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH BAR
  // ✅ Không có nút NEW — chỉ có ô tìm kiếm
  // ============================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged, // ✅ debounce 800ms
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey, size: 24),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            isDense: true,
            isCollapsed: true,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SORT LABEL
  // Tap vào để mở bottom sheet chọn sort
  // context.watch → tự rebuild khi currentSort thay đổi
  // ============================================================
  Widget _buildSortLabel() {
    final sort = context.watch<TrashViewModel>().currentSort;

    return GestureDetector(
      onTap: _showSortSheet,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              sort.label, // VD: "Last modified at", "Name", "Created at"
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              sort.order == SortOrder.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROJECT LIST
  // Dùng vm.sortedProjects thay vì vm.trashedProjects
  // → List luôn được sort đúng theo currentSort
  // ============================================================
  Widget _buildProjectList() {
    final vm = context.watch<TrashViewModel>();
    final displayList = vm.sortedProjects; // ✅ Luôn dùng sorted list

    // ── Trạng thái lỗi ──
    if (vm.errorMessage != null && vm.trashedProjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(vm.errorMessage!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => vm.fetchTrashedProjects(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // ── Trạng thái loading lần đầu ──
    if (vm.isLoading && displayList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: ColorApp.blueMainColor),
      );
    }

    // ── Trạng thái rỗng sau khi fetch ──
    if (vm.hasFetched && displayList.isEmpty && vm.errorMessage == null) {
      return RefreshIndicator(
        color: ColorApp.blueMainColor,
        onRefresh: () => vm.refreshProjects(search: _searchQuery),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFF3A3A3C), width: 1),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: ColorApp.blueMainColor,
                      size: 28,
                    ),
                    SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Thùng rác trống!',
                          style: TextStyle(
                            color: ColorApp.blueMainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Không có project nào trong thùng rác.',
                          style: TextStyle(
                            color: ColorApp.blueMainColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ── Danh sách chính ──
    return RefreshIndicator(
      color: ColorApp.blueMainColor,
      onRefresh: () => vm.refreshProjects(search: _searchQuery),
      child: ListView.separated(
        controller: _scrollController,
        // +1 để hiện loading spinner ở cuối khi load more
        itemCount: displayList.length + (vm.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(
          color: Color(0xFF3A3A3C),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          // Item cuối cùng là loading spinner (khi đang load more)
          if (index == displayList.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildProjectCard(displayList[index]);
        },
      ),
    );
  }

  // ============================================================
  // PROJECT CARD
  // Giống ProjectsScreen nhưng popup menu có Restore + Delete Permanently
  // ============================================================
  Widget _buildProjectCard(ProjectModel project) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildThumbnail(project),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên project
                Text(
                  project.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Created at: ${_formatDate(project.createdTs)}'),
                _buildInfoRow('Dentist name: ${project.dentist?.name ?? 'N/A'}'),
                _buildInfoRow('Shared with: N/A'), // TODO: thay bằng data thật
                _buildInfoRow(
                  'Last modified at: ${_formatDate(project.updatedTs)} (${project.updatedBy ?? 'N/A'})',
                ),
                const SizedBox(height: 8),
                _buildStatusBadge(project.status ?? ""),
              ],
            ),
          ),
          // ✅ Popup menu với 2 action: Restore và Delete Permanently
          _buildPopupMenu(project),
        ],
      ),
    );
  }

  Widget _buildThumbnail(ProjectModel project) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(AppSpacing.xs4),
        image: project.image != null && project.image!.imageUrl.isNotEmpty
            ? DecorationImage(
          image: NetworkImage(project.image!.imageUrl),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: project.image == null
          ? const Icon(Icons.folder, color: Colors.grey, size: 30)
          : null,
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SetupTextWidget(
        titleLabel: text,
        font: FontApp.robotoRegular,
        fontSize: 12,
        textColor: ColorApp.whiteMainColor.withAlpha(700),
        maxLine: 2,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color badgeColor = status == 'active' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ✅ Popup menu KHÁC với ProjectsScreen:
  //    - "Restore"           → khôi phục project
  //    - "Delete Permanently" → xoá vĩnh viễn (màu đỏ)
  // ─────────────────────────────────────────────
  Widget _buildPopupMenu(ProjectModel project) {
    return PopupMenuButton<String>(
      color: const Color(0xFF2C2C2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      icon: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF3A3A3C),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
      ),
      onSelected: (value) {
        // Xử lý action từ popup menu
        switch (value) {
          case 'restore':
            _onRestore(project);
            break;
          case 'delete':
            _onPermanentDelete(project);
            break;
        }
      },
      itemBuilder: (_) => [
        // Action 1: Restore
        const PopupMenuItem<String>(
          value: 'restore',
          child: Row(
            children: [
              Icon(Icons.restore, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('Restore', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ),
        // Action 2: Delete Permanently (màu đỏ để cảnh báo)
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
              SizedBox(width: 12),
              Text(
                'Delete Permanently',
                style: TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Format ngày giờ từ ISO string → "Mar 2, 2026 at 5:17 PM"
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$min $period';
    } catch (_) {
      return dateStr;
    }
  }
}

// ============================================================
// SORT BOTTOM SHEET cho TrashScreen
//
// Copy pattern từ _SortBottomSheet trong projects_screen.dart
// Không cần thay đổi logic, chỉ đổi tên class để tránh conflict
// ============================================================

class _TrashSortBottomSheet extends StatefulWidget {
  final SortProject currentSort;
  final ValueChanged<SortProject> onSortChanged;

  const _TrashSortBottomSheet({
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  State<_TrashSortBottomSheet> createState() => _TrashSortBottomSheetState();
}

class _TrashSortBottomSheetState extends State<_TrashSortBottomSheet> {
  late SortProject _current;

  @override
  void initState() {
    super.initState();
    _current = widget.currentSort;
  }

  void _onTapItem(SortField field) {
    SortProject next;

    if (_current.field == field) {
      // Tap lại cùng item → toggle ascending ↔ descending
      next = _current.copyWith(
        order: _current.order == SortOrder.ascending
            ? SortOrder.descending
            : SortOrder.ascending,
      );
    } else {
      // Tap item mới → mặc định ascending
      next = SortProject(field: field, order: SortOrder.ascending);
    }

    setState(() => _current = next);
    widget.onSortChanged(next); // Báo về TrashScreen → vm.applySort(next)
    // ✅ Sheet vẫn mở để user có thể đổi lại nếu muốn
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: ColorApp.blackMain1E1E1E),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Tiêu đề
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Sort by',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Các item sort — lặp qua tất cả SortField
          ...SortField.values.map((field) => _buildSortItem(field)),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildSortItem(SortField field) {
    final isSelected = _current.field == field;
    final label = SortProject(field: field).label;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTapItem(field),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          // Highlight item đang được chọn
          color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Mũi tên chỉ hiện khi item đang được chọn
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: isSelected
                  ? Icon(
                _current.order == SortOrder.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                key: ValueKey(_current.order),
                color: Colors.white,
                size: 20,
              )
                  : const SizedBox(width: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}