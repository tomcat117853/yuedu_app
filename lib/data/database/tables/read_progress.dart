import 'package:drift/drift.dart';

/// 阅读进度表定义
class ReadProgressTable extends Table {
  /// 书籍ID（主键）
  TextColumn get bookId => text()();

  /// 当前章节索引
  IntColumn get chapterIndex => integer().withDefault(const Constant(0))();

  /// 当前页索引
  IntColumn get pageIndex => integer().withDefault(const Constant(0))();

  /// 字符偏移量
  IntColumn get charOffset => integer().withDefault(const Constant(0))();

  /// 滚动偏移量
  RealColumn get scrollOffset => real().withDefault(const Constant(0.0))();

  /// 累计阅读时间（秒）
  IntColumn get readingTime => integer().withDefault(const Constant(0))();

  /// 最后阅读时间
  DateTimeColumn get lastReadAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// 阅读进度百分比
  RealColumn get progressPercent => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {bookId};

  @override
  List<Set<Column>> get uniqueKeys => [];
}
