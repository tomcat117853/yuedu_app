import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/routes.dart';
import 'config/theme.dart';

/// 阅读App根组件
class YueDuApp extends ConsumerStatefulWidget {
  const YueDuApp({super.key});

  @override
  ConsumerState<YueduApp> createState() => _YueduAppState();
}

class _YueDuAppState extends ConsumerState<YueDuApp> {
  late final GoRouter _router;

  /// 当前主题模式
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
    _loadThemeMode();
  }

  /// 加载主题模式设置
  Future<void> _loadThemeMode() async {
    // 实际项目中从 SharedPreferences 加载
    // 暂时使用系统默认
    setState(() {
      _themeMode = ThemeMode.system;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '阅读',
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // 路由配置
      routerConfig: _router,

      // 构建器 - 可用于全局配置
      builder: (context, child) {
        return MediaQuery(
          // 禁用系统文字缩放，保持排版一致性
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}