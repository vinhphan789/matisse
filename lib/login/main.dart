import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matisse/images/image_app.dart';
import 'package:matisse/login/language.dart';
import 'package:matisse/login/sign_in.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/extension/url_launcher.dart';
import 'package:matisse/splash_screen.dart';
import 'package:matisse/view_model/language_viewmodel.dart';
import 'package:matisse/view_model/login_view_model.dart';
import 'package:provider/provider.dart';
import '../colors/colors_app.dart';
import 'package:flutter/services.dart';

import '../extension/loading.dart';
import '../next_work/app_service.dart';
import '../view_model/project_view_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Gắn token cứng để test — sau này thay bằng token từ login
  // ApiService().saveCredentials(
  //   session: 'b2030d9b-52c2-4c79-a0ef-4c7bc792650b',
  //   token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik16WTFNamcxUlRNek5VTkRRamcxTVRFMFJEZ3lRMEUzT0RCQlFVWkVSRU5EUlRNMk1Ua3dSZyJ9.eyJuaWNrbmFtZSI6Im1hcmF0IiwibmFtZSI6Im1hcmF0QG1hdGlzc2UuYWkiLCJwaWN0dXJlIjoiaHR0cHM6Ly9zLmdyYXZhdGFyLmNvbS9hdmF0YXIvMmIwMTJhMmExZTE2ZGM1ZWY3NDc0MmVkZGZjODNkMTg_cz00ODAmcj1wZyZkPWh0dHBzJTNBJTJGJTJGY2RuLmF1dGgwLmNvbSUyRmF2YXRhcnMlMkZtYS5wbmciLCJ1cGRhdGVkX2F0IjoiMjAyNi0wMy0wOVQwODo1OTo1MC43NzlaIiwiZW1haWwiOiJtYXJhdEBtYXRpc3NlLmFpIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzcyI6Imh0dHBzOi8vZGV2LXBpZTU5cHl1LmV1LmF1dGgwLmNvbS8iLCJhdWQiOiJoVXVhRlg5TUw2cVJVakdUMlBDQUkwbFVIWVNLTGJQNyIsInN1YiI6ImF1dGgwfDYxYmIxYTNhMzIyMjU0MDA2OTY1NTAzZiIsImlhdCI6MTc3MzA0Njc5MSwiZXhwIjoxNzczMDgyNzkxfQ.rbRuPvIyBDtFIKZuAXU01rvcm8jSl9uw_jFpMBrxO5inhHjc0AxBC7SbayAtAWxt3IhWTC_rEAyTol9XSlgu6eiG53Jd6d81HKx4AmEcTX_zjgQzWuB71WU4w8cTHwSzhBPwQ-fmtiTnVnKHBezlqMz9tUAKPz3GAOACTT4k_Igk698WSbwWT7HcaMdkRGSxZkvyOhBvEPJ7N4bxzVSz_bpjGLF5pttJCIp9LsHNw0Eo6k07K9Qo2u1K1byaSQcZ4gx_dofDWXRMywHMHEZVrknNvdHsGxQXBEwuEzxDUshyUZcXhTjCWJpy0vr_mQ33xz8IDYLEV5hfnmZXafBEaA"
  // );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'RobotoCustom'),

      // 👇 DÙNG builder thay vì home: Stack
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child!, // 👈 toàn bộ navigator ở đây
            GlobalLoadingOverlay(), // 👈 luôn nằm trên cùng
          ],
        );
      },

      home: const SplashScreen(), // 👈 màn hình đầu tiên
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height / 4;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        // 🎨 Màu nền status bar là trắng
        statusBarIconBrightness: Brightness.light,
        // 🔷 Icon màu tối (để nhìn rõ trên nền trắng)
        statusBarBrightness: Brightness.dark, // 🍎 Cho iOS
      ),
      child: Scaffold(
        body: Container(
          // 🌑 Background gradient đen
          color: ColorApp.blackMain1E1E1E,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                children: [
                  /// 🌍 ICON GLOBE TOP RIGHT
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => LanguagePage(),
                          ),
                        );
                      },
                      icon: Image.asset(
                        ImageApp.languageIcon,
                        width: 24,
                        height: 24,
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => const SignInPage(),
                            ),
                          );
                        },
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
                          openLinkInBrowser('https://app.matisse.ai/try');
                          print("đã vào");
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
