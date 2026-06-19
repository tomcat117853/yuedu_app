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
      layoutConfig: config,
      totalPages: totalPages,
      currentPage: currentPage,
      currentPageText: pageText,
    );
  }

  Future<void> nextPage() async {
    if (state.currentPage >= state.totalPages - 1) {
      await nextChapter();
      return;
    }

    final nextPage = state.currentPage + 1;
    final pageText = _readEngine.getPageText(nextPage);

    state = state.copyWith(
      currentPage: nextPage,
      currentPageText: pageText,
    );
  }

  Future<void> prevPage() async {
    if (state.currentPage <= 0) {
      await prevChapter();
      return;
    }

    final prevPage = state.currentPage - 1;
    final pageText = _readEngine.getPageText(prevPage);

    state = state.copyWith(
      currentPage: prevPage,
      currentPageText: pageText,
    );
  }

  Future<void> nextChapter() async {
    if (state.currentChapterIndex >= state.chapters.length - 1) {
      return;
    }

    final nextChapterIndex = state.currentChapterIndex + 1;
    final chapter = state.chapters[nextChapterIndex];

    await _readEngine.loadChapter(chapter.id);
    await _readEngine.updateLayoutConfig(state.layoutConfig);

    final totalPages = _readEngine.getTotalPages();
    final pageText = _readEngine.getPageText(0);

    state = state.copyWith(
      currentChapterIndex: nextChapterIndex,
      currentPage: 0,
      totalPages: totalPages,
      currentPageText: pageText,
    );
  }

  Future<void> prevChapter() async {
    if (state.currentChapterIndex <= 0) {
      return;
    }

    final prevChapterIndex = state.currentChapterIndex - 1;
    final chapter = state.chapters[prevChapterIndex];

    await _readEngine.loadChapter(chapter.id);
    await _readEngine.updateLayoutConfig(state.layoutConfig);

    final totalPages = _readEngine.getTotalPages();
    final pageText = _readEngine.getPageText(totalPages - 1);

    state = state.copyWith(
      currentChapterIndex: prevChapterIndex,
      currentPage: totalPages - 1,
      totalPages: totalPages,
      currentPageText: pageText,
    );
  }

  Future<void> jumpToChapter(int index) async {
    if (index < 0 || index >= state.chapters.length) {
      return;
    }

    final chapter = state.chapters[index];
    await _readEngine.loadChapter(chapter.id);
    await _readEngine.updateLayoutConfig(state.layoutConfig);

    final totalPages = _readEngine.getTotalPages();
    final pageText = _readEngine.getPageText(0);

    state = state.copyWith(
      currentChapterIndex: index,
      currentPage: 0,
      totalPages: totalPages,
      currentPageText: pageText,
    );
  }

  Future<void> jumpToPage(int page) async {
    if (page < 0 || page >= state.totalPages) {
      return;
    }

    final pageText = _readEngine.getPageText(page);
    state = state.copyWith(
      currentPage: page,
      currentPageText: pageText,
    );
  }

  Future<ReadProgress> getProgress() async {
    final bookId = state.chapters.isNotEmpty ? state.chapters[0].bookId : '';
    return ReadProgress(
      bookId: bookId,
      chapterIndex: state.currentChapterIndex,
      pageIndex: state.currentPage,
      totalPages: state.totalPages,
      lastReadTime: DateTime.now(),
    );
  }

  Future<void> saveProgress() async {
    final progress = await getProgress();
    await _readEngine.saveProgress(progress);
  }
}

class ReaderState {
  final List<Chapter> chapters;
  final int currentChapterIndex;
  final int currentPage;
  final int totalPages;
  final String currentPageText;
  final LayoutConfig layoutConfig;
  final ReaderTheme theme;
  final bool isLoading;

  ReaderState({
    required this.chapters,
    required this.currentChapterIndex,
    required this.currentPage,
    required this.totalPages,
    required this.currentPageText,
    required this.layoutConfig,
    required this.theme,
    required this.isLoading,
  });

  ReaderState copyWith({
    List<Chapter>? chapters,
    int? currentChapterIndex,
    int? currentPage,
    int? totalPages,
    String? currentPageText,
    LayoutConfig? layoutConfig,
    ReaderTheme? theme,
    bool? isLoading,
  }) {
    return ReaderState(
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      currentPageText: currentPageText ?? this.currentPageText,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      theme: theme ?? this.theme,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}