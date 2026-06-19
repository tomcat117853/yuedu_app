import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/book.dart';
import '../../../../domain/models/chapter.dart';
import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';
import '../../../../domain/models/read_progress.dart';
import '../../../../domain/services/read_engine.dart';
import '../../../../providers.dart';

/// 阅读器状态
class ReaderState {
  final String bookId;
  final Book? book;
  final List<Chapter> chapters;
  final int currentChapterIndex;
  final int currentPageIndex;
  final int totalPages;
  final String currentPageText;
  final bool isLoading;
  final bool showMenu;
  final int readMode; // 0=翻页, 1=滚动
  final ReaderTheme readerTheme;
  final LayoutConfig layoutConfig;
  final ReadProgress? progress;
  final double scrollOffset;

  ReaderState({
    required this.bookId,
    this.book,
    this.chapters = const [],
    this.currentChapterIndex = 0,
    this.currentPageIndex = 0,
    this.totalPages = 0,
    this.currentPageText = '',
    this.isLoading = true,
    this.showMenu = false,
    this.readMode = 0,
    ReaderTheme? readerTheme,
    LayoutConfig? layoutConfig,
    this.progress,
    this.scrollOffset = 0.0,
  })  : readerTheme = readerTheme ?? ReaderTheme.presets[0],
        layoutConfig = layoutConfig ?? LayoutConfig();

  ReaderState copyWith({
    Book? book,
    List<Chapter>? chapters,
    int? currentChapterIndex,
    int? currentPageIndex,
    int? totalPages,
    String? currentPageText,
    bool? isLoading,
    bool? showMenu,
    int? readMode,
    ReaderTheme? readerTheme,
    LayoutConfig? layoutConfig,
    ReadProgress? progress,
    double? scrollOffset,
  }) {
    return ReaderState(
      bookId: bookId,
      book: book ?? this.book,
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      totalPages: totalPages ?? this.totalPages,
      currentPageText: currentPageText ?? this.currentPageText,
      isLoading: isLoading ?? this.isLoading,
      showMenu: showMenu ?? this.showMenu,
      readMode: readMode ?? this.readMode,
      readerTheme: readerTheme ?? this.readerTheme,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      progress: progress ?? this.progress,
      scrollOffset: scrollOffset ?? this.scrollOffset,
    );
  }
}

/// 阅读器状态通知器
class ReaderNotifier extends StateNotifier<ReaderState> {
  final Ref _ref;
  late final ReadEngine _readEngine;

  ReaderNotifier(String bookId, this._ref)
      : super(ReaderState(bookId: bookId, isLoading: true)) {
    // 创建阅读引擎实例
    final bookRepository = _ref.read(bookRepositoryProvider);
    _readEngine = ReadEngine(bookRepository);

    // 设置阅读引擎回调
    _setupCallbacks();

    _init(bookId);
  }

  /// 设置阅读引擎回调
  void _setupCallbacks() {
    // 进度变化回调
    _readEngine.onProgressChanged = (progress) {
      if (!mounted) return;
      state = state.copyWith(progress: progress);
    };

    // 分页完成回调
    _readEngine.onPaginationComplete = (pageRanges) {
      if (!mounted) return;
      final pageText = _readEngine.getCurrentPageText();
      state = state.copyWith(
        totalPages: pageRanges.length,
        currentPageText: pageText,
        currentPageIndex: _readEngine.currentChapterIndex == state.currentChapterIndex
            ? _readEngine.currentPage - 1
            : 0,
      );
    };
  }

  /// 初始化阅读器
  Future<void> _init(String bookId) async {
    try {
      final bookRepository = _ref.read(bookRepositoryProvider);

      // 加载书籍信息
      final book = await bookRepository.getBookById(bookId);
      if (book == null) {
        state = state.copyWith(
          isLoading: false,
          currentPageText: '书籍不存在',
        );
        return;
      }

      // 加载章节列表
      final chapters = await bookRepository.getChaptersByBookId(bookId);

      state = state.copyWith(
        book: book,
        chapters: chapters,
      );

      // 通过阅读引擎初始化阅读（自动恢复进度）
      await _readEngine.initReading(bookId, config: state.layoutConfig);

      // 同步阅读引擎状态到 UI
      final pageText = _readEngine.getCurrentPageText();
      state = state.copyWith(
        isLoading: false,
        currentChapterIndex: _readEngine.currentChapterIndex,
        currentPageIndex: _readEngine.currentPage - 1,
        totalPages: _readEngine.totalPages,
        currentPageText: pageText,
      );
    } catch (e) {
      debugPrint('初始化阅读器失败: $e');
      state = state.copyWith(
        isLoading: false,
        currentPageText: '加载失败: $e',
      );
    }
  }

  /// 加载章节
  Future<void> loadChapter(int chapterIndex) async {
    if (chapterIndex < 0 || chapterIndex >= state.chapters.length) return;

    state = state.copyWith(
      isLoading: true,
      currentChapterIndex: chapterIndex,
      currentPageIndex: 0,
    );

    try {
      // 通过阅读引擎加载章节并执行分页
      await _readEngine.loadChapter(chapterIndex);

      // 获取分页后的页面文本
      final pageText = _readEngine.getCurrentPageText();

      state = state.copyWith(
        isLoading: false,
        currentPageText: pageText,
        totalPages: _readEngine.totalPages,
        currentPageIndex: 0,
      );
    } catch (e) {
      debugPrint('加载章节失败: $e');
      state = state.copyWith(
        isLoading: false,
        currentPageText: '章节加载失败',
      );
    }
  }

  /// 翻到下一页
  void nextPage() {
    final moved = _readEngine.nextPage();
    if (moved) {
      // 阅读引擎成功翻页，更新 UI 状态
      final pageText = _readEngine.getCurrentPageText();
      state = state.copyWith(
        currentPageIndex: _readEngine.currentPage - 1,
        currentPageText: pageText,
      );
    } else {
      // 已到本章末尾，翻到下一章
      nextChapter();
    }
  }

  /// 翻到上一页
  void previousPage() {
    final moved = _readEngine.previousPage();
    if (moved) {
      // 阅读引擎成功翻页，更新 UI 状态
      final pageText = _readEngine.getCurrentPageText();
      state = state.copyWith(
        currentPageIndex: _readEngine.currentPage - 1,
        currentPageText: pageText,
      );
    } else {
      // 已到本章开头，翻到上一章
      previousChapter();
    }
  }

  /// 下一章
  void nextChapter() {
    if (state.currentChapterIndex < state.chapters.length - 1) {
      loadChapter(state.currentChapterIndex + 1);
    }
  }

  /// 上一章
  void previousChapter() {
    if (state.currentChapterIndex > 0) {
      loadChapter(state.currentChapterIndex - 1);
    }
  }

  /// 跳转到指定页
  void jumpToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < state.totalPages) {
      _readEngine.jumpToPage(pageIndex);
      final pageText = _readEngine.getCurrentPageText();
      state = state.copyWith(
        currentPageIndex: pageIndex,
        currentPageText: pageText,
      );
    }
  }

  /// 跳转到指定章节
  Future<void> jumpToChapter(int chapterIndex) async {
    await loadChapter(chapterIndex);
  }

  /// 切换菜单显示
  void toggleMenu() {
    state = state.copyWith(showMenu: !state.showMenu);
  }

  /// 切换阅读模式
  void toggleReadMode() {
    final newMode = state.readMode == 0 ? 1 : 0;
    _readEngine.updateReadMode(newMode);
    state = state.copyWith(readMode: newMode);
  }

  /// 切换主题
  void cycleTheme() {
    final nextIndex =
        (state.readerTheme.themeIndex + 1) % ReaderTheme.presets.length;
    state = state.copyWith(readerTheme: ReaderTheme.presets[nextIndex]);
  }

  /// 设置主题
  void setTheme(ReaderTheme newTheme) {
    state = state.copyWith(readerTheme: newTheme);
  }

  /// 更新排版配置
  Future<void> updateLayoutConfig(LayoutConfig config) async {
    // 先更新引擎配置并完成分页
    await _readEngine.updateLayoutConfig(config);
    
    // 分页完成后一次性更新所有状态
    final pageText = _readEngine.getCurrentPageText();
    state = state.copyWith(
      layoutConfig: config,
      totalPages: _readEngine.totalPages,
      currentPageText: pageText,
    );
  }

  /// 增大字体
  Future<void> increaseFontSize() async {
    final newConfig = state.layoutConfig.copyWith(
      fontSize: (state.layoutConfig.fontSize + 1).clamp(12.0, 32.0),
    );
    await updateLayoutConfig(newConfig);
  }

  /// 减小字体
  Future<void> decreaseFontSize() async {
    final newConfig = state.layoutConfig.copyWith(
      fontSize: (state.layoutConfig.fontSize - 1).clamp(12.0, 32.0),
    );
    await updateLayoutConfig(newConfig);
  }

  /// 增大行距
  Future<void> increaseLineHeight() async {
    final newConfig = state.layoutConfig.copyWith(
      lineHeight: (state.layoutConfig.lineHeight + 0.1).clamp(1.0, 3.0),
    );
    await updateLayoutConfig(newConfig);
  }

  /// 减小行距
  Future<void> decreaseLineHeight() async {
    final newConfig = state.layoutConfig.copyWith(
      lineHeight: (state.layoutConfig.lineHeight - 0.1).clamp(1.0, 3.0),
    );
    await updateLayoutConfig(newConfig);
  }

  @override
  void dispose() {
    _readEngine.dispose();
    super.dispose();
  }
}

/// 阅读器Provider（使用 family 传递 bookId 参数）
final readerProvider = StateNotifierProvider.autoDispose
    .family<ReaderNotifier, ReaderState, String>((ref, bookId) {
  return ReaderNotifier(bookId, ref);
});
