import 'package:flutter/material.dart';

/// ============================================================
/// 全局设计 Token 系统
/// 参考 Apple HIG + iOS 系统规范，为全平台阅读App定义统一的设计常量
/// ============================================================

/// ---- 系统语义色 (iOS Standard Colors) ----
class AppColors {
  AppColors._();

  // === System Semantic Colors (Light / Dark) ===
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemBlueDark = Color(0xFF0A84FF);

  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemIndigoDark = Color(0xFF5E5CE6);

  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemPurpleDark = Color(0xFFBF5AF2);

  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemPinkDark = Color(0xFFFF375F);

  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemRedDark = Color(0xFFFF453A);

  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemOrangeDark = Color(0xFFFF9F0A);

  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemGreenDark = Color(0xFF30D158);

  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemTealDark = Color(0xFF64D2FF);

  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGrayDark = Color(0xFF8E8E93);

  // === iOS Gray Scale (Light Mode) ===
  static const Color gray0 = Color(0xFFFFFFFF); // 纯白：卡片背景
  static const Color gray1 = Color(0xFFF2F2F7); // 浅灰：分组背景
  static const Color gray2 = Color(0xFFE5E5EA); // 分隔线
  static const Color gray3 = Color(0xFFD1D1D6); // 边框
  static const Color gray4 = Color(0xFFC7C7CC); // 禁用态
  static const Color gray5 = Color(0xFFAEAEB2); // 占位文字
  static const Color gray6 = Color(0xFF8E8E93); // 次要文字
  static const Color gray7 = Color(0xFF636366); // 辅助文字
  static const Color gray8 = Color(0xFF3A3A3C); // 深色文字
  static const Color gray9 = Color(0xFF1C1C1E); // 接近黑：主背景暗色

  // === iOS Gray Scale (Dark Mode) ===
  static const Color darkGray0 = Color(0xFF000000);
  static const Color darkGray1 = Color(0xFF1C1C1E);
  static const Color darkGray2 = Color(0xFF2C2C2E);
  static const Color darkGray3 = Color(0xFF3A3A3C);
  static const Color darkGray4 = Color(0xFF48484A);
  static const Color darkGray5 = Color(0xFF636366);
  static const Color darkGray6 = Color(0xFF8E8E93);
  static const Color darkGray7 = Color(0xFFAEAEB2);
  static const Color darkGray8 = Color(0xFFD1D1D6);
  static const Color darkGray9 = Color(0xFFE5E5EA);

  // === 阅读专用主题色 ===
  static const Color readingBgWhite = Color(0xFFFFFFFF);
  static const Color readingTextWhite = Color(0xFF1D1D1F);

  static const Color readingBgPaper = Color(0xFFF5F0E8);
  static const Color readingTextPaper = Color(0xFF333333);

  static const Color readingBgGreen = Color(0xFFC7EDCC);
  static const Color readingTextGreen = Color(0xFF333333);

  static const Color readingBgAmber = Color(0xFFFFF3E0);
  static const Color readingTextAmber = Color(0xFF5D4037);

  static const Color readingBgDarkGray = Color(0xFF1C1C1E);
  static const Color readingTextDarkGray = Color(0xFFE5E5EA);

  static const Color readingBgOled = Color(0xFF000000);
  static const Color readingTextOled = Color(0xFFB0B0B0);

  static const Color readingBgSepia = Color(0xFF2B1F17);
  static const Color readingTextSepia = Color(0xFFD4C5A9);

  // === 语义色快捷访问 ===
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;
  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;
  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;
  static Color hint(BuildContext context) => Theme.of(context).hintColor;
  static Color divider(BuildContext context) =>
      Theme.of(context).dividerColor;

  /// 根据亮度获取动态颜色
  static Color dynamic({
    required BuildContext context,
    required Color light,
    required Color dark,
  }) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
}

/// ---- 间距阶梯 (4pt 基准栅格) ----
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0; // 图标内微调
  static const double xs = 4.0; // 文字与图标间距
  static const double sm = 8.0; // 列表项内元素间距
  static const double md = 12.0; // 卡片内边距
  static const double base = 16.0; // 页面左右边距、段间距
  static const double lg = 20.0; // 卡片间距
  static const double xl = 24.0; // 分区之间间距
  static const double xxl = 32.0; // 大区块间距
  static const double xxxl = 48.0; // 页面级间距

  /// 各页面边距
  static const double bookshelfPadding = 16.0;
  static const double readerPadding = 24.0;
  static const double settingsPadding = 20.0;
  static const double searchPadding = 16.0;
  static const double sourcePadding = 16.0;
}

/// ---- 圆角系统 ----
class AppRadius {
  AppRadius._();

  static const double button = 8.0; // 小型按钮
  static const double input = 10.0; // 搜索框、文本输入
  static const double card = 12.0; // 书籍卡片、信息卡片
  static const double sheet = 16.0; // 模态底部弹出（grabber端）
  static const double sheetBody = 20.0; // 模态底部弹出（主体）
  static const double largeCard = 20.0; // 大型模态弹窗
  static const double avatar = 12.0; // 书籍封面圆角
  static const double smallChip = 4.0; // 小标签
  static const double mediumChip = 6.0; // 中标签
}

/// ---- 字号阶梯 (iOS Dynamic Type) ----
class AppFontSize {
  AppFontSize._();

  static const double largeTitle = 34.0; // 书架页大标题
  static const double title1 = 28.0; // 导航栏标题
  static const double title2 = 22.0; // 分区标题
  static const double title3 = 20.0; // 书名、章节标题
  static const double headline = 17.0; // 列表项主文字
  static const double body = 17.0; // 界面正文
  static const double callout = 16.0; // 辅助说明文字
  static const double subhead = 15.0; // 列表项副文字
  static const double footnote = 13.0; // 脚注、时间戳
  static const double caption1 = 12.0; // 图片说明
  static const double caption2 = 11.0; // 最小辅助文字
}

/// ---- 字重 ----
class AppFontWeight {
  AppFontWeight._();

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
}

/// ---- 动效规范 ----
class AppMotion {
  AppMotion._();

  // 时长
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration pageFlip = Duration(milliseconds: 600);

  // 曲线
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve spring = Curves.easeOutBack;
}

/// ---- 阴影系统 ----
class AppShadow {
  AppShadow._();

  /// 卡片阴影 (Light)
  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// 卡片阴影 (Dark)
  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// 根据主题获取卡片阴影
  static List<BoxShadow> card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : cardLight;
  }

  /// 封面阴影
  static List<BoxShadow> cover(BuildContext context) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(
          Theme.of(context).brightness == Brightness.dark ? 0.02 : 0.08,
        ),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ];
  }
}

/// ---- iOS 风格分组背景 ----
class AppGroupedBackground {
  AppGroupedBackground._();

  /// iOS Inset Grouped 分组背景色
  static Color groupBackground(BuildContext context) {
    return AppColors.dynamic(
      context: context,
      light: AppColors.gray0,
      dark: AppColors.darkGray2,
    );
  }

  /// iOS Inset Grouped 页面背景色
  static Color pageBackground(BuildContext context) {
    return AppColors.dynamic(
      context: context,
      light: AppColors.gray1,
      dark: AppColors.darkGray1,
    );
  }
}
