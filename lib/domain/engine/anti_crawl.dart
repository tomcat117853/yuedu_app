import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 反爬虫管理器 - 提供请求伪装和频率控制
///
/// 包含 User-Agent 池、Cookie 管理、Referer 自动设置、
/// 请求间隔控制等反反爬虫措施。通过 Dio 拦截器实现。
class AntiCrawlManager {
  /// 移动端 User-Agent 池
  static const List<String> _userAgentPool = [
    // Android Chrome
    'Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 13; SM-S918B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6045.193 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 14; SM-A546B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.210 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 13; Redmi Note 12 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.5993.111 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 12; V2254A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.163 Mobile Safari/537.36',
    // iOS Safari
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 16_7_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_1_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/120.0.6099.160 Mobile/15E148 Safari/604.1',
    // Android WebView / 夸克 / UC
    'Mozilla/5.0 (Linux; Android 14; Pixel 7a) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36 XiaoMi/MiuiBrowser/18.5.120216',
    'Mozilla/5.0 (Linux; Android 13; HarmonyOS; ALN-AL80) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.196 Mobile Safari/537.36 HuaweiBrowser/14.0.2.302',
    'Mozilla/5.0 (Linux; U; Android 13; zh-CN; OPPO Find X6 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/100.0.4896.127 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 14; 23116PN5BC) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36 EdgA/116.0.1938.76',
  ];

  /// 随机数生成器
  final Random _random = Random();

  /// 每个源的最后请求时间（用于控制请求间隔）
  final Map<String, DateTime> _lastRequestTime = {};

  /// 每个源的 Cookie 存储
  final Map<String, Map<String, String>> _cookieStore = {};

  /// 请求间隔（毫秒）
  final int requestIntervalMs;

  AntiCrawlManager({this.requestIntervalMs = 1000});

  /// 获取随机 User-Agent
  String getRandomUserAgent() {
    return _userAgentPool[_random.nextInt(_userAgentPool.length)];
  }

  /// 获取指定源的 Cookie 字符串
  String getCookiesForSource(String sourceBaseUrl) {
    final cookies = _cookieStore[sourceBaseUrl];
    if (cookies == null || cookies.isEmpty) return '';
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  /// 存储 Set-Cookie 响应头中的 Cookie
  void storeCookies(String sourceBaseUrl, List<String>? setCookieHeaders) {
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) return;
    _cookieStore.putIfAbsent(sourceBaseUrl, () => {});
    final store = _cookieStore[sourceBaseUrl]!;
    for (final header in setCookieHeaders) {
      // 解析 "key=value; path=/; ..." 格式
      final parts = header.split(';');
      if (parts.isNotEmpty) {
        final kv = parts[0].trim();
        final eqIndex = kv.indexOf('=');
        if (eqIndex > 0) {
          final key = kv.substring(0, eqIndex).trim();
          final value = kv.substring(eqIndex + 1).trim();
          store[key] = value;
        }
      }
    }
  }

  /// 清除指定源的 Cookie
  void clearCookies(String sourceBaseUrl) {
    _cookieStore.remove(sourceBaseUrl);
  }

  /// 清除所有 Cookie
  void clearAllCookies() {
    _cookieStore.clear();
  }

  /// 等待请求间隔（同一源的请求之间至少间隔指定时间）
  Future<void> waitForInterval(String sourceBaseUrl) async {
    final lastTime = _lastRequestTime[sourceBaseUrl];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime).inMilliseconds;
      if (elapsed < requestIntervalMs) {
        await Future.delayed(
          Duration(milliseconds: requestIntervalMs - elapsed),
        );
      }
    }
    _lastRequestTime[sourceBaseUrl] = DateTime.now();
  }

  /// 为 Dio 实例添加反爬虫拦截器
  void configureDio(Dio dio, {String? sourceBaseUrl}) {
    dio.interceptors.add(_UserAgentInterceptor(this));
    if (sourceBaseUrl != null) {
      dio.interceptors.add(_RefererInterceptor(sourceBaseUrl));
      dio.interceptors.add(_CookieInterceptor(this, sourceBaseUrl));
    }
  }

  /// 创建一个配置了反爬虫措施的 Dio 拦截器列表
  List<Interceptor> createInterceptors(String sourceBaseUrl) {
    return [
      _UserAgentInterceptor(this),
      _RefererInterceptor(sourceBaseUrl),
      _CookieInterceptor(this, sourceBaseUrl),
    ];
  }
}

/// User-Agent 随机拦截器
class _UserAgentInterceptor extends Interceptor {
  final AntiCrawlManager _manager;

  _UserAgentInterceptor(this._manager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 每次请求使用随机 User-Agent
    options.headers['User-Agent'] = _manager.getRandomUserAgent();
    // 设置常见的浏览器请求头
    options.headers['Accept'] =
        'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
    options.headers['Accept-Language'] = 'zh-CN,zh;q=0.9,en;q=0.8';
    options.headers['Accept-Encoding'] = 'gzip, deflate';
    handler.next(options);
  }
}

/// Referer 自动设置拦截器
class _RefererInterceptor extends Interceptor {
  final String _baseUrl;

  _RefererInterceptor(this._baseUrl);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 如果请求头中没有 Referer，自动设置为源的基础 URL
    if (!options.headers.containsKey('Referer')) {
      options.headers['Referer'] = _baseUrl;
    }
    handler.next(options);
  }
}

/// Cookie 管理拦截器
class _CookieInterceptor extends Interceptor {
  final AntiCrawlManager _manager;
  final String _sourceBaseUrl;

  _CookieInterceptor(this._manager, this._sourceBaseUrl);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 自动附加该源的 Cookie
    final cookies = _manager.getCookiesForSource(_sourceBaseUrl);
    if (cookies.isNotEmpty) {
      options.headers['Cookie'] = cookies;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 存储响应中的 Set-Cookie
    final setCookies = response.headers['set-cookie'];
    if (setCookies != null && setCookies.isNotEmpty) {
      _manager.storeCookies(_sourceBaseUrl, setCookies);
    }
    handler.next(response);
  }
}
