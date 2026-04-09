import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/images/image_app.dart';
import 'package:matisse/router/app_spacing.dart';

class CheckEmailScreen extends StatelessWidget {
  /// Email user vừa nhập — để hiển thị "We have sent an email to [email]"
  final String email;

  const CheckEmailScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorApp.blackMain1E1E1E,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),

              // ---- ICON EMAIL ----
              _buildEmailIcon(),

              const SizedBox(height: 20),

              // ---- TIÊU ĐỀ ----
              SetupTextWidget(
                titleLabel: "Check Your Email",
                font: FontApp.robotoMedium,
                fontSize: 24,
                textColor: ColorApp.whiteMainColor,
              ),

              const SizedBox(height: 16),

              // ---- MÔ TẢ ----
              _buildDescription(),

              const SizedBox(height: 16),

              // ---- GỢI Ý SPAM ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SetupTextWidget(
                  titleLabel:
                  "If you don't receive the email within a few minutes, please check your spam folder",
                  font: FontApp.robotoRegular,
                  fontSize: 15,
                  textColor: ColorApp.whiteMainColor,
                  maxLine: 3,
                  textAlign: TextAlign.center,
                ),
              ),


              const SizedBox(height: 50),
              // ---- NÚT BACK TO LOGIN ----
              _buildBackToLoginButton(context),

              const SizedBox(height: 16),

              // ---- NEED HELP ----
              _buildNeedHelpText(context),

              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
    );
  }

  /// Icon email — gradient hồng như design
  Widget _buildEmailIcon() {
    return Image.asset(ImageApp.emailIcon, width: 80, height: 80,);
  }

  /// Mô tả — highlight email bằng màu trắng đậm hơn
  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontFamily: FontApp.robotoRegular.family,
            fontWeight: FontApp.robotoRegular.weight,
            fontSize: 15,
            color: ColorApp.whiteMainColor.withOpacity(0.7),
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'We have sent an email to\n'),
            TextSpan(
              text: email,
              style: const TextStyle(
                color: ColorApp.whiteMainColor, // email nổi bật hơn
                // fontFamily: FontApp.robotoRegular.family,
                // fontWeight: FontApp.robotoRegular.weight,
              ),
            ),
            const TextSpan(
                text: '\nwith instructions on how to reset your password.'),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        // Pop hết về Login — tránh user back lại ForgotPassword
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
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

  /// "Need help? Contact Support"
  Widget _buildNeedHelpText(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: FontApp.robotoRegular.family,
          fontWeight: FontApp.robotoRegular.weight,
          fontSize: 14,
          color: ColorApp.whiteMainColor.withOpacity(0.6),
        ),
        children: [
          const TextSpan(text: "Need help? "),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                // TODO: mở link support hoặc màn hình support
              },
              child: SetupTextWidget(titleLabel: "Contact Support",
                font: FontApp.robotoMedium, fontSize: 14,
                textColor: ColorApp.blueMainColor),
              ),
            ),
        ],
      ),
    );
  }
}