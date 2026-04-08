import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/router/app_spacing.dart';
import 'package:matisse/extension/setup_widget.dart';

// ── Cách dùng: gọi hàm này khi nhấn button ──────────────────────────
// showCreateProjectSheet(context);
// ────────────────────────────────────────────────────────────────────

void showCreateProjectSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreateProjectSheet(),
  );
}

// ── Bottom Sheet Widget ──────────────────────────────────────────────
class CreateProjectSheet extends StatefulWidget {
  const CreateProjectSheet({super.key});

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final _patientNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _dentistController = TextEditingController();
  final _dentistFocusNode = FocusNode();
  bool _dentistFocused = false;

  static const _textColor = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _dentistFocusNode.addListener(() {
      setState(() => _dentistFocused = _dentistFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _dentistController.dispose();
    _dentistFocusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(color: ColorApp.greyBackground2C2C2E),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 50 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle bar ──────────────────────────────────────────
          Center(
            child: Container(
              width: 30,
              height: 6,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: ColorApp.greyBgr808080,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // ── Title ───────────────────────────────────────────────
          SetupTextWidget(
            titleLabel: 'Create New Project',
            font: FontApp.robotoMedium,
            fontSize: 24,
            textColor: Colors.white,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // ── Patient Name ─────────────────────────────────────────
          _buildTextField(
            controller: _patientNameController,
            label: 'Patient Name',
            hint: 'Enter Patient Name',
          ),
          const SizedBox(height: 20),

          // ── Dentist ──────────────────────────────────────────────
          _buildTextField(
            controller: _dentistController,
            label: 'Dentist',
            hint: 'Enter Dentist',
            focusNode: _dentistFocusNode,
            suffixIcon: Icon(
              _dentistFocused
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: ColorApp.whiteMainColor.withAlpha(77),
            ),
          ),
          const SizedBox(height: 20),

          // ── Description ──────────────────────────────────────────
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Enter Description',
            maxLines: 5,
          ),
          const SizedBox(height: 28),

          // ── Create & Add Button ───────────────────────────────────
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorApp.grayBorder525252Color,
                foregroundColor: _textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.xs4),
                ),
                elevation: 0,
              ),
              child: SetupTextWidget(titleLabel: 'CREATE & ADD',
                font: FontApp.robotoMedium, textColor: ColorApp.whiteMainColor.withAlpha(77),)
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    FocusNode? focusNode,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      style: const TextStyle(color: _textColor, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(700), fontSize: 15),
        hintText: hint,
        hintStyle: TextStyle(color: ColorApp.whiteMainColor.withAlpha(77), fontSize: 15),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: ColorApp.greyBackground2C2C2E,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.greyLine5E5E5E),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.xs4),
          borderSide: const BorderSide(color: ColorApp.greyLine5E5E5E),
        ),
      ),
    );
  }
}
