import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/extension/string.dart';
import 'package:matisse/home/left_menu.dart';
import 'package:provider/provider.dart';

import '../extension/app_router.dart';
import '../login/language.dart';
import '../login/main.dart';
import '../login/profile.dart';
import '../model/project_model.dart';       // 👈 ProjectModel từ API
import '../popup/logout_popup.dart';
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

  // ViewModel — KHÔNG dùng Provider vì bạn đang dùng AnimatedBuilder
  late ProjectViewModel vm ;
  final ProfileViewModel profileVM = ProfileViewModel();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 👈 Để detect scroll cuối list

  // Search query — dùng để gọi API search, không filter local nữa
  String _searchQuery = '';

  // Debounce timer để không gọi API liên tục khi user đang gõ
  // Giống debounce bên iOS
  DateTime? _lastSearchTime;

  @override
  void initState() {
    super.initState();
    vm = context.read<ProjectViewModel>();

    // Gọi API lần đầu sau khi widget build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.projects.isEmpty) {
        vm.fetchProjects();
      }
    });

    // Lắng nghe scroll — khi gần cuối list thì load more
    _scrollController.addListener(() {
      final position = _scrollController.position;
      final isNearBottom = position.pixels >= position.maxScrollExtent - 200;


      // 👈 Thêm log này để xem giá trị thực tế
      print('📜 scroll: pixels=${position.pixels.toInt()} max=${position.maxScrollExtent.toInt()} isNearBottom=$isNearBottom hasMore=${vm.hasMore} isLoadingMore=${vm.isLoadingMore} isLoading=${vm.isLoading}');

      if (isNearBottom) {
        final vm = context.read<ProjectViewModel>();

        if (vm.hasMore && !vm.isLoadingMore && !vm.isLoading) {
          vm.loadMore(
            search: _searchQuery,
            shared: _selectedTab == 1,
          );
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

  // Khi user đổi tab — fetch lại với param shared tương ứng
  void _onTabChanged(int index) {
    if (_selectedTab == index) return; // ✅ Không làm gì nếu tap tab đang chọn
    setState(() => _selectedTab = index);
    vm.fetchProjects(
      search: _searchQuery,
      shared: index == 1,
    );
  }


  // Khi user gõ search — gọi API sau 500ms (debounce)
  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _lastSearchTime = DateTime.now();
    final capturedTime = _lastSearchTime;

    Future.delayed(const Duration(milliseconds: 500), () {
      // Chỉ gọi API nếu user không gõ thêm trong 500ms
      if (capturedTime == _lastSearchTime) {
        vm.fetchProjects(
          search: value,
          shared: _selectedTab == 1,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MatisseDrawer(),
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
  // APPBAR
  // ============================================================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: SetupTextWidget(titleLabel: "Projects", font: FontApp.robotoMedium, textColor: Colors.white, fontSize: 24,),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyProfileScreen(profile: profileVM)),
              );
            },
            onWebshop: () {},
            onLanguage: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => LanguagePage(),
                ),
              );
            },
            onUserGuide: () {},
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
                      (route) => false, // xoá hết các màn hình trước đó
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
                onChanged: _onSearchChanged, // 👈 Gọi API search thay vì filter local
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
              label: SetupTextWidget(
                titleLabel: "NEW",
                font: FontApp.robotoMedium,
                textColor: Colors.black,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorApp.blueMainColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.xs4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB BAR
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
      onTap: () => _onTabChanged(index), // 👈 Gọi API khi đổi tab
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
  // SORT LABEL
  // ============================================================
  Widget _buildSortLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: const [
          Text(
            'Last modified at',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_upward, color: Colors.white, size: 18),
        ],
      ),
    );
  }

  // ============================================================
  // PROJECT LIST
  // ============================================================
  Widget _buildProjectList() {
    final vm = context.watch<ProjectViewModel>();

    // --- State 2: Có lỗi và chưa có data ---
    if (vm.errorMessage != null && vm.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              vm.errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => vm.fetchProjects(shared: _selectedTab == 1),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // --- State 3: Không có data ---
    // --- State 3: Không có data ---
    if (vm.hasFetched && vm.projects.isEmpty && vm.errorMessage == null && !vm.isShoHUD && !vm.isLoading) {
      return RefreshIndicator(
        color: ColorApp.blueMainColor,
        onRefresh: () async {
          await vm.refreshProjects(
            search: _searchQuery,
            shared: _selectedTab == 1,
          );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(), // ✅ Cho phép kéo dù không có item
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text('No projects found', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }

    // --- State 4: Có data ---
    return RefreshIndicator(
      color: ColorApp.blueMainColor, // 👈 Màu spinner kéo xuống
      onRefresh: () async {
        // Fetch lại từ đầu — giống pull to refresh bên iOS
        await vm.refreshProjects(
          search: _searchQuery,
          shared: _selectedTab == 1,
        );
      },
      child: ListView.separated(
        controller: _scrollController,
        itemCount: vm.projects.length + (vm.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(
          color: Color(0xFF3A3A3C),
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          if (index == vm.projects.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildProjectCard(vm.projects[index]);
        },
      ),
    );
  }

  // ============================================================
  // PROJECT CARD — dùng ProjectModel thay vì Project sample
  // ============================================================
  Widget _buildProjectCard(ProjectModel project) { // 👈 ProjectModel thay vì Project
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow('Dentist name: ${project.dentist?.name ?? 'N/A'}'),
                _buildInfoRow('Dentist name: ${project.dentist ?? 'N/A'}'),
                _buildInfoRow(
                  'Last modified at: ${_formatDate(project.updatedTs)} (${project.updatedBy ?? 'N/A'})',
                ),
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

  // ============================================================
  // THUMBNAIL
  // ============================================================
  Widget _buildThumbnail(ProjectModel project) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(AppSpacing.xs4),
        // Hiển thị ảnh nếu có
        image: project.image != null && project.image!.imageUrl.isNotEmpty
            ? DecorationImage(
          image: NetworkImage(project.image!.imageUrl),
          fit: BoxFit.cover,
        )
            : null,
      ),
      // Hiển thị icon placeholder nếu không có ảnh
      child: project.image == null
          ? const Icon(Icons.folder, color: Colors.grey, size: 30)
          : null,
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SetupTextWidget(
        titleLabel: text ?? "",
        font: FontApp.robotoRegular,
        fontSize: 12,
        textColor: ColorApp.whiteMainColor.withAlpha(700), maxLine: 2,
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
        decoration: const BoxDecoration(
          color: Color(0xFF3A3A3C),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildPopupItem(String label,
      {required VoidCallback onTap, bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          label,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // Parse date string từ API -> DateTime -> format đẹp
  // API trả về: "2026-03-02T10:17:04.407554Z"
  // ✅ Sau
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$min $period';
    } catch (_) {
      return dateStr;
    }
  }
}