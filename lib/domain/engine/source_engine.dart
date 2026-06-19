import 'dart:async';
import 'dart:math';

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
///
/// CSS 规则格式：css:selector@attribute##regex
/// - css: 前缀标识
/// - selector: CSS 选择器
/// - @attribute: 提取属性（text/html/href/src 等）
/// - ##regex: 正则替换清理
class _ParsedRule {
  final String selector;
  final String attribute;
  final String? regex;

  _ParsedRule({
    required this.selector,
    this.attribute = 'text',
    this.regex,
  });

  /// 规则是否为空（未配置）
  bool get isEmpty => selector.isEmpty;
}

/// 源引擎 - 书源规则执行核心
///
/// 负责根据书源定义执行搜索、获取详情、获取章节列表、获取章节内容等操作。
/// 内置并发控制、请求重试、反爬虫措施。
class SourceEngine {
  /// 全局并发请求信号量
  final _Semaphore _globalSemaphore;

  /// 每个源的串行执行锁
  final Map<String, _AsyncLock> _sourceLocks = {};

  /// 反爬虫管理器
  final AntiCrawlManager _antiCrawl;

  /// Dio 客户端缓存（每个源一个实例）
  final Map<String, Dio> _dioCache = {};

  /// 最大重试次数
  final int maxRetries;

  /// 单次请求超时（秒）
  final int requestTimeoutSeconds;

  /// 最大分页页数（防止无限循环）
  static const int _maxPages = 20;

  SourceEngine({
    AntiCrawlManager? antiCrawl,
    this.maxRetries = 2,
    this.requestTimeoutSeconds = 10,
  })  : _globalSemaphore = _Semaphore(10),
        _antiCrawl = antiCrawl ?? AntiCrawlManager();

  // ==================== 公共方法 ====================

  /// 执行搜索
  ///
  /// 根据书源定义的搜索 URL 和搜索规则，搜索书籍并返回结果列表。
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

      // 获取书籍列表元素
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

  /// 执行详情获取
  ///
  /// 根据书籍标识获取书籍详情信息。
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

  /// 执行章节列表获取
  ///
  /// 根据书籍标识获取所有章节列表。
  Future<List<ChapterInfo>> executeChapterList(
    SourceDefinition source,
    String bookKey,
  ) async {
    return _executeWithLock(source, () async {
      // 先获取详情页，检查是否有独立的章节列表页
      String chapterListUrl = _resolveUrl(source.bookSourceUrl, bookKey);

      // 如果详情页规则中有章节列表 URL 选择器，先尝试获取
      if (source.detailRule.chapterListUrl.isNotEmpty) {
        try {
          final detailHtml =
              await _fetchHtml(chapterListUrl, source);
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

      // 获取章节列表元素
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

  /// 执行章节内容获取
  ///
  /// 根据书籍和章节标识获取章节正文内容。
  /// 支持多页内容自动拼接（通过 nextPageUrl 规则）。
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

      // 循环处理分页
      do {
        final html = await _fetchHtml(currentUrl, source);
        final document = html_parser.parse(html);

        // 提取正文内容
        final contentRule = _parseRule(rule.content);
        String content = '';
        if (!contentRule.isEmpty) {
          content = _extractFieldFromDoc(document, rule.content);
        }

        // 应用正则替换清理
        content = _applyReplaceRules(content, rule.replace);

        contentBuffer.write(content);
        pageCount++;

        // 检查下一页
        if (rule.nextPageUrl.isNotEmpty && pageCount < _maxPages) {
          nextPage = _extractFieldOrNullFromDoc(
            document,
            rule.nextPageUrl,
          );
          if (nextPage != null && nextPage.isNotEmpty) {
            // 验证下一页 URL 是否合理（不能是章节列表页或当前页）
            final resolvedNext =
                _resolveUrl(source.bookSourceUrl, nextPage);
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

        // 首页获取标题
        if (pageCount == 1 && source.detailRule.name.isNotEmpty) {
          title = _extractFieldOrNullFromDoc(
            document,
            'css:title@text',
          );
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

  /// 执行健康检查
  ///
  /// 验证源是否可以正常访问。尝试访问源的基础 URL。
  Future<bool> executeHealthCheck(SourceDefinition source) async {
    try {
      final html = await _fetchHtml(source.bookSourceUrl, source);
      return html.isNotEmpty;
    } catch (e) {
      debugPrint('[SourceEngine] 健康检查失败 ${source.bookSourceName}: $e');
      return false;
    }
  }

  /// 释放指定源的 Dio 实例和锁
  void disposeSource(String sourceId) {
    _dioCache[sourceId]?.close();
    _dioCache.remove(sourceId);
    _sourceLocks.remove(sourceId);
  }

  /// 释放所有资源
  void dispose() {
    for (final dio in _dioCache.values) {
      dio.close();
    }
    _dioCache.clear();
    _sourceLocks.clear();
    _antiCrawl.clearAllCookies();
  }

  // ==================== URL 构建 ====================

  /// 构建搜索 URL
  ///
  /// 替换 {{key}} 和 {{page}} 模板变量，中文关键词进行 URL 编码。
  String _buildSearchUrl(
    SourceDefinition source,
    String keyword,
    int page,
  ) {
    var url = source.searchUrl;
    if (url.isEmpty) return '';

    // URL 编码关键词
    final encodedKey = Uri.encodeComponent(keyword);
    url = url.replaceAll('{{key}}', encodedKey);
    url = url.replaceAll('{{page}}', page.toString());

    return url;
  }

  /// 解析相对 URL 为绝对 URL
  ///
  /// 如果 [url] 已经是完整的绝对 URL，直接返回。
  /// 如果是相对路径，则拼接在 [baseUrl] 之后。
  String _resolveUrl(String baseUrl, String url) {
    if (url.isEmpty) return baseUrl;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // 处理相对路径
    try {
      final base = Uri.parse(baseUrl);
      if (url.startsWith('/')) {
        return '${base.scheme}://${base.host}$url';
      }
      // 相对路径
      final basePath = base.path;
      final lastSlash = basePath.lastIndexOf('/');
      final newPath = lastSlash >= 0
          ? '${basePath.substring(0, lastSlash + 1)}$url'
          : '/$url';
      return '${base.scheme}://${base.host}$newPath';
    } catch (e) {
      // 解析失败，尝试直接拼接
      if (url.startsWith('/')) {
        return '$baseUrl$url';
      }
      return '$baseUrl/$url';
    }
  }

  // ==================== HTTP 请求 ====================

  /// 获取或创建源的 Dio 实例
  Dio _getDio(SourceDefinition source) {
    return _dioCache.putIfAbsent(source.id, () {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        followRedirects: true,
        maxRedirects: 5,
        validateStatus: (status) =>
            status != null && status >= 200 && status < 400,
        responseType: ResponseType.plain,
      ));

      // 添加反爬虫拦截器
      final interceptors =
          _antiCrawl.createInterceptors(source.bookSourceUrl);
      dio.interceptors.addAll(interceptors);

      return dio;
    });
  }

  /// 获取 HTML 页面内容
  ///
  /// 包含并发控制、请求间隔、重试机制。
  Future<String> _fetchHtml(
    String url,
    SourceDefinition source,
  ) async {
    final dio = _getDio(source);

    // 请求间隔控制
    await _antiCrawl.waitForInterval(source.id);

    // 全局并发控制
    await _globalSemaphore.acquire();
    try {
      return await _fetchWithRetry(dio, url, source);
    } finally {
      _globalSemaphore.release();
    }
  }

  /// 带重试的 HTTP 请求
  Future<String> _fetchWithRetry(
    Dio dio,
    String url,
    SourceDefinition source,
  ) async {
    DioException? lastException;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          // 重试前等待一小段时间
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }

        final response = await dio.get<String>(url);
        if (response.data != null) {
          return response.data!;
        }
        throw DioException(
          requestOptions: RequestOptions(path: url),
          message: '响应数据为空',
        );
      } on DioException catch (e) {
        lastException = e;
        debugPrint(
          '[SourceEngine] 请求失败 (第${attempt + 1}次) $url: ${e.message}',
        );
        // 对于 4xx 客户端错误不重试
        if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 400 &&
            e.response!.statusCode! < 500) {
          break;
        }
      }
    }

    throw lastException ??
        DioException(
          requestOptions: RequestOptions(path: url),
          message: '所有重试均失败',
        );
  }

  // ==================== CSS 选择器提取 ====================

  /// 解析规则字符串
  ///
  /// 支持格式：css:selector@attribute##regex
  /// - css: 前缀（可选，默认按 CSS 处理）
  /// - selector: CSS 选择器
  /// - @attribute: 提取属性
  /// - ##regex: 正则替换
  _ParsedRule _parseRule(String ruleStr) {
    if (ruleStr.isEmpty) {
      return _ParsedRule(selector: '');
    }

    var rule = ruleStr.trim();

    // 移除 css: 前缀
    if (rule.startsWith('css:')) {
      rule = rule.substring(4);
    }

    // 分离正则替换部分
    String? regex;
    final regexIndex = rule.indexOf('##');
    if (regexIndex >= 0) {
      regex = rule.substring(regexIndex + 2);
      rule = rule.substring(0, regexIndex);
    }

    // 分离属性提取
    String attribute = 'text';
    final attrIndex = rule.lastIndexOf('@');
    if (attrIndex >= 0) {
      attribute = rule.substring(attrIndex + 1);
      rule = rule.substring(0, attrIndex);
    }

    return _ParsedRule(
      selector: rule.trim(),
      attribute: attribute.trim(),
      regex: regex?.isNotEmpty == true ? regex : null,
    );
  }

  /// 从元素中提取字段值
  String _extractField(dom.Element parent, String ruleStr) {
    final parsed = _parseRule(ruleStr);
    if (parsed.isEmpty) return '';

    try {
      final element = parent.querySelector(parsed.selector);
      if (element == null) return '';

      var value = _getAttributeValue(element, parsed.attribute);

      // 应用正则替换
      if (parsed.regex != null && value.isNotEmpty) {
        try {
          value = value.replaceAll(RegExp(parsed.regex!), '');
        } catch (_) {
          // 正则无效时忽略
        }
      }

      return value.trim();
    } catch (e) {
      debugPrint('[SourceEngine] 提取字段失败 [$ruleStr]: $e');
      return '';
    }
  }

  /// 从元素中提取字段值（可能返回 null）
  String? _extractFieldOrNull(dom.Element parent, String ruleStr) {
    final value = _extractField(parent, ruleStr);
    return value.isEmpty ? null : value;
  }

  /// 从文档中提取字段值
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

  /// 从文档中提取字段值（可能返回 null）
  String? _extractFieldOrNullFromDoc(
    dom.Document document,
    String ruleStr,
  ) {
    final value = _extractFieldFromDoc(document, ruleStr);
    return value.isEmpty ? null : value;
  }

  /// 获取元素的指定属性值
  String _getAttributeValue(dom.Element element, String attribute) {
    switch (attribute) {
      case 'text':
        return element.text;
      case 'html':
        return element.innerHtml;
      case 'href':
        return element.attributes['href'] ?? '';
      case 'src':
        return element.attributes['src'] ?? '';
      case 'title':
        return element.attributes['title'] ?? '';
      case 'alt':
        return element.attributes['alt'] ?? '';
      case 'data-src':
        return element.attributes['data-src'] ?? '';
      case 'data-original':
        return element.attributes['data-original'] ?? '';
      default:
        // 尝试获取自定义属性
        return element.attributes[attribute] ?? element.text;
    }
  }

  /// 查询选择器匹配所有元素
  List<dom.Element> _querySelectorAll(dom.Node root, String selector) {
    if (selector.isEmpty) return [];
    try {
      if (root is dom.Document) {
        return root.querySelectorAll(selector);
      } else if (root is dom.Element) {
        return root.querySelectorAll(selector);
      }
      return [];
    } catch (e) {
      debugPrint('[SourceEngine] 选择器查询失败 [$selector]: $e');
      return [];
    }
  }

  // ==================== 内容清洗 ====================

  /// 应用正则替换规则清理内容
  ///
  /// [content] 原始内容
  /// [replacePatterns] 正则替换规则列表
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

  // ==================== 并发控制辅助 ====================

  /// 在源锁保护下执行操作
  Future<T> _executeWithLock<T>(
    SourceDefinition source,
    Future<T> Function() action,
  ) async {
    final lock = _sourceLocks.putIfAbsent(source.id, () => _AsyncLock());
    return lock.run(action);
  }
}

/// 异步信号量 - 控制全局并发数量
class _Semaphore {
  final int _maxCount;
  int _currentCount = 0;
  final List<Completer<void>> _waiters = [];

  _Semaphore(this._maxCount);

  /// 获取信号量，如果已满则等待
  Future<void> acquire() async {
    if (_currentCount < _maxCount) {
      _currentCount++;
      return;
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    await completer.future;
  }

  /// 释放信号量
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

/// 异步串行锁 - 保证同一源的请求串行执行
class _AsyncLock {
  Future<void> _lastTask = Future.value();

  /// 在锁保护下执行异步操作
  Future<T> run<T>(Future<T> Function() action) async {
    final completer = Completer<T>();
    _lastTask = _lastTask.then((_) async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, stack) {
        completer.completeError(e, stack);
      }
    }).catchError((_) {
      // 忽略上一个任务的错误
    });
    return completer.future;
  }
}
