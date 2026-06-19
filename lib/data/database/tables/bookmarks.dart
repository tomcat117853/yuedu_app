import 'package:drift/drift.dart';

/// 书签表定义
class Bookmarks extends Table {
  /// 主键ID
  TextColumn get id => text()();

  /// 书籍ID
  TextColumn get bookId => text()();

  /// 章节索引
  IntegerColumn get chapterIndex => integer()();

  /// 字符偏移量
  IntegerColumn get charOffset => integer()();

  /// 书签标签
  TextColumn get label => text().withDefault(const Constant(''))();

  /// 书签颜色
  TextColumn get color => text().withDefault(const Constant('#FFC107'))();

  /// 创建时间
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];
}

/// 笔记表定义
class Notes extends Table {
  /// 主键ID
  TextColumn get id => text()();

  /// 书籍ID
  TextColumn get bookId => text()();

  /// 章节索引
  IntegerColumn get chapterIndex => integer()();

  /// 起始偏移量
  IntegerColumn get startOffset => integer()();

  /// 结束偏移量
  IntegerColumn get endOffset => integer()();

  /// 选中的内容
  TextColumn get content => text().nullable()();

  /// 笔记内容
  TextColumn get note => text().withDefault(const Constant(''))();

  /// 颜色
  TextColumn get color => text().withDefault(const Constant('#FFC107'))();

  /// 创建时间
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];
}
