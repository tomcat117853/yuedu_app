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

  /// 字重 (0=normal, 1=bold, 2-9 对应 w100-w800)
  int fontWeight;

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
    this.fontWeight = 0,
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
      fontWeight: json['font_weight'] as int? ?? 0,
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
      'font_weight': fontWeight,
      'letter_spacing': letterSpacing,
      'use_custom_font': useCustomFont,
      'custom_font_path': customFontPath,
    };
  }

  LayoutConfig copyWith({
    double? fontSize,
    double? lineHeight,
    double? paragraphSpacing,
    double? margin,
    int? indentChars,
    String? fontFamily,
    int? fontWeight,
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

/// FontWeight placeholder
class FontWeight {
  final int index;
  const FontWeight._(this.index);
  static const FontWeight normal = FontWeight._(0);
  static const FontWeight bold = FontWeight._(1);
  static const FontWeight w100 = FontWeight._(2);
  static const FontWeight w200 = FontWeight._(3);
  static const FontWeight w300 = FontWeight._(4);
  static const FontWeight w400 = FontWeight._(5);
  static const FontWeight w500 = FontWeight._(6);
  static const FontWeight w600 = FontWeight._(7);
  static const FontWeight w700 = FontWeight._(8);
  static const FontWeight w800 = FontWeight._(9);
}