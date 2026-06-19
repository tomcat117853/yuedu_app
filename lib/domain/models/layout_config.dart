import 'dart:convert';

/// 排版配置模型
class LayoutConfig {
  /// 字体大小 (sp)
  double fontSize;

  /// 行高倍数
  double lineHeight;

  /// 段间距倍数
  double paragraphSpacing;

  /// 页面边距 (dp)
  double margin;

  /// 首行缩进字符数
  int indentChars;

  /// 字体族
  String fontFamily;

  /// 字重
  FontWeight fontWeight;

  /// 字间距
  double letterSpacing;

  /// 是否使用自定义字体
  bool useCustomFont;

  /// 自定义字体路径
  String? customFontPath;

  LayoutConfig({
    this.fontSize = 18.0,
    this.lineHeight = 1.6,
    this.paragraphSpacing = 0.8,
    this.margin = 24.0,
    this.indentChars = 2,
    this.fontFamily = 'system',
    this.fontWeight = FontWeight.normal,
    this.letterSpacing = 0.0,
    this.useCustomFont = false,
    this.customFontPath,
  });

  /// 默认配置
  static LayoutConfig get defaultConfig => LayoutConfig();

  /// 计算首行缩进宽度
  double get indentWidth => fontSize * indentChars;

  /// 计算行间距
  double get lineSpacing => fontSize * (lineHeight - 1);

  /// 计算段间距
  double get paragraphGap => fontSize * paragraphSpacing;

  factory LayoutConfig.fromJson(Map<String, dynamic> json) {
    return LayoutConfig(
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 18.0,
      lineHeight: (json['line_height'] as num?)?.toDouble() ?? 1.6,
      paragraphSpacing:
          (json['paragraph_spacing'] as num?)?.toDouble() ?? 0.8,
      margin: (json['margin'] as num?)?.toDouble() ?? 24.0,
      indentChars: json['indent_chars'] as int? ?? 2,
      fontFamily: json['font_family'] as String? ?? 'system',
      fontWeight: _parseFontWeight(json['font_weight'] as int? ?? 0),
      letterSpacing: (json['letter_spacing'] as num?)?.toDouble() ?? 0.0,
      useCustomFont: json['use_custom_font'] as bool? ?? false,
      customFontPath: json['custom_font_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'font_size': fontSize,
      'line_height': lineHeight,
      'paragraph_spacing': paragraphSpacing,
      'margin': margin,
      'indent_chars': indentChars,
      'font_family': fontFamily,
      'font_weight': fontWeight.index,
      'letter_spacing': letterSpacing,
      'use_custom_font': useCustomFont,
      'custom_font_path': customFontPath,
    };
  }

  static FontWeight _parseFontWeight(int index) {
    switch (index) {
      case 0:
        return FontWeight.normal;
      case 1:
        return FontWeight.bold;
      case 2:
        return FontWeight.w100;
      case 3:
        return FontWeight.w200;
      case 4:
        return FontWeight.w300;
      case 5:
        return FontWeight.w400;
      case 6:
        return FontWeight.w500;
      case 7:
        return FontWeight.w600;
      case 8:
        return FontWeight.w700;
      case 9:
        return FontWeight.w800;
      default:
        return FontWeight.normal;
    }
  }

  LayoutConfig copyWith({
    double? fontSize,
    double? lineHeight,
    double? paragraphSpacing,
    double? margin,
    int? indentChars,
    String? fontFamily,
    FontWeight? fontWeight,
    double? letterSpacing,
    bool? useCustomFont,
    String? customFontPath,
  }) {
    return LayoutConfig(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      margin: margin ?? this.margin,
      indentChars: indentChars ?? this.indentChars,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      useCustomFont: useCustomFont ?? this.useCustomFont,
      customFontPath: customFontPath ?? this.customFontPath,
    );
  }

  @override
  String toString() =>
      'LayoutConfig(fontSize: $fontSize, lineHeight: $lineHeight, margin: $margin)';
}
