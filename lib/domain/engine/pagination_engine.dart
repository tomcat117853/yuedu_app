import '../models/layout_config.dart';

class PageRange {
  final int start, end, paragraphStart, paragraphEnd;
  const PageRange({required this.start, required this.end, this.paragraphStart = 0, this.paragraphEnd = 0});
  int get length => end - start;
}

class PaginationEngine {
  double textWidth = 0, textHeight = 0;

  List<PageRange> paginate({required String text, required LayoutConfig config, required double width, required double height}) {
    textWidth = width - config.margin * 2;
    textHeight = height - config.margin * 2;
    if (text.isEmpty || textWidth <= 0 || textHeight <= 0) return [];

    final paragraphs = _splitParagraphs(text);
    final pages = <PageRange>[];
    int currentOffset = 0, currentHeight = 0, pageStart = 0, pageParagraphStart = 0;

    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i];
      final paragraphHeight = _calculateParagraphHeight(paragraph, config);
      final spacing = i > 0 ? config.paragraphGap : 0;

      if (currentHeight + spacing + paragraphHeight > textHeight && currentHeight > 0) {
        pages.add(PageRange(start: pageStart, end: currentOffset, paragraphStart: pageParagraphStart, paragraphEnd: i));
        pageStart = currentOffset;
        pageParagraphStart = i;
        currentHeight = paragraphHeight;
      } else {
        currentHeight += spacing + paragraphHeight;
      }
      currentOffset += paragraph.length;
    }

    if (currentOffset > pageStart) {
      pages.add(PageRange(start: pageStart, end: currentOffset, paragraphStart: pageParagraphStart, paragraphEnd: paragraphs.length));
    }
    return pages;
  }

  List<String> _splitParagraphs(String text) => text.split(RegExp(r'\n+')).map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

  double _calculateParagraphHeight(String paragraph, LayoutConfig config) {
    final indentWidth = config.indentWidth;
    final availableWidth = textWidth - indentWidth;
    if (availableWidth <= 0) return config.lineSpacing;
    final charsPerLine = (availableWidth / config.fontSize).floor();
    if (charsPerLine <= 0) return config.lineSpacing;
    final lines = (paragraph.length / charsPerLine).ceil();
    return lines * config.fontSize * config.lineHeight;
  }
}