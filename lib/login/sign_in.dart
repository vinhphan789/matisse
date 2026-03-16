import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';          // 👈 Thêm
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/login/language.dart';
import 'package:matisse/login/forgot_password.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/extension/app_router.dart';

import '../home/project.dart';
import '../images/image_app.dart';
import '../view_model/login_view_model.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailCtrl = TextEditingController(text: "chungphanngoc.vn@gmail.com");
  final passCtrl = TextEditingController(text: "An&&&999");
  bool obscure = true;
  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  bool get isValid =>
      emailCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty;

  /// Hàm gọi login — giống @IBAction trong iOS
  Future<void> _onContinuePressed() async {
    // Ẩn bàn phím trước khi gọi API
    // Giống view.endEditing(true) bên iOS
    FocusScope.of(context).unfocus();

    final vm = context.read<LoginViewModel>();
    await vm.login(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
    );

    // Nếu login thành công thì navigate sang ProjectsScreen
    // Dùng mounted để tránh lỗi khi widget đã bị dispose
    if (vm.isLoggedIn && mounted) {
      Navigator.pushReplacement( // 👈 pushReplacement để không quay lại màn login
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
              if (vm.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    vm.errorMessage!,
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
                    backgroundColor: isValid
                        ? ColorApp.blueMainColor
                        : Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.xs4),
                    ),
                    elevation: 0,
                  ),
                  // Disable button khi đang loading hoặc form không hợp lệ
                  onPressed: isValid && !vm.isLoading ? _onContinuePressed : null,
                  child: vm.isLoading
                  // Hiển thị spinner khi đang gọi API
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
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
                  onPressed: () {},
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