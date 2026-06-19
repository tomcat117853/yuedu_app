import '../models/book_source.dart';
import '../models/search_result.dart';
import '../../data/repositories/source_repository.dart';

/// 书源服务 - 处理书源相关的业务逻辑
class SourceService {
  final SourceRepository _sourceRepository;

  SourceService(this._sourceRepository);

  /// 获取所有启用的书源
  Future<List<BookSource>> getEnabledSources(String bookId) async {
    final sources = await _sourceRepository.getSourcesByBookId(bookId);
    return sources.where((s) => s.enabled).toList();
  }

  /// 获取主要书源
  Future<BookSource?> getPrimarySource(String bookId) async {
    final sources = await _sourceRepository.getSourcesByBookId(bookId);
    for (final source in sources) {
      if (source.isPrimary && source.enabled) return source;
    }
    // 如果没有主要书源，返回置信度最高的
    final enabled = sources.where((s) => s.enabled).toList();
    if (enabled.isEmpty) return null;
    enabled.sort((a, b) => b.confidence.compareTo(a.confidence));
    return enabled.first;
  }

  /// 添加书源
  Future<BookSource> addSource({
    required String bookId,
    required String sourceId,
    required String sourceName,
    required String bookKey,
    bool isPrimary = false,
  }) async {
    final source = BookSource(
      id: _sourceRepository.generateId(),
      bookId: bookId,
      sourceId: sourceId,
      sourceName: sourceName,
      bookKey: bookKey,
      isPrimary: isPrimary,
    );
    await _sourceRepository.insertSource(source);
    return source;
  }

  /// 删除书源
  Future<void> deleteSource(String sourceId) async {
    await _sourceRepository.deleteSource(sourceId);
  }

  /// 更新书源信息
  Future<void> updateSource(BookSource source) async {
    await _sourceRepository.updateSource(source);
  }

  /// 设置主要书源
  Future<void> setPrimarySource(String bookId, String sourceId) async {
    final sources = await _sourceRepository.getSourcesByBookId(bookId);
    for (final source in sources) {
      await _sourceRepository.updateSource(
        source.copyWith(isPrimary: source.id == sourceId),
      );
    }
  }

  /// 更新书源置信度
  Future<void> updateConfidence(String sourceId, double confidence) async {
    final source = await _sourceRepository.getSourceById(sourceId);
    if (source != null) {
      await _sourceRepository.updateSource(
        source.copyWith(
          confidence: confidence,
          lastCheck: DateTime.now(),
        ),
      );
    }
  }

  /// 搜索书籍（通过所有可用书源）
  Future<List<SearchResult>> searchBook(String query) async {
    return _sourceRepository.searchBook(query);
  }

  /// 获取书源列表
  Future<List<BookSource>> getSourcesByBookId(String bookId) async {
    return _sourceRepository.getSourcesByBookId(bookId);
  }

  /// 检查书源可用性
  Future<bool> checkSourceAvailability(String sourceId) async {
    final source = await _sourceRepository.getSourceById(sourceId);
    if (source == null) return false;

    try {
      final isAvailable = await _sourceRepository.checkAvailability(source);
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

  /// 自动选择最佳书源
  Future<BookSource?> selectBestSource(String bookId) async {
    final sources = await getEnabledSources(bookId);
    if (sources.isEmpty) return null;

    // 按置信度排序，选择最高且最近可用的
    sources.sort((a, b) {
      final scoreCompare = b.confidence.compareTo(a.confidence);
      if (scoreCompare != 0) return scoreCompare;
      final aTime = a.lastAvailable ?? DateTime(2000);
      final bTime = b.lastAvailable ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });

    return sources.first;
  }
}
