import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/constants.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers.dart';

/// 主题模式 Provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

/// 主题模式管理
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final modeStr = prefs.getString(AppConstants.keyThemeMode) ?? 'system';
      switch (modeStr) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    } catch (_) {
      // SharedPreferences 未初始化时使用系统默认
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      String modeStr;
      switch (mode) {
        case ThemeMode.light:
          modeStr = 'light';
          break;
        case ThemeMode.dark:
          modeStr = 'dark';
          break;
        default:
          modeStr = 'system';
      }
      await prefs.setString(AppConstants.keyThemeMode, modeStr);
    } catch (_) {}
  }
}

/// 阅读App根组件
class YueDuApp extends ConsumerStatefulWidget {
  const YueDuApp({super.key});

  @override
  ConsumerState<YueDuApp> createState() => _YueDuAppState();
}

class _YueDuAppState extends ConsumerState<YueDuApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: '阅读',
      debugShowCheckedModeBanner: false,

      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

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
