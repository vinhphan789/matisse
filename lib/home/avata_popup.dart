import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:matisse/colors/colors_app.dart'; // hoặc package popup bạn đang dùng

class AvatarPopupButton extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String avatarInitials;
  final Color avatarColor;

  // Callbacks
  final VoidCallback? onMyProjects;
  final VoidCallback? onMyProfile;
  final VoidCallback? onWebshop;
  final VoidCallback? onLanguage;
  final VoidCallback? onUserGuide;
  final VoidCallback? onLogout;

  const AvatarPopupButton({
    Key? key,
    this.userName = 'Marat',
    this.userEmail = 'marat@matisse.ai',
    this.avatarInitials = 'MA',
    this.avatarColor = const Color(0xFF9C27B0),
    this.onMyProjects,
    this.onMyProfile,
    this.onWebshop,
    this.onLanguage,
    this.onUserGuide,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPopup(
      showArrow: true,
      arrowColor: ColorApp.greyBackground2C2C2E,
      barrierColor: Colors.transparent,
      contentDecoration: BoxDecoration(
        color: ColorApp.greyBackground2C2C2E,
        borderRadius: BorderRadius.circular(14),
      ),
      content: _PopupContent(
        userName: userName,
        userEmail: userEmail,
        onMyProjects: onMyProjects,
        onMyProfile: onMyProfile,
        onWebshop: onWebshop,
        onLanguage: onLanguage,
        onUserGuide: onUserGuide,
        onLogout: onLogout,
      ),
      child: _AvatarButton(
        initials: avatarInitials,
        color: avatarColor,
      ),
    );
  }
}

// ── Avatar Button ──────────────────────────────────────────────────────────────
class _AvatarButton extends StatelessWidget {
  final String initials;
  final Color color;

  const _AvatarButton({required this.initials, required this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 20,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ── Popup Content ──────────────────────────────────────────────────────────────
class _PopupContent extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback? onMyProjects;
  final VoidCallback? onMyProfile;
  final VoidCallback? onWebshop;
  final VoidCallback? onLanguage;
  final VoidCallback? onUserGuide;
  final VoidCallback? onLogout;

  const _PopupContent({
    required this.userName,
    required this.userEmail,
    this.onMyProjects,
    this.onMyProfile,
    this.onWebshop,
    this.onLanguage,
    this.onUserGuide,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── User Info Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userEmail,
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF3A3A3C), height: 1),
          const SizedBox(height: 4),

          // ── Menu Items ──
          _MenuItem(
            icon: Icons.folder_outlined,
            label: 'My Projects',
            onTap: () {
              Navigator.of(context).pop();
              onMyProjects?.call();
            },
          ),
          _MenuItem(
            icon: Icons.account_circle_outlined,
            label: 'My Profile',
            onTap: () {
              Navigator.of(context).pop();
              onMyProfile?.call();
            },
          ),
          _MenuItem(
            icon: Icons.shopping_cart_outlined,
            label: 'Webshop',
            onTap: () {
              Navigator.of(context).pop();
              onWebshop?.call();
            },
          ),
          _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Language',
            onTap: () {
              Navigator.of(context).pop();
              onLanguage?.call();
            },
          ),
          _MenuItem(
            icon: Icons.info_outline,
            label: 'User Guide',
            onTap: () {
              Navigator.of(context).pop();
              onUserGuide?.call();
            },
          ),

          const SizedBox(height: 4),
          const Divider(color: Color(0xFF3A3A3C), height: 1),

          // ── Logout ──
          _MenuItem(
            label: 'LOG OUT',
            labelStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            onTap: () {
              Navigator.of(context).pop();
              onLogout?.call();
            },
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Single Menu Item ───────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final TextStyle? labelStyle;
  final VoidCallback? onTap;

  const _MenuItem({
    this.icon,
    required this.label,
    this.labelStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 14),
            ],
            Text(
              label,
              style: labelStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
