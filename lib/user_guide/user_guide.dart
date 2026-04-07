import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/login/language.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserGuideScreen
//
// Màn hình hướng dẫn sử dụng app, gồm 4 bước (steps).
// Mỗi bước có: video (placeholder tạm), tiêu đề, mô tả.
// User có thể vuốt ngang hoặc nhấn nút "<" / ">" để chuyển bước.
// ─────────────────────────────────────────────────────────────────────────────

class UserGuideScreen extends StatefulWidget {
  final bool isFromOnboarding;
  const UserGuideScreen({Key? key, this.isFromOnboarding = false}) : super(key: key);

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  // Controller để điều khiển PageView (chuyển trang bằng code)
  final PageController _pageController = PageController();

  // Index của trang hiện tại (0 → 3)
  int _currentPage = 0;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _saveGuideSeen(); // Lưu trạng thái khi vào trang.
  }

  Future<void> _saveGuideSeen() async {
    // Lưu has_seen_guide = true — giống UserDefaults bên UIKit
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_guide', true);
  }
  // ── Dữ liệu 4 bước ──────────────────────────────────────────────────────────
  final List<Map<String, String>> _steps = const [
    {
      'title': 'Aesthetic Model',
      'description':
      'Copy the preparation color and adjacent teeth with Matisse ColorModel resin recipes.',
      'videoAsset': 'assets/videos/Aesthetic_Model_Edit.mp4',
    },
    {
      'title': 'Framework',
      'description': 'Get precise framework or full monolithic crown material advice.',
      'videoAsset': 'assets/videos/Framework_Edit.mp4',
    },
    {
      'title': 'Staining Studio: Full Monolithic',
      'description':
      'Stain full monolithic crowns or correct the color of layered crowns with our recipes.',
      'videoAsset': 'assets/videos/Staining_Stuio_Mono_Update.mp4',
    },
    {
      'title': 'Staining Studio: Color Model',
      'description':
      'Match the color of the 3D printed model to the natural teeth with our recipes.',
      'videoAsset': 'assets/videos/Staining_Studio_Color_Update.mp4',
    },
  ];

  // ── Giải phóng controller khi widget bị xóa khỏi cây widget ────────────────
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Chuyển sang trang TIẾP THEO ─────────────────────────────────────────────
  void _onNextPressed() {
    // Chỉ chuyển nếu chưa phải trang cuối
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  // ── Chuyển về trang TRƯỚC ────────────────────────────────────────────────────
  void _onBackPressed() {
    // Chỉ chuyển lùi nếu không phải trang đầu (index > 0)
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: widget.isFromOnboarding ? null : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Nút back trên AppBar: luôn thoát khỏi màn hình này (về màn trước)
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: widget.isFromOnboarding ? [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              // TODO: xử lý chọn ngôn ngữ
              Navigator.push(context, CupertinoPageRoute(builder: (_) => LanguagePage()));
            },
          ),] : null,

        title: const Text(
          'User Guide',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      // ── Body ────────────────────────────────────────────────────────────────
      // Container bọc ngoài để set màu nền khác với AppBar
      body: Container(
        // TODO: thay màu này theo design của bạn
        color: const Color(0xFF1C1C1E), // xám tối (khác với đen của AppBar)
        child: Column(
          children: [
            // ── ① PageView: CHỈ chứa video, chiếm không gian cố định ─────────────
            // Dùng SizedBox thay vì Expanded để video không chiếm hết màn hình
            SizedBox(
              height: 460, // chiều cao cố định cho vùng video
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  // Cập nhật state khi user vuốt tay hoặc nhấn nút
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  // Mỗi trang chỉ hiển thị phone mockup (video)
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Center(
                      child: _PhoneMockup(videoAsset: _steps[index]['videoAsset']!),
                    ),
                  );
                },
              ),
            ),

            // ── ② Dot indicator + nút back/next: ĐỨNG YÊN, không nằm trong PageView
            _BottomNavigation(
              totalPages: _steps.length,
              currentPage: _currentPage,
              onNextPressed: _onNextPressed,
              onBackPressed: _onBackPressed,
            ),

            const SizedBox(height: 16),

            // ── ③ Title: đứng yên, cập nhật theo _currentPage ────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _steps[_currentPage]['title']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── ④ Description: đứng yên, cập nhật theo _currentPage ──────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _steps[_currentPage]['description']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ), // end Column
      ), // end Container
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GuidePageContent
//
// Layout của MỘT trang theo thứ tự từ trên xuống:
//   ① _PhoneMockup       (video)
//   ② _BottomNavigation  (nút back/next + dot indicator) ← ngay dưới video
//   ③ Text               (title)
//   ④ Text               (description)
// ─────────────────────────────────────────────────────────────────────────────
class _GuidePageContent extends StatelessWidget {
  final String title;
  final String description;
  final String videoAsset;

  // Các tham số để hiển thị navigation ngay dưới video
  final int totalPages;
  final int currentPage;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;

  const _GuidePageContent({
    required this.title,
    required this.description,
    required this.videoAsset,
    required this.totalPages,
    required this.currentPage,
    required this.onNextPressed,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ① Video / Phone Mockup
          _PhoneMockup(videoAsset: videoAsset),

          // ② Dot indicator + nút back/next (ngay dưới video)
          _BottomNavigation(
            totalPages: totalPages,
            currentPage: currentPage,
            onNextPressed: onNextPressed,
            onBackPressed: onBackPressed,
          ),

          const SizedBox(height: 16),

          // ③ Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          // ④ Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PhoneMockup
//
// Khung điện thoại giả lập chứa video.
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneMockup extends StatelessWidget {
  final String videoAsset;

  const _PhoneMockup({required this.videoAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 420,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3A3A3C), width: 3),
        borderRadius: BorderRadius.circular(36),
        color: const Color(0xFF1C1C1E),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(33),
        child: Column(
          children: [
            // Notch giả lập ở đầu điện thoại
            Container(
              height: 28,
              color: Colors.black,
              alignment: Alignment.center,
              child: Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),

            // Phần nội dung: video hoặc placeholder
            Expanded(
              child: videoAsset.isEmpty
                  ? _VideoPlaceholder()
                  : _VideoPlayerWidget(assetPath: videoAsset),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _VideoPlayerWidget
//
// Widget phát video từ assets.
// - Tự động phát khi được tạo (autoplay)
// - Lặp lại liên tục (loop)
// - Tắt tiếng (mute) — phù hợp cho video hướng dẫn
// - Hiện placeholder khi đang load
// ─────────────────────────────────────────────────────────────────────────────
class _VideoPlayerWidget extends StatefulWidget {
  final String assetPath;

  const _VideoPlayerWidget({required this.assetPath});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  // Controller quản lý việc phát video
  late VideoPlayerController _controller;

  // Trạng thái: video đã sẵn sàng phát chưa
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo controller với file video từ assets
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        // Khi video đã load xong
        setState(() {
          _isInitialized = true;
        });

        _controller.setLooping(true);  // lặp lại liên tục
        _controller.setVolume(0);      // tắt tiếng
        _controller.play();            // tự động phát
      });
  }

  // Giải phóng controller khi widget bị xóa (quan trọng, tránh memory leak)
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Đang load video → hiện placeholder tạm
      return _VideoPlaceholder();
    }

    // Video đã sẵn sàng → hiện video, giữ đúng tỉ lệ khung hình
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _VideoPlaceholder
//
// Hiển thị tạm khi chưa có video. Xóa và thay bằng VideoPlayer sau.
// ─────────────────────────────────────────────────────────────────────────────
class _VideoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2C2C2E),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Video coming soon',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomNavigation
//
// Layout: [nút back] ─── [dot indicators] ─── [nút next]
//
// Quy tắc hiển thị:
//   - Nút back ("<") : ẩn khi currentPage == 0 (trang đầu tiên)
//   - Nút next (">") : ẩn khi currentPage == totalPages - 1 (trang cuối)
//
// Dùng Opacity(opacity: 0) thay vì if() để layout không bị giật
// (dot indicator luôn ở giữa dù nút có hay không).
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNavigation extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;

  const _BottomNavigation({
    required this.totalPages,
    required this.currentPage,
    required this.onNextPressed,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFirstPage = currentPage == 0;
    final bool isLastPage = currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Nút BACK "<" ─────────────────────────────────────────────────
          // opacity: 0 = trong suốt (ẩn) nhưng vẫn chiếm không gian
          // → giúp dot indicator luôn căn giữa
          Opacity(
            opacity: isFirstPage ? 0.0 : 1.0,
            child: _NavButton(
              icon: Icons.arrow_back_ios_rounded,
              // Khi đang ẩn không cho nhấn bằng cách truyền null
              onTap: isFirstPage ? null : onBackPressed,
            ),
          ),

          // ── Dot Indicator ─────────────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalPages, (index) {
              final bool isActive = index == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                // Chấm active: rộng hơn (pill shape) | inactive: tròn nhỏ
                width:  8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFF9500) // cam
                      : const Color(0xFF3A3A3C), // xám tối
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          // ── Nút NEXT ">" ──────────────────────────────────────────────────
          Opacity(
            opacity: isLastPage ? 0.0 : 1.0,
            child: _NavButton(
              icon: Icons.arrow_forward_ios_rounded,
              onTap: isLastPage ? null : onNextPressed,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NavButton
//
// Nút tròn màu xanh dùng chung cho cả back lẫn next.
// icon: icon hiển thị bên trong
// onTap: null = không cho nhấn (dùng khi đang ẩn)
// ─────────────────────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: ColorApp.blueMainColor,
        ),
        child: Icon(icon, color: Colors.black, size: 20),
      ),
    );
  }
}