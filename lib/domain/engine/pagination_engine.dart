import '../models/layout_config.dart';

/// 页面范围 - 表示一页文本的起止位置
class PageRange {
  final int start;
  final int end;
  final int paragraphStart;
  final int paragraphEnd;

  const PageRange({
    required this.start,
    required this.end,
    this.paragraphStart = 0,
    this.paragraphEnd = 0,
  });

  int get length => end - start;

  @override
  String toString() => 'PageRange($start, $end)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageRange && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// 分页引擎 - 将文本内容按排版参数分页
class PaginationEngine {
  /// 文本宽度（可用区域宽度）
  double textWidth = 0;

  /// 文本高度（可用区域高度）
  double textHeight = 0;

  /// 执行分页计算
  ///
  /// [text] - 纯文本内容
  /// [config] - 排版配置
  /// [width] - 可用宽度
  /// [height] - 可用高度
  List<PageRange> paginate({
    required String text,
    required LayoutConfig config,
    required double width,
    required double height,
  }) {
    textWidth = width - config.margin * 2;
    textHeight = height - config.margin * 2;

    if (text.isEmpty || textWidth <= 0 || textHeight <= 0) {
      return [];
    }

    // 按段落分割
    final paragraphs = _splitParagraphs(text);
    final pages = <PageRange>[];
    int currentOffset = 0;
    double currentHeight = 0;
    int pageStart = 0;
    int pageParagraphStart = 0;

    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i];
      final paragraphHeight = _calculateParagraphHeight(
        paragraph,
        config,
      );

      // 段间距（非首段）
      final spacing = i > 0 ? config.paragraphGap : 0;

      if (currentHeight + spacing + paragraphHeight > textHeight &&
          currentHeight > 0) {
        // 当前页已满，创建新页
        pages.add(PageRange(
          start: pageStart,
          end: currentOffset,
          paragraphStart: pageParagraphStart,
          paragraphEnd: i,
        ));
        pageStart = currentOffset;
        pageParagraphStart = i;
        currentHeight = paragraphHeight;
      } else {
        currentHeight += spacing + paragraphHeight;
      }

      currentOffset += paragraph.length;
    }

    // 最后一页
    if (currentOffset > pageStart) {
      pages.add(PageRange(
        start: pageStart,
        end: currentOffset,
        paragraphStart: pageParagraphStart,
        paragraphEnd: paragraphs.length,
      ));
    }

    return pages;
  }

  /// 按段落分割文本
  List<String> _splitParagraphs(String text) {
    return text
        .split(RegExp(r'\n+'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// 计算段落高度
  double _calculateParagraphHeight(String paragraph, LayoutConfig config) {
    final indentWidth = config.indentWidth;
    final availableWidth = textWidth - indentWidth;

    if (availableWidth <= 0) return config.lineSpacing;

    // 估算每行字符数
    final charsPerLine = (availableWidth / config.fontSize).floor();
    if (charsPerLine <= 0) return config.lineSpacing;

    // 计算行数
    final lines = (paragraph.length / charsPerLine).ceil();

    // 首行有缩进，后续行没有
    final firstLineChars = (availableWidth / config.fontSize).floor();
    final remainingChars = paragraph.length > firstLineChars
        ? paragraph.length - firstLineChars
        : 0;
    final remainingLines =
        firstLineChars > 0 ? (remainingChars / charsPerLine).ceil() : 0;
    final totalLines = remainingLines + (paragraph.isEmpty ? 0 : 1);

    return totalLines * config.fontSize * config.lineHeight;
  }
}
