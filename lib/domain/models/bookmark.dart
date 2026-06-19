
/// 书签模型
class Bookmark {
  final String id;
  final String bookId;
  int chapterIndex;
  int charOffset;
  String label;
  String color;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.bookId,
    required this.chapterIndex,
    required this.charOffset,
    required this.label,
    this.color = '#FFC107',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      chapterIndex: json['chapter_index'] as int? ?? 0,
      charOffset: json['char_offset'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      color: json['color'] as String? ?? '#FFC107',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book_id': bookId,
      'chapter_index': chapterIndex,
      'char_offset': charOffset,
      'label': label,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Bookmark copyWith({
    String? id,
    String? bookId,
    int? chapterIndex,
    int? charOffset,
    String? label,
    String? color,
    DateTime? createdAt,
  }) {
    return Bookmark(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      charOffset: charOffset ?? this.charOffset,
      label: label ?? this.label,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Bookmark && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
