import 'book.dart';
import 'chapter.dart';
import 'layout_config.dart';
import 'reader_theme.dart';

/// 阅读器状态模型
class ReaderState {
  final Book? book;
  final List<Chapter> chapters;
  final int currentChapterIndex;
  final int currentPageIndex;
  final int totalPages;
  final String currentPageText;
  final LayoutConfig layoutConfig;
  final ReaderTheme readerTheme;
  final bool isLoading;
  final int readMode; // 0: 翻页模式, 1: 滚动模式
  final bool showMenu;
  final String? error;

  const ReaderState({
    this.book,
    this.chapters = const [],
    this.currentChapterIndex = 0,
    this.currentPageIndex = 0,
    this.totalPages = 0,
    this.currentPageText = '',
    required this.layoutConfig,
    required this.readerTheme,
    this.isLoading = false,
    this.readMode = 0,
    this.showMenu = false,
    this.error,
  });

  /// 获取当前章节
  Chapter? get currentChapter =>
      chapters.isNotEmpty && currentChapterIndex < chapters.length
          ? chapters[currentChapterIndex]
          : null;

  /// 获取当前页码（1-based，用于显示）
  int get currentPage => currentPageIndex + 1;

  /// 兼容性别名
  ReaderTheme get theme => readerTheme;

  /// 复制方法
  ReaderState copyWith({
    Book? book,
    List<Chapter>? chapters,
    int? currentChapterIndex,
    int? currentPageIndex,
    int? totalPages,
    String? currentPageText,
    LayoutConfig? layoutConfig,
    ReaderTheme? readerTheme,
    bool? isLoading,
    int? readMode,
    bool? showMenu,
    String? error,
  }) {
    return ReaderState(
      book: book ?? this.book,
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      totalPages: totalPages ?? this.totalPages,
      currentPageText: currentPageText ?? this.currentPageText,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      readerTheme: readerTheme ?? this.readerTheme,
      isLoading: isLoading ?? this.isLoading,
      readMode: readMode ?? this.readMode,
      showMenu: showMenu ?? this.showMenu,
      error: error,
    );
  }
}
