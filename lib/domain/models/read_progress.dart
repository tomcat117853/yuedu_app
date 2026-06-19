/// 阅读进度模型
class ReadProgress {
  final String bookId;
  int chapterIndex;
  int pageIndex;
  int charOffset;
  double scrollOffset;
  int readingTime; // 累计阅读时间（秒）
  DateTime lastReadAt;
  double progressPercent;

  ReadProgress({
    required this.bookId,
    this.chapterIndex = 0,
    this.pageIndex = 0,
    this.charOffset = 0,
    this.scrollOffset = 0.0,
    this.readingTime = 0,
    DateTime? lastReadAt,
    this.progressPercent = 0.0,
  }) : lastReadAt = lastReadAt ?? DateTime.now();

  factory ReadProgress.fromJson(Map<String, dynamic> json) {
    return ReadProgress(
      bookId: json['book_id'] as String,
      chapterIndex: json['chapter_index'] as int? ?? 0,
      pageIndex: json['page_index'] as int? ?? 0,
      charOffset: json['char_offset'] as int? ?? 0,
      scrollOffset: (json['scroll_offset'] as num?)?.toDouble() ?? 0.0,
      readingTime: json['reading_time'] as int? ?? 0,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : DateTime.now(),
      progressPercent:
          (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'chapter_index': chapterIndex,
      'page_index': pageIndex,
      'char_offset': charOffset,
      'scroll_offset': scrollOffset,
      'reading_time': readingTime,
      'last_read_at': lastReadAt.toIso8601String(),
      'progress_percent': progressPercent,
    };
  }

  ReadProgress copyWith({
    String? bookId,
    int? chapterIndex,
    int? pageIndex,
    int? charOffset,
    double? scrollOffset,
    int? readingTime,
    DateTime? lastReadAt,
    double? progressPercent,
  }) {
    return ReadProgress(
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      pageIndex: pageIndex ?? this.pageIndex,
      charOffset: charOffset ?? this.charOffset,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      readingTime: readingTime ?? this.readingTime,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }

  /// 格式化阅读时间
  String get formattedReadingTime {
    final hours = readingTime ~/ 3600;
    final minutes = (readingTime % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    }
    return '${minutes}分钟';
  }

  /// 格式化进度百分比
  String get formattedProgress {
    return '${progressPercent.toStringAsFixed(1)}%';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReadProgress && bookId == other.bookId;

  @override
  int get hashCode => bookId.hashCode;
}
