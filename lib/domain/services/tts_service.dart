import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS（文字转语音）服务
///
/// 提供文本转语音功能，支持语速调节、自动翻页。
class TtsService {
  late final FlutterTts _flutterTts;

  /// 是否正在播放
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// 当前播放位置（字符偏移）
  int _currentOffset = 0;
  int get currentOffset => _currentOffset;

  /// 语速（0.5 ~ 2.0）
  double _speechRate = 1.0;
  double get speechRate => _speechRate;

  /// 音调（0.5 ~ 2.0）
  double _pitch = 1.0;
  double get pitch => _pitch;

  /// 语言
  String _language = 'zh-CN';
  String get language => _language;

  /// 当前正在朗读的文本
  String _currentText = '';

  /// 播放进度回调
  void Function(int offset)? onProgressChanged;

  /// 播放完成回调
  VoidCallback? onCompleted;

  /// 播放错误回调
  void Function(String error)? onError;

  /// 初始化 TTS 引擎
  Future<void> init() async {
    try {
      _flutterTts = FlutterTts();

      // 配置 TTS 参数
      await _flutterTts.setLanguage(_language);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_pitch);

      // 设置回调处理器
      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        _currentOffset = 0;
        onCompleted?.call();
      });

      _flutterTts.setProgressHandler((text, start, end, word) {
        _currentOffset = end;
        onProgressChanged?.call(end);
      });

      _flutterTts.setErrorHandler((error) {
        _isPlaying = false;
        onError?.call(error.toString());
      });

      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
      });

      debugPrint('[TtsService] 初始化完成');
    } catch (e) {
      debugPrint('[TtsService] 初始化失败: $e');
    }
  }

  /// 开始朗读
  Future<void> speak(String text, {int startOffset = 0}) async {
    if (text.isEmpty) return;

    _currentText = text;
    _currentOffset = startOffset;
    _isPlaying = true;

    try {
      final textToSpeak = text.substring(startOffset);
      await _flutterTts.speak(textToSpeak);
      debugPrint('[TtsService] 开始朗读 (offset: $startOffset)');
    } catch (e) {
      _isPlaying = false;
      onError?.call(e.toString());
    }
  }

  /// 暂停朗读
  Future<void> pause() async {
    _isPlaying = false;
    await _flutterTts.pause();
    debugPrint('[TtsService] 暂停');
  }

  /// 恢复朗读
  Future<void> resume() async {
    if (_currentText.isEmpty) return;
    _isPlaying = true;
    await _flutterTts.speak(_currentText.substring(_currentOffset));
    debugPrint('[TtsService] 恢复朗读 (offset: $_currentOffset)');
  }

  /// 停止朗读
  Future<void> stop() async {
    _isPlaying = false;
    _currentText = '';
    _currentOffset = 0;
    await _flutterTts.stop();
    debugPrint('[TtsService] 停止');
  }

  /// 设置语速
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.5, 2.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  /// 设置音调
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
  }

  /// 设置语言
  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _flutterTts.setLanguage(_language);
  }

  /// 获取可用语言列表
  Future<List<String>> getAvailableLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return languages.cast<String>();
  }

  /// 释放资源
  Future<void> dispose() async {
    await stop();
  }
}
