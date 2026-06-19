import 'dart:math';

import 'package:dio/dio.dart';

/// 反爬虫管理器
class AntiCrawlManager {
  static const List<String> _userAgentPool = [
    'Mozilla/5.0 (Linux; Android 14; Pixel 8 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.230 Mobile Safari/537.36',
    'Mozilla/5.0 (Linux; Android 13; SM-S918B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.6045.193 Mobile Safari/537.36',
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1',
    'Mozilla/5.0 (Linux; Android 14; SM-A546B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.210 Mobile Safari/537.36',
  ];

  final Random _random = Random();
  final Map<String, DateTime> _lastRequestTime = {};
  final Map<String, Map<String, String>> _cookieStore = {};
  final int requestIntervalMs;

  AntiCrawlManager({this.requestIntervalMs = 1000});

  String getRandomUserAgent() => _userAgentPool[_random.nextInt(_userAgentPool.length)];

  String getCookiesForSource(String sourceBaseUrl) {
    final cookies = _cookieStore[sourceBaseUrl];
    if (cookies == null || cookies.isEmpty) return '';
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  void storeCookies(String sourceBaseUrl, List<String>? setCookieHeaders) {
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) return;
    _cookieStore.putIfAbsent(sourceBaseUrl, () => {});
    final store = _cookieStore[sourceBaseUrl]!;
    for (final header in setCookieHeaders) {
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

  void clearCookies(String sourceBaseUrl) => _cookieStore.remove(sourceBaseUrl);
  void clearAllCookies() => _cookieStore.clear();

  Future<void> waitForInterval(String sourceBaseUrl) async {
    final lastTime = _lastRequestTime[sourceBaseUrl];
    if (lastTime != null) {
      final elapsed = DateTime.now().difference(lastTime).inMilliseconds;
      if (elapsed < requestIntervalMs) {
        await Future.delayed(Duration(milliseconds: requestIntervalMs - elapsed));
      }
    }
    _lastRequestTime[sourceBaseUrl] = DateTime.now();
  }

  void configureDio(Dio dio, {String? sourceBaseUrl}) {
    dio.interceptors.add(_UserAgentInterceptor(this));
    if (sourceBaseUrl != null) {
      dio.interceptors.add(_RefererInterceptor(sourceBaseUrl));
      dio.interceptors.add(_CookieInterceptor(this, sourceBaseUrl));
    }
  }

  List<Interceptor> createInterceptors(String sourceBaseUrl) => [
    _UserAgentInterceptor(this),
    _RefererInterceptor(sourceBaseUrl),
    _CookieInterceptor(this, sourceBaseUrl),
  ];
}

class _UserAgentInterceptor extends Interceptor {
  final AntiCrawlManager _manager;
  _UserAgentInterceptor(this._manager);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['User-Agent'] = _manager.getRandomUserAgent();
    options.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8';
    options.headers['Accept-Language'] = 'zh-CN,zh;q=0.9,en;q=0.8';
    options.headers['Accept-Encoding'] = 'gzip, deflate';
    handler.next(options);
  }
}

class _RefererInterceptor extends Interceptor {
  final String _baseUrl;
  _RefererInterceptor(this._baseUrl);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.headers.containsKey('Referer')) {
      options.headers['Referer'] = _baseUrl;
    }
    handler.next(options);
  }
}

class _CookieInterceptor extends Interceptor {
  final AntiCrawlManager _manager;
  final String _sourceBaseUrl;
  _CookieInterceptor(this._manager, this._sourceBaseUrl);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cookies = _manager.getCookiesForSource(_sourceBaseUrl);
    if (cookies.isNotEmpty) {
      options.headers['Cookie'] = cookies;
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final setCookies = response.headers['set-cookie'];
    if (setCookies != null && setCookies.isNotEmpty) {
      _manager.storeCookies(_sourceBaseUrl, setCookies);
    }
    handler.next(response);
  }
}