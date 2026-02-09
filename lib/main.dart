import 'package:flutter/material.dart';
import 'package:matisse/images/image_app.dart';
import 'package:matisse/setup_widget.dart';
import 'colors/colors_app.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'RobotoCustom'),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height / 4;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,           // 🎨 Màu nền status bar là trắng
        statusBarIconBrightness: Brightness.light, // 🔷 Icon màu tối (để nhìn rõ trên nền trắng)
        statusBarBrightness: Brightness.light,    // 🍎 Cho iOS
      ),
      child: Scaffold(
        body: Container(
          // 🌑 Background gradient đen
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F), Color(0xFF000000)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                children: [
                  /// 🌍 ICON GLOBE TOP RIGHT
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  SizedBox(height: screenHeight),

                  /// 🦷 LOGO (tạm dùng text, bạn thay bằng Image.asset)
                  Image.asset(
                    ImageApp.matisseLogo,
                    width: 264,
                    height: 72,
                    fit: BoxFit.cover,
                  ),

                  const SizedBox(height: 20),

                  SetupTextWidget(
                    titleLabel: "Dental Shade Matching Made Easy",
                    textColor: ColorApp.whiteMainColor,
                    textAlign: TextAlign.start,
                    fontSize: 16,
                    font: FontApp.robotoRegular,
                    maxLine: 1,
                  ),

                  const SizedBox(height: 70),

                  /// 🔵 BUTTON 1 — FILLED
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9DD7FF),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "I ALREADY HAVE AN ACCOUNT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔲 BUTTON 2 — OUTLINE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          print("object");
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF9DD7FF),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: const Color(0xFF9DD7FF),
                        ),
                        child: const Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔢 VERSION TEXT
                  SetupTextWidget(
                    titleLabel: "Version 2.2(1)",
                    textColor: ColorApp.whiteMainColor,
                    fontSize: 12,
                    font: FontApp.robotoRegular,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
