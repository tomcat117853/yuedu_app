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

class ReadEngine {
  final BookRepository _bookRepository;
  int _readMode = 0;
  int get readMode => _readMode;
  set readMode(int mode) => _readMode = mode;
  LayoutConfig _layoutConfig = LayoutConfig.defaultConfig;
  LayoutConfig get layoutConfig => _layoutConfig;
  String? _currentBookId;
  int _currentChapterIndex = 0;
  int _currentPageIndex = 0;
  double _scrollOffset = 0.0;
  ChapterContent? _currentContent;
  List<PageRange> _pageRanges = [];
  final TextLayout _textLayout = TextLayout();
  final ChapterMapper _chapterMapper = ChapterMapper();
  void Function(ReadProgress)? onProgressChanged;
  void Function(ChapterContent)? onChapterLoaded;
  void Function(List<PageRange>)? onPaginationComplete;

  ReadEngine(this._bookRepository);

  Future<void> initReading(String bookId, {LayoutConfig? config}) async {
    _currentBookId = bookId;
    if (config != null) _layoutConfig = config;
    final progress = await _bookRepository.getReadProgress(bookId);
    if (progress != null) { _currentChapterIndex = progress.chapterIndex; _currentPageIndex = progress.pageIndex; _scrollOffset = progress.scrollOffset; }
    await loadChapter(_currentChapterIndex);
  }

  Future<void> loadChapter(int chapterIndex) async {
    if (_currentBookId == null) return;
    _currentChapterIndex = chapterIndex;
    _currentPageIndex = 0;
    _scrollOffset = 0.0;
    try { _currentContent = await _bookRepository.getChapterContent(_currentBookId!, chapterIndex); onChapterLoaded?.call(_currentContent!); await paginate(); } catch (e) { debugPrint('加载章节失败: $e'); }
  }

  Future<void> paginate() async {
    if (_currentContent == null) return;
    final content = _currentContent!.plainText;
    final config = _layoutConfig;
    try { if (content.length > 100000) { _pageRanges = await _paginateInIsolate(content, config); } else { _pageRanges = _textLayout.calculatePages(text: content, config: config); } onPaginationComplete?.call(_pageRanges); } catch (e) { debugPrint('分页计算失败: $e'); _pageRanges = []; }
  }

  Future<List<PageRange>> _paginateInIsolate(String text, LayoutConfig config) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolatePaginationEntry, _PaginationMessage(text: text, fontSize: config.fontSize, lineHeight: config.lineHeight, paragraphSpacing: config.paragraphSpacing, margin: config.margin, indentChars: config.indentChars, letterSpacing: config.letterSpacing, sendPort: receivePort.sendPort));
    return await receivePort.first as List<PageRange>;
  }

  static void _isolatePaginationEntry(_PaginationMessage message) {
    final layout = TextLayout();
    final config = LayoutConfig(fontSize: message.fontSize, lineHeight: message.lineHeight, paragraphSpacing: message.paragraphSpacing, margin: message.margin, indentChars: message.indentChars, letterSpacing: message.letterSpacing);
    final pages = layout.calculatePages(text: message.text, config: config);
    message.sendPort.send(pages);
  }

  bool nextPage() { if (_readMode != 0) return false; if (_currentPageIndex < _pageRanges.length - 1) { _currentPageIndex++; _saveProgress(); return true; } return false; }
  bool previousPage() { if (_readMode != 0) return false; if (_currentPageIndex > 0) { _currentPageIndex--; _saveProgress(); return true; } return false; }
  void jumpToPage(int pageIndex) { if (pageIndex >= 0 && pageIndex < _pageRanges.length) { _currentPageIndex = pageIndex; _saveProgress(); } }
  Future<void> jumpToChapter(int chapterIndex) async => await loadChapter(chapterIndex);
  String getCurrentPageText() { if (_pageRanges.isEmpty || _currentPageIndex >= _pageRanges.length) return ''; final range = _pageRanges[_currentPageIndex]; return _currentContent?.getTextRange(range.start, range.end) ?? ''; }
  int get totalPages => _pageRanges.length;
  int get currentPage => _currentPageIndex + 1;
  int get currentChapterIndex => _currentChapterIndex;
  int get totalChapters => _chapterMapper.totalChapters;
  Future<void> updateLayoutConfig(LayoutConfig config) async { _layoutConfig = config; await paginate(); }
  void updateReadMode(int mode) => _readMode = mode;

  Future<void> _saveProgress() async {
    if (_currentBookId == null) return;
    final totalChars = _currentContent?.plainText.length ?? 0;
    final progressPercent = totalChars > 0 ? (_currentPageIndex / _pageRanges.length * 100).clamp(0.0, 100.0) : 0.0;
    final progress = ReadProgress(bookId: _currentBookId!, chapterIndex: _currentChapterIndex, pageIndex: _currentPageIndex, charOffset: _pageRanges.isNotEmpty && _currentPageIndex < _pageRanges.length ? _pageRanges[_currentPageIndex].start : 0, scrollOffset: _scrollOffset, progressPercent: progressPercent);
    await _bookRepository.saveReadProgress(progress);
    onProgressChanged?.call(progress);
  }

  void dispose() { _currentContent = null; _pageRanges.clear(); }
}

class _PaginationMessage {
  final String text;
  final double fontSize, lineHeight, paragraphSpacing, margin, letterSpacing;
  final int indentChars;
  final SendPort sendPort;
  _PaginationMessage({required this.text, required this.fontSize, required this.lineHeight, required this.paragraphSpacing, required this.margin, required this.indentChars, required this.letterSpacing, required this.sendPort});
}