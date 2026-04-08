// ============================================================
// FILE 3: lib/home/projects_screen.dart  (FULL — thay thế toàn bộ)
// ✅ Thay đổi so với code cũ:
//   1. _buildSortLabel() → tap được, hiển thị đúng tên sort
//   2. Thêm hàm _showSortSheet()
//   3. _buildProjectList() dùng vm.sortedProjects thay vì vm.projects
//   4. Thêm class _SortBottomSheet ở cuối file
//   5. ✅ [MỚI] _onSearchChanged: debounce 1.5 giây trước khi gọi API
//      → Người dùng gõ liên tục sẽ không spam API,
//        chỉ gọi API sau khi ngừng gõ đủ 1.5 giây
// ============================================================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/extension/string.dart';
import 'package:matisse/home/left_menu.dart';
import 'package:matisse/home/sort_project.dart'; // ✅ import sort
import 'package:provider/provider.dart';

import '../router/app_spacing.dart';
import '../login/language.dart';
import '../login/main.dart';
import '../login/profile.dart';
import '../model/project_model.dart';
import '../popup/logout_popup.dart';
import '../user_guide/user_guide.dart';
import '../view_model/profile_view_model.dart';
import '../view_model/project_view_model.dart';
import 'avata_popup.dart';
import 'create_new_project.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedTab = 0;

  late ProjectViewModel vm;
  final ProfileViewModel profileVM = ProfileViewModel();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';

  // ✅ [MỚI] Dùng DateTime để theo dõi lần gõ cuối cùng của người dùng.
  // Mục đích: so sánh trong Future.delayed để biết có lần gõ mới nào
  // xen vào trong 1.5 giây hay không. Nếu không → gọi API.
  DateTime? _lastSearchTime;

  @override
  void initState() {
    super.initState();
    vm = context.read<ProjectViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.projects.isEmpty) {
        vm.fetchProjects();
      }
    });

    _scrollController.addListener(() {
      final position = _scrollController.position;
      final isNearBottom = position.pixels >= position.maxScrollExtent - 200;

      print('📜 scroll: pixels=${position.pixels.toInt()} max=${position.maxScrollExtent.toInt()} isNearBottom=$isNearBottom hasMore=${vm.hasMore} isLoadingMore=${vm.isLoadingMore} isLoading=${vm.isLoading}');

      if (isNearBottom) {
        final vm = context.read<ProjectViewModel>();
        if (vm.hasMore && !vm.isLoadingMore && !vm.isLoading) {
          vm.loadMore(search: _searchQuery, shared: _selectedTab == 1);
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

  void _onTabChanged(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    vm.fetchProjects(search: _searchQuery, shared: index == 1);
  }

  // ✅ [ĐÃ SỬA] Debounce search: chờ 1.5 giây sau lần gõ cuối mới gọi API.
  //
  // Cơ chế hoạt động:
  //   1. Mỗi lần người dùng gõ phím → lưu thời điểm hiện tại vào _lastSearchTime.
  //   2. Đặt một Future chờ 1.5 giây.
  //   3. Khi Future hoàn thành → so sánh capturedTime với _lastSearchTime:
  //      - Bằng nhau  → không có lần gõ mới → ✅ gọi API với từ khoá hiện tại.
  //      - Khác nhau  → đã có lần gõ mới xen vào → ❌ bỏ qua, Future kia sẽ xử lý.
  //
  // ✅ forceReload: true → bỏ qua guard isNotEmpty trong ViewModel,
  //    đảm bảo API luôn được gọi với keyword mới dù list đang có data
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);

    _lastSearchTime = DateTime.now();
    final capturedTime = _lastSearchTime;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (capturedTime == _lastSearchTime) {
        print('🔍 Search debounce triggered — query: "$value"');
        context.read<ProjectViewModel>().fetchProjects(
          search: value,
          shared: _selectedTab == 1,
          forceReload: true, // ✅ THÊM: luôn gọi API, không bị chặn bởi guard
        );
      }
    });
  }

  // ✅ Mở Sort bottom sheet
  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (_) => _SortBottomSheet(
        currentSort: vm.currentSort,
        onSortChanged: (newSort) {
          // ✅ Gọi applySort trong ViewModel
          // ViewModel sẽ sort list local và notifyListeners → UI tự rebuild
          // KHÔNG fetch API, KHÔNG gọi setState ở đây
          vm.applySort(newSort);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ProjectsLeftMenu(
        onMyProjectsTap: (tab) {
          switch (tab) {
            case ProjectsLeftTap.myProjects:
              _onTabChanged(0); // ✅ switch sang tab My Projects (index 0)
            case ProjectsLeftTap.shareProjects:
              _onTabChanged(1);
            case ProjectsLeftTap.trash:
              // TODO: Handle this case.
              throw UnimplementedError();
          }
        },
      ),
      backgroundColor: ColorApp.blackMain1E1E1E,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          _buildSortLabel(),
          Expanded(child: _buildProjectList()),
        ],
      ),
    );
  }

  // ============================================================
  // APPBAR — giữ nguyên
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: SetupTextWidget(
        titleLabel: "Projects",
        font: FontApp.robotoMedium,
        textColor: Colors.white,
        fontSize: 24,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AvatarPopupButton(
            userName: profileVM.profile?.name.getName() ?? "",
            userEmail: profileVM.profile?.name ?? "",
            avatarInitials: profileVM.profile?.name.getAbbName() ?? "",
            avatarColor: ColorApp.bruBackgroundCE93D8,
            onMyProjects: () {},
            onMyProfile: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyProfileScreen(profile: profileVM)));
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
  // SEARCH BAR — giữ nguyên
  // ============================================================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(AppSpacing.xs4),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged, // ✅ gọi hàm debounce 1.5s
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
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => showCreateProjectSheet(context),
              icon: const Icon(Icons.add, size: 18),
              label: SetupTextWidget(titleLabel: "NEW", font: FontApp.robotoMedium, textColor: Colors.black),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorApp.blueMainColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.xs4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB BAR — giữ nguyên
  // ============================================================
  Widget _buildTabBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTab('MY PROJECTS', 0)),
            Expanded(child: _buildTab('SHARED', 1)),
          ],
        ),
        Container(height: 1, color: const Color(0xFF3A3A3C)),
      ],
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? ColorApp.blueMainColor : Colors.white.withAlpha(90),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            color: isSelected ? ColorApp.blueMainColor : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ✅ SORT LABEL — tap được + hiển thị sort đang chọn
  // ============================================================
  Widget _buildSortLabel() {
    // context.watch để widget tự rebuild khi currentSort thay đổi
    final sort = context.watch<ProjectViewModel>().currentSort;

    return GestureDetector(
      onTap: _showSortSheet, // ✅ tap vào đây để mở sheet
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              sort.label, // ✅ hiển thị tên sort hiện tại (VD: "Create At")
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(width: 4),
            Icon(
              sort.order == SortOrder.ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROJECT LIST — dùng vm.sortedProjects thay vì vm.projects
  // ============================================================
  Widget _buildProjectList() {
    final vm = context.watch<ProjectViewModel>();

    // Lấy list đã được sort local
    // ✅ sortedProjects tự sort lại mỗi khi currentSort thay đổi
    final displayList = vm.sortedProjects;

    if (vm.errorMessage != null && vm.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(vm.errorMessage!, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => vm.fetchProjects(shared: _selectedTab == 1),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (vm.hasFetched && displayList.isEmpty && vm.errorMessage == null && !vm.isShoHUD && !vm.isLoading) {
      return RefreshIndicator(
        color: ColorApp.blueMainColor,
        onRefresh: () async {
          await vm.refreshProjects(search: _searchQuery, shared: _selectedTab == 1);
        },
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: ColorApp.blueMainColor,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Oops!',
                          style: TextStyle(
                            color: ColorApp.blueMainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'No result found.',
                          style: TextStyle(
                            color: ColorApp.blueMainColor,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
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

    return RefreshIndicator(
      color: ColorApp.blueMainColor,
      onRefresh: () async {
        await vm.refreshProjects(search: _searchQuery, shared: _selectedTab == 1);
      },
      child: ListView.separated(
        controller: _scrollController,
        itemCount: displayList.length + (vm.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(
          color: Color(0xFF3A3A3C),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
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
  // PROJECT CARD — giữ nguyên
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
                Text(
                  project.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Dentist name: ${project.dentist?.name ?? 'N/A'}'),
                _buildInfoRow('Dentist name: ${project.dentist ?? 'N/A'}'),
                _buildInfoRow('Last modified at: ${_formatDate(project.updatedTs)} (${project.updatedBy ?? 'N/A'})'),
                const SizedBox(height: 8),
                _buildStatusBadge(project.status ?? ""),
              ],
            ),
          ),
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
            ? DecorationImage(image: NetworkImage(project.image!.imageUrl), fit: BoxFit.cover)
            : null,
      ),
      child: project.image == null ? const Icon(Icons.folder, color: Colors.grey, size: 30) : null,
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
      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildPopupMenu(ProjectModel project) {
    return CustomPopup(
      arrowColor: ColorApp.greyBackground2C2C2E,
      backgroundColor: ColorApp.greyBackground2C2C2E,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPopupItem('Share', onTap: () {}),
          _buildPopupItem('Duplicate', onTap: () {}),
          _buildPopupItem('Manage', onTap: () {}),
          _buildPopupItem('Delete', onTap: () {}, isDestructive: true),
        ],
      ),
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(color: Color(0xFF3A3A3C), shape: BoxShape.circle),
        child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildPopupItem(String label, {required VoidCallback onTap, bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: TextStyle(color: isDestructive ? Colors.redAccent : Colors.white, fontSize: 16),
        ),
      ),
    );
  }

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
// ✅ SORT BOTTOM SHEET
// Đặt ở cuối file projects_screen.dart cho tiện, không cần tạo file riêng
// ============================================================

class _SortBottomSheet extends StatefulWidget {
  final SortProject currentSort;
  final ValueChanged<SortProject> onSortChanged;

  const _SortBottomSheet({
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  State<_SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<_SortBottomSheet> {
  // _current: sort đang được highlight trong sheet
  late SortProject _current;

  @override
  void initState() {
    super.initState();
    _current = widget.currentSort; // khởi đầu từ sort hiện tại của ViewModel
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
      // Tap item khác → chọn item mới, mặc định ascending
      next = SortProject(field: field, order: SortOrder.ascending);
    }

    setState(() => _current = next); // cập nhật highlight trong sheet
    widget.onSortChanged(next);      // báo về ProjectsScreen → vm.applySort(next)
    // ✅ KHÔNG gọi Navigator.pop → sheet vẫn mở
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ColorApp.blackMain1E1E1E,
      ),
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
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),

          // Các item sort
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
          color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            // Mũi tên chỉ hiện khi item đang được chọn
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
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