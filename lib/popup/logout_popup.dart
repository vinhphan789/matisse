import 'package:flutter/material.dart';

import '../next_work/app_service.dart';

/// Hiển thị dialog xác nhận đăng xuất
Future<void> showLogoutPopup(BuildContext context) async {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (context) => const LogoutAlertDialog(),
  );
}

class LogoutAlertDialog extends StatelessWidget {
  const LogoutAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Message ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),

            // ── Divider ───────────────────────────────────────
            const Divider(color: Color(0xFF3A3A3C), height: 1),

            // ── Buttons ───────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                children: [
                  // Cancel
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                        overlayColor: Colors.white10,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Vertical divider
                  const VerticalDivider(
                    color: Color(0xFF3A3A3C),
                    width: 1,
                    thickness: 1,
                  ),

                  // Log Out
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);

                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        overlayColor: Colors.white10,
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ví dụ sử dụng ─────────────────────────────────────────────────────────────
class ExampleScreen extends StatelessWidget {
  final ApiService _api = ApiService();


  ExampleScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text('Projects'),
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              barrierColor: Colors.black.withOpacity(0.6),
              builder: (_) => const LogoutAlertDialog(),
            );
            if (confirmed == true) {
              // TODO: xử lý logout
              debugPrint('Đã đăng xuất');
              _api.clearCredentials();
            }
          },
          child: const Text('Log Out'),
        ),
      ),
    );
  }
}