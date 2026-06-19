import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

/// 应用入口
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置错误处理
  FlutterError.onError = (details) {
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  runApp(
    const ProviderScope(
      child: YueDuApp(),
    ),
  );
}
