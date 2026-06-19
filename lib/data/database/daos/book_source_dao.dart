import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/book_sources.dart';

part 'book_source_dao.g.dart';

/// 书源数据访问对象
@DriftAccessor(tables: [BookSources])
class BookSourceDao extends DatabaseAccessor<AppDatabase>
    with _$BookSourceDaoMixin {
  BookSourceDao(super.db);

  /// 根据书籍ID获取书源列表
  Future<List<BookSource>> getSourcesByBookId(String bookId) {
    return (select(bookSources)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.score, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// 根据ID获取书源
  Future<BookSource?> getSourceById(String id) {
    return (select(bookSources)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// 获取所有书源
  Future<List<BookSource>> getAllSources() {
    return (select(bookSources)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.score, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// 获取所有启用的书源
  Future<List<BookSource>> getEnabledSources() {
    return (select(bookSources)
          ..where((t) => t.enabled.equals(true))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.score, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// 获取书籍的主书源
  Future<BookSource?> getPrimarySource(String bookId) {
    return (select(bookSources)
          ..where((t) =>
              t.bookId.equals(bookId) & t.isPrimary.equals(true)))
        .getSingleOrNull();
  }

  /// 插入书源
  Future<void> insertSource(BookSourcesCompanion source) {
    return into(bookSources)
        .insert(source, mode: InsertMode.insertOrReplace);
  }

  /// 批量插入书源
  Future<void> insertSources(List<BookSourcesCompanion> sources) {
    return batch((b) {
      b.insertAll(bookSources, sources, mode: InsertMode.insertOrReplace);
    });
  }

  /// 更新书源
  Future<bool> updateSource(BookSourcesCompanion source) {
    return (update(bookSources)
          ..where((t) => t.id.equals(source.id.value)))
        .write(source)
        .then((rows) => rows > 0);
  }

  /// 删除书源
  Future<int> deleteSource(String id) {
    return (delete(bookSources)..where((t) => t.id.equals(id))).go();
  }

  /// 删除书籍的所有书源
  Future<int> deleteSourcesByBookId(String bookId) {
    return (delete(bookSources)..where((t) => t.bookId.equals(bookId))).go();
  }

  /// 获取书源数量
  Future<int> getSourceCount() async {
    final countExpr = bookSources.id.count();
    final query = selectOnly(bookSources)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// 根据sourceId获取书源（跨书籍）
  Future<List<BookSource>> getSourcesBySourceId(String sourceId) {
    return (select(bookSources)
          ..where((t) => t.sourceId.equals(sourceId)))
        .get();
  }

  /// 监听书源变化
  Stream<List<BookSource>> watchSourcesByBookId(String bookId) {
    return (select(bookSources)
          ..where((t) => t.bookId.equals(bookId))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.score, mode: OrderingMode.desc)
          ]))
        .watch();
  }
}
