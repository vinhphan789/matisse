import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/app_router.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/extension/string.dart';
import 'package:matisse/view_model/profile_view_model.dart';

import '../view_model/project_view_model.dart';
import 'coutry.dart';

class MyProfileScreen extends StatefulWidget {
  // 🍎 Swift: var viewModel: ProfileViewModel
  // 🐦 Flutter: final field, truyền từ màn trước qua constructor
  final ProfileViewModel profile;

  const MyProfileScreen({super.key, required this.profile}); // 👈 thêm const + super.key

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {

  // ── Controllers ────────────────────────────────────────────────────────────
  // 🍎 Swift: @State var fullName: String = ""
  // 🐦 Flutter: TextEditingController — giống UITextField delegate
  //             Khởi tạo text rỗng trước, điền sau ở initState
  late TextEditingController _fullNameController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  // 👆 dùng late vì cần data từ ViewModel để khởi tạo
  //    late = "tôi hứa sẽ gán trước khi dùng" — compile không báo lỗi

  // ── State ──────────────────────────────────────────────────────────────────
  String _selectedCountry = '';
  bool _acceptedEula = true;

  @override
  void initState() {
    super.initState();

    // 🍎 Swift: viewDidLoad — nơi setup data sau khi view được tạo
    // 🐦 Flutter: initState — tương đương viewDidLoad

    // Lấy profile từ ViewModel để điền vào các field
    // widget.profile = truy cập vào field của StatefulWidget từ State
    // 🍎 Swift: self.viewModel.profile
    // 🐦 Flutter: widget.xxx — cách duy nhất để State access StatefulWidget fields
    final p = widget.profile.profile;

    _fullNameController = TextEditingController(text: p?.name ?? '');
    _addressController  = TextEditingController(text: p?.address1 ?? '');
    _cityController     = TextEditingController(text: p?.city ?? '');

    // Lưu country ban đầu — country trong model là int (id)
    // TODO: map country id → country name khi có danh sách
    _selectedCountry = p?.country.toString() ?? '';
  }

  @override
  void dispose() {
    // 🍎 Swift: ARC tự dọn — không cần làm gì
    // 🐦 Flutter: PHẢI dispose controller thủ công để tránh memory leak
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
    // Lấy profile mỗi lần build — để UI tự cập nhật nếu ViewModel thay đổi
    // 🍎 Swift: @ObservedObject tự động — Flutter phải lấy thủ công
    final p = widget.profile.profile;

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
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: ColorApp.bruBackgroundCE93D8,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SetupTextWidget(
                      // 🍎 Swift: viewModel.profile?.name.toInitials() ?? "??"
                      // 🐦 Flutter: ?. và ?? hoàn toàn giống Swift
                      titleLabel: p?.name.getAbbName() ?? '??', // ← thay 'MA'
                      font: FontApp.robotoMedium,
                      fontSize: 30,
                      textColor: ColorApp.whiteMainColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SetupTextWidget(titleLabel: p?.name.getName() ?? "User",
                      font: FontApp.robotoMedium, fontSize: 25, maxLine: 2, textColor: Colors.white,),

                    const SizedBox(height: 4),

                    SetupTextWidget(titleLabel: p?.name ?? "User",
                      font: FontApp.robotoMedium, fontSize: 14, maxLine: 2,
                      textColor: Colors.white,),
                  ],
                ),)

              ],
            ),

            const SizedBox(height: 32),

            // ── Full Name ───────────────────────────────────────────────────
            _buildTextField(
              label: 'Full Name',
              controller: _fullNameController, // ← đã có data từ initState
            ),

            const SizedBox(height: 16),

            // ── Address ─────────────────────────────────────────────────────
            _buildTextField(
              label: 'Address',
              controller: _addressController, // ← đã có data từ initState
            ),

            const SizedBox(height: 16),

            // ── Country Dropdown ─────────────────────────────────────────────
            _buildCountryField(),

            const SizedBox(height: 16),

            // ── City ─────────────────────────────────────────────────────────
            _buildTextField(
              label: 'City',
              controller: _cityController, // ← đã có data từ initState
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.grayBorder525252Color, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.blueMainColor, width: 1),
        ),
        filled: true,
        fillColor: ColorApp.blackMain1E1E1E,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  // ── Widget: Dropdown Country ───────────────────────────────────────────────
  Widget _buildCountryField() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.of(context).push<String>(
          CupertinoPageRoute(
            fullscreenDialog: true,
            builder: (_) => SelectCountryScreen(
              selectedCountry: _selectedCountry,
            ),
          ),
        );

        // 🍎 Swift: if let result = result { self.selectedCountry = result }
        // 🐦 Flutter: if (result != null) — optional unwrap tương đương
        if (result != null) {
          setState(() => _selectedCountry = result);
        }
      },
      borderRadius: BorderRadius.circular(AppSpacing.xs4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Country',
          labelStyle: const TextStyle(color: ColorApp.whiteMainColor, fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
            borderSide: const BorderSide(color: ColorApp.grayBorder525252Color, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.xs4),
            borderSide: const BorderSide(color: ColorApp.blueMainColor, width: 1),
          ),
          filled: true,
          fillColor: ColorApp.blackMain1E1E1E,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8E8E93)),
        ),
        child: Text(
          _selectedCountry.isEmpty ? 'Select country' : _selectedCountry,
          style: TextStyle(
            // Hiển thị grey nếu chưa chọn, white nếu đã có
            color: _selectedCountry.isEmpty ? Colors.grey : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ── Widget: Checkbox EULA ─────────────────────────────────────────────────
  Widget _buildEulaCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedEula,
          onChanged: (value) {
            // 🍎 Swift: self.acceptedEula = value ?? false
            // 🐦 Flutter: setState — báo Flutter rebuild UI
            //             setState tương đương @State didSet bên Swift
            setState(() => _acceptedEula = value ?? false);
          },
          activeColor: ColorApp.blueMainColor,
          checkColor: Colors.black,
          side: BorderSide(color: ColorApp.blueMainColor, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.xs4)),
        ),
        const SizedBox(width: 4),
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
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'data processing agreement.',
                    style: TextStyle(
                      color: ColorApp.blueMainColor,
                      fontWeight: FontWeight.w600,
                    ),
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
        onPressed: _acceptedEula ? _onSave : null,
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
