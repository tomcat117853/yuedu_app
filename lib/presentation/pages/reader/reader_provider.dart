import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/chapter.dart';
import '../../../domain/models/layout_config.dart';
import '../../../domain/models/read_progress.dart';
import '../../../domain/models/reader_theme.dart';
import '../../../domain/services/read_engine.dart';

final readerProvider = NotifierProvider<ReaderProvider, ReaderState>(
  () => throw UnimplementedError(),
);

class ReaderProvider extends Notifier<ReaderState> {
  late final ReadEngine _readEngine;

  @override
  ReaderState build() {
    _readEngine = ref.read(readEngineProvider);
    return ReaderState(
      chapters: [],
      currentChapterIndex: 0,
      currentPage: 0,
      totalPages: 0,
      currentPageText: '',
      layoutConfig: LayoutConfig.defaultConfig(),
      theme: ReaderTheme.day(),
      isLoading: false,
    );
  }

  Future<void> loadBook(String bookId) async {
    state = state.copyWith(isLoading: true);
    try {
      final chapters = await _readEngine.loadBook(bookId);
      if (chapters.isEmpty) {
        state = state.copyWith(
          chapters: [],
          currentChapterIndex: 0,
          currentPage: 0,
          totalPages: 0,
          currentPageText: '',
          isLoading: false,
        );
        return;
      }

      await _readEngine.loadChapter(chapters[0].id);
      await _readEngine.updateLayoutConfig(state.layoutConfig);

      final totalPages = _readEngine.getTotalPages();
      final pageText = _readEngine.getPageText(0);

      state = state.copyWith(
        chapters: chapters,
        currentChapterIndex: 0,
        currentPage: 0,
        totalPages: totalPages,
        currentPageText: pageText,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> setTheme(ReaderTheme theme) async {
    state = state.copyWith(theme: theme);
  }

  Future<void> updateLayoutConfig(LayoutConfig config) async {
    await _readEngine.updateLayoutConfig(config);
    final totalPages = _readEngine.getTotalPages();
    final currentPage = _readEngine.getCurrentPage();
    final pageText = _readEngine.getPageText(currentPage);

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

  /// 更新排版配置
  void updateLayoutConfig(LayoutConfig config) async {
    state = state.copyWith(layoutConfig: config);
    // 通过阅读引擎更新排版并重新分页
    await _readEngine.updateLayoutConfig(config);
    // 分页完成后更新 UI
    final pageText = _readEngine.getCurrentPageText();
    state = state.copyWith(
      totalPages: _readEngine.totalPages,
      currentPageText: pageText,
    );
  }

  /// 增大字体
  void increaseFontSize() {
    final newConfig = state.layoutConfig.copyWith(
      fontSize: (state.layoutConfig.fontSize + 1).clamp(12.0, 32.0),
    );
    updateLayoutConfig(newConfig);
  }

  /// 减小字体
  void decreaseFontSize() {
    final newConfig = state.layoutConfig.copyWith(
      fontSize: (state.layoutConfig.fontSize - 1).clamp(12.0, 32.0),
    );
    updateLayoutConfig(newConfig);
  }

  /// 增大行距
  void increaseLineHeight() {
    final newConfig = state.layoutConfig.copyWith(
      lineHeight: (state.layoutConfig.lineHeight + 0.1).clamp(1.0, 3.0),
    );
    updateLayoutConfig(newConfig);
  }

  /// 减小行距
  void decreaseLineHeight() {
    final newConfig = state.layoutConfig.copyWith(
      lineHeight: (state.layoutConfig.lineHeight - 0.1).clamp(1.0, 3.0),
    );
    updateLayoutConfig(newConfig);
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
