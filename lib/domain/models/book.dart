
/// 书籍模型
class Book {
  final String id;
  String title;
  String author;
  String? coverPath;
  String? intro;
  String? category;
  String type; // local, online, hybrid
  String? localPath;
  String format; // txt, epub, pdf
  int totalChapters;
  int wordCount;
  int status; // 0=reading, 1=finished, 2=archived
  final DateTime createdAt;
  DateTime updatedAt;
  String groupId;
  int sortOrder;

  Book({
    required this.id,
    required this.title,
    this.author = '',
    this.coverPath,
    this.intro,
    this.category,
    this.type = 'local',
    this.localPath,
    this.format = 'txt',
    this.totalChapters = 0,
    this.wordCount = 0,
    this.status = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.groupId = 'default',
    this.sortOrder = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 从JSON创建
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String? ?? '',
      coverPath: json['cover_path'] as String?,
      intro: json['intro'] as String?,
      category: json['category'] as String?,
      type: json['type'] as String? ?? 'local',
      localPath: json['local_path'] as String?,
      format: json['format'] as String? ?? 'txt',
      totalChapters: json['total_chapters'] as int? ?? 0,
      wordCount: json['word_count'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      groupId: json['group_id'] as String? ?? 'default',
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'cover_path': coverPath,
      'intro': intro,
      'category': category,
      'type': type,
      'local_path': localPath,
      'format': format,
      'total_chapters': totalChapters,
      'word_count': wordCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'group_id': groupId,
      'sort_order': sortOrder,
    };
  }

  /// 创建副本
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverPath,
    String? intro,
    String? category,
    String? type,
    String? localPath,
    String? format,
    int? totalChapters,
    int? wordCount,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? groupId,
    int? sortOrder,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverPath: coverPath ?? this.coverPath,
      intro: intro ?? this.intro,
      category: category ?? this.category,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      format: format ?? this.format,
      totalChapters: totalChapters ?? this.totalChapters,
      wordCount: wordCount ?? this.wordCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupId: groupId ?? this.groupId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() => 'Book(id: $id, title: $title, author: $author)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Book && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
