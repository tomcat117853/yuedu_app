import '../models/layout_config.dart';
import 'pagination_engine.dart';

/// 文本布局计算器
class TextLayout {
  /// 默认页面尺寸（用于无Widget环境下的计算）
  static const double defaultPageWidth = 360.0;
  static const double defaultPageHeight = 640.0;

  /// 计算文本分页
  ///
  /// [text] - 纯文本内容
  /// [config] - 排版配置
  /// [pageWidth] - 页面宽度（默认360dp）
  /// [pageHeight] - 页面高度（默认640dp）
  List<PageRange> calculatePages({
    required String text,
    required LayoutConfig config,
    double pageWidth = defaultPageWidth,
    double pageHeight = defaultPageHeight,
  }) {
    final engine = PaginationEngine();
    return engine.paginate(
      text: text,
      config: config,
      width: pageWidth,
      height: pageHeight,
    );
  }

  /// 计算单行文本宽度
  double measureLineWidth(String text, LayoutConfig config) {
    // 简单估算：中文字符宽度约等于字体大小，英文约为字体大小的0.6倍
    double width = 0;
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      if (codeUnit > 127) {
        // 中文字符
        width += config.fontSize;
      } else {
        // 英文字符
        width += config.fontSize * 0.6;
      }
      width += config.letterSpacing;
    }
    return width;
  }

  /// 计算可用文本宽度
  double getAvailableWidth(double pageWidth, LayoutConfig config) {
    return pageWidth - config.margin * 2;
  }

  /// 计算可用文本高度
  double getAvailableHeight(double pageHeight, LayoutConfig config) {
    return pageHeight - config.margin * 2;
  }

  /// 计算每行可容纳的字符数（估算）
  int estimateCharsPerLine(double pageWidth, LayoutConfig config) {
    final availableWidth = getAvailableWidth(pageWidth, config);
    final indentWidth = config.indentWidth;
    final textWidth = availableWidth - indentWidth;
    if (textWidth <= 0) return 0;
    return (textWidth / (config.fontSize * 0.8)).floor();
  }

  /// 计算每页可容纳的行数
  int estimateLinesPerPage(double pageHeight, LayoutConfig config) {
    final availableHeight = getAvailableHeight(pageHeight, config);
    final lineHeight = config.fontSize * config.lineHeight;
    if (lineHeight <= 0) return 0;
    return (availableHeight / lineHeight).floor();
  }

  /// 构建带缩进的段落文本
  String buildIndentedParagraph(String text, LayoutConfig config) {
    if (text.isEmpty) return text;
    final indent = '　' * config.indentChars; // 使用全角空格
    return '$indent$text';
  }

  /// 格式化文本用于显示（添加段落间距等）
  List<TextSegment> formatText(String text, LayoutConfig config) {
    final paragraphs = text.split(RegExp(r'\n+'));
    final segments = <TextSegment>[];
    int offset = 0;

    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();
      if (paragraph.isEmpty) continue;

      segments.add(TextSegment(
        text: paragraph,
        offset: offset,
        isParagraphStart: true,
        hasIndent: i > 0 || true, // 所有段落都有缩进
        paragraphIndex: i,
      ));

      offset += paragraph.length;
    }

    return segments;
  }
}

/// 文本片段
class TextSegment {
  final String text;
  final int offset;
  final bool isParagraphStart;
  final bool hasIndent;
  final int paragraphIndex;

  const TextSegment({
    required this.text,
    required this.offset,
    required this.isParagraphStart,
    required this.hasIndent,
    required this.paragraphIndex,
  });

  int get length => text.length;
}
