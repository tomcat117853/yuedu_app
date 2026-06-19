import 'package:flutter/foundation.dart';

import '../models/book_source_protocol.dart';
import '../models/search_result.dart';
import '../models/source_definition.dart';
import 'source_engine.dart';

/// 书源引擎适配器 - 将书源定义与源引擎结合，实现书源协议
///
/// 包装 [SourceDefinition] 和 [SourceEngine]，将所有 [BookSourceProtocol]
/// 的方法调用委托给 [SourceEngine] 执行。
class SourceEngineAdapter implements BookSourceProtocol {
  /// 书源定义
  final SourceDefinition definition;

  /// 源引擎实例
  final SourceEngine _engine;

  SourceEngineAdapter({
    required this.definition,
    required SourceEngine engine,
  }) : _engine = engine;

  @override
  String get id => definition.id;

  @override
  String get name => definition.bookSourceName;

  @override
  String get baseUrl => definition.bookSourceUrl;

  @override
  String get group => definition.bookSourceGroup;

  @override
  int get weight => definition.weight;

  @override
  bool get enabled => definition.enabled;

  /// 搜索书籍
  @override
  Future<List<SearchResult>> search({
    required String keyword,
    int page = 1,
  }) async {
    try {
      return await _engine.executeSearch(definition, keyword, page: page);
    } catch (e) {
      debugPrint('[SourceEngineAdapter] 搜索失败 ($name): $e');
      return [];
    }
  }

  /// 获取书籍详情
  @override
  Future<BookDetail> getDetail({required String bookKey}) async {
    return await _engine.executeDetail(definition, bookKey);
  }

  /// 获取章节列表
  @override
  Future<List<ChapterInfo>> getChapterList({
    required String bookKey,
  }) async {
    return await _engine.executeChapterList(definition, bookKey);
  }

  /// 获取章节内容
  @override
  Future<SourceChapterContent> getChapterContent({
    required String bookKey,
    required String chapterKey,
  }) async {
    return await _engine.executeContent(
      definition,
      bookKey,
      chapterKey,
    );
  }

  /// 发现书籍（浏览/推荐）
  ///
  /// 如果书源定义支持发现功能（searchUrl 为空关键词可用），
  /// 则使用搜索功能进行发现。否则返回空列表。
  @override
  Future<List<SearchResult>> discover({int page = 1}) async {
    try {
      // 尝试使用空关键词搜索作为发现功能
      if (definition.searchUrl.isNotEmpty) {
        return await _engine.executeSearch(definition, '', page: page);
      }
      return [];
    } catch (e) {
      debugPrint('[SourceEngineAdapter] 发现失败 ($name): $e');
      return [];
    }
  }

  /// 健康检查
  @override
  Future<bool> healthCheck() async {
    return await _engine.executeHealthCheck(definition);
  }

  @override
  String toString() =>
      'SourceEngineAdapter(name: $name, url: $baseUrl, enabled: $enabled)';
}
