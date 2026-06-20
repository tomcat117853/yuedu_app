import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// ============================================================
/// Apple 风格主题系统
/// 参考 Apple HIG + iOS 系统规范
/// ============================================================
class AppTheme {
  AppTheme._();

  // ============================================================
  // 亮色主题
  // ============================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.systemBlue,

      colorScheme: const ColorScheme.light(
        primary: AppColors.systemBlue,
        secondary: AppColors.systemIndigo,
        tertiary: AppColors.systemPurple,
        error: AppColors.systemRed,
        surface: AppColors.gray0,
        onSurface: AppColors.gray9,
        onSurfaceVariant: AppColors.gray6,
        outline: AppColors.gray4,
        outlineVariant: AppColors.gray3,
      ),

      scaffoldBackgroundColor: AppColors.gray1,
      dividerColor: AppColors.gray2,
      hintColor: AppColors.gray5,
      canvasColor: AppColors.gray1,
      cardColor: AppColors.gray0,
      dialogBackgroundColor: AppColors.gray0,

      // iOS 字号阶梯
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppFontSize.largeTitle,
          fontWeight: AppFontWeight.bold,
          letterSpacing: -1.0,
          height: 1.21,
          color: AppColors.gray9,
        ),
        displayMedium: TextStyle(
          fontSize: AppFontSize.title1,
          fontWeight: AppFontWeight.bold,
          letterSpacing: -0.8,
          height: 1.21,
          color: AppColors.gray9,
        ),
        titleLarge: TextStyle(
          fontSize: AppFontSize.title2,
          fontWeight: AppFontWeight.bold,
          letterSpacing: -0.8,
          height: 1.27,
          color: AppColors.gray9,
        ),
        titleMedium: TextStyle(
          fontSize: AppFontSize.title3,
          fontWeight: AppFontWeight.semibold,
          height: 1.25,
          color: AppColors.gray9,
        ),
        headlineSmall: TextStyle(
          fontSize: AppFontSize.headline,
          fontWeight: AppFontWeight.semibold,
          height: 1.29,
          color: AppColors.gray9,
        ),
        bodyLarge: TextStyle(
          fontSize: AppFontSize.body,
          fontWeight: AppFontWeight.regular,
          letterSpacing: -0.4,
          height: 1.29,
          color: AppColors.gray9,
        ),
        bodyMedium: TextStyle(
          fontSize: AppFontSize.subhead,
          fontWeight: AppFontWeight.regular,
          height: 1.33,
          color: AppColors.gray7,
        ),
        labelLarge: TextStyle(
          fontSize: AppFontSize.callout,
          fontWeight: AppFontWeight.regular,
          height: 1.31,
          color: AppColors.gray8,
        ),
        labelSmall: TextStyle(
          fontSize: AppFontSize.footnote,
          fontWeight: AppFontWeight.regular,
          height: 1.38,
          color: AppColors.gray6,
        ),
      ),

      // AppBar - iOS Large Title 风格
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Color(0x00000000), // 透明背景
        foregroundColor: AppColors.gray9,
        iconTheme: IconThemeData(color: AppColors.systemBlue, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.systemBlue, size: 22),
        titleTextStyle: TextStyle(
          fontSize: AppFontSize.title1,
          fontWeight: AppFontWeight.bold,
          color: AppColors.gray9,
          letterSpacing: -0.8,
        ),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      // 底部导航栏
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF5FFFFFF), // 半透明白
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 56,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: AppColors.systemBlue.withOpacity(0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 10,
              fontWeight: AppFontWeight.medium,
              color: AppColors.systemBlue,
            );
          }
          return const TextStyle(
            fontSize: 10,
            fontWeight: AppFontWeight.regular,
            color: AppColors.gray6,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.systemBlue, size: 24);
          }
          return const IconThemeData(color: AppColors.gray6, size: 24);
        }),
      ),

      // 卡片
      cardTheme: CardThemeData(
        color: AppColors.gray0,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      // 按钮
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.systemBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: AppFontWeight.semibold,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.systemBlue,
          side: const BorderSide(color: AppColors.systemBlue, width: 1),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: AppFontWeight.semibold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.systemBlue,
          textStyle: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: AppFontWeight.regular,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButtonThemeData().style?.copyWith(
              backgroundColor: WidgetStateProperty.all(AppColors.systemBlue),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              elevation: WidgetStateProperty.all(0),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: AppFontSize.body,
                  fontWeight: AppFontWeight.semibold,
                ),
              ),
            ),
      ),

      // 图标按钮
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.systemBlue,
          iconSize: 22,
        ),
      ),

      // 输入框
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray5.withOpacity(0.12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.systemBlue, width: 1),
        ),
        hintStyle: const TextStyle(
          color: AppColors.gray5,
          fontSize: AppFontSize.body,
          fontWeight: AppFontWeight.regular,
        ),
        prefixIconColor: AppColors.gray6,
        suffixIconColor: AppColors.gray6,
      ),

      // 列表项
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        titleTextStyle: const TextStyle(
          fontSize: AppFontSize.body,
          fontWeight: AppFontWeight.regular,
          color: AppColors.gray9,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: AppFontSize.footnote,
          color: AppColors.gray6,
        ),
        iconColor: AppColors.gray6,
        minLeadingWidth: 28,
        minVerticalPadding: 8,
      ),

      // 对话框 - iOS 风格
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.gray0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.largeCard),
        ),
        titleTextStyle: const TextStyle(
          fontSize: AppFontSize.title3,
          fontWeight: AppFontWeight.semibold,
          color: AppColors.gray9,
        ),
        contentTextStyle: const TextStyle(
          fontSize: AppFontSize.body,
          color: AppColors.gray7,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      // 底部 Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.gray0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.sheetBody),
            topRight: Radius.circular(AppRadius.sheetBody),
          ),
        ),
        elevation: 0,
        modalBackgroundColor: AppColors.gray0,
      ),

      // 分割线
      dividerTheme: const DividerThemeData(
        color: AppColors.gray2,
        thickness: 0.5,
        space: 0.5,
      ),

      // 进度条
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.systemBlue,
        linearTrackColor: AppColors.gray2,
      ),

      // 滑块
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.systemBlue,
        inactiveTrackColor: AppColors.gray3,
        thumbColor: Colors.white,
        overlayColor: Color(0x29007AFF),
        trackHeight: 2,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.gray1,
        selectedColor: AppColors.systemBlue.withOpacity(0.15),
        labelStyle: const TextStyle(
          fontSize: AppFontSize.subhead,
          fontWeight: AppFontWeight.regular,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray8,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: AppFontSize.callout,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.systemGreen;
          return AppColors.gray4;
        }),
      ),

      // TabBar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.systemBlue,
        unselectedLabelColor: AppColors.gray6,
        indicatorColor: AppColors.systemBlue,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: AppFontSize.callout,
          fontWeight: AppFontWeight.semibold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppFontSize.callout,
          fontWeight: AppFontWeight.regular,
        ),
        dividerColor: AppColors.gray2,
      ),

      // Popup
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.gray0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        textStyle: const TextStyle(
          fontSize: AppFontSize.body,
          color: AppColors.gray9,
        ),
      ),
    );
  }

  // ============================================================
  // 暗色主题
  // ============================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.systemBlueDark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.systemBlueDark,
        secondary: AppColors.systemIndigoDark,
        tertiary: AppColors.systemPurpleDark,
        error: AppColors.systemRedDark,
        surface: AppColors.darkGray1,
        onSurface: AppColors.darkGray9,
        onSurfaceVariant: AppColors.darkGray6,
        outline: AppColors.darkGray4,
        outlineVariant: AppColors.darkGray3,
      ),

      scaffoldBackgroundColor: AppColors.darkGray0,
      dividerColor: AppColors.darkGray3,
      hintColor: AppColors.darkGray5,
      canvasColor: AppColors.darkGray0,
      cardColor: AppColors.darkGray2,
      dialogBackgroundColor: AppColors.darkGray2,

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppFontSize.largeTitle,
          fontWeight: AppFontWeight.bold,
          letterSpacing: -1.0,
          height: 1.21,
          color: AppColors.darkGray9,
        ),
        displayMedium: TextStyle(
          fontSize: AppFontSize.title1,
          fontWeight: AppFontWeight.bold,
          letterSpacing: -0.8,
          height: 1.21,
          color: AppColors.darkGray9,
        ),
        titleLarge: TextStyle(
          fontSize: AppFontSize.title2,
          fontWeight: AppFontWeight.bold,
          letterSpacing: -0.8,
          height: 1.27,
          color: AppColors.darkGray9,
        ),
        titleMedium: TextStyle(
          fontSize: AppFontSize.title3,
          fontWeight: AppFontWeight.semibold,
          height: 1.25,
          color: AppColors.darkGray9,
        ),
        headlineSmall: TextStyle(
          fontSize: AppFontSize.headline,
          fontWeight: AppFontWeight.semibold,
          height: 1.29,
          color: AppColors.darkGray9,
        ),
        bodyLarge: TextStyle(
          fontSize: AppFontSize.body,
          fontWeight: AppFontWeight.regular,
          letterSpacing: -0.4,
          height: 1.29,
          color: AppColors.darkGray9,
        ),
        bodyMedium: TextStyle(
          fontSize: AppFontSize.subhead,
          fontWeight: AppFontWeight.regular,
          height: 1.33,
          color: AppColors.darkGray7,
        ),
        labelLarge: TextStyle(
          fontSize: AppFontSize.callout,
          fontWeight: AppFontWeight.regular,
          height: 1.31,
          color: AppColors.darkGray8,
        ),
        labelSmall: TextStyle(
          fontSize: AppFontSize.footnote,
          fontWeight: AppFontWeight.regular,
          height: 1.38,
          color: AppColors.darkGray6,
        ),
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: Color(0x00000000),
        foregroundColor: AppColors.darkGray9,
        iconTheme: IconThemeData(color: AppColors.systemBlueDark, size: 22),
        actionsIconTheme: IconThemeData(color: AppColors.systemBlueDark, size: 22),
        titleTextStyle: TextStyle(
          fontSize: AppFontSize.title1,
          fontWeight: AppFontWeight.bold,
          color: AppColors.darkGray9,
          letterSpacing: -0.8,
        ),
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xF5000000), // 半透明黑
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 56,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: AppColors.systemBlueDark.withOpacity(0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 10,
              fontWeight: AppFontWeight.medium,
              color: AppColors.systemBlueDark,
            );
          }
          return const TextStyle(
            fontSize: 10,
            fontWeight: AppFontWeight.regular,
            color: AppColors.darkGray6,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.systemBlueDark, size: 24);
          }
          return const IconThemeData(color: AppColors.darkGray6, size: 24);
        }),
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkGray2,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.02),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.systemBlueDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: AppFontWeight.semibold,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.systemBlueDark,
          side: const BorderSide(color: AppColors.systemBlueDark, width: 1),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          textStyle: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: AppFontWeight.semibold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.systemBlueDark,
          textStyle: const TextStyle(
            fontSize: AppFontSize.body,
            fontWeight: AppFontWeight.regular,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButtonThemeData().style?.copyWith(
              backgroundColor: WidgetStateProperty.all(AppColors.systemBlueDark),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              elevation: WidgetStateProperty.all(0),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: AppFontSize.body,
                  fontWeight: AppFontWeight.semibold,
                ),
              ),
            ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.systemBlueDark,
          iconSize: 22,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGray5.withOpacity(0.2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.systemBlueDark, width: 1),
        ),
        hintStyle: const TextStyle(
          color: AppColors.darkGray5,
          fontSize: AppFontSize.body,
          fontWeight: AppFontWeight.regular,
        ),
        prefixIconColor: AppColors.darkGray6,
        suffixIconColor: AppColors.darkGray6,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        titleTextStyle: const TextStyle(
          fontSize: AppFontSize.body,
          fontWeight: AppFontWeight.regular,
          color: AppColors.darkGray9,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: AppFontSize.footnote,
          color: AppColors.darkGray6,
        ),
        iconColor: AppColors.darkGray6,
        minLeadingWidth: 28,
        minVerticalPadding: 8,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkGray2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.largeCard),
        ),
        titleTextStyle: const TextStyle(
          fontSize: AppFontSize.title3,
          fontWeight: AppFontWeight.semibold,
          color: AppColors.darkGray9,
        ),
        contentTextStyle: const TextStyle(
          fontSize: AppFontSize.body,
          color: AppColors.darkGray7,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkGray2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppRadius.sheetBody),
            topRight: Radius.circular(AppRadius.sheetBody),
          ),
        ),
        elevation: 0,
        modalBackgroundColor: AppColors.darkGray2,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkGray3,
        thickness: 0.5,
        space: 0.5,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.systemBlueDark,
        linearTrackColor: AppColors.darkGray3,
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.systemBlueDark,
        inactiveTrackColor: AppColors.darkGray4,
        thumbColor: Colors.white,
        overlayColor: Color(0x290A84FF),
        trackHeight: 2,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkGray3,
        selectedColor: AppColors.systemBlueDark.withOpacity(0.2),
        labelStyle: const TextStyle(
          fontSize: AppFontSize.subhead,
          fontWeight: AppFontWeight.regular,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGray5,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: AppFontSize.callout,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.systemGreenDark;
          return AppColors.darkGray4;
        }),
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.systemBlueDark,
        unselectedLabelColor: AppColors.darkGray6,
        indicatorColor: AppColors.systemBlueDark,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: AppFontSize.callout,
          fontWeight: AppFontWeight.semibold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppFontSize.callout,
          fontWeight: AppFontWeight.regular,
        ),
        dividerColor: AppColors.darkGray3,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkGray2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        textStyle: const TextStyle(
          fontSize: AppFontSize.body,
          color: AppColors.darkGray9,
        ),
      ),
    );
  }
}
