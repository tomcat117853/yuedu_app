import 'package:flutter/foundation.dart';
import '../models/book_source.dart';
import '../models/search_result.dart';
import '../models/source_definition.dart';
import '../engine/source_engine.dart';
import '../engine/source_matcher.dart';
import '../../data/repositories/source_repository.dart';

class SourceService {
  final SourceRepository _sourceRepository;
  final SourceEngine? _engine;
  final SourceMatcher? _matcher;

  SourceService(this._sourceRepository, {SourceEngine? engine, SourceMatcher? matcher}) : _engine = engine, _matcher = matcher;

  Future<List<BookSource>> getEnabledSources(String bookId) async { final sources = await _sourceRepository.getSourcesByBookId(bookId); return sources.where((s) => s.enabled).toList(); }

  Future<BookSource?> getPrimarySource(String bookId) async {
    final sources = await _sourceRepository.getSourcesByBookId(bookId);
    for (final source in sources) { if (source.isPrimary && source.enabled) return source; }
    final enabled = sources.where((s) => s.enabled).toList();
    if (enabled.isEmpty) return null;
    enabled.sort((a, b) => b.confidence.compareTo(a.confidence));
    return enabled.first;
  }

  Future<BookSource> addSource({required String bookId, required String sourceId, required String sourceName, required String bookKey, bool isPrimary = false}) async {
    final source = BookSource(id: _sourceRepository.generateId(), bookId: bookId, sourceId: sourceId, sourceName: sourceName, bookKey: bookKey, isPrimary: isPrimary);
    await _sourceRepository.insertSource(source);
    return source;
  }

  Future<void> deleteSource(String sourceId) => _sourceRepository.deleteSource(sourceId);
  Future<void> updateSource(BookSource source) => _sourceRepository.updateSource(source);

  Future<void> setPrimarySource(String bookId, String sourceId) async {
    final sources = await _sourceRepository.getSourcesByBookId(bookId);
    for (final source in sources) { await _sourceRepository.updateSource(source.copyWith(isPrimary: source.id == sourceId)); }
  }

  Future<void> updateConfidence(String sourceId, double confidence) async {
    final source = await _sourceRepository.getSourceById(sourceId);
    if (source != null) { await _sourceRepository.updateSource(source.copyWith(confidence: confidence, lastCheck: DateTime.now())); }
  }

  Future<List<SearchResult>> searchBook(String query, {List<SourceDefinition>? sourceDefinitions}) async {
    if (_engine == null) return [];
    final definitions = sourceDefinitions ?? [];
    final allResults = <SearchResult>[];
    final futures = definitions.where((d) => d.enabled && d.searchUrl.isNotEmpty).map((def) async { try { return await _engine!.executeSearch(def, query); } catch (e) { debugPrint('[SourceService] 搜索书源 ${def.bookSourceName} 失败: $e'); return <SearchResult>[]; }});
    final resultList = await Future.wait(futures);
    for (final results in resultList) { allResults.addAll(results); }
    final seen = <String>{}; final deduplicated = <SearchResult>[];
    for (final r in allResults) { if (r.bookKey.isNotEmpty && seen.add(r.bookKey)) { deduplicated.add(r); } else if (r.bookKey.isEmpty) { deduplicated.add(r); }}
    return deduplicated;
  }

  Future<List<BookSource>> getSourcesByBookId(String bookId) => _sourceRepository.getSourcesByBookId(bookId);

  Future<bool> checkSourceAvailability(String sourceId, {SourceDefinition? definition}) async {
    final source = await _sourceRepository.getSourceById(sourceId);
    if (source == null) return false;
    if (_engine != null && definition != null) { try { final isAvailable = await _engine!.executeHealthCheck(definition); await _sourceRepository.updateSource(source.copyWith(lastAvailable: isAvailable ? DateTime.now() : source.lastAvailable, lastCheck: DateTime.now(), confidence: isAvailable ? (source.confidence + 0.1).clamp(0.0, 1.0) : (source.confidence - 0.1).clamp(0.0, 1.0))); return isAvailable; } catch (_) { return false; }}
    return source.enabled;
  }

  Future<BookSource?> selectBestSource(String bookId) async {
    final sources = await getEnabledSources(bookId);
    if (sources.isEmpty) return null;
    for (final source in sources) { source.score = _calculateCompositeScore(source); }
    sources.sort((a, b) => b.score.compareTo(a.score));
    final best = sources.first;
    if (best.score < 0.5 && best.lastCheck != null && best.confidence < 0.3) { if (sources.length > 1) return sources[1]; }
    return best;
  }

  double _calculateCompositeScore(BookSource source) {
    final confidenceScore = source.confidence;
    final chapterScore = source.chapterCount > 0 ? (source.chapterCount / 100).clamp(0.0, 1.0) : 0.5;
    double freshnessScore = 0.5;
    if (source.lastCheck != null) { final hoursSinceCheck = DateTime.now().difference(source.lastCheck!).inHours; freshnessScore = (1.0 - hoursSinceCheck / 168).clamp(0.0, 1.0); }
    double responseScore = 0.5;
    if (source.lastAvailable != null) { final hoursSinceAvailable = DateTime.now().difference(source.lastAvailable!).inHours; responseScore = (1.0 - hoursSinceAvailable / 168).clamp(0.0, 1.0); }
    final successScore = source.confidence * 0.7 + (source.lastAvailable != null ? 0.3 : 0.0);
    return (confidenceScore * 0.30 + chapterScore * 0.25 + freshnessScore * 0.20 + responseScore * 0.15 + successScore * 0.10).clamp(0.0, 1.0);
  }

  Future<List<BookSource>> getAllSources() => _sourceRepository.getAllSources();
}