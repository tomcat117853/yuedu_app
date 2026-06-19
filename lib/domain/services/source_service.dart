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

  SourceService(
    this._sourceRepository, {
    SourceEngine? engine,
    SourceMatcher? matcher,
  })  : _engine = engine,
        _matcher = matcher;

  Future<List<BookSource>> getEnabledSources(String bookId) async { final sources = await _sourceRepository.getSourcesByBookId(bookId); return sources.where((s) => s.enabled).toList(); }

  Future<BookSource?> getPrimarySource(String bookId) async {
    final sources = await _sourceRepository.getSourcesByBookId(bookId);
    for (final source in sources) {
      if (source.isPrimary && source.enabled) return source;
    }
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

  /// 搜索书籍（通过所有可用的 SourceDefinition）
  ///
  /// 使用 SourceEngine 对每个启用的书源定义执行搜索，
  /// 然后通过 SourceMatcher 对结果进行匹配评分。
  Future<List<SearchResult>> searchBook(
    String query, {
    List<SourceDefinition>? sourceDefinitions,
  }) async {
    if (_engine == null) return [];

    final definitions = sourceDefinitions ?? [];
    final allResults = <SearchResult>[];

    // 并发搜索所有启用的书源
    final futures = definitions
        .where((d) => d.enabled && d.searchUrl.isNotEmpty)
        .map((def) async {
      try {
        final results = await _engine.executeSearch(def, query);
        return results;
      } catch (e) {
        debugPrint('[SourceService] 搜索书源 ${def.bookSourceName} 失败: $e');
        return <SearchResult>[];
      }
    });

    final resultList = await Future.wait(futures);
    for (final results in resultList) {
      allResults.addAll(results);
    }

    // 去重（按 bookKey）
    final seen = <String>{};
    final deduplicated = <SearchResult>[];
    for (final r in allResults) {
      if (r.bookKey.isNotEmpty && seen.add(r.bookKey)) {
        deduplicated.add(r);
      } else if (r.bookKey.isEmpty) {
        deduplicated.add(r);
      }
    }

    return deduplicated;
  }

  Future<List<BookSource>> getSourcesByBookId(String bookId) => _sourceRepository.getSourcesByBookId(bookId);

  /// 检查书源可用性（通过 SourceEngine 健康检查）
  Future<bool> checkSourceAvailability(
    String sourceId, {
    SourceDefinition? definition,
  }) async {
    final source = await _sourceRepository.getSourceById(sourceId);
    if (source == null) return false;

    // 如果有 SourceEngine 和定义，使用引擎做真实检查
    if (_engine != null && definition != null) {
      try {
        final isAvailable = await _engine.executeHealthCheck(definition);
        await _sourceRepository.updateSource(
          source.copyWith(
            lastAvailable: isAvailable ? DateTime.now() : source.lastAvailable,
            lastCheck: DateTime.now(),
            confidence: isAvailable
                ? (source.confidence + 0.1).clamp(0.0, 1.0)
                : (source.confidence - 0.1).clamp(0.0, 1.0),
          ),
        );
        return isAvailable;
      } catch (_) {
        return false;
      }
    }

    // 回退：仅检查 enabled 状态
    return source.enabled;
  }

  /// 自动选择最佳书源（5 维度加权评分）
  Future<BookSource?> selectBestSource(String bookId) async {
    final sources = await getEnabledSources(bookId);
    if (sources.isEmpty) return null;

    // 计算综合评分
    for (final source in sources) {
      source.score = _calculateCompositeScore(source);
    }

    // 按综合评分排序
    sources.sort((a, b) => b.score.compareTo(a.score));

    // 自动降级：评分 < 0.5 且连续 3 次检查失败
    final best = sources.first;
    if (best.score < 0.5 &&
        best.lastCheck != null &&
        best.confidence < 0.3) {
      // 尝试切换到下一个可用书源
      if (sources.length > 1) {
        return sources[1];
      }
    }

    return best;
  }

  /// 5 维度加权评分算法
  ///
  /// - 匹配置信度 30%：书源匹配的历史置信度
  /// - 内容完整度 25%：章节数量是否充足
  /// - 检测时效 20%：最近一次检测的时间衰减
  /// - 响应速度 15%：基于最近可用时间推断
  /// - 成功率 10%：基于置信度和可用性历史
  double _calculateCompositeScore(BookSource source) {
    // 1. 匹配置信度 (30%)
    final confidenceScore = source.confidence;

    // 2. 内容完整度 (25%)
    final chapterScore = source.chapterCount > 0
        ? (source.chapterCount / 100).clamp(0.0, 1.0)
        : 0.5; // 未知时给中等分

    // 3. 检测时效 (20%)
    double freshnessScore = 0.5;
    if (source.lastCheck != null) {
      final hoursSinceCheck =
          DateTime.now().difference(source.lastCheck!).inHours;
      // 24小时内为满分，逐渐衰减
      freshnessScore = (1.0 - hoursSinceCheck / 168).clamp(0.0, 1.0);
    }

    // 4. 响应速度 (15%)
    double responseScore = 0.5;
    if (source.lastAvailable != null) {
      final hoursSinceAvailable =
          DateTime.now().difference(source.lastAvailable!).inHours;
      responseScore = (1.0 - hoursSinceAvailable / 168).clamp(0.0, 1.0);
    }

    // 5. 成功率 (10%)
    final successScore = source.confidence * 0.7 +
        (source.lastAvailable != null ? 0.3 : 0.0);

    // 加权计算
    final compositeScore = confidenceScore * 0.30 +
        chapterScore * 0.25 +
        freshnessScore * 0.20 +
        responseScore * 0.15 +
        successScore * 0.10;

    return compositeScore.clamp(0.0, 1.0);
  }

  /// 获取所有书源
  Future<List<BookSource>> getAllSources() async {
    return _sourceRepository.getAllSources();
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