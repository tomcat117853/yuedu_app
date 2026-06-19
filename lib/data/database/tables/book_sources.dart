import 'package:drift/drift.dart';

/// 书源表定义
class BookSources extends Table {
  /// 主键ID
  TextColumn get id => text()();

  /// 书籍ID
  TextColumn get bookId => text()();

  /// 书源ID
  TextColumn get sourceId => text()();

  /// 书源名称
  TextColumn get sourceName => text()();

  /// 书源中的书籍键值
  TextColumn get bookKey => text()();

  /// 是否为主要书源
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  /// 置信度 (0.0 - 1.0)
  RealColumn get confidence => real().withDefault(const Constant(0.5))();

  /// 评分
  RealColumn get score => real().withDefault(const Constant(0.0))();

  /// 最后检查时间
  DateTimeColumn get lastCheck => dateTime().nullable()();

  /// 最后可用时间
  DateTimeColumn get lastAvailable => dateTime().nullable()();

  /// 章节数量
  IntegerColumn get chapterCount => integer().withDefault(const Constant(0))();

  /// 是否启用
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];
}
