import 'package:flutter/material.dart' show FontWeight, Colors;

/// 排版配置模型
class LayoutConfig {
  /// 字体大小 (sp)
  final double fontSize;

  /// 行高倍数
  final double lineHeight;

  /// 段间距倍数
  final double paragraphSpacing;

  /// 页面边距
  final PagePadding padding;

  /// 首行缩进字符数
  final int indentChars;

  /// 字体族
  final String fontFamily;

  /// 字重
  final FontWeight fontWeight;

  /// 字间距类型
  final LetterSpacing letterSpacing;

  /// 行间距类型
  final LineSpacing lineSpacing;

  /// 是否显示章节标题
  final bool showChapterTitle;

  /// 是否跟随系统主题
  final bool followSystemTheme;

  /// 是否使用自定义字体
  final bool useCustomFont;

  /// 自定义字体路径
  final String? customFontPath;

  const LayoutConfig({
    this.fontSize = 18.0,
    this.lineHeight = 1.6,
    this.paragraphSpacing = 0.8,
    this.padding = PagePadding.normal,
    this.indentChars = 2,
    this.fontFamily = 'system',
    this.fontWeight = FontWeight.normal,
    this.letterSpacing = LetterSpacing.normal,
    this.lineSpacing = LineSpacing.normal,
    this.showChapterTitle = true,
    this.followSystemTheme = false,
    this.useCustomFont = false,
    this.customFontPath,
  });

  /// 默认配置
  static const LayoutConfig defaultConfig = LayoutConfig();

  /// 计算首行缩进宽度
  double get indentWidth => fontSize * indentChars;
  /// 计算行间距
  double get lineSpacingValue => fontSize * (lineHeight - 1);

  /// 计算段间距
  double get paragraphGap => fontSize * paragraphSpacing;

  /// 计算页面边距值
  double get pagePaddingValue {
    switch (padding) {
      case PagePadding.narrow:
        return 12.0;
      case PagePadding.normal:
        return 24.0;
      case PagePadding.wide:
        return 36.0;
    }
  }

  /// 兼容性getter - 页面边距值
  double get margin => pagePaddingValue;

  /// 计算字间距值
  double get letterSpacingValue {
    switch (letterSpacing) {
      case LetterSpacing.tight:
        return -0.5;
      case LetterSpacing.normal:
        return 0.0;
      case LetterSpacing.loose:
        return 1.0;
    }
  }

  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    return LayoutConfig(
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 18.0,
      lineHeight: (json['line_height'] as num?)?.toDouble() ?? 1.6,
      paragraphSpacing: (json['paragraph_spacing'] as num?)?.toDouble() ?? 0.8,
      padding: PagePadding.values[json['padding'] as int? ?? 1],
      indentChars: json['indent_chars'] as int? ?? 2,
      fontFamily: json['font_family'] as String? ?? 'system',
      letterSpacing: LetterSpacing.values[json['letter_spacing'] as int? ?? 1],
      lineSpacing: LineSpacing.values[json['line_spacing'] as int? ?? 1],
      showChapterTitle: json['show_chapter_title'] as bool? ?? true,
      followSystemTheme: json['follow_system_theme'] as bool? ?? false,
      useCustomFont: json['use_custom_font'] as bool? ?? false,
      customFontPath: json['custom_font_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'font_size': fontSize,
      'line_height': lineHeight,
      'paragraph_spacing': paragraphSpacing,
      'padding': padding.index,
      'indent_chars': indentChars,
      'font_family': fontFamily,
      'letter_spacing': letterSpacing.index,
      'line_spacing': lineSpacing.index,
      'show_chapter_title': showChapterTitle,
      'follow_system_theme': followSystemTheme,
      'use_custom_font': useCustomFont,
      'custom_font_path': customFontPath,
    };
  }

  LayoutConfig copyWith({
    double? fontSize,
    double? lineHeight,
    double? paragraphSpacing,
    PagePadding? padding,
    int? indentChars,
    String? fontFamily,
    FontWeight? fontWeight,
    LetterSpacing? letterSpacing,
    LineSpacing? lineSpacing,
    bool? showChapterTitle,
    bool? followSystemTheme,
    bool? useCustomFont,
    String? customFontPath,
  }) {
    return LayoutConfig(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      padding: padding ?? this.padding,
      indentChars: indentChars ?? this.indentChars,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      showChapterTitle: showChapterTitle ?? this.showChapterTitle,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
      useCustomFont: useCustomFont ?? this.useCustomFont,
      customFontPath: customFontPath ?? this.customFontPath,
    );
  }

  @override
  String toString() =>
      'LayoutConfig(fontSize: $fontSize, lineHeight: $lineHeight, padding: $padding)';
}

/// 页面边距类型
enum PagePadding {
  narrow,
  normal,
  wide,
}

/// 行间距类型
enum LineSpacing {
  tight,
  normal,
  loose,
}

/// 字间距类型
enum LetterSpacing {
  tight,
  normal,
  loose,
}