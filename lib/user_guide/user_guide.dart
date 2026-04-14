import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/login/language.dart';
import 'package:matisse/user_guide/web_shop_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../home/projects.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserGuideScreen
// ─────────────────────────────────────────────────────────────────────────────

class UserGuideScreen extends StatefulWidget {
  final bool isFromOnboarding;
  const UserGuideScreen({Key? key, this.isFromOnboarding = false}) : super(key: key);

  @override
  State<UserGuideScreen> createState() => _UserGuideScreenState();
}

class _UserGuideScreenState extends State<UserGuideScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _saveGuideSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_guide', true);
  }

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() async {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else if (widget.isFromOnboarding) {
      await _saveGuideSeen();
      if (mounted) {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (_) => WebShopScreen()),
        );
      }
    }
  }

  void _onBackPressed() {
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: widget.isFromOnboarding
            ? null
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: widget.isFromOnboarding
            ? [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (_) => LanguagePage()));
            },
          ),
        ]
            : null,
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
      body: Container(
        color: ColorApp.blackMain1E1E1E,
        child: Column(
          children: [
            SizedBox(height: 20,),
            SetupTextWidget(titleLabel: "Before you start...", font: FontApp.robotoBold,
              fontSize: 20, textColor: ColorApp.whiteMainColor,),
            // ── ① PageView: hiển thị VIDEO trực tiếp (không còn phone mockup) ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                    child: Center(
                      // THAY ĐỔI: _PhoneMockup → _VideoPlayerWidget trực tiếp
                      child: _VideoPlayerWidget(
                        assetPath: _steps[index]['videoAsset']!,
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── ② Dot indicator + nút back/next ──────────────────────────────
            _BottomNavigation(
              totalPages: _steps.length,
              currentPage: _currentPage,
              onNextPressed: _onNextPressed,
              onBackPressed: _onBackPressed,
              isFromOnboarding: widget.isFromOnboarding,
            ),

            const SizedBox(height: 16),

            // ── ③ Title ───────────────────────────────────────────────────────
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

            // ── ④ Description ─────────────────────────────────────────────────
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

            const SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _GuidePageContent (nếu vẫn dùng ở nơi khác)
// THAY ĐỔI: _PhoneMockup → _VideoPlayerWidget trực tiếp
// ─────────────────────────────────────────────────────────────────────────────
class _GuidePageContent extends StatelessWidget {
  final String title;
  final String description;
  final String videoAsset;
  final bool isFromOnboarding;
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
    this.isFromOnboarding = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // THAY ĐỔI: _PhoneMockup → _VideoPlayerWidget trực tiếp
          _VideoPlayerWidget(assetPath: videoAsset),

          _BottomNavigation(
            totalPages: totalPages,
            currentPage: currentPage,
            onNextPressed: onNextPressed,
            onBackPressed: onBackPressed,
            isFromOnboarding: isFromOnboarding,
          ),

          const SizedBox(height: 16),

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
// _VideoPlayerWidget
//
// THAY ĐỔI SO VỚI BẢN CŨ:
//   - Bọc thêm Container với ClipRRect(borderRadius: 16) để bo góc video
//   - Thêm BoxDecoration màu nền tối khi đang load
//   - Khi chưa init: hiện CircularProgressIndicator thay vì _VideoPlaceholder
//     (vì _VideoPlaceholder đã bị xóa cùng _PhoneMockup)
// ─────────────────────────────────────────────────────────────────────────────
class _VideoPlayerWidget extends StatefulWidget {
  final String assetPath;

  const _VideoPlayerWidget({required this.assetPath});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bo góc video, thêm nền tối khi đang load
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: const Color(0xFF2C2C2E),
        child: _isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
        // Đang load: hiện spinner đơn giản thay _VideoPlaceholder
            : const SizedBox(
          height: 300,
          child: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF9500),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _BottomNavigation — KHÔNG THAY ĐỔI GÌ
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNavigation extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;
  final bool isFromOnboarding;

  const _BottomNavigation({
    required this.totalPages,
    required this.currentPage,
    required this.onNextPressed,
    required this.onBackPressed,
    required this.isFromOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFirstPage = currentPage == 0;
    final bool isLastPage = isFromOnboarding ? false : currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: isFirstPage ? 0.0 : 1.0,
            child: _NavButton(
              icon: Icons.arrow_back_ios_rounded,
              onTap: isFirstPage ? null : onBackPressed,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalPages, (index) {
              final bool isActive = index == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFF9500)
                      : const Color(0xFF3A3A3C),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
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
// _NavButton — KHÔNG THAY ĐỔI GÌ
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