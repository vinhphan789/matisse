import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matisse/extension/app_version.dart';
import 'package:matisse/images/image_app.dart';
import 'package:matisse/login/language.dart';
import 'package:matisse/login/sign_in.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/extension/url_launcher.dart';
import 'package:matisse/model/forgot_password_model.dart';
import 'package:matisse/router/app_constant.dart';
import 'package:matisse/splash_screen.dart';
import 'package:matisse/view_model/fogot_password_view_model.dart';
import 'package:matisse/view_model/language_viewmodel.dart';
import 'package:matisse/view_model/login_view_model.dart';
import 'package:provider/provider.dart';
import '../api_endpoint/api_endpoint.dart';
import '../colors/colors_app.dart';
import 'package:flutter/services.dart';

import '../extension/loading.dart';
import '../home/projects.dart';
import '../next_work/app_service.dart';
import '../user_storage.dart';
import '../view_model/project_view_model.dart';
import '../view_model/trash_view_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await UserStorage.shared.loadToken();
  await UserStorage.shared.loadEmail();

  final isValid = UserStorage.shared.isTokenValid();

  if (isValid) {
    ApiService().saveCredentials(
      token: UserStorage.shared.token!,
      session: UserStorage.shared.sessionId ?? '',
    );

    // 👈 Clear session cũ trước khi dùng
    try {
      await ApiService().get(ApiEndpoint.clearSession);
      print('✅ Session cleared on restore');
    } catch (e) {
      print('⚠️ Clear session failed: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ProjectViewModel()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordViewModel()),
        ChangeNotifierProvider(create: (_) => TrashViewModel()),
      ],
      child: MyApp(isLoggedIn: isValid),
    ),
  );
}
class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({required this.isLoggedIn, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'RobotoCustom'),

      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child!,
            GlobalLoadingOverlay(),
          ],
        );
      },

      home: isLoggedIn ? const ProjectsScreen() : const SplashScreen(),
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
                          backgroundColor: ColorApp.blueMainColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
                          openLinkInBrowser(AppConstant.createNewAccount);
                          print("đã vào");
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF9DD7FF),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          foregroundColor: ColorApp.blueMainColor,
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
                  AppVersionWidget(),

                  const SizedBox(height: 220),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
