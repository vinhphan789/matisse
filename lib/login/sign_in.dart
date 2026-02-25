import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matisse/app_router.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/language.dart';
import 'package:matisse/login/forgot_password.dart';
import 'package:matisse/setup_widget.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  /// Controllers để đọc text input
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  /// Ẩn / hiện password
  bool obscure = true;

  /// Validate đơn giản (chỉ check không rỗng)
  bool get isValid =>
      emailCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty;

  final emailFocus = FocusNode();
  final passFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      /// 🎨 Style status bar (nền đen, icon sáng)
      value: const SystemUiOverlayStyle(
        statusBarColor: ColorApp.blackMain1E1E1E,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ColorApp.blackMain1E1E1E,

        /// ================= APP BAR =================
        appBar: AppBar(
          backgroundColor: ColorApp.blackMain1E1E1E,
          elevation: 0,

          /// 🔙 Nút back
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),

          /// 🌍 Icon language (push sang LanguagePage)
          actions: [
            IconButton(
              icon: const Icon(Icons.language, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguagePage()),
                );
              },
            ),
          ],

          /// Divider mỏng dưới AppBar
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
        ),

        /// ================= BODY =================
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// 📝 TITLE
              const SetupTextWidget(titleLabel: "Sign in",
                font: FontApp.robotoBold, fontSize: 24, textColor: ColorApp.whiteMainColor,),
              const SizedBox(height: 24),

              /// 📧 EMAIL FIELD
              _inputField(
                label: "Email address",
                controller: emailCtrl,
                focusNode: emailFocus,
              ),

             SizedBox(height: 20,),

              _inputField(
                label: "Password",
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

              const SizedBox(height: 28),

              /// ▶️ CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    /// Đổi màu theo trạng thái valid
                    backgroundColor: isValid
                        ? ColorApp.blueMainColor
                        : Colors.grey.shade700,
                    disabledBackgroundColor: Colors.grey.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.xs4),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isValid ? () {} : null,
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(
                      letterSpacing: 1,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔑 FORGOT PASSWORD
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (_) => const ForgotPasswordScreen()));
                  },
                  child: const Text(
                    "Forgot your password?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              /// 🆕 CREATE ACCOUNT
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

  /// ============================================================
  /// 🔤 CUSTOM INPUT FIELD (Reusable)
  /// ============================================================
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,

      /// rebuild UI khi focus đổi
      onTap: () => setState(() {}),
      onChanged: (_) => setState(() {}),
      onEditingComplete: () => setState(() {}),

      obscureText: obscureText,

      /// ❌ text bên trong giữ nguyên màu trắng
      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        labelText: label,

        /// label luôn ở trên
        floatingLabelBehavior: FloatingLabelBehavior.always,

        /// ⭐ CHỈ label đổi màu khi focus
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
    );
  }
  }