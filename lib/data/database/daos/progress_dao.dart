import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/read_progress.dart';
import '../tables/bookmarks.dart';

part 'progress_dao.g.dart';

/// 阅读进度数据访问对象
@DriftAccessor(tables: [ReadProgressTable, Bookmarks])
class ProgressDao extends DatabaseAccessor<AppDatabase>
    with _$ProgressDaoMixin {
  ProgressDao(super.db);

  /// 获取阅读进度
  Future<ReadProgress?> getProgress(String bookId) {
    return (select(readProgressTable)
          ..where((t) => t.bookId.equals(bookId)))
        .getSingleOrNull();
  }

  /// 获取所有阅读进度
  Future<List<ReadProgress>> getAllProgress() {
    return (select(readProgressTable)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.lastReadAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// 保存或更新阅读进度
  Future<void> saveProgress(ReadProgressTableCompanion progress) {
    return into(readProgressTable)
        .insertOnConflictUpdate(progress);
  }

  /// 删除阅读进度
  Future<int> deleteProgress(String bookId) {
    return (delete(readProgressTable)..where((t) => t.bookId.equals(bookId)))
        .go();
  }

  /// 获取最近阅读的进度
  Future<List<ReadProgress>> getRecentProgress({int limit = 10}) {
    return (select(readProgressTable)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.lastReadAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }

  /// 监听进度变化
  Stream<ReadProgress?> watchProgress(String bookId) {
    return (select(readProgressTable)
          ..where((t) => t.bookId.equals(bookId)))
        .watchSingleOrNull();
  }

  // ==================== 书签相关 ====================

  /// 获取书籍的所有书签
  Future<List<Bookmark>> getBookmarks(String bookId) {
    return (select(bookmarks)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.chapterIndex),
            (t) => OrderingTerm(expression: t.charOffset),
          ]))
        .get();
  }

  /// 添加书签
  Future<void> insertBookmark(BookmarksCompanion bookmark) {
    return into(bookmarks).insert(bookmark);
  }

  /// 删除书签
  Future<int> deleteBookmark(String id) {
    return (delete(bookmarks)..where((t) => t.id.equals(id))).go();
  }

  /// 删除书籍的所有书签
  Future<int> deleteBookmarksByBookId(String bookId) {
    return (delete(bookmarks)..where((t) => t.bookId.equals(bookId))).go();
  }

  /// 监听书签变化
  Stream<List<Bookmark>> watchBookmarks(String bookId) {
    return (select(bookmarks)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.chapterIndex),
            (t) => OrderingTerm(expression: t.charOffset),
          ]))
        .watch();
  }
}
