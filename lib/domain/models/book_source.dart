/// 书源模型
class BookSource {
  final String id;
  final String bookId;
  final String sourceId;
  String sourceName;
  final String bookKey;
  bool isPrimary;
  double confidence;
  double score;
  DateTime? lastCheck;
  DateTime? lastAvailable;
  int chapterCount;
  bool enabled;

  BookSource({
    required this.id,
    required this.bookId,
    required this.sourceId,
    required this.sourceName,
    required this.bookKey,
    this.isPrimary = false,
    this.confidence = 0.5,
    this.score = 0.0,
    this.lastCheck,
    this.lastAvailable,
    this.chapterCount = 0,
    this.enabled = true,
  });

  factory BookSource.fromJson(Map<String, dynamic> json) {
    return BookSource(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      sourceId: json['source_id'] as String,
      sourceName: json['source_name'] as String,
      bookKey: json['book_key'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      lastCheck: json['last_check'] != null
          ? DateTime.parse(json['last_check'] as String)
          : null,
      lastAvailable: json['last_available'] != null
          ? DateTime.parse(json['last_available'] as String)
          : null,
      chapterCount: json['chapter_count'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'source_id': sourceId,
      'source_name': sourceName,
      'book_key': bookKey,
      'is_primary': isPrimary,
      'confidence': confidence,
      'score': score,
      'last_check': lastCheck?.toIso8601String(),
      'last_available': lastAvailable?.toIso8601String(),
      'chapter_count': chapterCount,
      'enabled': enabled,
    };
  }

  BookSource copyWith({
    String? id,
    String? bookId,
    String? sourceId,
    String? sourceName,
    String? bookKey,
    bool? isPrimary,
    double? confidence,
    double? score,
    DateTime? lastCheck,
    DateTime? lastAvailable,
    int? chapterCount,
    bool? enabled,
  }) {
    return BookSource(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      bookKey: bookKey ?? this.bookKey,
      isPrimary: isPrimary ?? this.isPrimary,
      confidence: confidence ?? this.confidence,
      score: score ?? this.score,
      lastCheck: lastCheck ?? this.lastCheck,
      lastAvailable: lastAvailable ?? this.lastAvailable,
      chapterCount: chapterCount ?? this.chapterCount,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BookSource && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
