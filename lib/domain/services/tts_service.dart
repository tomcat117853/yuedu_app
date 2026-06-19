import 'dart:async';
import 'package:flutter/foundation.dart';

/// TTS（文字转语音）服务
///
/// 提供文本转语音功能，支持语速、音调、音量调节，声音选择等。
/// 注意：当前为占位实现，完整功能需要flutter_tts依赖
class TtsService {
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

  /// 音量（0.0 ~ 1.0）
  double _volume = 1.0;
  double get volume => _volume;

  /// 语言
  String _language = 'zh-CN';
  String get language => _language;

  /// 当前选择的声音
  String _voice = 'default';
  String get voice => _voice;

  /// 是否启用句子分割（朗读完一句后停顿）
  bool _sentenceSplitEnabled = true;
  bool get sentenceSplitEnabled => _sentenceSplitEnabled;

  /// 句子分割停顿时长（毫秒）
  int _sentencePauseDuration = 300;
  int get sentencePauseDuration => _sentencePauseDuration;

  /// 朗读是否在每章结束后自动停止
  bool _autoStopAtChapterEnd = false;
  bool get autoStopAtChapterEnd => _autoStopAtChapterEnd;

  /// 当前正在朗读的文本
  String _currentText = '';

  /// 播放进度回调
  void Function(int offset)? onProgressChanged;

  /// 播放完成回调
  VoidCallback? onCompleted;

  /// 播放错误回调
  void Function(String error)? onError;

  /// 公开构造函数
  TtsService();

  /// 初始化 TTS 引擎
  Future<void> init() async {
    debugPrint('[TtsService] 初始化完成（占位实现）');
  }

  /// 开始朗读
  Future<void> speak(String text, {int startOffset = 0}) async {
    if (text.isEmpty) return;
    debugPrint('[TtsService] 开始朗读（占位实现）');
    _currentText = text;
    _currentOffset = startOffset;
    _isPlaying = true;

    // 模拟播放完成（根据文本长度估算时间，100ms ~ 50字）
    final estimatedDuration = (text.length * 2).clamp(100, 30000);
    await Future.delayed(Duration(milliseconds: estimatedDuration));
    
    if (!_isPlaying) return; // 如果已被停止或暂停，则不触发完成
    _isPlaying = false;
    _currentOffset = 0;
    onCompleted?.call();
  }

  /// 暂停朗读
  Future<void> pause() async {
    _isPlaying = false;
    debugPrint('[TtsService] 暂停（占位实现）');
  }

  /// 恢复朗读
  Future<void> resume() async {
    if (_currentText.isEmpty) return;
    _isPlaying = true;
    debugPrint('[TtsService] 恢复朗读（占位实现）');

    // 模拟播放完成（根据剩余文本长度估算）
    final estimatedDuration = (_currentText.length * 2).clamp(100, 30000);
    await Future.delayed(Duration(milliseconds: estimatedDuration));
    
    if (!_isPlaying) return; // 如果已被停止或暂停，则不触发完成
    _isPlaying = false;
    _currentOffset = 0;
    onCompleted?.call();
  }

  /// 停止朗读
  Future<void> stop() async {
    _isPlaying = false;
    _currentText = '';
    _currentOffset = 0;
    debugPrint('[TtsService] 停止（占位实现）');
  }

  /// 设置语速
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.5, 2.0);
  }

  /// 设置音调
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
  }

  /// 设置音量
  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
  }

  /// 设置语言
  Future<void> setLanguage(String lang) async {
    _language = lang;
  }

  /// 设置声音
  Future<void> setVoice(String voiceId) async {
    _voice = voiceId;
  }

  /// 设置句子分割
  Future<void> setSentenceSplitEnabled(bool enabled) async {
    _sentenceSplitEnabled = enabled;
  }

  /// 设置句子停顿时长
  Future<void> setSentencePauseDuration(int ms) async {
    _sentencePauseDuration = ms.clamp(100, 1000);
  }

  /// 设置章节结束自动停止
  Future<void> setAutoStopAtChapterEnd(bool enabled) async {
    _autoStopAtChapterEnd = enabled;
  }

  /// 获取可用语言列表
  Future<List<TtsLanguage>> getAvailableLanguages() async {
    return [
      TtsLanguage('zh-CN', '中文（中国）'),
      TtsLanguage('en-US', 'English (US)'),
      TtsLanguage('en-GB', 'English (UK)'),
      TtsLanguage('ja-JP', '日本語'),
    ];
  }

  /// 获取可用声音列表
  Future<List<TtsVoice>> getAvailableVoices() async {
    return [
      TtsVoice('default', '默认', 'zh-CN'),
      TtsVoice('male', '男声', 'zh-CN'),
      TtsVoice('female', '女声', 'zh-CN'),
      TtsVoice('elder', '老年', 'zh-CN'),
    ];
  }

  /// 释放资源
  Future<void> dispose() async {
    await stop();
  }

  /// 从配置映射创建
  factory TtsService.fromConfig(TtsConfig config) {
    final service = TtsService();
    service._speechRate = config.speechRate;
    service._pitch = config.pitch;
    service._volume = config.volume;
    service._language = config.language;
    service._voice = config.voice;
    service._sentenceSplitEnabled = config.sentenceSplitEnabled;
    service._sentencePauseDuration = config.sentencePauseDuration;
    service._autoStopAtChapterEnd = config.autoStopAtChapterEnd;
    return service;
  }

  /// 导出配置
  TtsConfig toConfig() {
    return TtsConfig(
      speechRate: _speechRate,
      pitch: _pitch,
      volume: _volume,
      language: _language,
      voice: _voice,
      sentenceSplitEnabled: _sentenceSplitEnabled,
      sentencePauseDuration: _sentencePauseDuration,
      autoStopAtChapterEnd: _autoStopAtChapterEnd,
    );
  }
}

/// TTS 配置
class TtsConfig {
  final double speechRate;
  final double pitch;
  final double volume;
  final String language;
  final String voice;
  final bool sentenceSplitEnabled;
  final int sentencePauseDuration;
  final bool autoStopAtChapterEnd;

  const TtsConfig({
    this.speechRate = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.language = 'zh-CN',
    this.voice = 'default',
    this.sentenceSplitEnabled = true,
    this.sentencePauseDuration = 300,
    this.autoStopAtChapterEnd = false,
  });

  factory TtsConfig.fromJson(Map<String, dynamic> json) {
    return TtsConfig(
      speechRate: (json['speech_rate'] as num?)?.toDouble() ?? 1.0,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      language: json['language'] as String? ?? 'zh-CN',
      voice: json['voice'] as String? ?? 'default',
      sentenceSplitEnabled: json['sentence_split_enabled'] as bool? ?? true,
      sentencePauseDuration: json['sentence_pause_duration'] as int? ?? 300,
      autoStopAtChapterEnd: json['auto_stop_at_chapter_end'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speech_rate': speechRate,
      'pitch': pitch,
      'volume': volume,
      'language': language,
      'voice': voice,
      'sentence_split_enabled': sentenceSplitEnabled,
      'sentence_pause_duration': sentencePauseDuration,
      'auto_stop_at_chapter_end': autoStopAtChapterEnd,
    };
  }
}

/// TTS 语言
class TtsLanguage {
  final String code;
  final String displayName;

  const TtsLanguage(this.code, this.displayName);
}

/// TTS 声音
class TtsVoice {
  final String id;
  final String displayName;
  final String language;

  const TtsVoice(this.id, this.displayName, this.language);
}