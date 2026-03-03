import 'package:flutter/material.dart';
import 'package:matisse/colors/colors_app.dart';
import 'package:matisse/extension/setup_widget.dart';
import 'package:matisse/images/image_app.dart';

// ─────────────────────────────────────────────
// MATISSE DRAWER
// Usage: Set `drawer: const MatisseDrawer()` in your Scaffold
// ─────────────────────────────────────────────

class MatisseDrawer extends StatefulWidget {
  const MatisseDrawer({super.key});

  @override
  State<MatisseDrawer> createState() => _MatisseDrawerState();
}

class _MatisseDrawerState extends State<MatisseDrawer> {
  bool _projectsExpanded = false;
  bool _recipeExpanded = false;
  bool _stainingExpanded = false;

  static const Color _bgColor = Color(0xFF2C2C2C);
  static const Color _subTextColor = Color(0xFFCCCCCC);
  static const Color _dividerColor = Color(0xFF444444);
  static const Color _iconColor = Color(0xFF999999);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.78,
      backgroundColor: _bgColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Logo ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Image.asset(ImageApp.matisseMenuIcon, width: 77, height: 21,),
            ),

            // ── Projects ──
            _buildProjectsSection(),

            _buildDivider(),

            // ── Get Recipe ──
            _buildExpandableSection(
              title: 'Get Recipe',
              isExpanded: _recipeExpanded,
              onTap: () => setState(() => _recipeExpanded = !_recipeExpanded),
              children: [
                _buildSubItem('Aesthetic Model', onTap: () {}),
                _buildSubItem('Framework', onTap: () {}),
                _buildSubItem('Dentin', onTap: () {}),
                _buildSubItem('Enamel', onTap: () {}),
                _buildSubItem('ShadeGuide AI', onTap: () {}),
              ], assetPath: ImageApp.recipeIcon,
            ),

            _buildDivider(),

            // ── Staining Studio ──
            _buildExpandableSection(
              title: 'Staining Studio',
              isExpanded: _stainingExpanded,
              onTap: () =>
                  setState(() => _stainingExpanded = !_stainingExpanded),
              children: [
                _buildSubItem('Monolithic/ Color Corrections', onTap: () {}),
                _buildSubItem('ColorModel/ Stump Shade', onTap: () {}),
              ], assetPath: ImageApp.stainingIcon,
            ),

            _buildDivider(),

            const Spacer(),

            // ── Version ──
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  'Version 2.3(7)',
                  style: TextStyle(color: _iconColor, fontSize: 12),
                ),
              ),
            ),
            Expanded(child: Spacer())
          ],
        ),
      ),
    );
  }

  // ── Projects section (custom expand with 3 fixed sub-items) ──
  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () =>
              setState(() => _projectsExpanded = !_projectsExpanded),
          splashColor: Colors.white10,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Image.asset(ImageApp.fileMenuIcon, width: 20, height: 20, color: Colors.grey,),
                const SizedBox(width: 12),
                Expanded(
                  child: SetupTextWidget(titleLabel: "Projects",
                      font: FontApp.robotoMedium,
                      fontSize: 16,
                      textColor: Colors.white)),
                AnimatedRotation(
                    turns: _projectsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down, color: _iconColor, size: 20,)
                )
                  ],
                ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _projectsExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubItem('My Projects', onTap: () {}),
              _buildSubItem('Shared Projects', onTap: () {}),
              _buildSubItem('Trash', onTap: () {}),
            ],
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── Generic expandable section ──
  Widget _buildExpandableSection({
    required String assetPath,
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          splashColor: Colors.white10,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Image.asset(assetPath, width: 20, height: 20,),
                const SizedBox(width: 12),
                Expanded(
                  child: SetupTextWidget(titleLabel: title,
                    font: FontApp.robotoMedium, fontSize: 16, textColor: Colors.white,)
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(Icons.keyboard_arrow_down,
                      color: _iconColor, size: 20),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: isExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Column(children: children),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── Sub-item row ──
  Widget _buildSubItem(String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.only(
            left: 52, right: 20, top: 13, bottom: 13),
        child: SizedBox(
          width: double.infinity,
          child: SetupTextWidget(titleLabel: title,
            font: FontApp.robotoMedium, fontSize: 14,
            textColor: Colors.white,
            textAlign: TextAlign.left,),
        )
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(color: _dividerColor, height: 1, thickness: 1);
}

