import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/books.dart';

part 'book_dao.g.dart';

/// 书籍数据访问对象
@DriftAccessor(tables: [Books])
class BookDao extends DatabaseAccessor<AppDatabase> with _$BookDaoMixin {
  BookDao(super.db);

  /// 获取所有书籍
  Future<List<Book>> getAllBooks() {
    return (select(books)
          ..orderBy([
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// 根据ID获取书籍
  Future<Book?> getBookById(String id) {
    return (select(books)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// 根据分组获取书籍
  Future<List<Book>> getBooksByGroup({String? groupId}) {
    if (groupId == null || groupId == 'all') {
      return getAllBooks();
    }
    return (select(books)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  /// 搜索书籍
  Future<List<Book>> searchBooks(String query) {
    return (select(books)
          ..where((t) =>
              t.title.like('%$query%') | t.author.like('%$query%')))
        .get();
  }

  /// 插入书籍
  Future<void> insertBook(BooksCompanion book) {
    return into(books).insert(book, mode: InsertMode.insertOrReplace);
  }

  /// 更新书籍
  Future<bool> updateBook(BooksCompanion book) {
    return (update(books)..where((t) => t.id.equals(book.id.value)))
        .write(book)
        .then((rows) => rows > 0);
  }

  /// 删除书籍
  Future<int> deleteBook(String id) {
    return (delete(books)..where((t) => t.id.equals(id))).go();
  }

  /// 获取书籍数量
  Future<int> getBookCount() async {
    final countExpr = books.id.count();
    final query = selectOnly(books)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// 获取最近更新的书籍
  Future<List<Book>> getRecentBooks({int limit = 10}) {
    return (select(books)
          ..orderBy([
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ])
          ..limit(limit))
        .get();
  }

  /// 监听所有书籍变化
  Stream<List<Book>> watchAllBooks() {
    return (select(books)
          ..orderBy([
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  /// 监听分组书籍变化
  Stream<List<Book>> watchBooksByGroup(String groupId) {
    return (select(books)
          ..where((t) => t.groupId.equals(groupId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.updatedAt, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  // ==================== 分组管理 ====================

  /// 获取所有分组（从书籍的 groupId 字段派生）
  Future<List<String>> getAllGroups() async {
    final result = await customSelect(
      'SELECT DISTINCT group_id FROM books WHERE group_id IS NOT NULL AND group_id != ""',
    ).get();
    final groups = result.map((row) => row.read<String>('group_id')).toList();
    // 确保默认分组存在
    if (!groups.contains('default')) {
      groups.insert(0, 'default');
    }
    return groups;
  }

  /// 创建分组（如果分组不存在则添加）
  Future<void> createGroup(String name) async {
    // 分组会在书籍添加时自动创建，这里只需确保分组可用
    // 如果需要持久化分组列表，可扩展此方法
  }

  /// 删除分组
  Future<void> deleteGroup(String groupId) async {
    if (groupId == 'default' || groupId == 'all') return;
    // 将该分组的书籍移到默认分组
    await (update(books)..where((t) => t.groupId.equals(groupId)))
        .write(const BooksCompanion(groupId: Value('default')));
  }

  /// 重命名分组
  Future<void> renameGroup(String oldName, String newName) async {
    if (oldName == 'default' || oldName == 'all') return;
    await (update(books)..where((t) => t.groupId.equals(oldName)))
        .write(BooksCompanion(groupId: Value(newName)));
  }
}
