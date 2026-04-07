import 'package:flutter/material.dart';
import 'package:matisse/user_guide/user_guide.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState(); // giống viewDidLoad bên UIKit
    _checkFirstLaunch(); // tự động chạy khi màn hình khởi động
  }

  Future<void> _checkFirstLaunch() async {
    // Lấy SharedPreferences — giống UserDefaults.standard bên UIKit
    final prefs = await SharedPreferences.getInstance();

    // Đọc giá trị has_seen_guide, mặc định false nếu chưa có
    final hasSeenGuide = prefs.getBool('has_seen_guide') ?? false;

    if (hasSeenGuide) {
      // Đã xem rồi → vào thẳng WelcomeScreen
      // giống pushReplacement bên UIKit (không quay lại được)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    } else {
      // Chưa xem → vào UserGuideScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserGuideScreen(
          isFromOnboarding: true,
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Màn hình trắng trong lúc đang kiểm tra
    // giống LaunchScreen bên UIKit
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}