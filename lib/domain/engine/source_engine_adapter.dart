import 'package:flutter/foundation.dart';
import '../models/book_source_protocol.dart';
import '../models/search_result.dart';
import 'source_engine.dart';

class SourceEngineAdapter implements BookSourceProtocol {
  final SourceDefinition definition;
  final SourceEngine _engine;

  SourceEngineAdapter({required this.definition, required SourceEngine engine}) : _engine = engine;

  @override String get id => definition.id;
  @override String get name => definition.bookSourceName;
  @override String get baseUrl => definition.bookSourceUrl;
  @override String get group => definition.bookSourceGroup;
  @override int get weight => definition.weight;
  @override bool get enabled => definition.enabled;

  @override Future<List<SearchResult>> search({required String keyword, int page = 1}) async {
    try { return await _engine.executeSearch(definition, keyword, page: page); }
    catch (e) { debugPrint('[SourceEngineAdapter] 搜索失败 ($name): $e'); return []; }
  }

  @override Future<BookDetail> getDetail({required String bookKey}) => _engine.executeDetail(definition, bookKey);

  @override Future<List<ChapterInfo>> getChapterList({required String bookKey}) => _engine.executeChapterList(definition, bookKey);

  @override Future<SourceChapterContent> getChapterContent({required String bookKey, required String chapterKey}) => _engine.executeContent(definition, bookKey, chapterKey);

  @override Future<List<SearchResult>> discover({int page = 1}) async {
    try { if (definition.searchUrl.isNotEmpty) return await _engine.executeSearch(definition, '', page: page); return []; }
    catch (e) { debugPrint('[SourceEngineAdapter] 发现失败 ($name): $e'); return []; }
  }

  @override Future<bool> healthCheck() => _engine.executeHealthCheck(definition);

  @override String toString() => 'SourceEngineAdapter(name: $name, url: $baseUrl, enabled: $enabled)';
}