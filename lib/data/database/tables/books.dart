import 'package:drift/drift.dart';

/// 书籍表定义
class Books extends Table {
  /// 主键ID
  TextColumn get id => text()();

  /// 书名
  TextColumn get title => text().withLength(min: 1, max: 500)();

  /// 作者
  TextColumn get author => text().withDefault(const Constant(''))();

  /// 封面路径
  TextColumn get coverPath => text().nullable()();

  /// 简介
  TextColumn get intro => text().nullable()();

  /// 分类
  TextColumn get category => text().nullable()();

  /// 类型: local, online, hybrid
  TextColumn get type => text().withDefault(const Constant('local'))();

  /// 本地文件路径
  TextColumn get localPath => text().nullable()();

  /// 格式: txt, epub, pdf
  TextColumn get format => text().withDefault(const Constant('txt'))();

  /// 总章节数
  IntegerColumn get totalChapters => integer().withDefault(const Constant(0))();

  /// 总字数
  IntegerColumn get wordCount => integer().withDefault(const Constant(0))();

  /// 状态: 0=reading, 1=finished, 2=archived
  IntegerColumn get status => integer().withDefault(const Constant(0))();

  /// 创建时间
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// 更新时间
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// 分组ID
  TextColumn get groupId => text().withDefault(const Constant('default'))();

  /// 排序
  IntegerColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];
}
