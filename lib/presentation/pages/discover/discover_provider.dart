import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/book_source_protocol.dart';
import '../../../domain/models/search_result.dart';
import '../../../domain/models/source_definition.dart';
import '../../../domain/models/book.dart';
import '../../../domain/models/chapter.dart';
import '../../../domain/engine/source_engine.dart';
import '../../../providers.dart';

/// 搜索结果聚合项（可能来自多个书源）
class AggregatedResult {
  final String title;
  final String author;
  final String? coverUrl;
  final String? intro;
  final String? category;
  final List<SearchResult> sources;

  AggregatedResult({
    required this.title,
    required this.author,
    this.coverUrl,
    this.intro,
    this.category,
    required this.sources,
  });

  String get bestBookKey =>
      sources.isNotEmpty ? sources.first.bookKey : '';
  String get bestSourceId =>
      sources.isNotEmpty ? sources.first.sourceId : '';
  String get bestSourceName =>
      sources.isNotEmpty ? sources.first.sourceName : '';
}

/// 发现页状态
class DiscoverState {
  final bool isLoading;
  final bool isSearching;
  final String searchQuery;
  final List<AggregatedResult> searchResults;
  final List<SearchResult> recommendations;
  final String? error;

  DiscoverState({
    this.isLoading = false,
    this.isSearching = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.recommendations = const [],
    this.error,
  });

  DiscoverState copyWith({
    bool? isLoading,
    bool? isSearching,
    String? searchQuery,
    List<AggregatedResult>? searchResults,
    List<SearchResult>? recommendations,
    String? error,
  }) {
    return DiscoverState(
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      recommendations: recommendations ?? this.recommendations,
      error: error,
    );
  }
}

/// 发现页状态管理
class DiscoverNotifier extends StateNotifier<DiscoverState> {
  final Ref _ref;

  DiscoverNotifier(this._ref) : super(DiscoverState());

  SourceEngine get _engine => _ref.read(sourceEngineProvider);
  List<SourceDefinition> get _definitions =>
      _ref.read(sourceDefinitionsProvider);

  /// 执行搜索
  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(
      isSearching: true,
      searchQuery: query,
      error: null,
    );

    try {
      final enabledDefs =
          _definitions.where((d) => d.enabled && d.searchUrl.isNotEmpty);
      if (enabledDefs.isEmpty) {
        state = state.copyWith(
          isSearching: false,
          searchResults: [],
          error: '没有可用的书源',
        );
        return;
      }

      // 并发搜索所有启用的书源
      final futures = enabledDefs.map((def) async {
        try {
          return await _engine.executeSearch(def, query);
        } catch (e) {
          debugPrint('[Discover] 搜索书源 ${def.bookSourceName} 失败: $e');
          return <SearchResult>[];
        }
      });

      final allResults = await Future.wait(futures);
      final flatResults = allResults.expand((r) => r).toList();

      // 聚合去重（按标题+作者归组）
      final aggregated = _aggregateResults(flatResults);

      if (mounted) {
        state = state.copyWith(
          isSearching: false,
          searchResults: aggregated,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isSearching: false,
          error: '搜索失败: $e',
        );
      }
    }
  }

  /// 聚合搜索结果（按标题+作者归组）
  List<AggregatedResult> _aggregateResults(List<SearchResult> results) {
    final groups = <String, List<SearchResult>>{};

    for (final result in results) {
      final key = '${_normalize(result.title)}|${_normalize(result.author)}';
      groups.putIfAbsent(key, () => []).add(result);
    }

    return groups.values.map((group) {
      final first = group.first;
      return AggregatedResult(
        title: first.title,
        author: first.author,
        coverUrl: group
            .map((r) => r.coverUrl)
            .firstWhere((c) => c != null && c.isNotEmpty, orElse: () => null),
        intro: first.intro,
        category: first.category,
        sources: group,
      );
    }).toList();
  }

  String _normalize(String text) {
    return text
        .replaceAll(RegExp(r'[\s\u3000]+'), '')
        .toLowerCase()
        .trim();
  }

  /// 获取书籍详情（通过 SourceEngine）
  Future<BookDetail?> getBookDetail(
    SourceDefinition sourceDef,
    String bookKey,
  ) async {
    try {
      return await _engine.executeDetail(sourceDef, bookKey);
    } catch (e) {
      debugPrint('[Discover] 获取详情失败: $e');
      return null;
    }
  }

  /// 获取章节列表
  Future<List<ChapterInfo>> getChapterList(
    SourceDefinition sourceDef,
    String bookKey,
  ) async {
    try {
      return await _engine.executeChapterList(sourceDef, bookKey);
    } catch (e) {
      debugPrint('[Discover] 获取章节列表失败: $e');
      return [];
    }
  }

  /// 加入书架
  Future<Book> addToBookshelf({
    required BookDetail detail,
    required SourceDefinition sourceDef,
    required List<ChapterInfo> chapters,
  }) async {
    final bookRepository = _ref.read(bookRepositoryProvider);
    final sourceRepository = _ref.read(sourceRepositoryProvider);

    // 创建书籍
    final book = Book(
      id: bookRepository.generateId(),
      title: detail.title,
      author: detail.author,
      coverPath: detail.coverUrl,
      intro: detail.intro,
      category: detail.category,
      type: 'online',
      format: 'online',
      totalChapters: chapters.length,
      wordCount: int.tryParse(detail.wordCount ?? '') ?? 0,
    );

    await bookRepository.insertBook(book);

    // 创建章节记录
    final chapterModels = chapters
        .map((ci) => Chapter(
              id: bookRepository.generateId(),
              bookId: book.id,
              sourceId: sourceDef.id,
              chapterKey: ci.chapterKey,
              title: ci.title,
              orderIndex: ci.orderIndex,
              isVip: ci.isVip,
            ))
        .toList();

    await bookRepository.insertChapters(chapterModels);

    // 关联书源
    final bookSource = await _ref.read(sourceServiceProvider).addSource(
          bookId: book.id,
          sourceId: sourceDef.id,
          sourceName: sourceDef.bookSourceName,
          bookKey: detail.bookKey,
          isPrimary: true,
        );

    return book;
  }

  /// 清空搜索结果
  void clearSearch() {
    state = state.copyWith(
      searchQuery: '',
      searchResults: [],
      error: null,
    );
  }

  /// 获取推荐（使用书源的 discover 或空关键词搜索）
  Future<void> loadRecommendations() async {
    state = state.copyWith(isLoading: true);

    try {
      final enabledDefs = _definitions
          .where((d) => d.enabled && d.searchUrl.isNotEmpty)
          .take(3);

      final allResults = <SearchResult>[];
      for (final def in enabledDefs) {
        try {
          final results = await _engine.executeSearch(def, '', page: 1);
          allResults.addAll(results.take(10));
        } catch (_) {}
      }

      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          recommendations: allResults.take(20).toList(),
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

/// 发现页 Provider
final discoverProvider =
    StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  return DiscoverNotifier(ref);
});
