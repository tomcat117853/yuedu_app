import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/chapters.dart';

part 'chapter_dao.g.dart';

/// 章节数据访问对象
@DriftAccessor(tables: [Chapters])
class ChapterDao extends DatabaseAccessor<AppDatabase> with _$ChapterDaoMixin {
  ChapterDao(super.db);

  /// 根据书籍ID获取所有章节
  Future<List<Chapter>> getChaptersByBookId(String bookId) {
    return (select(chapters)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .get();
  }

  /// 根据ID获取章节
  Future<Chapter?> getChapterById(String id) {
    return (select(chapters)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// 根据书籍ID和排序索引获取章节
  Future<Chapter?> getChapterByOrderIndex(String bookId, int orderIndex) {
    return (select(chapters)
          ..where((t) =>
              t.bookId.equals(bookId) & t.orderIndex.equals(orderIndex)))
        .getSingleOrNull();
  }

  /// 插入章节
  Future<void> insertChapter(ChaptersCompanion chapter) {
    return into(chapters).insert(chapter, mode: InsertMode.insertOrReplace);
  }

  /// 批量插入章节
  Future<void> insertChapters(List<ChaptersCompanion> chaptersList) {
    return batch((b) {
      b.insertAll(chapters, chaptersList, mode: InsertMode.insertOrReplace);
    });
  }

  /// 更新章节
  Future<bool> updateChapter(ChaptersCompanion chapter) {
    return (update(chapters)..where((t) => t.id.equals(chapter.id.value)))
        .write(chapter)
        .then((rows) => rows > 0);
  }

  /// 删除书籍的所有章节
  Future<int> deleteChaptersByBookId(String bookId) {
    return (delete(chapters)..where((t) => t.bookId.equals(bookId))).go();
  }

  /// 删除单个章节
  Future<int> deleteChapter(String id) {
    return (delete(chapters)..where((t) => t.id.equals(id))).go();
  }

  /// 获取已缓存的章节
  Future<List<Chapter>> getCachedChapters(String bookId) {
    return (select(chapters)
          ..where((t) => t.bookId.equals(bookId) & t.isCached.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .get();
  }

  /// 获取未缓存的章节
  Future<List<Chapter>> getUncachedChapters(String bookId) {
    return (select(chapters)
          ..where((t) => t.bookId.equals(bookId) & t.isCached.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .get();
  }

  /// 获取章节总数
  Future<int> getChapterCount(String bookId) async {
    final countExpr = chapters.id.count();
    final query = selectOnly(chapters)
      ..addColumns([countExpr])
      ..where(chapters.bookId.equals(bookId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// 监听章节变化
  Stream<List<Chapter>> watchChaptersByBookId(String bookId) {
    return (select(chapters)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
        .watch();
  }
}
