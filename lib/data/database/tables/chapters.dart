import 'package:drift/drift.dart';

/// 章节表定义
class Chapters extends Table {
  /// 主键ID
  TextColumn get id => text()();

  /// 所属书籍ID
  TextColumn get bookId => text()();

  /// 书源ID
  TextColumn get sourceId => text().nullable()();

  /// 章节键值
  TextColumn get chapterKey => text()();

  /// 章节标题
  TextColumn get title => text()();

  /// 排序索引
  IntColumn get orderIndex => integer()();

  /// 内容存储路径
  TextColumn get contentPath => text().nullable()();

  /// 是否已缓存
  BoolColumn get isCached => boolean().withDefault(const Constant(false))();

  /// 是否VIP章节
  BoolColumn get isVip => boolean().withDefault(const Constant(false))();

  /// 字数
  IntColumn get wordCount => integer().withDefault(const Constant(0))();

  /// 获取时间
  DateTimeColumn get fetchedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];
}
