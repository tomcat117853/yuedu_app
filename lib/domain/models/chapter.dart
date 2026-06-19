/// 章节模型
class Chapter {
  final String id;
  final String bookId;
  final String? sourceId;
  final String chapterKey;
  String title;
  int orderIndex;
  String? contentPath;
  bool isCached;
  bool isVip;
  int wordCount;
  DateTime? fetchedAt;

  Chapter({
    required this.id,
    required this.bookId,
    this.sourceId,
    required this.chapterKey,
    required this.title,
    required this.orderIndex,
    this.contentPath,
    this.isCached = false,
    this.isVip = false,
    this.wordCount = 0,
    this.fetchedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      sourceId: json['source_id'] as String?,
      chapterKey: json['chapter_key'] as String,
      title: json['title'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      contentPath: json['content_path'] as String?,
      isCached: json['is_cached'] as bool? ?? false,
      isVip: json['is_vip'] as bool? ?? false,
      wordCount: json['word_count'] as int? ?? 0,
      fetchedAt: json['fetched_at'] != null
          ? DateTime.parse(json['fetched_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'source_id': sourceId,
      'chapter_key': chapterKey,
      'title': title,
      'order_index': orderIndex,
      'content_path': contentPath,
      'is_cached': isCached,
      'is_vip': isVip,
      'word_count': wordCount,
      'fetched_at': fetchedAt?.toIso8601String(),
    };
  }

  Chapter copyWith({
    String? id,
    String? bookId,
    String? sourceId,
    String? chapterKey,
    String? title,
    int? orderIndex,
    String? contentPath,
    bool? isCached,
    bool? isVip,
    int? wordCount,
    DateTime? fetchedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      sourceId: sourceId ?? this.sourceId,
      chapterKey: chapterKey ?? this.chapterKey,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      contentPath: contentPath ?? this.contentPath,
      isCached: isCached ?? this.isCached,
      isVip: isVip ?? this.isVip,
      wordCount: wordCount ?? this.wordCount,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Chapter && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
