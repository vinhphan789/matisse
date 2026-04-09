import 'package:flutter/material.dart';
import 'package:matisse/router/app_spacing.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/images/image_app.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:provider/provider.dart';

import '../extension/loading.dart';
import '../view_model/fogot_password_view_model.dart';
import 'check_email.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ✅ Thêm biến kiểm tra email hợp lệ
  bool _isEmailValid = false;

  // ✅ Regex email
  final _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    // ✅ Lắng nghe thay đổi email realtime
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final isValid = _emailRegex.hasMatch(_emailController.text.trim());
    if (isValid != _isEmailValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    LoadingService().show();

    final vm = context.read<ForgotPasswordViewModel>();
    await vm.sendResetEmail(email: _emailController.text.trim());

    LoadingService().hide();

    if (!mounted) return;

    if (vm.isEmailSent) {
      // ✅ Print sau khi gửi thành công
      print('✅ Email đặt lại mật khẩu đã gửi tới: ${_emailController.text.trim()}');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CheckEmailScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else if (vm.errorMessage != null) {
      print('❌ Gửi email thất bại: ${vm.errorMessage}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset(ImageApp.keyLockIcon, width: 100, height: 100, fit: BoxFit.cover),
                const SizedBox(height: 32),
                SetupTextWidget(
                  titleLabel: "Forgot password?",
                  font: FontApp.robotoMedium,
                  fontSize: 24,
                  textColor: ColorApp.whiteMainColor,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SetupTextWidget(
                    titleLabel: "To reset your password, enter the email address from your original account. You'll receive a link to reset your password.",
                    font: FontApp.robotoRegular,
                    fontSize: 16,
                    textColor: ColorApp.whiteMainColor,
                    maxLine: 5,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 32),
                _buildSendEmailButton(),
                const SizedBox(height: 16),
                _buildBackToLoginButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      cursorColor: const Color(0xFF76C442),
      decoration: InputDecoration(
        labelText: 'Email address',
        hintText: 'Enter email address',
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white38),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.grayBorder525252Color),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.grayBorder525252Color),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: ColorApp.blackMain1E1E1E,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập địa chỉ email';
        }
        if (!_emailRegex.hasMatch(value.trim())) {
          return 'Email không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildSendEmailButton() {
    // ✅ Đổi màu theo trạng thái email
    final Color bgColor = _isEmailValid
        ? ColorApp.blueMainColor   // Xanh lá khi hợp lệ
        : const Color(0xFF3A3A3A);  // Xám khi chưa hợp lệ

    final Color textColor = _isEmailValid
        ? Colors.white
        : ColorApp.whiteMainColor.withAlpha(87);

    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        // ✅ Chỉ cho bấm khi email hợp lệ và không loading
        onPressed: (_isLoading || !_isEmailValid) ? null : _sendResetEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
        )
            : SetupTextWidget(
          titleLabel: "SEND EMAIL",
          font: FontApp.robotoMedium,
          fontSize: 15,
          textColor: textColor,
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: ColorApp.blueMainColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
          ),
        ),
        child: SetupTextWidget(
          titleLabel: "BACK TO LOGIN",
          font: FontApp.robotoMedium,
          fontSize: 15,
          textColor: ColorApp.blueMainColor,
        ),
      ),
    );
  }
}