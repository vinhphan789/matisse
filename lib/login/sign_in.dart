import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matisse/router/app_constant.dart';
import 'package:provider/provider.dart';          // 👈 Thêm
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/login/language.dart';
import 'package:matisse/login/forgot_password.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/router/app_spacing.dart';

import '../extension/url_launcher.dart';
import '../home/projects.dart';
import '../images/image_app.dart';
import '../user_storage.dart';
import '../view_model/login_view_model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailCtrl = TextEditingController(text: "Marat@matisse.ai"); // chungphanngoc.vn@gmail.com
  final passCtrl = TextEditingController(text: "Matisse-123!"); // An&&&999
  bool obscure = true;
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    emailFocus.addListener(() => setState(() {}));
    passFocus.addListener(() => setState(() {}));
  }

  bool get isValid {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return emailRegex.hasMatch(emailCtrl.text.trim()) && passCtrl.text.isNotEmpty;
  }

  /// Hàm gọi login — giống @IBAction trong iOS
  Future<void> _onContinuePressed() async {
    FocusScope.of(context).unfocus();

    final vm = context.read<LoginViewModel>();
    await vm.login(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
    );

    if (!mounted) return;

    // ✅ Kiểm tra no subscription trước
    if (vm.noSubscription) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'No Active Subscription',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Your account does not have an active subscription. Please purchase a plan to continue.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openLinkInBrowser(AppConstant.createNewAccount); // hoặc link mua gói
              },
              child: const Text('Buy Plan', style: TextStyle(color: Color(0xFF2196F3))),
            ),
          ],
        ),
      );
      return; // Không navigate
    }

    // Login thành công và có subscription
    if (vm.isLoggedIn) {
      await UserStorage.shared.saveEmail(emailCtrl.text);
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const ProjectsScreen()),
      );
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    emailFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Lắng nghe LoginViewModel
    final vm = context.watch<LoginViewModel>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: ColorApp.blackMain1E1E1E,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ColorApp.blackMain1E1E1E,
        appBar: AppBar(
          backgroundColor: ColorApp.blackMain1E1E1E,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
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
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              const SetupTextWidget(
                titleLabel: "Sign in",
                font: FontApp.robotoBold,
                fontSize: 24,
                textColor: ColorApp.whiteMainColor,
              ),
              const SizedBox(height: 24),

              _inputField(
                label: "Email address",
                hinText: "Enter email address",
                controller: emailCtrl,
                focusNode: emailFocus,
              ),
              const SizedBox(height: 20),

              _inputField(
                label: "Password",
                hinText: "Enter password",
                controller: passCtrl,
                focusNode: passFocus,
                obscureText: obscure,
                suffix: IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),

              const SizedBox(height: 12),

              // --- Hiển thị lỗi từ API ---
              // Chỉ hiện khi có errorMessage
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(vm.errorMessage ?? "",
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // --- CONTINUE BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (isValid && !vm.isLoading)
                        ? ColorApp.blueMainColor
                        : Colors.grey.shade700,
                    disabledBackgroundColor: ColorApp.grayBackground90CAF9Color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.xs4),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isValid && !vm.isLoading ? _onContinuePressed : null,
                  child: vm.isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: ColorApp.grayBorder525252Color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SetupTextWidget(
                        titleLabel: "CONTINUE",
                        font: FontApp.robotoMedium,
                        fontSize: 15,
                        textColor: ColorApp.grayBorder525252Color,
                      ),
                    ],
                  )
                      : SetupTextWidget(
                    titleLabel: "CONTINUE",
                    font: FontApp.robotoMedium,
                    fontSize: 15,
                    textColor: isValid
                        ? ColorApp.whiteMainColor
                        : ColorApp.grayBorder525252Color,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    "Forgot your password?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () {
                    openLinkInBrowser(AppConstant.createNewAccount);
                  },
                  child: const Text(
                    "Create an account",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required String hinText,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onTap: () => setState(() {}),
        onChanged: (_) => setState(() {}),
        onEditingComplete: () => setState(() {}),
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hinText,
          hintStyle: TextStyle(color: ColorApp.grayBorder525252Color),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelStyle: TextStyle(
            color: focusNode.hasFocus ? ColorApp.blueMainColor : Colors.grey,
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
            borderSide: const BorderSide(color: ColorApp.blueMainColor),
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }
}