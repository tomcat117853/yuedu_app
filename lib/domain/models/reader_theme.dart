import 'package:flutter/material.dart';

/// 阅读器主题模型
class ReaderTheme {
  final int themeIndex;
  final String name;
  final Color backgroundColor;
  final Color textColor;
  final Color hintColor;

  const ReaderTheme({
    required this.themeIndex,
    required this.name,
    required this.backgroundColor,
    required this.textColor,
    required this.hintColor,
  });

  /// 兼容性别名
  Color get bgColor => backgroundColor;
  
  /// 预定义主题列表（别名）
  static const List<ReaderTheme> all = presets;

  /// 预定义主题列表
  static const List<ReaderTheme> presets = [
    ReaderTheme(
      themeIndex: 0,
      name: '日间',
      backgroundColor: Color(0xFFF5F5F0),
      textColor: Color(0xFF333333),
      hintColor: Color(0xFF999999),
    ),
    ReaderTheme(
      themeIndex: 1,
      name: '夜间',
      backgroundColor: Color(0xFF1A1A1A),
      textColor: Color(0xFFB0B0B0),
      hintColor: Color(0xFF666666),
    ),
    ReaderTheme(
      themeIndex: 2,
      name: '护眼',
      backgroundColor: Color(0xFFF0E6D2),
      textColor: Color(0xFF5B4636),
      hintColor: Color(0xFF8B7355),
    ),
    ReaderTheme(
      themeIndex: 3,
      name: '墨水屏',
      backgroundColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF000000),
      hintColor: Color(0xFF888888),
    ),
  ];

  /// 根据索引获取主题
  static ReaderTheme fromIndex(int index) {
    if (index < 0 || index >= presets.length) return presets[0];
    return presets[index];
  }

  /// 获取日间主题
  static ReaderTheme day() => presets[0];

  factory ReaderTheme.fromJson(Map<String, dynamic> json) {
    return ReaderTheme(
      themeIndex: json['theme_index'] as int? ?? 0,
      name: json['name'] as String? ?? '日间',
      backgroundColor: Color(json['background_color'] as int? ?? 0xFFF5F5F0),
      textColor: Color(json['text_color'] as int? ?? 0xFF333333),
      hintColor: Color(json['hint_color'] as int? ?? 0xFF999999),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme_index': themeIndex,
      'name': name,
      'background_color': backgroundColor.toARGB32(),
      'text_color': textColor.toARGB32(),
      'hint_color': hintColor.toARGB32(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReaderTheme && themeIndex == other.themeIndex;

  @override
  int get hashCode => themeIndex.hashCode;
}
