import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import '../../data/database/app_database.dart' as db;
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/source_repository.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_source.dart';
import '../../domain/models/read_progress.dart';
import '../../domain/models/bookmark.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/layout_config.dart';
import '../../domain/models/reader_theme.dart';

/// 备份数据模型
class BackupData {
  final String version;
  final DateTime createdAt;
  final List<BookData> books;
  final List<ChapterData> chapters;
  final List<BookSourceData> bookSources;
  final List<ProgressData> readProgress;
  final List<BookmarkData> bookmarks;
  final SettingsData settings;

  BackupData({
    required this.version,
    required this.createdAt,
    List<BookData>? books,
    List<ChapterData>? chapters,
    List<BookSourceData>? bookSources,
    List<ProgressData>? readProgress,
    List<BookmarkData>? bookmarks,
    required this.settings,
  }) : books = books ?? [],
       chapters = chapters ?? [],
       bookSources = bookSources ?? [],
       readProgress = readProgress ?? [],
       bookmarks = bookmarks ?? [];

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      version: json['version'] as String? ?? '1.0',
      createdAt: DateTime.parse(json['created_at'] as String),
      books: (json['books'] as List?)
          ?.map((e) => BookData.fromJson(e as Map<String, dynamic>))
          .toList(),
      chapters: (json['chapters'] as List?)
          ?.map((e) => ChapterData.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookSources: (json['book_sources'] as List?)
          ?.map((e) => BookSourceData.fromJson(e as Map<String, dynamic>))
          .toList(),
      readProgress: (json['read_progress'] as List?)
          ?.map((e) => ProgressData.fromJson(e as Map<String, dynamic>))
          .toList(),
      bookmarks: (json['bookmarks'] as List?)
          ?.map((e) => BookmarkData.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings: SettingsData.fromJson(json['settings'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'books': books.map((e) => e.toJson()).toList(),
      'chapters': chapters.map((e) => e.toJson()).toList(),
      'book_sources': bookSources.map((e) => e.toJson()).toList(),
      'read_progress': readProgress.map((e) => e.toJson()).toList(),
      'bookmarks': bookmarks.map((e) => e.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }
}

/// 书籍数据
class BookData {
  final String id;
  final String title;
  final String? author;
  final String? coverPath;
  final String? intro;
  final String? category;
  final int type;
  final String? localPath;
  final String? format;
  final int totalChapters;
  final int? wordCount;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? groupId;
  final int sortOrder;

  BookData({
    required this.id,
    required this.title,
    this.author,
    this.coverPath,
    this.intro,
    this.category,
    this.type = 0,
    this.localPath,
    this.format,
    this.totalChapters = 0,
    this.wordCount,
    this.status = 0,
    required this.createdAt,
    required this.updatedAt,
    this.groupId,
    this.sortOrder = 0,
  });

  factory BookData.fromJson(Map<String, dynamic> json) {
    return BookData(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      coverPath: json['cover_path'] as String?,
      intro: json['intro'] as String?,
      category: json['category'] as String?,
      type: json['type'] as int? ?? 0,
      localPath: json['local_path'] as String?,
      format: json['format'] as String?,
      totalChapters: json['total_chapters'] as int? ?? 0,
      wordCount: json['word_count'] as int?,
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      groupId: json['group_id'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

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

  factory BookData.fromModel(Book book) {
    return BookData(
      id: book.id,
      title: book.title,
      author: book.author,
      coverPath: book.coverPath,
      intro: book.intro,
      category: book.category,
      type: book.type,
      localPath: book.localPath,
      format: book.format,
      totalChapters: book.totalChapters,
      wordCount: book.wordCount,
      status: book.status,
      createdAt: book.createdAt,
      updatedAt: book.updatedAt,
      groupId: book.groupId,
      sortOrder: book.sortOrder,
    );
  }
}

/// 章节数据
class ChapterData {
  final String id;
  final String bookId;
  final String? sourceId;
  final String? chapterKey;
  final String title;
  final int orderIndex;
  final String? contentPath;
  final bool isCached;
  final bool isVip;
  final int? wordCount;
  final DateTime? fetchedAt;

  ChapterData({
    required this.id,
    required this.bookId,
    this.sourceId,
    this.chapterKey,
    required this.title,
    this.orderIndex = 0,
    this.contentPath,
    this.isCached = false,
    this.isVip = false,
    this.wordCount,
    this.fetchedAt,
  });

  factory ChapterData.fromJson(Map<String, dynamic> json) {
    return ChapterData(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      sourceId: json['source_id'] as String?,
      chapterKey: json['chapter_key'] as String?,
      title: json['title'] as String,
      orderIndex: json['order_index'] as int? ?? 0,
      contentPath: json['content_path'] as String?,
      isCached: json['is_cached'] as bool? ?? false,
      isVip: json['is_vip'] as bool? ?? false,
      wordCount: json['word_count'] as int?,
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

  factory ChapterData.fromModel(Chapter chapter) {
    return ChapterData(
      id: chapter.id,
      bookId: chapter.bookId,
      sourceId: chapter.sourceId,
      chapterKey: chapter.chapterKey,
      title: chapter.title,
      orderIndex: chapter.orderIndex,
      contentPath: chapter.contentPath,
      isCached: chapter.isCached,
      isVip: chapter.isVip,
      wordCount: chapter.wordCount,
      fetchedAt: chapter.fetchedAt,
    );
  }
}

/// 书源数据
class BookSourceData {
  final String id;
  final String bookId;
  final String sourceId;
  final String sourceName;
  final String bookKey;
  final bool isPrimary;
  final double confidence;
  final double score;
  final DateTime? lastCheck;
  final DateTime? lastAvailable;
  final int chapterCount;
  final bool enabled;

  BookSourceData({
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

  factory BookSourceData.fromJson(Map<String, dynamic> json) {
    return BookSourceData(
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

  factory BookSourceData.fromModel(BookSource source) {
    return BookSourceData(
      id: source.id,
      bookId: source.bookId,
      sourceId: source.sourceId,
      sourceName: source.sourceName,
      bookKey: source.bookKey,
      isPrimary: source.isPrimary,
      confidence: source.confidence,
      score: source.score,
      lastCheck: source.lastCheck,
      lastAvailable: source.lastAvailable,
      chapterCount: source.chapterCount,
      enabled: source.enabled,
    );
  }
}

/// 阅读进度数据
class ProgressData {
  final String bookId;
  final int chapterIndex;
  final int pageIndex;
  final int charOffset;
  final double scrollOffset;
  final int readingTime;
  final DateTime lastReadAt;
  final double progressPercent;

  ProgressData({
    required this.bookId,
    this.chapterIndex = 0,
    this.pageIndex = 0,
    this.charOffset = 0,
    this.scrollOffset = 0.0,
    this.readingTime = 0,
    required this.lastReadAt,
    this.progressPercent = 0.0,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      bookId: json['book_id'] as String,
      chapterIndex: json['chapter_index'] as int? ?? 0,
      pageIndex: json['page_index'] as int? ?? 0,
      charOffset: json['char_offset'] as int? ?? 0,
      scrollOffset: (json['scroll_offset'] as num?)?.toDouble() ?? 0.0,
      readingTime: json['reading_time'] as int? ?? 0,
      lastReadAt: DateTime.parse(json['last_read_at'] as String),
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
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

  factory ProgressData.fromModel(ReadProgress progress) {
    return ProgressData(
      bookId: progress.bookId,
      chapterIndex: progress.chapterIndex,
      pageIndex: progress.pageIndex,
      charOffset: progress.charOffset,
      scrollOffset: progress.scrollOffset,
      readingTime: progress.readingTime,
      lastReadAt: progress.lastReadAt,
      progressPercent: progress.progressPercent,
    );
  }
}

/// 书签数据
class BookmarkData {
  final String id;
  final String bookId;
  final int chapterIndex;
  final int charOffset;
  final String? label;
  final int? color;
  final DateTime createdAt;

  BookmarkData({
    required this.id,
    required this.bookId,
    this.chapterIndex = 0,
    this.charOffset = 0,
    this.label,
    this.color,
    required this.createdAt,
  });

  factory BookmarkData.fromJson(Map<String, dynamic> json) {
    return BookmarkData(
      id: json['id'] as String,
      bookId: json['book_id'] as String,
      chapterIndex: json['chapter_index'] as int? ?? 0,
      charOffset: json['char_offset'] as int? ?? 0,
      label: json['label'] as String?,
      color: json['color'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
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

  factory BookmarkData.fromModel(Bookmark bookmark) {
    return BookmarkData(
      id: bookmark.id,
      bookId: bookmark.bookId,
      chapterIndex: bookmark.chapterIndex,
      charOffset: bookmark.charOffset,
      label: bookmark.label,
      color: bookmark.color,
      createdAt: bookmark.createdAt,
    );
  }
}

/// 设置数据
class SettingsData {
  final int themeIndex;
  final double fontSize;
  final double lineHeight;
  final double paragraphSpacing;
  final double margin;
  final int indentChars;
  final String fontFamily;
  final int fontWeight;
  final double letterSpacing;
  final int readMode;

  const SettingsData({
    this.themeIndex = 0,
    this.fontSize = 18.0,
    this.lineHeight = 1.6,
    this.paragraphSpacing = 0.8,
    this.margin = 24.0,
    this.indentChars = 2,
    this.fontFamily = 'system',
    this.fontWeight = 0,
    this.letterSpacing = 0.0,
    this.readMode = 0,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      themeIndex: json['theme_index'] as int? ?? 0,
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 18.0,
      lineHeight: (json['line_height'] as num?)?.toDouble() ?? 1.6,
      paragraphSpacing: (json['paragraph_spacing'] as num?)?.toDouble() ?? 0.8,
      margin: (json['margin'] as num?)?.toDouble() ?? 24.0,
      indentChars: json['indent_chars'] as int? ?? 2,
      fontFamily: json['font_family'] as String? ?? 'system',
      fontWeight: json['font_weight'] as int? ?? 0,
      letterSpacing: (json['letter_spacing'] as num?)?.toDouble() ?? 0.0,
      readMode: json['read_mode'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme_index': themeIndex,
      'font_size': fontSize,
      'line_height': lineHeight,
      'paragraph_spacing': paragraphSpacing,
      'margin': margin,
      'indent_chars': indentChars,
      'font_family': fontFamily,
      'font_weight': fontWeight,
      'letter_spacing': letterSpacing,
      'read_mode': readMode,
    };
  }

  factory SettingsData.fromConfig(LayoutConfig config, ReaderTheme theme, int readMode) {
    return SettingsData(
      themeIndex: theme.themeIndex,
      fontSize: config.fontSize,
      lineHeight: config.lineHeight,
      paragraphSpacing: config.paragraphSpacing,
      margin: config.margin,
      indentChars: config.indentChars,
      fontFamily: config.fontFamily,
      fontWeight: config.fontWeight,
      letterSpacing: config.letterSpacing,
      readMode: readMode,
    );
  }
}

/// 备份服务 - 数据导出与恢复
class BackupService {
  final db.AppDatabase _db;
  final BookRepository _bookRepository;
  final SourceRepository _sourceRepository;

  static const String _backupVersion = '1.0';
  static const String _backupFileName = 'yuedu_backup.json';

  BackupService(
    this._db,
    this._bookRepository,
    this._sourceRepository,
  );

  /// 导出所有数据到JSON文件
  Future<String> exportData({
    LayoutConfig? layoutConfig,
    ReaderTheme? theme,
    int readMode = 0,
  }) async {
    // 收集所有数据
    final books = await _bookRepository.getAllBooks();
    final allChapters = <Chapter>[];
    for (final book in books) {
      final chapters = await _bookRepository.getChaptersByBookId(book.id);
      allChapters.addAll(chapters);
    }
    
    final bookSources = await _sourceRepository.getAllSources();
    final readProgress = await _bookRepository.getAllProgress();
    
    // 收集所有书签
    final allBookmarks = <Bookmark>[];
    for (final book in books) {
      final bookmarks = await _bookRepository.getBookmarks(book.id);
      allBookmarks.addAll(bookmarks);
    }

    // 构建备份数据
    final backupData = BackupData(
      version: _backupVersion,
      createdAt: DateTime.now(),
      books: books.map(BookData.fromModel).toList(),
      chapters: allChapters.map(ChapterData.fromModel).toList(),
      bookSources: bookSources.map(BookSourceData.fromModel).toList(),
      readProgress: readProgress.map(ProgressData.fromModel).toList(),
      bookmarks: allBookmarks.map(BookmarkData.fromModel).toList(),
      settings: SettingsData.fromConfig(
        layoutConfig ?? const LayoutConfig(),
        theme ?? ReaderTheme.presets[0],
        readMode,
      ),
    );

    // 转换为JSON
    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData.toJson());

    // 保存到文件
    final backupDir = await _getBackupDirectory();
    final backupFile = File(p.join(backupDir.path, _backupFileName));
    await backupFile.writeAsString(jsonString);

    return backupFile.path;
  }

  /// 导入数据从JSON文件
  Future<ImportResult> importData(String filePath, {bool merge = false}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult(success: false, message: '文件不存在');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final backupData = BackupData.fromJson(jsonData);

      // 验证版本
      if (backupData.version != _backupVersion) {
        return ImportResult(
          success: false, 
          message: '备份版本不兼容: ${backupData.version}',
        );
      }

      if (!merge) {
        // 清空现有数据
        await _clearAllData();
      }

      // 导入书籍
      int booksImported = 0;
      for (final bookData in backupData.books) {
        await _importBook(bookData);
        booksImported++;
      }

      // 导入章节
      int chaptersImported = 0;
      for (final chapterData in backupData.chapters) {
        await _importChapter(chapterData);
        chaptersImported++;
      }

      // 导入书源
      int sourcesImported = 0;
      for (final sourceData in backupData.bookSources) {
        await _importBookSource(sourceData);
        sourcesImported++;
      }

      // 导入阅读进度
      int progressImported = 0;
      for (final progressData in backupData.readProgress) {
        await _importProgress(progressData);
        progressImported++;
      }

      // 导入书签
      int bookmarksImported = 0;
      for (final bookmarkData in backupData.bookmarks) {
        await _importBookmark(bookmarkData);
        bookmarksImported++;
      }

      return ImportResult(
        success: true,
        message: '导入成功',
        booksImported: booksImported,
        chaptersImported: chaptersImported,
        sourcesImported: sourcesImported,
        progressImported: progressImported,
        bookmarksImported: bookmarksImported,
        settings: backupData.settings,
      );
    } catch (e) {
      return ImportResult(success: false, message: '导入失败: $e');
    }
  }

  /// 分享备份文件
  Future<void> shareBackup(String filePath) async {
    await Share.shareXFiles([XFile(filePath)], subject: '阅读App数据备份');
  }

  /// 获取备份目录
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDir.path, 'backup'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// 清空所有数据
  Future<void> _clearAllData() async {
    await _db.delete(_db.books).go();
    await _db.delete(_db.chapters).go();
    await _db.delete(_db.bookSources).go();
    await _db.delete(_db.readProgressTable).go();
    await _db.delete(_db.bookmarks).go();
  }

  /// 导入单本书籍
  Future<void> _importBook(BookData data) async {
    await _db.into(_db.books).insert(
      db.BooksCompanion(
        id: Value(data.id),
        title: Value(data.title),
        author: Value(data.author),
        coverPath: Value(data.coverPath),
        intro: Value(data.intro),
        category: Value(data.category),
        type: Value(data.type),
        localPath: Value(data.localPath),
        format: Value(data.format),
        totalChapters: Value(data.totalChapters),
        wordCount: Value(data.wordCount),
        status: Value(data.status),
        createdAt: Value(data.createdAt),
        updatedAt: Value(data.updatedAt),
        groupId: Value(data.groupId),
        sortOrder: Value(data.sortOrder),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// 导入单个章节
  Future<void> _importChapter(ChapterData data) async {
    await _db.into(_db.chapters).insert(
      db.ChaptersCompanion(
        id: Value(data.id),
        bookId: Value(data.bookId),
        sourceId: Value(data.sourceId),
        chapterKey: Value(data.chapterKey),
        title: Value(data.title),
        orderIndex: Value(data.orderIndex),
        contentPath: Value(data.contentPath),
        isCached: Value(data.isCached),
        isVip: Value(data.isVip),
        wordCount: Value(data.wordCount),
        fetchedAt: Value(data.fetchedAt),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// 导入单个书源
  Future<void> _importBookSource(BookSourceData data) async {
    await _db.into(_db.bookSources).insert(
      db.BookSourcesCompanion(
        id: Value(data.id),
        bookId: Value(data.bookId),
        sourceId: Value(data.sourceId),
        sourceName: Value(data.sourceName),
        bookKey: Value(data.bookKey),
        isPrimary: Value(data.isPrimary),
        confidence: Value(data.confidence),
        score: Value(data.score),
        lastCheck: Value(data.lastCheck),
        lastAvailable: Value(data.lastAvailable),
        chapterCount: Value(data.chapterCount),
        enabled: Value(data.enabled),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// 导入阅读进度
  Future<void> _importProgress(ProgressData data) async {
    await _db.into(_db.readProgressTable).insert(
      db.ReadProgressTableCompanion(
        bookId: Value(data.bookId),
        chapterIndex: Value(data.chapterIndex),
        pageIndex: Value(data.pageIndex),
        charOffset: Value(data.charOffset),
        scrollOffset: Value(data.scrollOffset),
        readingTime: Value(data.readingTime),
        lastReadAt: Value(data.lastReadAt),
        progressPercent: Value(data.progressPercent),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// 导入书签
  Future<void> _importBookmark(BookmarkData data) async {
    await _db.into(_db.bookmarks).insert(
      db.BookmarksCompanion(
        id: Value(data.id),
        bookId: Value(data.bookId),
        chapterIndex: Value(data.chapterIndex),
        charOffset: Value(data.charOffset),
        label: Value(data.label),
        color: Value(data.color),
        createdAt: Value(data.createdAt),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  /// 获取备份文件列表
  Future<List<BackupFileInfo>> getBackupFiles() async {
    final backupDir = await _getBackupDirectory();
    final files = await backupDir.list().toList();
    
    final backupFiles = <BackupFileInfo>[];
    for (final file in files) {
      if (file is File && p.extension(file.path) == '.json') {
        try {
          final jsonString = await file.readAsString();
          final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
          final backupData = BackupData.fromJson(jsonData);
          
          backupFiles.add(BackupFileInfo(
            path: file.path,
            createdAt: backupData.createdAt,
            bookCount: backupData.books.length,
            version: backupData.version,
          ));
        } catch (_) {
          // 跳过无效文件
        }
      }
    }
    
    // 按创建时间排序（最新的在前）
    backupFiles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backupFiles;
  }

  /// 删除备份文件
  Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

/// 导入结果
class ImportResult {
  final bool success;
  final String message;
  final int booksImported;
  final int chaptersImported;
  final int sourcesImported;
  final int progressImported;
  final int bookmarksImported;
  final SettingsData? settings;

  ImportResult({
    required this.success,
    required this.message,
    this.booksImported = 0,
    this.chaptersImported = 0,
    this.sourcesImported = 0,
    this.progressImported = 0,
    this.bookmarksImported = 0,
    this.settings,
  });
}

/// 备份文件信息
class BackupFileInfo {
  final String path;
  final DateTime createdAt;
  final int bookCount;
  final String version;

  BackupFileInfo({
    required this.path,
    required this.createdAt,
    required this.bookCount,
    required this.version,
  });
}