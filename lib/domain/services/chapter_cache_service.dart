import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/source_repository.dart';
import '../../domain/models/source_definition.dart';
import '../engine/source_engine.dart';
import '../../domain/models/book_source.dart';
import '../../platform/file_service.dart';

/// 章节缓存服务 - 预加载和缓存章节内容
class ChapterCacheService {
  final FileService fileService;
  final BookRepository bookRepository;
  final SourceEngine sourceEngine;
  final SourceRepository sourceRepository;

  /// 缓存上限（章数）
  static const int maxCachedChapters = 50;

  /// 预加载数量（当前章之后的N章）
  static const int preloadCount = 2;

  /// 已缓存章节 LRU 记录（bookId_chapterIndex -> 访问时间）
  final Map<String, DateTime> _cacheIndex = {};

  /// 正在预加载的任务
  final Set<String> _activePreloads = {};

  ChapterCacheService({
    required this.fileService,
    required this.bookRepository,
    required this.sourceEngine,
    required this.sourceRepository,
  });

  /// 触发预加载（读到第 N 章时，后台预加载 N+1、N+2）
  void triggerPreload(
    String bookId,
    int currentChapterIndex,
    int totalChapters, {
    List<SourceDefinition>? sourceDefinitions,
  }) {
    for (int i = 1; i <= preloadCount; i++) {
      final targetIndex = currentChapterIndex + i;
      if (targetIndex >= totalChapters) break;

      final cacheKey = '${bookId}_$targetIndex';
      if (_cacheIndex.containsKey(cacheKey)) continue;
      if (_activePreloads.contains(cacheKey)) continue;

      _activePreloads.add(cacheKey);
      _preloadChapter(
        bookId,
        targetIndex,
        sourceDefinitions: sourceDefinitions,
      ).whenComplete(() {
        _activePreloads.remove(cacheKey);
      });
    }
  }

  /// 预加载单个章节
  Future<void> _preloadChapter(
    String bookId,
    int chapterIndex, {
    List<SourceDefinition>? sourceDefinitions,
  }) async {
    try {
      // 先检查文件缓存是否已存在
      final cached = await fileService.readChapterContent(bookId, chapterIndex);
      if (cached != null && cached.isNotEmpty) {
        _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now();
        return;
      }

      // 获取章节的 sourceId 和 chapterKey
      final chapters = await bookRepository.getChaptersByBookId(bookId);
      if (chapterIndex >= chapters.length) return;

      final chapter = chapters[chapterIndex];
      if (chapter.chapterKey.isEmpty) return;
      final sourceId = chapter.sourceId;
      if (sourceId == null || sourceId.isEmpty) return;

      // 获取书源定义
      final sourceDef = _findSourceDefinition(
        sourceId,
        sourceDefinitions,
      );
      if (sourceDef == null) return;

      // 获取书籍的 bookKey
      final bookSource = await _getBookSourceForBook(bookId, sourceDef.id);
      if (bookSource == null) return;
      final bookKey = bookSource.bookKey as String?;
      if (bookKey == null || bookKey.isEmpty) return;

      // 通过 SourceEngine 获取章节内容
      final content = await sourceEngine.executeContent(
        sourceDef,
        bookKey,
        chapter.chapterKey,
      );

      // 保存到文件缓存
      final plainText = content.content;
      if (plainText.isNotEmpty) {
        await fileService.saveChapterContent(bookId, chapterIndex, plainText);
        _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now();

        // 更新章节的缓存标记
        final updatedChapter = chapter.copyWith(
          isCached: true,
          contentPath: '$bookId/$chapterIndex',
          wordCount: plainText.length,
        );
        await bookRepository.updateChapter(updatedChapter);

        // LRU 淘汰
        await _enforceCacheLimit(bookId);
      }
    } catch (e) {
      debugPrint('[ChapterCache] 预加载章节 $chapterIndex 失败: $e');
    }
  }

  /// 获取章节内容（优先从缓存读取）
  Future<String?> getChapterContent(
    String bookId,
    int chapterIndex,
  ) async {
    final content = await fileService.readChapterContent(bookId, chapterIndex);
    if (content != null && content.isNotEmpty) {
      _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now();
      return content;
    }
    return null;
  }

  /// 强制缓存章节内容（在线书籍加载时调用）
  Future<String> fetchAndCacheContent(
    String bookId,
    int chapterIndex,
    String bookKey,
    String chapterKey,
    SourceDefinition sourceDef,
  ) async {
    // 先检查文件缓存
    final cached = await fileService.readChapterContent(bookId, chapterIndex);
    if (cached != null && cached.isNotEmpty) {
      _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now();
      return cached;
    }

    // 从网络获取
    final content = await sourceEngine.executeContent(
      sourceDef,
      bookKey,
      chapterKey,
    );

    final plainText = content.content;
    if (plainText.isNotEmpty) {
      await fileService.saveChapterContent(bookId, chapterIndex, plainText);
      _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now();
      await _enforceCacheLimit(bookId);
    }

    return plainText;
  }

  /// LRU 淘汰：超过缓存上限时删除最旧的缓存
  Future<void> _enforceCacheLimit(String bookId) async {
    final bookEntries = _cacheIndex.entries
        .where((e) => e.key.startsWith('${bookId}_'))
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    while (bookEntries.length > maxCachedChapters) {
      final oldest = bookEntries.removeAt(0);
      final parts = oldest.key.split('_');
      if (parts.length >= 2) {
        final idx = int.tryParse(parts.last);
        if (idx != null) {
          _cacheIndex.remove(oldest.key);
          // 不删除文件，只是从索引中移除
        }
      }
    }
  }

  /// 获取缓存大小（字节）
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await fileService.getCacheDirectory();
      return await fileService.getDirectorySize('$cacheDir/chapters');
    } catch (e) {
      return 0;
    }
  }

  /// 清理所有缓存
  Future<void> clearCache() async {
    _cacheIndex.clear();
    await fileService.clearCache();
  }

  /// 清理指定书籍的缓存
  Future<void> clearBookCache(String bookId) async {
    _cacheIndex.removeWhere((key, _) => key.startsWith('${bookId}_'));
    final cacheDir = await fileService.getCacheDirectory();
    final bookCacheDir = '$cacheDir/chapters/$bookId';
    try {
      final dir = Directory(bookCacheDir);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {}
  }

  SourceDefinition? _findSourceDefinition(
    String sourceId,
    List<SourceDefinition>? definitions,
  ) {
    if (definitions == null) return null;
    for (final def in definitions) {
      if (def.id == sourceId) return def;
    }
    return null;
  }

  Future<BookSource?> _getBookSourceForBook(String bookId, String sourceId) async {
    try {
      final sources = await sourceRepository.getSourcesByBookId(bookId);
      for (final s in sources) {
        if (s.sourceId == sourceId) return s;
      }
      return sources.isNotEmpty ? sources.first : null;
    } catch (_) {
      return null;
    }
  }
}
