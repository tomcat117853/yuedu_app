import 'package:flutter/material.dart';

/// 阅读器主题配置
class ReaderThemeData {
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color hintColor;

  const ReaderThemeData({
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.hintColor,
  });
}

/// 预定义阅读器主题
class ReaderThemes {
  /// 日间模式
  static const ReaderThemeData light = ReaderThemeData(
    name: '日间',
    backgroundColor: Color(0xFFF5F5F0),
    textColor: Color(0xFF333333),
    hintColor: Color(0xFF999999),
  );

  /// 夜间模式
  static const ReaderThemeData dark = ReaderThemeData(
    name: '夜间',
    backgroundColor: Color(0xFF1A1A1A),
    textColor: Color(0xFFB0B0B0),
    hintColor: Color(0xFF666666),
  );

  /// 护眼模式
  static const ReaderThemeData eyeCare = ReaderThemeData(
    name: '护眼',
    backgroundColor: Color(0xFFF0E6D2),
    textColor: Color(0xFF5B4636),
    hintColor: Color(0xFF8B7355),
  );

  /// 墨水屏模式
  static const ReaderThemeData ink = ReaderThemeData(
    name: '墨水屏',
    backgroundColor: Color(0xFFFFFFFF),
    textColor: Color(0xFF000000),
    hintColor: Color(0xFF888888),
  );

  static const List<ReaderThemeData> all = [light, dark, eyeCare, ink];

  /// 根据索引获取主题
  static ReaderThemeData fromIndex(int index) {
    if (index < 0 || index >= all.length) return light;
    return all[index];
  }
}

/// 应用主题配置
class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF6B5CE7);
  static const Color primaryLight = Color(0xFF9D8DF7);
  static const Color primaryDark = Color(0xFF4A3DB5);

  // 辅助色
  static const Color accentColor = Color(0xFFFF6B6B);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);

  // 中性色
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);

  /// 构建亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: textHint),
      ),
    );
  }

  /// 构建暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFE0E0E0),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryLight,
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF333333),
        thickness: 0.5,
      ),
    );
  }
}