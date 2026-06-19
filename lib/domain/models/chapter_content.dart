/// 章节内容模型
class ChapterContent {
  final String chapterId;
  final String bookId;
  final String title;
  final String content;
  final int wordCount;
  final bool isVip;
  final DateTime? fetchedAt;

  ChapterContent({
    required this.chapterId,
    required this.bookId,
    required this.title,
    required this.content,
    this.wordCount = 0,
    this.isVip = false,
    this.fetchedAt,
  });

  /// 获取纯文本内容（去除HTML标签）
  String get plainText {
    return content.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// 按段落分割内容
  List<String> get paragraphs {
    final text = plainText;
    return text
        .split(RegExp(r'\n{2,}'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  /// 获取指定范围的文本
  String getTextRange(int start, int end) {
    if (start < 0) start = 0;
    if (end > content.length) end = content.length;
    if (start >= end) return '';
    return plainText.substring(start, end);
  }

  factory ChapterContent.fromJson(Map<String, dynamic> json) {
    return ChapterContent(
      chapterId: json['chapter_id'] as String,
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      wordCount: json['word_count'] as int? ?? 0,
      isVip: json['is_vip'] as bool? ?? false,
      fetchedAt: json['fetched_at'] != null
          ? DateTime.parse(json['fetched_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'book_id': bookId,
      'title': title,
      'content': content,
      'word_count': wordCount,
      'is_vip': isVip,
      'fetched_at': fetchedAt?.toIso8601String(),
    };
  }
}