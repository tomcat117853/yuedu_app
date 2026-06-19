/// 搜索结果模型
class SearchResult {
  final String bookId;
  final String title;
  final String author;
  final String? coverUrl;
  final String? intro;
  final String sourceId;
  final String sourceName;
  final String bookKey;
  final String? latestChapter;
  final int? chapterCount;
  final String? category;
  final String? status;
  final String? wordCount;

  SearchResult({
    required this.bookId,
    required this.title,
    required this.author,
    this.coverUrl,
    this.intro,
    required this.sourceId,
    required this.sourceName,
    required this.bookKey,
    this.latestChapter,
    this.chapterCount,
    this.category,
    this.status,
    this.wordCount,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      bookId: json['book_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      intro: json['intro'] as String?,
      sourceId: json['source_id'] as String? ?? '',
      sourceName: json['source_name'] as String? ?? '',
      bookKey: json['book_key'] as String? ?? '',
      latestChapter: json['latest_chapter'] as String?,
      chapterCount: json['chapter_count'] as int?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      wordCount: json['word_count'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'title': title,
      'author': author,
      'cover_url': coverUrl,
      'intro': intro,
      'source_id': sourceId,
      'source_name': sourceName,
      'book_key': bookKey,
      'latest_chapter': latestChapter,
      'chapter_count': chapterCount,
      'category': category,
      'status': status,
      'word_count': wordCount,
    };
  }
}
