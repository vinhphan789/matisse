import 'package:flutter/material.dart';
import 'package:matisse/router/app_spacing.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/images/image_app.dart';
import 'package:matisse/extension/setup_widget.dart';

/// Màn hình "Quên mật khẩu" - Forgot Password Screen
/// Cho phép người dùng nhập email để nhận link đặt lại mật khẩu
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controller để lấy giá trị từ ô nhập email
  final TextEditingController _emailController = TextEditingController();

  // Key để quản lý và validate form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Biến trạng thái để hiển thị loading khi đang gửi email
  bool _isLoading = false;

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi widget bị hủy
    _emailController.dispose();
    super.dispose();
  }

  /// Hàm xử lý gửi email đặt lại mật khẩu
  Future<void> _sendResetEmail() async {
    // Kiểm tra form hợp lệ trước khi gửi
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Giả lập gọi API (thay bằng logic thực tế)
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Hiển thị thông báo thành công
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email đặt lại mật khẩu đã được gửi!'),
          backgroundColor: Color(0xFF8BC34A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền màu tối
      backgroundColor: ColorApp.blackMain1E1E1E,

      // AppBar với nút quay lại
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

                // ---- BIỂU TƯỢNG KHÓA ----
                Image.asset(ImageApp.keyLockIcon, width: 100, height: 100, fit: BoxFit.cover,),


                const SizedBox(height: 32),

                // ---- TIÊU ĐỀ ----
                SetupTextWidget(titleLabel: "Forgot password?", font: FontApp.robotoMedium,
                  fontSize: 24, textColor: ColorApp.whiteMainColor,),

                const SizedBox(height: 16),

                // ---- MÔ TẢ HƯỚNG DẪN ----
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SetupTextWidget(titleLabel: "To reset your password, enter the email address from your original account. You’ll receive a link to reset your password.",
                    font: FontApp.robotoRegular,
                    fontSize: 16, textColor: ColorApp.whiteMainColor, maxLine: 5, textAlign: TextAlign.center,),

                ),

                const SizedBox(height: 32),

                // ---- Ô NHẬP EMAIL ----
                _buildEmailField(),

                const SizedBox(height: 32),

                // ---- NÚT GỬI EMAIL ----
                _buildSendEmailButton(),

                const SizedBox(height: 16),

                // ---- NÚT QUAY LẠI ĐĂNG NHẬP ----
                _buildBackToLoginButton(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget ô nhập địa chỉ email với viền bo tròn
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      cursorColor: const Color(0xFF76C442),

      // Trang trí ô nhập liệu
      decoration: InputDecoration(
        labelText: 'Email address',
        hintText: 'Enter email address',
        labelStyle: const TextStyle(color: Colors.white54),
        hintStyle: const TextStyle(color: Colors.white38),
        /// label luôn ở trên
        floatingLabelBehavior: FloatingLabelBehavior.always,
        // Viền mặc định
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.grayBorder525252Color),
        ),

        // Viền khi focus (đang nhập)
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

      // Kiểm tra hợp lệ khi người dùng submit form
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập địa chỉ email';
        }
        // Regex kiểm tra định dạng email cơ bản
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

        return null;
      },
    );
  }

  /// Nút gửi email đặt lại mật khẩu (màu xám, chữ trắng)
  Widget _buildSendEmailButton() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendResetEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A3A3A), // Màu xám đậm như ảnh mẫu
          disabledBackgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
          ),
          elevation: 0,
        ),
        child: _isLoading
        // Hiển thị vòng xoay loading khi đang gửi
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white54,
            strokeWidth: 2,
          ),
        )
            : SetupTextWidget(titleLabel: "SEND EMAIL", font: FontApp.robotoMedium,
          fontSize: 15, textColor: ColorApp.whiteMainColor.withAlpha(87),),
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
            color: ColorApp.blueMainColor, // Viền xanh lam như ảnh mẫu
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
          ),
        ),
        child: SetupTextWidget(titleLabel: "BACK TO LOGIN", font: FontApp.robotoMedium,
          fontSize: 15, textColor: ColorApp.blueMainColor,),
      ),
    );
  }
}

