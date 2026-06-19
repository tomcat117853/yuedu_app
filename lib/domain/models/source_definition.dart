/// 书源定义模型 - 描述一个书源的完整配置
///
/// 包含搜索规则、详情规则、章节列表规则和内容规则，
/// 使用 CSS 选择器从网页中提取书籍数据。
class SourceDefinition {
  /// 书源名称
  final String bookSourceName;

  /// 书源基础 URL
  final String bookSourceUrl;

  /// 书源分组
  final String bookSourceGroup;

  /// 书源类型（0=文本，1=音频，2=图片）
  final int bookSourceType;

  /// 书源备注
  final String bookSourceComment;

  /// 是否启用
  final bool enabled;

  /// 权重（用于排序，越大越优先）
  final int weight;

  /// 搜索 URL 模板，支持 {{key}} 和 {{page}} 占位符
  final String searchUrl;

  /// 搜索规则
  final SearchRule searchRule;

  /// 详情规则
  final DetailRule detailRule;

  /// 章节列表规则
  final ChapterListRule chapterListRule;

  /// 内容规则
  final ContentRule contentRule;

  /// 登录 URL
  final String loginUrl;

  /// 登录规则
  final Map<String, dynamic> loginRule;

  SourceDefinition({
    required this.bookSourceName,
    required this.bookSourceUrl,
    this.bookSourceGroup = '',
    this.bookSourceType = 0,
    this.bookSourceComment = '',
    this.enabled = true,
    this.weight = 50,
    this.searchUrl = '',
    SearchRule? searchRule,
    DetailRule? detailRule,
    ChapterListRule? chapterListRule,
    ContentRule? contentRule,
    this.loginUrl = '',
    Map<String, dynamic>? loginRule,
  })  : searchRule = searchRule ?? SearchRule(),
        detailRule = detailRule ?? DetailRule(),
        chapterListRule = chapterListRule ?? ChapterListRule(),
        contentRule = contentRule ?? ContentRule(),
        loginRule = loginRule ?? {};

  /// 从 JSON 创建书源定义
  factory SourceDefinition.fromJson(Map<String, dynamic> json) {
    return SourceDefinition(
      bookSourceName: json['bookSourceName'] as String? ?? '',
      bookSourceUrl: json['bookSourceUrl'] as String? ?? '',
      bookSourceGroup: json['bookSourceGroup'] as String? ?? '',
      bookSourceType: json['bookSourceType'] as int? ?? 0,
      bookSourceComment: json['bookSourceComment'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      weight: json['weight'] as int? ?? 50,
      searchUrl: json['searchUrl'] as String? ?? '',
      searchRule: json['searchRule'] != null
          ? SearchRule.fromJson(json['searchRule'] as Map<String, dynamic>)
          : null,
      detailRule: json['detailRule'] != null
          ? DetailRule.fromJson(json['detailRule'] as Map<String, dynamic>)
          : null,
      chapterListRule: json['chapterListRule'] != null
          ? ChapterListRule.fromJson(
              json['chapterListRule'] as Map<String, dynamic>)
          : null,
      contentRule: json['contentRule'] != null
          ? ContentRule.fromJson(json['contentRule'] as Map<String, dynamic>)
          : null,
      loginUrl: json['loginUrl'] as String? ?? '',
      loginRule: (json['loginRule'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'bookSourceName': bookSourceName,
      'bookSourceUrl': bookSourceUrl,
      'bookSourceGroup': bookSourceGroup,
      'bookSourceType': bookSourceType,
      'bookSourceComment': bookSourceComment,
      'enabled': enabled,
      'weight': weight,
      'searchUrl': searchUrl,
      'searchRule': searchRule.toJson(),
      'detailRule': detailRule.toJson(),
      'chapterListRule': chapterListRule.toJson(),
      'contentRule': contentRule.toJson(),
      'loginUrl': loginUrl,
      'loginRule': loginRule,
    };
  }

  /// 书源唯一标识（基于 URL）
  String get id => bookSourceUrl;

  @override
  String toString() =>
      'SourceDefinition(name: $bookSourceName, url: $bookSourceUrl)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceDefinition && bookSourceUrl == other.bookSourceUrl;

  @override
  int get hashCode => bookSourceUrl.hashCode;
}

/// 搜索规则 - 定义如何从搜索结果页面提取书籍列表
class SearchRule {
  /// 书籍列表选择器
  final String bookList;

  /// 书名选择器
  final String name;

  /// 作者选择器
  final String author;

  /// 书籍详情 URL 选择器
  final String bookUrl;

  /// 封面 URL 选择器
  final String coverUrl;

  /// 简介选择器
  final String intro;

  /// 分类选择器
  final String category;

  SearchRule({
    this.bookList = '',
    this.name = '',
    this.author = '',
    this.bookUrl = '',
    this.coverUrl = '',
    this.intro = '',
    this.category = '',
  });

  factory SearchRule.fromJson(Map<String, dynamic> json) {
    return SearchRule(
      bookList: json['bookList'] as String? ?? '',
      name: json['name'] as String? ?? '',
      author: json['author'] as String? ?? '',
      bookUrl: json['bookUrl'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      category: json['category'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookList': bookList,
      'name': name,
      'author': author,
      'bookUrl': bookUrl,
      'coverUrl': coverUrl,
      'intro': intro,
      'category': category,
    };
  }
}

/// 详情规则 - 定义如何从书籍详情页面提取书籍信息
class DetailRule {
  /// 书名选择器
  final String name;

  /// 作者选择器
  final String author;

  /// 简介选择器
  final String intro;

  /// 封面 URL 选择器
  final String coverUrl;

  /// 分类选择器
  final String category;

  /// 字数选择器
  final String wordCount;

  /// 连载状态选择器
  final String status;

  /// 最新章节选择器
  final String lastChapter;

  /// 章节列表页 URL 选择器（当章节列表不在详情页时）
  final String chapterListUrl;

  DetailRule({
    this.name = '',
    this.author = '',
    this.intro = '',
    this.coverUrl = '',
    this.category = '',
    this.wordCount = '',
    this.status = '',
    this.lastChapter = '',
    this.chapterListUrl = '',
  });

  factory DetailRule.fromJson(Map<String, dynamic> json) {
    return DetailRule(
      name: json['name'] as String? ?? '',
      author: json['author'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      wordCount: json['wordCount'] as String? ?? '',
      status: json['status'] as String? ?? '',
      lastChapter: json['lastChapter'] as String? ?? '',
      chapterListUrl: json['chapterListUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'author': author,
      'intro': intro,
      'coverUrl': coverUrl,
      'category': category,
      'wordCount': wordCount,
      'status': status,
      'lastChapter': lastChapter,
      'chapterListUrl': chapterListUrl,
    };
  }
}

/// 章节列表规则 - 定义如何从章节列表页面提取章节信息
class ChapterListRule {
  /// 章节列表容器选择器
  final String chapterList;

  /// 章节名称选择器
  final String chapterName;

  /// 章节 URL 选择器
  final String chapterUrl;

  /// 是否 VIP 章节选择器
  final String isVip;

  ChapterListRule({
    this.chapterList = '',
    this.chapterName = '',
    this.chapterUrl = '',
    this.isVip = '',
  });

  factory ChapterListRule.fromJson(Map<String, dynamic> json) {
    return ChapterListRule(
      chapterList: json['chapterList'] as String? ?? '',
      chapterName: json['chapterName'] as String? ?? '',
      chapterUrl: json['chapterUrl'] as String? ?? '',
      isVip: json['isVip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterList': chapterList,
      'chapterName': chapterName,
      'chapterUrl': chapterUrl,
      'isVip': isVip,
    };
  }
}

/// 内容规则 - 定义如何从章节内容页面提取正文内容
class ContentRule {
  /// 正文内容选择器
  final String content;

  /// 下一页 URL 选择器（用于多页章节）
  final String nextPageUrl;

  /// 正则替换规则列表（用于清除广告等无关内容）
  final List<String> replace;

  ContentRule({
    this.content = '',
    this.nextPageUrl = '',
    List<String>? replace,
  }) : replace = replace ?? [];

  factory ContentRule.fromJson(Map<String, dynamic> json) {
    return ContentRule(
      content: json['content'] as String? ?? '',
      nextPageUrl: json['nextPageUrl'] as String? ?? '',
      replace: (json['replace'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'nextPageUrl': nextPageUrl,
      'replace': replace,
    };
  }
}
