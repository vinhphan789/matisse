import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/app_router.dart';
import 'package:matisse/extension/setup_widget.dart';

// ============================================================
// MODEL: Dữ liệu dự án
// ============================================================
class Project {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? dentistName;
  final List<String> sharedWith;
  final DateTime lastModifiedAt;
  final String modifiedBy;
  final String status;
  final String? thumbnailUrl;

  const Project({
    required this.id,
    required this.name,
    required this.createdAt,
    this.dentistName,
    this.sharedWith = const [],
    required this.lastModifiedAt,
    required this.modifiedBy,
    this.status = 'Active',
    this.thumbnailUrl,
  });
}

// ============================================================
// SAMPLE DATA: Dữ liệu mẫu
// ============================================================
final List<Project> sampleProjects = [
  Project(
    id: '1',
    name: 'UNNAMED 1',
    createdAt: DateTime(2026, 2, 21, 0, 27),
    lastModifiedAt: DateTime(2026, 2, 21, 0, 27),
    modifiedBy: 'Marat',
  ),
  Project(
    id: '2',
    name: 'Alp',
    createdAt: DateTime(2026, 2, 12, 22, 40),
    lastModifiedAt: DateTime(2026, 2, 12, 22, 40),
    modifiedBy: 'Marat',
    thumbnailUrl: 'tooth_alp',
  ),
  Project(
    id: '3',
    name: 'Warrens case',
    createdAt: DateTime(2026, 2, 7, 5, 9),
    lastModifiedAt: DateTime(2026, 2, 7, 5, 9),
    modifiedBy: 'Marat',
    thumbnailUrl: 'tooth_warren',
  ),
  Project(
    id: '4',
    name: 'Dani copy (4)',
    createdAt: DateTime(2026, 1, 29, 10, 49),
    sharedWith: ['An Phan', 'Chung'],
    lastModifiedAt: DateTime(2026, 2, 3, 17, 17),
    modifiedBy: 'Marat',
    thumbnailUrl: 'tooth_dani',
  ),
  Project(
    id: '5',
    name: 'Dani copy (4)',
    createdAt: DateTime(2026, 1, 29, 10, 49),
    sharedWith: ['An Phan', 'Chung'],
    lastModifiedAt: DateTime(2026, 2, 3, 17, 17),
    modifiedBy: 'Marat',
    thumbnailUrl: 'tooth_dani',
  ),
];

// ============================================================
// MAIN SCREEN
// ============================================================
class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> get _filteredProjects {
    if (_searchQuery.isEmpty) return sampleProjects;
    return sampleProjects
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),   // <-- đã fix
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
        onPressed: () {},
      ),
      title: const Text(
        'Projects',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: const Color(0xFFCE93D8),
            child: const Text(
              'MA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
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
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 24,),
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
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: SetupTextWidget(titleLabel: "NEW",
                font: FontApp.robotoMedium,
                textColor: Colors.black,),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DA3FF),
                foregroundColor: Colors.black,
                padding:
                const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.xs4),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }

  // ============================================================
  // TAB BAR — FIX CHÍNH:
  Widget _buildTabBar() {
    return Column(
      children: [
        // Hàng chứa 2 tab, mỗi tab chiếm 50% chiều rộng
        Row(
          children: [
            Expanded(child: _buildTab('MY PROJECTS', 0)),
            Expanded(child: _buildTab('SHARED', 1)),
          ],
        ),
        // Đường kẻ xám nền phía dưới toàn bộ tab bar
        Container(height: 1, color: const Color(0xFF3A3A3C)),
      ],
    );
  }

  /// Mỗi tab: text + gạch chân (chỉ hiện khi selected)
  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF4DA3FF)
                    : Colors.white.withAlpha(90),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Gạch chân — dùng AnimatedContainer để có hiệu ứng mượt
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            // width tự co theo Expanded, KHÔNG dùng double.infinity trong Row
            color: isSelected
                ? const Color(0xFF4DA3FF)
                : Colors.transparent,
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
    final projects = _filteredProjects;
    if (projects.isEmpty) {
      return const Center(
        child: Text('No projects found', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      itemCount: projects.length,
      separatorBuilder: (_, __) => const Divider(
        color: Color(0xFF3A3A3C),
        height: 1,
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) => _buildProjectCard(projects[index]),
    );
  }

  // ============================================================
  // PROJECT CARD
  // ============================================================
  Widget _buildProjectCard(Project project) {
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
                _buildInfoRow('Created at: ${_formatDate(project.createdAt)}'),
                _buildInfoRow('Dentist name: ${project.dentistName ?? 'N/A'}'),
                _buildInfoRow(
                  'Shared with: ${project.sharedWith.isEmpty ? 'N/A' : project.sharedWith.join(', ')}',
                ),
                _buildInfoRow(
                  'Last modified at: ${_formatDate(project.lastModifiedAt)}\n(${project.modifiedBy})',
                ),
                const SizedBox(height: 8),
                _buildStatusBadge(project.status),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showProjectOptions(project),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF3A3A3C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // THUMBNAIL
  // ============================================================
  Widget _buildThumbnail(Project project) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: project.thumbnailUrl != null
          ? const Icon(Icons.image, color: Colors.grey, size: 30)
          : const Icon(Icons.folder, color: Colors.grey, size: 30),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: SetupTextWidget(titleLabel: text, font: FontApp.robotoRegular,
        fontSize: 12, textColor: ColorApp.whiteMainColor.withAlpha(700),)
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color badgeColor = status == 'Active' ? Colors.green : Colors.grey;
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

  // Widget _buildChatFAB() {
  //   return FloatingActionButton(
  //     onPressed: () {},
  //     backgroundColor: const Color(0xFF4DA3FF),
  //     child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
  //   );
  // }

  void _showProjectOptions(Project project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.white),
            title: const Text('Rename', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.share, color: Colors.white),
            title: const Text('Share', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.redAccent),
            title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour =
    dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$min $period';
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProjectsScreen(),
  ));
}