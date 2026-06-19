import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import '../models/chapter_content.dart';
import '../models/layout_config.dart';
import '../models/read_progress.dart';
import '../engine/pagination_engine.dart';
import '../engine/text_layout.dart';
import '../engine/chapter_mapper.dart';
import '../../data/repositories/book_repository.dart';

/// 阅读引擎 - 核心阅读功能
class ReadEngine {
  final BookRepository _bookRepository;

  /// 当前阅读模式: 0=翻页, 1=滚动
  int _readMode = 0;
  int get readMode => _readMode;
  set readMode(int mode) {
    _readMode = mode;
  }

  /// 排版配置
  LayoutConfig _layoutConfig = LayoutConfig.defaultConfig;
  LayoutConfig get layoutConfig => _layoutConfig;

  /// 当前书籍ID
  String? _currentBookId;

  /// 当前章节索引
  int _currentChapterIndex = 0;

  /// 当前页索引（翻页模式）
  int _currentPageIndex = 0;

  /// 滚动偏移量（滚动模式）
  double _scrollOffset = 0.0;

  /// 当前章节内容
  ChapterContent? _currentContent;

  /// 分页结果
  List<PageRange> _pageRanges = [];

  /// 文本布局计算器
  final TextLayout _textLayout = TextLayout();

  /// 章节映射器
  final ChapterMapper _chapterMapper = ChapterMapper();

  /// 阅读进度更新回调
  void Function(ReadProgress)? onProgressChanged;

  /// 章节加载完成回调
  void Function(ChapterContent)? onChapterLoaded;

  /// 分页完成回调
  void Function(List<PageRange>)? onPaginationComplete;

  ReadEngine(this._bookRepository);

  /// 初始化阅读
  Future<void> initReading(String bookId, {LayoutConfig? config}) async {
    _currentBookId = bookId;
    if (config != null) {
      _layoutConfig = config;
    }

    // 恢复阅读进度
    final progress = await _bookRepository.getReadProgress(bookId);
    if (progress != null) {
      _currentChapterIndex = progress.chapterIndex;
      _currentPageIndex = progress.pageIndex;
      _scrollOffset = progress.scrollOffset;
    }

    // 加载章节内容
    await loadChapter(_currentChapterIndex);
  }

  /// 加载章节
  Future<void> loadChapter(int chapterIndex) async {
    if (_currentBookId == null) return;

    _currentChapterIndex = chapterIndex;
    _currentPageIndex = 0;
    _scrollOffset = 0.0;

    try {
      _currentContent =
          await _bookRepository.getChapterContent(_currentBookId!, chapterIndex);
      onChapterLoaded?.call(_currentContent!);

      // 执行分页
      await paginate();
    } catch (e) {
      debugPrint('加载章节失败: $e');
    }
  }

  /// 执行分页计算（在Isolate中）
  Future<void> paginate() async {
    if (_currentContent == null) return;

    final content = _currentContent!.plainText;
    final config = _layoutConfig;

    try {
      if (content.length > 100000) {
        // 大文本使用Isolate计算
        _pageRanges = await _paginateInIsolate(content, config);
      } else {
        // 小文本直接计算
        _pageRanges = _textLayout.calculatePages(
          text: content,
          config: config,
        );
      }
      onPaginationComplete?.call(_pageRanges);
    } catch (e) {
      debugPrint('分页计算失败: $e');
      _pageRanges = [];
    }
  }

  /// 在Isolate中执行分页计算
  Future<List<PageRange>> _paginateInIsolate(
    String text,
    LayoutConfig config,
  ) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _isolatePaginationEntry,
      _PaginationMessage(
        text: text,
        fontSize: config.fontSize,
        lineHeight: config.lineHeight,
        paragraphSpacing: config.paragraphSpacing,
        margin: config.margin,
        indentChars: config.indentChars,
        letterSpacing: config.letterSpacing,
        sendPort: receivePort.sendPort,
      ),
    );

    final result = await receivePort.first as List<PageRange>;
    return result;
  }

  /// Isolate入口函数
  static void _isolatePaginationEntry(_PaginationMessage message) {
    final layout = TextLayout();
    final config = LayoutConfig(
      fontSize: message.fontSize,
      lineHeight: message.lineHeight,
      paragraphSpacing: message.paragraphSpacing,
      margin: message.margin,
      indentChars: message.indentChars,
      letterSpacing: message.letterSpacing,
    );
    final pages = layout.calculatePages(text: message.text, config: config);
    message.sendPort.send(pages);
  }

  /// 翻到下一页
  bool nextPage() {
    if (_readMode != 0) return false;
    if (_currentPageIndex < _pageRanges.length - 1) {
      _currentPageIndex++;
      _saveProgress();
      return true;
    } else {
      // 下一章
      return false;
    }
  }

  /// 翻到上一页
  bool previousPage() {
    if (_readMode != 0) return false;
    if (_currentPageIndex > 0) {
      _currentPageIndex--;
      _saveProgress();
      return true;
    } else {
      return false;
    }
  }

  /// 跳转到指定页
  void jumpToPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _pageRanges.length) {
      _currentPageIndex = pageIndex;
      _saveProgress();
    }
  }

  /// 跳转到指定章节
  Future<void> jumpToChapter(int chapterIndex) async {
    await loadChapter(chapterIndex);
  }

  /// 获取当前页文本
  String getCurrentPageText() {
    if (_pageRanges.isEmpty || _currentPageIndex >= _pageRanges.length) {
      return '';
    }
    final range = _pageRanges[_currentPageIndex];
    return _currentContent?.getTextRange(range.start, range.end) ?? '';
  }

  /// 获取总页数
  int get totalPages => _pageRanges.length;

  /// 获取当前页码
  int get currentPage => _currentPageIndex + 1;

  /// 获取当前章节索引
  int get currentChapterIndex => _currentChapterIndex;

  /// 获取总章节数
  int get totalChapters => _chapterMapper.totalChapters;

  /// 更新排版配置
  Future<void> updateLayoutConfig(LayoutConfig config) async {
    _layoutConfig = config;
    await paginate();
  }

  /// 更新阅读模式
  void updateReadMode(int mode) {
    _readMode = mode;
  }

  /// 保存阅读进度
  Future<void> _saveProgress() async {
    if (_currentBookId == null) return;

    final totalChars = _currentContent?.plainText.length ?? 0;
    final progressPercent = totalChars > 0
        ? (_currentPageIndex / _pageRanges.length * 100).clamp(0.0, 100.0)
        : 0.0;

    final progress = ReadProgress(
      bookId: _currentBookId!,
      chapterIndex: _currentChapterIndex,
      pageIndex: _currentPageIndex,
      charOffset: _pageRanges.isNotEmpty && _currentPageIndex < _pageRanges.length
          ? _pageRanges[_currentPageIndex].start
          : 0,
      scrollOffset: _scrollOffset,
      progressPercent: progressPercent,
    );

    await _bookRepository.saveReadProgress(progress);
    onProgressChanged?.call(progress);
  }

  /// 释放资源
  void dispose() {
    _currentContent = null;
    _pageRanges.clear();
  }
}

/// Isolate通信消息
class _PaginationMessage {
  final String text;
  final double fontSize;
  final double lineHeight;
  final double paragraphSpacing;
  final double margin;
  final int indentChars;
  final double letterSpacing;
  final SendPort sendPort;

  _PaginationMessage({
    required this.text,
    required this.fontSize,
    required this.lineHeight,
    required this.paragraphSpacing,
    required this.margin,
    required this.indentChars,
    required this.letterSpacing,
    required this.sendPort,
  });
}
