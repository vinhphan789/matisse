import 'package:flutter/material.dart';


class LoadingService {
  static final LoadingService _instance = LoadingService._internal();
  factory LoadingService() => _instance;
  LoadingService._internal();

  final ValueNotifier<bool> _loading = ValueNotifier(false);

  ValueNotifier<bool> get loadingNotifier => _loading;

  void show() {
    _loading.value = true;
  }

  void hide() {
    _loading.value = false;
  }
}

class GlobalLoadingOverlay extends StatelessWidget {
  const GlobalLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final loadingService = LoadingService();

    return ValueListenableBuilder<bool>(
      valueListenable: loadingService.loadingNotifier,
      builder: (context, isLoading, child) {
        if (!isLoading) return const SizedBox.shrink();

        return Container(
          child: Center(
            child: Container(
              width: 200,
              height: 70,
              padding: const EdgeInsets.symmetric(vertical: 0),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(width: 16),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}