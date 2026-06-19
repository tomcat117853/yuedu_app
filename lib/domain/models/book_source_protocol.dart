import 'search_result.dart';

/// 书源协议接口 - 所有书源必须实现此接口
///
/// 定义了书源的核心操作：搜索、获取详情、获取章节列表、获取章节内容。
/// 每个书源通过实现此接口来提供统一的书籍数据访问能力。
abstract interface class BookSourceProtocol {
  /// 书源唯一标识
  String get id;

  /// 书源名称
  String get name;

  /// 书源基础 URL
  String get baseUrl;

  /// 书源分组
  String get group;

  /// 权重（越大越优先）
  int get weight;

  /// 是否启用
  bool get enabled;

  /// 搜索书籍
  ///
  /// [keyword] 搜索关键词
  /// [page] 页码，从 1 开始
  Future<List<SearchResult>> search({required String keyword, int page = 1});

  /// 获取书籍详情
  ///
  /// [bookKey] 书籍在源中的唯一标识（通常是详情页路径或 URL）
  Future<BookDetail> getDetail({required String bookKey});

  /// 获取章节列表
  ///
  /// [bookKey] 书籍在源中的唯一标识
  Future<List<ChapterInfo>> getChapterList({required String bookKey});

  /// 获取章节内容
  ///
  /// [bookKey] 书籍在源中的唯一标识
  /// [chapterKey] 章节在源中的唯一标识（通常是章节页路径或 URL）
  Future<SourceChapterContent> getChapterContent({
    required String bookKey,
    required String chapterKey,
  });

  /// 发现书籍（浏览/推荐）
  ///
  /// [page] 页码，从 1 开始
  Future<List<SearchResult>> discover({int page = 1});

  /// 健康检查 - 验证书源是否可用
  Future<bool> healthCheck();
}

/// 书籍详情 - 从书源获取的完整书籍信息
class BookDetail {
  /// 书籍在源中的标识
  final String bookKey;

  /// 书名
  final String title;

  /// 作者
  final String author;

  /// 简介
  final String intro;

  /// 封面 URL
  final String? coverUrl;

  /// 分类
  final String? category;

  /// 字数
  final String? wordCount;

  /// 连载状态（连载中/完结）
  final String? status;

  /// 最新章节标题
  final String? lastChapter;

  /// 章节列表页 URL（当章节列表不在详情页时使用）
  final String? chapterListUrl;

  /// 来源 ID
  final String sourceId;

  /// 来源名称
  final String sourceName;

  BookDetail({
    required this.bookKey,
    required this.title,
    required this.author,
    this.intro = '',
    this.coverUrl,
    this.category,
    this.wordCount,
    this.status,
    this.lastChapter,
    this.chapterListUrl,
    required this.sourceId,
    required this.sourceName,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    return BookDetail(
      bookKey: json['book_key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      category: json['category'] as String?,
      wordCount: json['word_count'] as String?,
      status: json['status'] as String?,
      lastChapter: json['last_chapter'] as String?,
      chapterListUrl: json['chapter_list_url'] as String?,
      sourceId: json['source_id'] as String? ?? '',
      sourceName: json['source_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_key': bookKey,
      'title': title,
      'author': author,
      'intro': intro,
      'cover_url': coverUrl,
      'category': category,
      'word_count': wordCount,
      'status': status,
      'last_chapter': lastChapter,
      'chapter_list_url': chapterListUrl,
      'source_id': sourceId,
      'source_name': sourceName,
    };
  }
}

/// 章节信息 - 从书源获取的轻量章节数据
class ChapterInfo {
  /// 章节在源中的标识（URL 或路径）
  final String chapterKey;

  /// 章节标题
  final String title;

  /// 章节排序索引
  final int orderIndex;

  /// 是否为 VIP 章节
  final bool isVip;

  ChapterInfo({
    required this.chapterKey,
    required this.title,
    required this.orderIndex,
    this.isVip = false,
  });

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(
      chapterKey: json['chapter_key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? 0,
      isVip: json['is_vip'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_key': chapterKey,
      'title': title,
      'order_index': orderIndex,
      'is_vip': isVip,
    };
  }
}

/// 源章节内容 - 从书源获取的原始章节内容
///
/// 与 [ChapterContent] 不同，此类表示从网络获取的未经处理的原始内容，
/// 后续会经过清洗和转换后存储为 [ChapterContent]。
class SourceChapterContent {
  /// 章节标识
  final String chapterKey;

  /// 章节标题
  final String title;

  /// 正文内容（可能包含 HTML）
  final String content;

  /// 下一页 URL（多页章节时使用）
  final String? nextPageUrl;

  /// 是否为 VIP 章节
  final bool isVip;

  SourceChapterContent({
    required this.chapterKey,
    required this.title,
    required this.content,
    this.nextPageUrl,
    this.isVip = false,
  });

  /// 获取纯文本内容（去除 HTML 标签）
  String get plainText {
    return content.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  factory SourceChapterContent.fromJson(Map<String, dynamic> json) {
    return SourceChapterContent(
      chapterKey: json['chapter_key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      nextPageUrl: json['next_page_url'] as String?,
      isVip: json['is_vip'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_key': chapterKey,
      'title': title,
      'content': content,
      'next_page_url': nextPageUrl,
      'is_vip': isVip,
    };
  }
}
