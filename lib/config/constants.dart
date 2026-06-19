/// 应用全局常量定义
class AppConstants {
  // 应用信息
  static const String appName = '阅读';
  static const String appVersion = '1.0.0';

  // 数据库
  static const String databaseName = 'yuedu.db';
  static const int databaseVersion = 1;

  // 文件大小阈值
  static const int largeFileThreshold = 10 * 1024 * 1024; // 10MB

  // 分页默认参数
  static const double defaultFontSize = 18.0;
  static const double defaultLineHeight = 1.6;
  static const double defaultParagraphSpacing = 0.8;
  static const double defaultMargin = 24.0;
  static const int defaultIndentChars = 2;

  // 阅读模式
  static const int pageMode = 0;
  static const int scrollMode = 1;

  // 书籍类型
  static const String bookTypeLocal = 'local';
  static const String bookTypeOnline = 'online';
  static const String bookTypeHybrid = 'hybrid';

  // 书籍格式
  static const String formatTxt = 'txt';
  static const String formatEpub = 'epub';
  static const String formatPdf = 'pdf';

  // 书籍状态
  static const int statusReading = 0;
  static const int statusFinished = 1;
  static const int statusArchived = 2;

  // 书源置信度
  static const double sourceConfidenceHigh = 0.9;
  static const double sourceConfidenceMedium = 0.7;
  static const double sourceConfidenceLow = 0.5;

  // 缓存
  static const int maxCacheSize = 200 * 1024 * 1024; // 200MB
  static const int coverCacheSize = 50 * 1024 * 1024; // 50MB

  // 网络请求
  static const int connectTimeout = 10000; // 10秒
  static const int receiveTimeout = 30000; // 30秒

  // 动画
  static const int pageTurnDuration = 300; // 毫秒
  static const int menuAnimationDuration = 200;

  // 书架分组
  static const String defaultGroupId = 'default';
  static const String favoritesGroupId = 'favorites';

  // Hive boxes
  static const String settingsBox = 'settings';
  static const String readerThemeBox = 'reader_theme';
  static const String cacheBox = 'cache';

  // SharedPreferences keys
  static const String keyLastBookId = 'last_book_id';
  static const String keyReaderMode = 'reader_mode';
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstLaunch = 'first_launch';
}