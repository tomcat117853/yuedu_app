import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/source_repository.dart';
import '../models/source_definition.dart';
import '../engine/source_engine.dart';
import '../../platform/file_service.dart';

class ChapterCacheService {
  final FileService fileService;
  final BookRepository bookRepository;
  final SourceEngine sourceEngine;
  final SourceRepository sourceRepository;
  static const int maxCachedChapters = 50;
  static const int preloadCount = 2;
  final Map<String, DateTime> _cacheIndex = {};
  final Set<String> _activePreloads = {};

  ChapterCacheService({required this.fileService, required this.bookRepository, required this.sourceEngine, required this.sourceRepository});

  void triggerPreload(String bookId, int currentChapterIndex, int totalChapters, {List<SourceDefinition>? sourceDefinitions}) {
    for (int i = 1; i <= preloadCount; i++) {
      final targetIndex = currentChapterIndex + i;
      if (targetIndex >= totalChapters) break;
      final cacheKey = '${bookId}_$targetIndex';
      if (_cacheIndex.containsKey(cacheKey)) continue;
      if (_activePreloads.contains(cacheKey)) continue;
      _activePreloads.add(cacheKey);
      _preloadChapter(bookId, targetIndex, sourceDefinitions: sourceDefinitions).whenComplete(() { _activePreloads.remove(cacheKey); });
    }
  }

  Future<void> _preloadChapter(String bookId, int chapterIndex, {List<SourceDefinition>? sourceDefinitions}) async {
    try {
      final cached = await fileService.readChapterContent(bookId, chapterIndex);
      if (cached != null && cached.isNotEmpty) { _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now(); return; }
      final chapters = await bookRepository.getChaptersByBookId(bookId);
      if (chapterIndex >= chapters.length) return;
      final chapter = chapters[chapterIndex];
      if (chapter.chapterKey.isEmpty) return;
      final sourceDef = _findSourceDefinition(chapter.sourceId, sourceDefinitions);
      if (sourceDef == null) return;
      final bookSource = await _getBookSourceForBook(bookId, sourceDef.id);
      if (bookSource == null) return;
      final content = await sourceEngine.executeContent(sourceDef, bookSource.bookKey, chapter.chapterKey);
      final plainText = content.plainText;
      if (plainText.isNotEmpty) { await fileService.saveChapterContent(bookId, chapterIndex, plainText); _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now(); final updatedChapter = chapter.copyWith(isCached: true, contentPath: '$bookId/$chapterIndex', wordCount: plainText.length); await bookRepository.updateChapter(updatedChapter); await _enforceCacheLimit(bookId); }
    } catch (e) { debugPrint('[ChapterCache] 预加载章节 $chapterIndex 失败: $e'); }
  }

  Future<String?> getChapterContent(String bookId, int chapterIndex) async { final content = await fileService.readChapterContent(bookId, chapterIndex); if (content != null && content.isNotEmpty) { _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now(); return content; } return null; }

  Future<String> fetchAndCacheContent(String bookId, int chapterIndex, String bookKey, String chapterKey, SourceDefinition sourceDef) async {
    final cached = await fileService.readChapterContent(bookId, chapterIndex);
    if (cached != null && cached.isNotEmpty) { _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now(); return cached; }
    final content = await sourceEngine.executeContent(sourceDef, bookKey, chapterKey);
    final plainText = content.plainText;
    if (plainText.isNotEmpty) { await fileService.saveChapterContent(bookId, chapterIndex, plainText); _cacheIndex['${bookId}_$chapterIndex'] = DateTime.now(); await _enforceCacheLimit(bookId); }
    return plainText;
  }

  Future<void> _enforceCacheLimit(String bookId) async {
    final bookEntries = _cacheIndex.entries.where((e) => e.key.startsWith('${bookId}_')).toList()..sort((a, b) => a.value.compareTo(b.value));
    while (bookEntries.length > maxCachedChapters) { final oldest = bookEntries.removeAt(0); _cacheIndex.remove(oldest.key); }
  }

  Future<int> getCacheSize() async { try { final cacheDir = await fileService.getCacheDirectory(); return await fileService.getDirectorySize('$cacheDir/chapters'); } catch (e) { return 0; }}
  Future<void> clearCache() async { _cacheIndex.clear(); await fileService.clearCache(); }
  Future<void> clearBookCache(String bookId) async { _cacheIndex.removeWhere((key, _) => key.startsWith('${bookId}_')); final cacheDir = await fileService.getCacheDirectory(); final bookCacheDir = '$cacheDir/chapters/$bookId'; try { final dir = Directory(bookCacheDir); if (await dir.exists()) await dir.delete(recursive: true); } catch (_) {} }

  SourceDefinition? _findSourceDefinition(String sourceId, List<SourceDefinition>? definitions) { if (definitions == null) return null; for (final def in definitions) { if (def.id == sourceId) return def; } return null; }
  Future<dynamic> _getBookSourceForBook(String bookId, String sourceId) async { try { final sources = await sourceRepository.getSourcesByBookId(bookId); for (final s in sources) { if (s.sourceId == sourceId) return s; } return sources.isNotEmpty ? sources.first : null; } catch (_) { return null; }}
}