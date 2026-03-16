// lib/extension/string_extension.dart

// 🍎 Swift: extension String { func getInitials() -> String { ... } }
// 🐦 Flutter: hoàn toàn giống — extension cú pháp gần như identical

extension StringExtension on String {
  String getName() {
    if (isEmpty) return '??';
    final username = split('@').first;
    return username;
  }

  String getAbbName() {
    if (isEmpty) return '??';
    return substring(0, 2).toUpperCase();
  }
}