import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';
import '../../domain/models/chapter_content.dart';
import '../../domain/models/read_progress.dart';
import '../../domain/models/bookmark.dart';
import '../database/app_database.dart';
import '../database/tables/books.dart';
import '../database/tables/chapters.dart';
import '../database/tables/read_progress.dart';
import '../database/tables/bookmarks.dart';

const _uuid = Uuid();

/// 书籍仓库 - 封装数据库操作，提供领域模型转换
class BookRepository {
  final AppDatabase _db;

  BookRepository(this._db);

  /// 生成唯一ID
  String generateId() => _uuid.v4();

  /// 获取所有书籍
  Future<List<Book>> getAllBooks() async {
    final entities = await _db.bookDao.getAllBooks();
    return entities.map(_entityToModel).toList();
  }

  /// 根据ID获取书籍
  Future<Book?> getBookById(String id) async {
    final entity = await _db.bookDao.getBookById(id);
    return entity != null ? _entityToModel(entity) : null;
  }

  /// 根据分组获取书籍
  Future<List<Book>> getBooksByGroup({String? groupId}) async {
    final entities = await _db.bookDao.getBooksByGroup(groupId: groupId);
    return entities.map(_entityToModel).toList();
  }

  /// 插入书籍
  Future<void> insertBook(Book book) async {
    await _db.bookDao.insertBook(_modelToCompanion(book));
  }

  /// 批量插入章节
  Future<void> insertChapters(List<Chapter> chapterList) async {
    final companions = chapterList.map(_chapterModelToCompanion).toList();
    await _db.chapterDao.insertChapters(companions);
  }

  /// 插入单个章节
  Future<void> insertChapter(Chapter chapter) async {
    await _db.chapterDao.insertChapter(_chapterModelToCompanion(chapter));
  }

  /// 更新书籍
  Future<void> updateBook(Book book) async {
    await _db.bookDao.updateBook(_modelToCompanion(book));
  }

  /// 删除书籍
  Future<void> deleteBook(String id) async {
    await _db.bookDao.deleteBook(id);
    // 同时删除关联数据
    await _db.chapterDao.deleteChaptersByBookId(id);
    await _db.progressDao.deleteProgress(id);
    await _db.progressDao.deleteBookmarksByBookId(id);
  }

  /// 搜索书籍
  Future<List<Book>> searchBooks(String query) async {
    final entities = await _db.bookDao.searchBooks(query);
    return entities.map(_entityToModel).toList();
  }

  /// 获取书籍的章节列表
  Future<List<Chapter>> getChaptersByBookId(String bookId) async {
    final entities = await _db.chapterDao.getChaptersByBookId(bookId);
    return entities.map(_chapterEntityToModel).toList();
  }

  /// 获取章节内容
  Future<ChapterContent> getChapterContent(
      String bookId, int chapterIndex) async {
    final chapter =
        await _db.chapterDao.getChapterByOrderIndex(bookId, chapterIndex);
    if (chapter == null) {
      return ChapterContent(
        chapterId: '',
        bookId: bookId,
        title: '',
        content: '',
      );
    }

    // 如果有缓存路径，从文件读取
    String content = '';
    if (chapter.contentPath != null) {
      try {
        final file = _db as dynamic;
        content = '已缓存内容'; // 实际从文件读取
      } catch (_) {
        content = '';
      }
    }

    return ChapterContent(
      chapterId: chapter.id,
      bookId: bookId,
      title: chapter.title,
      content: content,
      wordCount: chapter.wordCount,
      isVip: chapter.isVip,
      fetchedAt: chapter.fetchedAt,
    );
  }

  /// 保存阅读进度
  Future<void> saveReadProgress(ReadProgress progress) async {
    await _db.progressDao.saveProgress(
      ReadProgressTableCompanion(
        bookId: drift.Value(progress.bookId),
        chapterIndex: drift.Value(progress.chapterIndex),
        pageIndex: drift.Value(progress.pageIndex),
        charOffset: drift.Value(progress.charOffset),
        scrollOffset: drift.Value(progress.scrollOffset),
        readingTime: drift.Value(progress.readingTime),
        lastReadAt: drift.Value(progress.lastReadAt),
        progressPercent: drift.Value(progress.progressPercent),
      ),
    );
  }

  /// 获取阅读进度
  Future<ReadProgress?> getReadProgress(String bookId) async {
    final entity = await _db.progressDao.getProgress(bookId);
    if (entity == null) return null;
    return _progressEntityToModel(entity);
  }

  /// 获取所有阅读进度
  Future<List<ReadProgress>> getAllProgress() async {
    final entities = await _db.progressDao.getAllProgress();
    return entities.map(_progressEntityToModel).toList();
  }

  /// 获取书签列表
  Future<List<Bookmark>> getBookmarks(String bookId) async {
    final entities = await _db.progressDao.getBookmarks(bookId);
    return entities.map(_bookmarkEntityToModel).toList();
  }

  /// 添加书签
  Future<void> insertBookmark(Bookmark bookmark) async {
    await _db.progressDao.insertBookmark(
      BookmarksCompanion(
        id: drift.Value(bookmark.id),
        bookId: drift.Value(bookmark.bookId),
        chapterIndex: drift.Value(bookmark.chapterIndex),
        charOffset: drift.Value(bookmark.charOffset),
        label: drift.Value(bookmark.label),
        color: drift.Value(bookmark.color),
        createdAt: drift.Value(bookmark.createdAt),
      ),
    );
  }

  /// 删除书签
  Future<void> deleteBookmark(String id) async {
    await _db.progressDao.deleteBookmark(id);
  }

  /// 监听所有书籍变化
  Stream<List<Book>> watchAllBooks() {
    return _db.bookDao.watchAllBooks().map(
          (entities) => entities.map(_entityToModel).toList(),
        );
  }

  /// 监听分组书籍变化
  Stream<List<Book>> watchBooksByGroup(String groupId) {
    return _db.bookDao.watchBooksByGroup(groupId).map(
          (entities) => entities.map(_entityToModel).toList(),
        );
  }

  // ==================== 转换方法 ====================

  /// 数据库实体转领域模型
  Book _entityToModel(Book entity) {
    return Book(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      coverPath: entity.coverPath,
      intro: entity.intro,
      category: entity.category,
      type: entity.type,
      localPath: entity.localPath,
      format: entity.format,
      totalChapters: entity.totalChapters,
      wordCount: entity.wordCount,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      groupId: entity.groupId,
      sortOrder: entity.sortOrder,
    );
  }

  /// 领域模型转数据库Companion
  BooksCompanion _modelToCompanion(Book book) {
    return BooksCompanion(
      id: drift.Value(book.id),
      title: drift.Value(book.title),
      author: drift.Value(book.author),
      coverPath: drift.Value(book.coverPath),
      intro: drift.Value(book.intro),
      category: drift.Value(book.category),
      type: drift.Value(book.type),
      localPath: drift.Value(book.localPath),
      format: drift.Value(book.format),
      totalChapters: drift.Value(book.totalChapters),
      wordCount: drift.Value(book.wordCount),
      status: drift.Value(book.status),
      createdAt: drift.Value(book.createdAt),
      updatedAt: drift.Value(book.updatedAt),
      groupId: drift.Value(book.groupId),
      sortOrder: drift.Value(book.sortOrder),
    );
  }

  /// 章节实体转模型
  Chapter _chapterEntityToModel(Chapter entity) {
    return Chapter(
      id: entity.id,
      bookId: entity.bookId,
      sourceId: entity.sourceId,
      chapterKey: entity.chapterKey,
      title: entity.title,
      orderIndex: entity.orderIndex,
      contentPath: entity.contentPath,
      isCached: entity.isCached,
      isVip: entity.isVip,
      wordCount: entity.wordCount,
      fetchedAt: entity.fetchedAt,
    );
  }

  /// 章节模型转数据库Companion
  ChaptersCompanion _chapterModelToCompanion(Chapter chapter) {
    return ChaptersCompanion(
      id: drift.Value(chapter.id),
      bookId: drift.Value(chapter.bookId),
      sourceId: drift.Value(chapter.sourceId),
      chapterKey: drift.Value(chapter.chapterKey),
      title: drift.Value(chapter.title),
      orderIndex: drift.Value(chapter.orderIndex),
      contentPath: drift.Value(chapter.contentPath),
      isCached: drift.Value(chapter.isCached),
      isVip: drift.Value(chapter.isVip),
      wordCount: drift.Value(chapter.wordCount),
      fetchedAt: drift.Value(chapter.fetchedAt),
    );
  }

  /// 阅读进度实体转模型
  ReadProgress _progressEntityToModel(ReadProgress entity) {
    return ReadProgress(
      bookId: entity.bookId,
      chapterIndex: entity.chapterIndex,
      pageIndex: entity.pageIndex,
      charOffset: entity.charOffset,
      scrollOffset: entity.scrollOffset,
      readingTime: entity.readingTime,
      lastReadAt: entity.lastReadAt,
      progressPercent: entity.progressPercent,
    );
  }

  /// 书签实体转模型
  Bookmark _bookmarkEntityToModel(Bookmark entity) {
    return Bookmark(
      id: entity.id,
      bookId: entity.bookId,
      chapterIndex: entity.chapterIndex,
      charOffset: entity.charOffset,
      label: entity.label,
      color: entity.color,
      createdAt: entity.createdAt,
    );
  }
}
