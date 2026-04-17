import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionWidget extends StatefulWidget {
  const AppVersionWidget({super.key});

  @override
  State<AppVersionWidget> createState() => _AppVersionWidgetState();
}

class _AppVersionWidgetState extends State<AppVersionWidget> {
  String _versionText = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _versionText = 'Version ${info.version}(${info.buildNumber})';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _versionText,
      style: const TextStyle(fontSize: 14, color: Colors.grey),
    );
  }
}