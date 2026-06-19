import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/book.dart';
import '../../../domain/models/chapter.dart';
import '../../../domain/models/layout_config.dart';
import '../../../domain/models/reader_state.dart';
import '../../../domain/models/reader_theme.dart';
import '../../../domain/services/read_engine.dart';

final readerProvider = NotifierProvider<ReaderProvider, ReaderState>(
  ReaderProvider.new,
);

class ReaderProvider extends Notifier<ReaderState> {
  late final ReadEngine _readEngine;

  @override
  ReaderState build() {
    _readEngine = ref.read(readEngineProvider);
    return ReaderState(
      layoutConfig: LayoutConfig.defaultConfig(),
      readerTheme: ReaderTheme.day(),
    );
  }

  /// 加载书籍
  Future<void> loadBook(String bookId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final chapters = await _readEngine.loadBook(bookId);
      
      if (chapters.isEmpty) {
        state = state.copyWith(
          isLoading: false,
        );
        return;
      }

      await _readEngine.loadChapter(0);
      await _readEngine.updateLayoutConfig(state.layoutConfig);

      final totalPages = _readEngine.totalPages;
      final pageText = _readEngine.getCurrentPageText();

      state = state.copyWith(
        currentChapterIndex: 0,
        currentPageIndex: 0,
        totalPages: totalPages,
        currentPageText: pageText,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载书籍失败: $e',
      );
    }
  }

  /// 加载指定章节
  Future<void> loadChapter(int chapterIndex) async {
    if (chapterIndex < 0 || chapterIndex >= state.chapters.length) return;
    
    state = state.copyWith(isLoading: true);
    try {
      await _readEngine.loadChapter(chapterIndex);
      
      final totalPages = _readEngine.totalPages;
      final pageText = _readEngine.getCurrentPageText();

      state = state.copyWith(
        currentChapterIndex: chapterIndex,
        currentPageIndex: 0,
        totalPages: totalPages,
        currentPageText: pageText,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '加载章节失败: $e',
      );
    }
  }

  /// 设置主题
  void setTheme(ReaderTheme theme) {
    state = state.copyWith(readerTheme: theme);
  }

  /// 更新排版配置
  Future<void> updateLayoutConfig(LayoutConfig config) async {
    state = state.copyWith(layoutConfig: config);
    await _readEngine.updateLayoutConfig(config);
    
    final totalPages = _readEngine.totalPages;
    final pageText = _readEngine.getCurrentPageText();
    
    state = state.copyWith(
      totalPages: totalPages,
      currentPageText: pageText,
    );
  }

  /// 翻到下一页
  void nextPage() {
    final moved = _readEngine.nextPage();
    if (moved) {
      final pageText = _readEngine.getCurrentPageText();
      state = state.copyWith(
        currentPageIndex: _readEngine.currentPage - 1,
        currentPageText: pageText,
      );
    } else {
      nextChapter();
    }
  }

  /// 翻到上一页
  void previousPage() {
    final moved = _readEngine.previousPage();
    if (moved) {
      final pageText = _readEngine.getCurrentPageText();
      state = state.copyWith(
        currentPageIndex: _readEngine.currentPage - 1,
        currentPageText: pageText,
      );
    } else {
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
    final nextIndex = (state.theme.themeIndex + 1) % ReaderTheme.presets.length;
    state = state.copyWith(readerTheme: ReaderTheme.presets[nextIndex]);
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

  /// 增大段距
  void increaseParagraphSpacing() {
    final newConfig = state.layoutConfig.copyWith(
      paragraphSpacing: (state.layoutConfig.paragraphSpacing + 0.1).clamp(0.0, 2.0),
    );
    updateLayoutConfig(newConfig);
  }

  /// 减小段距
  void decreaseParagraphSpacing() {
    final newConfig = state.layoutConfig.copyWith(
      paragraphSpacing: (state.layoutConfig.paragraphSpacing - 0.1).clamp(0.0, 2.0),
    );
    updateLayoutConfig(newConfig);
  }
}
