import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/extension/url_launcher.dart';
import 'package:matisse/router/app_constant.dart';
import 'package:matisse/router/app_spacing.dart';
import 'package:matisse/user_guide/web_shop.dart';
import 'package:url_launcher/url_launcher.dart';

import '../home/projects.dart';
import '../images/image_app.dart';
import '../login/language.dart';


// TODO: thay bằng màn hình thật


class WebShopScreen extends StatefulWidget {
  const WebShopScreen({super.key});

  @override
  State<WebShopScreen> createState() => _WebShopScreenState();
}

class _WebShopScreenState extends State<WebShopScreen> {
  final PageController _pageController = PageController();
  WebShopStep _currentStep = WebShopStep.optishadeStyleItaliano;


  // Danh sách theo thứ tự
  final List<WebShopStep> _steps = WebShopStep.values;

  void _onNextPressed() {
    final next = _currentStep.next;
    if (next != null) {
      // Chưa phải trang cuối → chuyển trang
      setState(() => _currentStep = next);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      // Trang cuối → push ProjectsScreen
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => const ProjectsScreen()),
      );
    }
  }

  Future<void> _onPurchasePressed() async {
    openLinkInBrowser(WebLink.webShop);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.blackMain1E1E1E,
      appBar: AppBar(
        backgroundColor: ColorApp.blackMain1E1E1E,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Image.asset(ImageApp.languageIcon, width: 24, height: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguagePage()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withOpacity(0.2)),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ---- TIÊU ĐỀ CỐ ĐỊNH ----
            SetupTextWidget(
              titleLabel: "Don't miss this!",
              font: FontApp.robotoMedium,
              fontSize: 24,
              textColor: ColorApp.whiteMainColor,
            ),

            const SizedBox(height: 8),

            // ---- MÔ TẢ CỐ ĐỊNH ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SetupTextWidget(
                titleLabel: 'Make sure you are equipped with these products to generate recipes successfully.',
                font: FontApp.robotoRegular,
                fontSize: 14,
                textColor: ColorApp.whiteMainColor,
                maxLine: 3,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // ---- ẢNH SẢN PHẨM (PageView) ----
            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                // physics: const NeverScrollableScrollPhysics(), // chỉ dùng nút
                onPageChanged: ( index ) {
                  setState(() {
                    _currentStep = _steps[index];
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.xs4),
                      child: Image.asset(
                        _steps[index].imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.white10,
                          child: const Icon(Icons.image, color: Colors.white30, size: 60),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ---- DOT INDICATOR ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _steps.map((step) {
                final isActive = step == _currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFFA726) // cam
                        : const Color(0xFF92949C), // xám
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ---- BADGE (Must-Have / Good-to-Have) ----
            _buildBadge(),

            const SizedBox(height: 8),

            // ---- TÊN SẢN PHẨM ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SetupTextWidget(
                titleLabel: _currentStep.title,
                font: FontApp.robotoMedium,
                fontSize: 20,
                textColor: ColorApp.whiteMainColor,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // ---- MÔ TẢ SẢN PHẨM ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SetupTextWidget(
                titleLabel: _currentStep.description,
                font: FontApp.robotoRegular,
                fontSize: 14,
                textColor: const Color(0xFFA0A0A0),
                maxLine: 4,
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 25,),

            // ---- NÚT YES I HAVE / NEXT TIME ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildNextButton(),
            ),

            const SizedBox(height: 12),

            // ---- NÚT PURCHASE ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildPurchaseButton(),
            ),

            const Spacer()
          ],
        ),
      ),
    );
  }

  /// Badge "Must-Have" hoặc "Good-to-Have"
  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: _currentStep.requestBadgeColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
          bottomRight: Radius.circular(2),
          // góc dưới trái KHÔNG bo — giống iOS
        ),
      ),
      child: Text(
        _currentStep.requestTitle,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// Nút YES I HAVE / NEXT TIME
  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _onNextPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorApp.blueMainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
          ),
        ),
        icon: const SizedBox.shrink(),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SetupTextWidget(
              titleLabel: _currentStep.continueTitle,
              font: FontApp.robotoMedium,
              fontSize: 15,
              textColor: Colors.black,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black, size: 16),
          ],
        ),
      ),
    );
  }

  /// Nút PURCHASE
  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _onPurchasePressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: ColorApp.blueMainColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
          ),
        ),
        icon: const SizedBox.shrink(),
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SetupTextWidget(
              titleLabel: 'PURCHASE',
              font: FontApp.robotoMedium,
              fontSize: 15,
              textColor: ColorApp.blueMainColor,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.open_in_new, color: ColorApp.blueMainColor, size: 16),
          ],
        ),
      ),
    );
  }
}