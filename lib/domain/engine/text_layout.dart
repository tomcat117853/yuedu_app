import '../models/layout_config.dart';
import 'pagination_engine.dart';

class TextLayout {
  static const double defaultPageWidth = 360.0;
  static const double defaultPageHeight = 640.0;

  List<PageRange> calculatePages({required String text, required LayoutConfig config, double pageWidth = defaultPageWidth, double pageHeight = defaultPageHeight}) {
    final engine = PaginationEngine();
    return engine.paginate(text: text, config: config, width: pageWidth, height: pageHeight);
  }

  double measureLineWidth(String text, LayoutConfig config) {
    double width = 0;
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      if (codeUnit > 127) width += config.fontSize;
      else width += config.fontSize * 0.6;
      width += config.letterSpacing;
    }
    return width;
  }

  double getAvailableWidth(double pageWidth, LayoutConfig config) => pageWidth - config.margin * 2;
  double getAvailableHeight(double pageHeight, LayoutConfig config) => pageHeight - config.margin * 2;
  int estimateCharsPerLine(double pageWidth, LayoutConfig config) { final availableWidth = getAvailableWidth(pageWidth, config) - config.indentWidth; if (availableWidth <= 0) return 0; return (availableWidth / (config.fontSize * 0.8)).floor(); }
  int estimateLinesPerPage(double pageHeight, LayoutConfig config) { final availableHeight = getAvailableHeight(pageHeight, config); final lineHeight = config.fontSize * config.lineHeight; if (lineHeight <= 0) return 0; return (availableHeight / lineHeight).floor(); }
  String buildIndentedParagraph(String text, LayoutConfig config) { if (text.isEmpty) return text; final indent = '　' * config.indentChars; return '$indent$text'; }

  List<TextSegment> formatText(String text, LayoutConfig config) {
    final paragraphs = text.split(RegExp(r'\n+'));
    final segments = <TextSegment>[];
    int offset = 0;
    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();
      if (paragraph.isEmpty) continue;
      segments.add(TextSegment(text: paragraph, offset: offset, isParagraphStart: true, hasIndent: true, paragraphIndex: i));
      offset += paragraph.length;
    }
    return segments;
  }
}

class TextSegment {
  final String text;
  final int offset;
  final bool isParagraphStart;
  final bool hasIndent;
  final int paragraphIndex;

  const TextSegment({required this.text, required this.offset, required this.isParagraphStart, required this.hasIndent, required this.paragraphIndex});
  int get length => text.length;
}