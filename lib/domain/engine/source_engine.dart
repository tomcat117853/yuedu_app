import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../../config/constants.dart';
import '../models/book_source_protocol.dart';
import '../models/search_result.dart';
import '../models/source_definition.dart';
import 'anti_crawl.dart';

/// 解析后的规则结构
class _ParsedRule {
  final String selector;
  final String attribute;
  final String? regex;

  _ParsedRule({
    required this.selector,
    this.attribute = 'text',
    this.regex,
  });

  bool get isEmpty => selector.isEmpty;
}

/// 源引擎 - 书源规则执行核心
class SourceEngine {
  final _Semaphore _globalSemaphore;
  final Map<String, _AsyncLock> _sourceLocks = {};
  final AntiCrawlManager _antiCrawl;
  final Map<String, Dio> _dioCache = {};
  final int maxRetries;
  final int requestTimeoutSeconds;
  static const int _maxPages = 20;

  SourceEngine({
    AntiCrawlManager? antiCrawl,
    this.maxRetries = 2,
    this.requestTimeoutSeconds = 10,
  })  : _globalSemaphore = _Semaphore(10),
        _antiCrawl = antiCrawl ?? AntiCrawlManager();

  Future<List<SearchResult>> executeSearch(
    SourceDefinition source,
    String keyword, {
    int page = 1,
  }) async {
    return _executeWithLock(source, () async {
      final url = _buildSearchUrl(source, keyword, page);
      if (url.isEmpty) return [];

      final html = await _fetchHtml(url, source);
      final document = html_parser.parse(html);
      final rule = source.searchRule;

      final listRule = _parseRule(rule.bookList);
      if (listRule.isEmpty) return [];

      final items = _querySelectorAll(document, listRule.selector);
      if (items.isEmpty) return [];

      final results = <SearchResult>[];
      for (final item in items) {
        try {
          final name = _extractField(item, rule.name);
          final bookUrl = _extractField(item, rule.bookUrl);
          if (name.isEmpty || bookUrl.isEmpty) continue;

          results.add(SearchResult(
            bookId: '',
            title: name,
            author: _extractField(item, rule.author),
            coverUrl: _extractFieldOrNull(item, rule.coverUrl),
            intro: _extractFieldOrNull(item, rule.intro),
            sourceId: source.id,
            sourceName: source.bookSourceName,
            bookKey: _resolveUrl(source.bookSourceUrl, bookUrl),
            latestChapter: null,
            category: _extractFieldOrNull(item, rule.category),
          ));
        } catch (e) {
          debugPrint('[SourceEngine] 解析搜索结果项失败: $e');
        }
      }
      return results;
    });
  }

  Future<BookDetail> executeDetail(
    SourceDefinition source,
    String bookKey,
  ) async {
    return _executeWithLock(source, () async {
      final url = _resolveUrl(source.bookSourceUrl, bookKey);
      final html = await _fetchHtml(url, source);
      final document = html_parser.parse(html);
      final rule = source.detailRule;

      return BookDetail(
        bookKey: bookKey,
        title: _extractFieldFromDoc(document, rule.name),
        author: _extractFieldFromDoc(document, rule.author),
        intro: _extractFieldFromDoc(document, rule.intro),
        coverUrl: _extractFieldOrNullFromDoc(document, rule.coverUrl),
        category: _extractFieldOrNullFromDoc(document, rule.category),
        wordCount: _extractFieldOrNullFromDoc(document, rule.wordCount),
        status: _extractFieldOrNullFromDoc(document, rule.status),
        lastChapter: _extractFieldOrNullFromDoc(document, rule.lastChapter),
        chapterListUrl:
            _extractFieldOrNullFromDoc(document, rule.chapterListUrl),
        sourceId: source.id,
        sourceName: source.bookSourceName,
      );
    });
  }

  Future<List<ChapterInfo>> executeChapterList(
    SourceDefinition source,
    String bookKey,
  ) async {
    return _executeWithLock(source, () async {
      String chapterListUrl = _resolveUrl(source.bookSourceUrl, bookKey);

      if (source.detailRule.chapterListUrl.isNotEmpty) {
        try {
          final detailHtml = await _fetchHtml(chapterListUrl, source);
          final detailDoc = html_parser.parse(detailHtml);
          final listUrl = _extractFieldOrNullFromDoc(
            detailDoc,
            source.detailRule.chapterListUrl,
          );
          if (listUrl != null && listUrl.isNotEmpty) {
            chapterListUrl = _resolveUrl(source.bookSourceUrl, listUrl);
          }
        } catch (e) {
          debugPrint('[SourceEngine] 获取章节列表页 URL 失败: $e');
        }
      }

      final html = await _fetchHtml(chapterListUrl, source);
      final document = html_parser.parse(html);
      final rule = source.chapterListRule;

      final listRule = _parseRule(rule.chapterList);
      if (listRule.isEmpty) return [];

      final items = _querySelectorAll(document, listRule.selector);
      if (items.isEmpty) return [];

      final chapters = <ChapterInfo>[];
      for (int i = 0; i < items.length; i++) {
        try {
          final item = items[i];
          final chapterName = _extractField(item, rule.chapterName);
          final chapterUrl = _extractField(item, rule.chapterUrl);
          if (chapterName.isEmpty || chapterUrl.isEmpty) continue;

          final isVip = rule.isVip.isNotEmpty
              ? _extractField(item, rule.isVip).isNotEmpty
              : false;

          chapters.add(ChapterInfo(
            chapterKey: _resolveUrl(source.bookSourceUrl, chapterUrl),
            title: chapterName,
            orderIndex: i,
            isVip: isVip,
          ));
        } catch (e) {
          debugPrint('[SourceEngine] 解析章节项失败: $e');
        }
      }
      return chapters;
    });
  }

  Future<SourceChapterContent> executeContent(
    SourceDefinition source,
    String bookKey,
    String chapterKey,
  ) async {
    return _executeWithLock(source, () async {
      final rule = source.contentRule;
      final contentBuffer = StringBuffer();
      String? title;
      String? nextPage;
      String currentUrl = _resolveUrl(source.bookSourceUrl, chapterKey);
      int pageCount = 0;

      do {
        final html = await _fetchHtml(currentUrl, source);
        final document = html_parser.parse(html);

        final contentRule = _parseRule(rule.content);
        String content = '';
        if (!contentRule.isEmpty) {
          content = _extractFieldFromDoc(document, rule.content);
        }

        content = _applyReplaceRules(content, rule.replace);
        contentBuffer.write(content);
        pageCount++;

        if (rule.nextPageUrl.isNotEmpty && pageCount < _maxPages) {
          nextPage = _extractFieldOrNullFromDoc(document, rule.nextPageUrl);
          if (nextPage != null && nextPage.isNotEmpty) {
            final resolvedNext = _resolveUrl(source.bookSourceUrl, nextPage);
            if (resolvedNext == currentUrl ||
                resolvedNext == _resolveUrl(source.bookSourceUrl, bookKey)) {
              nextPage = null;
            } else {
              currentUrl = resolvedNext;
            }
          }
        } else {
          nextPage = null;
        }

        if (pageCount == 1 && source.detailRule.name.isNotEmpty) {
          title = _extractFieldOrNullFromDoc(document, 'css:title@text');
        }
      } while (nextPage != null && nextPage.isNotEmpty);

      return SourceChapterContent(
        chapterKey: chapterKey,
        title: title ?? '',
        content: contentBuffer.toString(),
        isVip: false,
      );
    });
  }

  Future<bool> executeHealthCheck(SourceDefinition source) async {
    try {
      final html = await _fetchHtml(source.bookSourceUrl, source);
      return html.isNotEmpty;
    } catch (e) {
      debugPrint('[SourceEngine] 健康检查失败 ${source.bookSourceName}: $e');
      return false;
    }
  }

  void disposeSource(String sourceId) {
    _dioCache[sourceId]?.close();
    _dioCache.remove(sourceId);
    _sourceLocks.remove(sourceId);
  }

  void dispose() {
    for (final dio in _dioCache.values) {
      dio.close();
    }
    _dioCache.clear();
    _sourceLocks.clear();
    _antiCrawl.clearAllCookies();
  }

  String _buildSearchUrl(SourceDefinition source, String keyword, int page) {
    var url = source.searchUrl;
    if (url.isEmpty) return '';
    final encodedKey = Uri.encodeComponent(keyword);
    url = url.replaceAll('{{key}}', encodedKey);
    url = url.replaceAll('{{page}}', page.toString());
    return url;
  }

  String _resolveUrl(String baseUrl, String url) {
    if (url.isEmpty) return baseUrl;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    try {
      final base = Uri.parse(baseUrl);
      if (url.startsWith('/')) {
        return '${base.scheme}://${base.host}$url';
      }
      final basePath = base.path;
      final lastSlash = basePath.lastIndexOf('/');
      final newPath = lastSlash >= 0
          ? '${basePath.substring(0, lastSlash + 1)}$url'
          : '/$url';
      return '${base.scheme}://${base.host}$newPath';
    } catch (e) {
      if (url.startsWith('/')) {
        return '$baseUrl$url';
      }
      return '$baseUrl/$url';
    }
  }

  Dio _getDio(SourceDefinition source) {
    return _dioCache.putIfAbsent(source.id, () {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(milliseconds: Constants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: Constants.receiveTimeout),
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) => status != null && status >= 200 && status < 400,
        responseType: ResponseType.plain,
      ));
      final interceptors = _antiCrawl.createInterceptors(source.bookSourceUrl);
      dio.interceptors.addAll(interceptors);
      return dio;
    });
  }

  Future<String> _fetchHtml(String url, SourceDefinition source) async {
    final dio = _getDio(source);
    await _antiCrawl.waitForInterval(source.id);
    await _globalSemaphore.acquire();
    try {
      return await _fetchWithRetry(dio, url, source);
    } finally {
      _globalSemaphore.release();
    }
  }

  Future<String> _fetchWithRetry(Dio dio, String url, SourceDefinition source) async {
    DioException? lastException;
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
        final response = await dio.get<String>(url);
        if (response.data != null) {
          return response.data!;
        }
        throw DioException(requestOptions: RequestOptions(path: url), message: '响应数据为空');
      } on DioException catch (e) {
        lastException = e;
        debugPrint('[SourceEngine] 请求失败 (第${attempt + 1}次) $url: ${e.message}');
        if (e.response?.statusCode != null && e.response!.statusCode! >= 400 && e.response!.statusCode! < 500) {
          break;
        }
      }
    }
    throw lastException ?? DioException(requestOptions: RequestOptions(path: url), message: '所有重试均失败');
  }

  _ParsedRule _parseRule(String ruleStr) {
    if (ruleStr.isEmpty) return _ParsedRule(selector: '');
    var rule = ruleStr.trim();
    if (rule.startsWith('css:')) rule = rule.substring(4);
    String? regex;
    final regexIndex = rule.indexOf('##');
    if (regexIndex >= 0) {
      regex = rule.substring(regexIndex + 2);
      rule = rule.substring(0, regexIndex);
    }
    String attribute = 'text';
    final attrIndex = rule.lastIndexOf('@');
    if (attrIndex >= 0) {
      attribute = rule.substring(attrIndex + 1);
      rule = rule.substring(0, attrIndex);
    }
    return _ParsedRule(selector: rule.trim(), attribute: attribute.trim(), regex: regex?.isNotEmpty == true ? regex : null);
  }

  String _extractField(dom.Element parent, String ruleStr) {
    final parsed = _parseRule(ruleStr);
    if (parsed.isEmpty) return '';
    try {
      final element = parent.querySelector(parsed.selector);
      if (element == null) return '';
      var value = _getAttributeValue(element, parsed.attribute);
      if (parsed.regex != null && value.isNotEmpty) {
        try {
          value = value.replaceAll(RegExp(parsed.regex!), '');
        } catch (_) {}
      }
      return value.trim();
    } catch (e) {
      debugPrint('[SourceEngine] 提取字段失败 [$ruleStr]: $e');
      return '';
    }
  }

  String? _extractFieldOrNull(dom.Element parent, String ruleStr) {
    final value = _extractField(parent, ruleStr);
    return value.isEmpty ? null : value;
  }

  String _extractFieldFromDoc(dom.Document document, String ruleStr) {
    final parsed = _parseRule(ruleStr);
    if (parsed.isEmpty) return '';
    try {
      final element = document.querySelector(parsed.selector);
      if (element == null) return '';
      var value = _getAttributeValue(element, parsed.attribute);
      if (parsed.regex != null && value.isNotEmpty) {
        try {
          value = value.replaceAll(RegExp(parsed.regex!), '');
        } catch (_) {}
      }
      return value.trim();
    } catch (e) {
      debugPrint('[SourceEngine] 从文档提取字段失败 [$ruleStr]: $e');
      return '';
    }
  }

  String? _extractFieldOrNullFromDoc(dom.Document document, String ruleStr) {
    final value = _extractFieldFromDoc(document, ruleStr);
    return value.isEmpty ? null : value;
  }

  String _getAttributeValue(dom.Element element, String attribute) {
    switch (attribute) {
      case 'text': return element.text;
      case 'html': return element.innerHtml;
      case 'href': return element.attributes['href'] ?? '';
      case 'src': return element.attributes['src'] ?? '';
      case 'title': return element.attributes['title'] ?? '';
      case 'alt': return element.attributes['alt'] ?? '';
      case 'data-src': return element.attributes['data-src'] ?? '';
      case 'data-original': return element.attributes['data-original'] ?? '';
      default: return element.attributes[attribute] ?? element.text;
    }
  }

  List<dom.Element> _querySelectorAll(dom.Node root, String selector) {
    if (selector.isEmpty) return [];
    try {
      if (root is dom.Document) return root.querySelectorAll(selector);
      if (root is dom.Element) return root.querySelectorAll(selector);
      return [];
    } catch (e) {
      debugPrint('[SourceEngine] 选择器查询失败 [$selector]: $e');
      return [];
    }
  }

  String _applyReplaceRules(String content, List<String> replacePatterns) {
    if (replacePatterns.isEmpty) return content;
    var result = content;
    for (final pattern in replacePatterns) {
      if (pattern.isEmpty) continue;
      try {
        result = result.replaceAll(RegExp(pattern), '');
      } catch (e) {
        debugPrint('[SourceEngine] 正则替换失败 [$pattern]: $e');
      }
    }
    return result;
  }

  Future<T> _executeWithLock<T>(SourceDefinition source, Future<T> Function() action) async {
    final lock = _sourceLocks.putIfAbsent(source.id, () => _AsyncLock());
    return lock.run(action);
  }
}

class _Semaphore {
  final int _maxCount;
  int _currentCount = 0;
  final List<Completer<void>> _waiters = [];
  _Semaphore(this._maxCount);

  Future<void> acquire() async {
    if (_currentCount < _maxCount) {
      _currentCount++;
      return;
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    await completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _currentCount--;
      final next = _waiters.removeAt(0);
      _currentCount++;
      next.complete();
    } else {
      _currentCount--;
    }
  }
}

class _AsyncLock {
  Future<void> _lastTask = Future.value();

  Future<T> run<T>(Future<T> Function() action) async {
    final completer = Completer<T>();
    _lastTask = _lastTask.then((_) async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, stack) {
        completer.completeError(e, stack);
      }
    }).catchError((_) {});
    return completer.future;
  }
}