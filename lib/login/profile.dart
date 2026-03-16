import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/app_router.dart';
import 'package:matisse/extension/setup_widget.dart';

import '../view_model/project_view_model.dart';
import 'coutry.dart';



class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final ProjectViewModel vm = ProjectViewModel();

  // ── Controllers ────────────────────────────────────────────────────────────
  final TextEditingController _fullNameController =
  TextEditingController(text: 'Marat');
  final TextEditingController _addressController =
  TextEditingController(text: 's7s7s');
  final TextEditingController _cityController =
  TextEditingController(text: 'sjsj');

  // ── State ──────────────────────────────────────────────────────────────────
  String _selectedCountry = 'Algeria';
  bool _acceptedEula = true;

  // Danh sách quốc gia mẫu
  final List<String> _countries = [
    'Algeria',
    'France',
    'Germany',
    'United States',
    'Vietnam',
    'United Kingdom',
  ];

  // Thông tin user hiển thị phía trên
  final String _userName = 'Marat';
  final String _userEmail = 'marat@matisse.ai';
  final String _userInitials = 'MA';

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi widget bị huỷ
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ── Xử lý nút SAVE ────────────────────────────────────────────────────────
  void _onSave() {
    // TODO: gọi API lưu thông tin profile
    debugPrint('Saving profile...');
    debugPrint('Full Name: ${_fullNameController.text}');
    debugPrint('Address: ${_addressController.text}');
    debugPrint('Country: $_selectedCountry');
    debugPrint('City: ${_cityController.text}');
    debugPrint('Accepted EULA: $_acceptedEula');
  }

  // ── Xử lý nút DELETE ──────────────────────────────────────────────────────
  void _onDelete() {
    // TODO: gọi API xoá tài khoản
    debugPrint('Delete account...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      // ── Body ───────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + Tên + Email ────────────────────────────────────────
            Row(
              children: [
                // Avatar hình tròn với chữ viết tắt
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: ColorApp.bruBackgroundCE93D8, // tím
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SetupTextWidget(titleLabel: _userInitials,
                      font: FontApp.robotoMedium, fontSize: 30,
                      textColor: ColorApp.whiteMainColor,)
                  ),
                ),
                const SizedBox(width: 16),

                // Tên và email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Full Name ───────────────────────────────────────────────────
            _buildTextField(
              label: 'Full Name',
              controller: _fullNameController,
            ),

            const SizedBox(height: 16),

            // ── Address ─────────────────────────────────────────────────────
            _buildTextField(
              label: 'Address',
              controller: _addressController,
            ),

            const SizedBox(height: 16),

            // ── Country Dropdown ─────────────────────────────────────────────
            _buildCountryField(),

            const SizedBox(height: 16),

            // ── City ─────────────────────────────────────────────────────────
            _buildTextField(
              label: 'City',
              controller: _cityController,
            ),

            const SizedBox(height: 24),

            // ── Checkbox EULA ────────────────────────────────────────────────
            _buildEulaCheckbox(),

            const SizedBox(height: 24),

            // ── Nút SAVE ─────────────────────────────────────────────────────
            _buildSaveButton(),

            const SizedBox(height: 12),

            // ── Nút DELETE ───────────────────────────────────────────────────
            _buildDeleteButton(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Widget: TextField có label nổi ────────────────────────────────────────
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: ColorApp.whiteMainColor, fontSize: 14),

        // Viền mặc định
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.grayBorder525252Color, width: 1),
        ),

        // Viền khi focus
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.blueMainColor, width: 1),
        ),

        filled: true,
        fillColor: ColorApp.blackMain1E1E1E,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),

        // Đẩy label lên trên khi có nội dung
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  // ── Widget: Dropdown Country ───────────────────────────────────────────────
  Widget _buildCountryField() {
    return InkWell(
      onTap: () async {
        // Present SelectCountryScreen như một full-screen modal
        final result = await Navigator.of(context).push<String>(
          CupertinoPageRoute(
            fullscreenDialog: true,          // slide từ dưới lên (iOS style)
            builder: (_) => SelectCountryScreen(
              selectedCountry: _selectedCountry,
            ),
          ),
        );

        // Nếu user chọn xong và pop về, cập nhật giá trị
        if (result != null) {
          setState(() => _selectedCountry = result);
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.xs4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Country',
          labelStyle: const TextStyle(
            color: ColorApp.whiteMainColor,
            fontSize: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
            borderSide: const BorderSide(
              color: ColorApp.grayBorder525252Color,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
            borderSide: const BorderSide(
              color: ColorApp.blueMainColor,
              width: 1,
            ),
          ),
          filled: true,
          fillColor: ColorApp.blackMain1E1E1E,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF8E8E93),
          ),
        ),
        child: Text(
          _selectedCountry,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  // ── Widget: Checkbox EULA ─────────────────────────────────────────────────
  Widget _buildEulaCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox tuỳ chỉnh màu
        Checkbox(
          value: _acceptedEula,
          onChanged: (value) {
            setState(() => _acceptedEula = value ?? false);
          },
          activeColor: ColorApp.blueMainColor,
          checkColor: Colors.black,
          side: BorderSide(color: ColorApp.blueMainColor, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.xs4)),
        ),

        const SizedBox(width: 4),

        // Text với link highlight
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.white, fontSize: 14),
                children: [
                  TextSpan(text: 'I accept to the '),
                  TextSpan(
                    text: 'EULA',
                    style: TextStyle(
                      color: ColorApp.blueMainColor,
                      fontWeight: FontWeight.w600,
                    ),
                    // TODO: thêm TapGestureRecognizer để mở link EULA
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'data processing agreement.',
                    style: TextStyle(
                      color: ColorApp.blueMainColor,
                      fontWeight: FontWeight.w600,
                    ),
                    // TODO: thêm TapGestureRecognizer để mở link
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Widget: Nút SAVE ──────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.viewHeight,
      child: ElevatedButton(
        onPressed: _acceptedEula ? _onSave : null, // disable nếu chưa tick EULA
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A3A3C),
          disabledBackgroundColor: const Color(0xFF3A3A3C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
          ),
          elevation: 0,
        ),
        child: const Text(
          'SAVE',
          style: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // ── Widget: Nút DELETE ────────────────────────────────────────────────────
  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.viewHeight,
      child: ElevatedButton(
        onPressed: _onDelete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
          ),
          elevation: 0,
        ),
        child: const Text(
          'DELETE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}