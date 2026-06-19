// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _coverPathMeta =
      const VerificationMeta('coverPath');
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
      'cover_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _introMeta = const VerificationMeta('intro');
  @override
  late final GeneratedColumn<String> intro = GeneratedColumn<String>(
      'intro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
      'format', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('txt'));
  static const VerificationMeta _totalChaptersMeta =
      const VerificationMeta('totalChapters');
  @override
  late final GeneratedColumn<int> totalChapters = GeneratedColumn<int>(
      'total_chapters', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _wordCountMeta =
      const VerificationMeta('wordCount');
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
      'word_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        author,
        coverPath,
        intro,
        category,
        type,
        localPath,
        format,
        totalChapters,
        wordCount,
        status,
        createdAt,
        updatedAt,
        groupId,
        sortOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(Insertable<Book> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    }
    if (data.containsKey('cover_path')) {
      context.handle(_coverPathMeta,
          coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta));
    }
    if (data.containsKey('intro')) {
      context.handle(
          _introMeta, intro.isAcceptableOrUnknown(data['intro']!, _introMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    }
    if (data.containsKey('format')) {
      context.handle(_formatMeta,
          format.isAcceptableOrUnknown(data['format']!, _formatMeta));
    }
    if (data.containsKey('total_chapters')) {
      context.handle(
          _totalChaptersMeta,
          totalChapters.isAcceptableOrUnknown(
              data['total_chapters']!, _totalChaptersMeta));
    }
    if (data.containsKey('word_count')) {
      context.handle(_wordCountMeta,
          wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      coverPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cover_path']),
      intro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intro']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path']),
      format: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])!,
      totalChapters: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_chapters'])!,
      wordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_count'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  /// 主键ID
  final String id;

  /// 书名
  final String title;

  /// 作者
  final String author;

  /// 封面路径
  final String? coverPath;

  /// 简介
  final String? intro;

  /// 分类
  final String? category;

  /// 类型: local, online, hybrid
  final String type;

  /// 本地文件路径
  final String? localPath;

  /// 格式: txt, epub, pdf
  final String format;

  /// 总章节数
  final int totalChapters;

  /// 总字数
  final int wordCount;

  /// 状态: 0=reading, 1=finished, 2=archived
  final int status;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 分组ID
  final String groupId;

  /// 排序
  final int sortOrder;
  const Book(
      {required this.id,
      required this.title,
      required this.author,
      this.coverPath,
      this.intro,
      this.category,
      required this.type,
      this.localPath,
      required this.format,
      required this.totalChapters,
      required this.wordCount,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      required this.groupId,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || intro != null) {
      map['intro'] = Variable<String>(intro);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || localPath != null) {
      map['local_path'] = Variable<String>(localPath);
    }
    map['format'] = Variable<String>(format);
    map['total_chapters'] = Variable<int>(totalChapters);
    map['word_count'] = Variable<int>(wordCount);
    map['status'] = Variable<int>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['group_id'] = Variable<String>(groupId);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      intro:
          intro == null && nullToAbsent ? const Value.absent() : Value(intro),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      type: Value(type),
      localPath: localPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPath),
      format: Value(format),
      totalChapters: Value(totalChapters),
      wordCount: Value(wordCount),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      groupId: Value(groupId),
      sortOrder: Value(sortOrder),
    );
  }

  factory Book.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      intro: serializer.fromJson<String?>(json['intro']),
      category: serializer.fromJson<String?>(json['category']),
      type: serializer.fromJson<String>(json['type']),
      localPath: serializer.fromJson<String?>(json['localPath']),
      format: serializer.fromJson<String>(json['format']),
      totalChapters: serializer.fromJson<int>(json['totalChapters']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      status: serializer.fromJson<int>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      groupId: serializer.fromJson<String>(json['groupId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'coverPath': serializer.toJson<String?>(coverPath),
      'intro': serializer.toJson<String?>(intro),
      'category': serializer.toJson<String?>(category),
      'type': serializer.toJson<String>(type),
      'localPath': serializer.toJson<String?>(localPath),
      'format': serializer.toJson<String>(format),
      'totalChapters': serializer.toJson<int>(totalChapters),
      'wordCount': serializer.toJson<int>(wordCount),
      'status': serializer.toJson<int>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'groupId': serializer.toJson<String>(groupId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Book copyWith(
          {String? id,
          String? title,
          String? author,
          Value<String?> coverPath = const Value.absent(),
          Value<String?> intro = const Value.absent(),
          Value<String?> category = const Value.absent(),
          String? type,
          Value<String?> localPath = const Value.absent(),
          String? format,
          int? totalChapters,
          int? wordCount,
          int? status,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? groupId,
          int? sortOrder}) =>
      Book(
        id: id ?? this.id,
        title: title ?? this.title,
        author: author ?? this.author,
        coverPath: coverPath.present ? coverPath.value : this.coverPath,
        intro: intro.present ? intro.value : this.intro,
        category: category.present ? category.value : this.category,
        type: type ?? this.type,
        localPath: localPath.present ? localPath.value : this.localPath,
        format: format ?? this.format,
        totalChapters: totalChapters ?? this.totalChapters,
        wordCount: wordCount ?? this.wordCount,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        groupId: groupId ?? this.groupId,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      intro: data.intro.present ? data.intro.value : this.intro,
      category: data.category.present ? data.category.value : this.category,
      type: data.type.present ? data.type.value : this.type,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      format: data.format.present ? data.format.value : this.format,
      totalChapters: data.totalChapters.present
          ? data.totalChapters.value
          : this.totalChapters,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('coverPath: $coverPath, ')
          ..write('intro: $intro, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('format: $format, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('wordCount: $wordCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('groupId: $groupId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      author,
      coverPath,
      intro,
      category,
      type,
      localPath,
      format,
      totalChapters,
      wordCount,
      status,
      createdAt,
      updatedAt,
      groupId,
      sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.coverPath == this.coverPath &&
          other.intro == this.intro &&
          other.category == this.category &&
          other.type == this.type &&
          other.localPath == this.localPath &&
          other.format == this.format &&
          other.totalChapters == this.totalChapters &&
          other.wordCount == this.wordCount &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.groupId == this.groupId &&
          other.sortOrder == this.sortOrder);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String?> coverPath;
  final Value<String?> intro;
  final Value<String?> category;
  final Value<String> type;
  final Value<String?> localPath;
  final Value<String> format;
  final Value<int> totalChapters;
  final Value<int> wordCount;
  final Value<int> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> groupId;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.intro = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.localPath = const Value.absent(),
    this.format = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.groupId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    required String id,
    required String title,
    this.author = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.intro = const Value.absent(),
    this.category = const Value.absent(),
    this.type = const Value.absent(),
    this.localPath = const Value.absent(),
    this.format = const Value.absent(),
    this.totalChapters = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.groupId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title);
  static Insertable<Book> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? coverPath,
    Expression<String>? intro,
    Expression<String>? category,
    Expression<String>? type,
    Expression<String>? localPath,
    Expression<String>? format,
    Expression<int>? totalChapters,
    Expression<int>? wordCount,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? groupId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (coverPath != null) 'cover_path': coverPath,
      if (intro != null) 'intro': intro,
      if (category != null) 'category': category,
      if (type != null) 'type': type,
      if (localPath != null) 'local_path': localPath,
      if (format != null) 'format': format,
      if (totalChapters != null) 'total_chapters': totalChapters,
      if (wordCount != null) 'word_count': wordCount,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (groupId != null) 'group_id': groupId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? author,
      Value<String?>? coverPath,
      Value<String?>? intro,
      Value<String?>? category,
      Value<String>? type,
      Value<String?>? localPath,
      Value<String>? format,
      Value<int>? totalChapters,
      Value<int>? wordCount,
      Value<int>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? groupId,
      Value<int>? sortOrder,
      Value<int>? rowid}) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverPath: coverPath ?? this.coverPath,
      intro: intro ?? this.intro,
      category: category ?? this.category,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      format: format ?? this.format,
      totalChapters: totalChapters ?? this.totalChapters,
      wordCount: wordCount ?? this.wordCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      groupId: groupId ?? this.groupId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (intro.present) {
      map['intro'] = Variable<String>(intro.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (totalChapters.present) {
      map['total_chapters'] = Variable<int>(totalChapters.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('coverPath: $coverPath, ')
          ..write('intro: $intro, ')
          ..write('category: $category, ')
          ..write('type: $type, ')
          ..write('localPath: $localPath, ')
          ..write('format: $format, ')
          ..write('totalChapters: $totalChapters, ')
          ..write('wordCount: $wordCount, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('groupId: $groupId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chapterKeyMeta =
      const VerificationMeta('chapterKey');
  @override
  late final GeneratedColumn<String> chapterKey = GeneratedColumn<String>(
      'chapter_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentPathMeta =
      const VerificationMeta('contentPath');
  @override
  late final GeneratedColumn<String> contentPath = GeneratedColumn<String>(
      'content_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCachedMeta =
      const VerificationMeta('isCached');
  @override
  late final GeneratedColumn<bool> isCached = GeneratedColumn<bool>(
      'is_cached', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_cached" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isVipMeta = const VerificationMeta('isVip');
  @override
  late final GeneratedColumn<bool> isVip = GeneratedColumn<bool>(
      'is_vip', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_vip" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _wordCountMeta =
      const VerificationMeta('wordCount');
  @override
  late final GeneratedColumn<int> wordCount = GeneratedColumn<int>(
      'word_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        sourceId,
        chapterKey,
        title,
        orderIndex,
        contentPath,
        isCached,
        isVip,
        wordCount,
        fetchedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(Insertable<Chapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('chapter_key')) {
      context.handle(
          _chapterKeyMeta,
          chapterKey.isAcceptableOrUnknown(
              data['chapter_key']!, _chapterKeyMeta));
    } else if (isInserting) {
      context.missing(_chapterKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('content_path')) {
      context.handle(
          _contentPathMeta,
          contentPath.isAcceptableOrUnknown(
              data['content_path']!, _contentPathMeta));
    }
    if (data.containsKey('is_cached')) {
      context.handle(_isCachedMeta,
          isCached.isAcceptableOrUnknown(data['is_cached']!, _isCachedMeta));
    }
    if (data.containsKey('is_vip')) {
      context.handle(
          _isVipMeta, isVip.isAcceptableOrUnknown(data['is_vip']!, _isVipMeta));
    }
    if (data.containsKey('word_count')) {
      context.handle(_wordCountMeta,
          wordCount.isAcceptableOrUnknown(data['word_count']!, _wordCountMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id']),
      chapterKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chapter_key'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      contentPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_path']),
      isCached: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_cached'])!,
      isVip: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_vip'])!,
      wordCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}word_count'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at']),
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  /// 主键ID
  final String id;

  /// 所属书籍ID
  final String bookId;

  /// 书源ID
  final String? sourceId;

  /// 章节键值
  final String chapterKey;

  /// 章节标题
  final String title;

  /// 排序索引
  final int orderIndex;

  /// 内容存储路径
  final String? contentPath;

  /// 是否已缓存
  final bool isCached;

  /// 是否VIP章节
  final bool isVip;

  /// 字数
  final int wordCount;

  /// 获取时间
  final DateTime? fetchedAt;
  const Chapter(
      {required this.id,
      required this.bookId,
      this.sourceId,
      required this.chapterKey,
      required this.title,
      required this.orderIndex,
      this.contentPath,
      required this.isCached,
      required this.isVip,
      required this.wordCount,
      this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['chapter_key'] = Variable<String>(chapterKey);
    map['title'] = Variable<String>(title);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || contentPath != null) {
      map['content_path'] = Variable<String>(contentPath);
    }
    map['is_cached'] = Variable<bool>(isCached);
    map['is_vip'] = Variable<bool>(isVip);
    map['word_count'] = Variable<int>(wordCount);
    if (!nullToAbsent || fetchedAt != null) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt);
    }
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      bookId: Value(bookId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      chapterKey: Value(chapterKey),
      title: Value(title),
      orderIndex: Value(orderIndex),
      contentPath: contentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(contentPath),
      isCached: Value(isCached),
      isVip: Value(isVip),
      wordCount: Value(wordCount),
      fetchedAt: fetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchedAt),
    );
  }

  factory Chapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      chapterKey: serializer.fromJson<String>(json['chapterKey']),
      title: serializer.fromJson<String>(json['title']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      contentPath: serializer.fromJson<String?>(json['contentPath']),
      isCached: serializer.fromJson<bool>(json['isCached']),
      isVip: serializer.fromJson<bool>(json['isVip']),
      wordCount: serializer.fromJson<int>(json['wordCount']),
      fetchedAt: serializer.fromJson<DateTime?>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'chapterKey': serializer.toJson<String>(chapterKey),
      'title': serializer.toJson<String>(title),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'contentPath': serializer.toJson<String?>(contentPath),
      'isCached': serializer.toJson<bool>(isCached),
      'isVip': serializer.toJson<bool>(isVip),
      'wordCount': serializer.toJson<int>(wordCount),
      'fetchedAt': serializer.toJson<DateTime?>(fetchedAt),
    };
  }

  Chapter copyWith(
          {String? id,
          String? bookId,
          Value<String?> sourceId = const Value.absent(),
          String? chapterKey,
          String? title,
          int? orderIndex,
          Value<String?> contentPath = const Value.absent(),
          bool? isCached,
          bool? isVip,
          int? wordCount,
          Value<DateTime?> fetchedAt = const Value.absent()}) =>
      Chapter(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        chapterKey: chapterKey ?? this.chapterKey,
        title: title ?? this.title,
        orderIndex: orderIndex ?? this.orderIndex,
        contentPath: contentPath.present ? contentPath.value : this.contentPath,
        isCached: isCached ?? this.isCached,
        isVip: isVip ?? this.isVip,
        wordCount: wordCount ?? this.wordCount,
        fetchedAt: fetchedAt.present ? fetchedAt.value : this.fetchedAt,
      );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      chapterKey:
          data.chapterKey.present ? data.chapterKey.value : this.chapterKey,
      title: data.title.present ? data.title.value : this.title,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      contentPath:
          data.contentPath.present ? data.contentPath.value : this.contentPath,
      isCached: data.isCached.present ? data.isCached.value : this.isCached,
      isVip: data.isVip.present ? data.isVip.value : this.isVip,
      wordCount: data.wordCount.present ? data.wordCount.value : this.wordCount,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('sourceId: $sourceId, ')
          ..write('chapterKey: $chapterKey, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('contentPath: $contentPath, ')
          ..write('isCached: $isCached, ')
          ..write('isVip: $isVip, ')
          ..write('wordCount: $wordCount, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, sourceId, chapterKey, title,
      orderIndex, contentPath, isCached, isVip, wordCount, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.sourceId == this.sourceId &&
          other.chapterKey == this.chapterKey &&
          other.title == this.title &&
          other.orderIndex == this.orderIndex &&
          other.contentPath == this.contentPath &&
          other.isCached == this.isCached &&
          other.isVip == this.isVip &&
          other.wordCount == this.wordCount &&
          other.fetchedAt == this.fetchedAt);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String?> sourceId;
  final Value<String> chapterKey;
  final Value<String> title;
  final Value<int> orderIndex;
  final Value<String?> contentPath;
  final Value<bool> isCached;
  final Value<bool> isVip;
  final Value<int> wordCount;
  final Value<DateTime?> fetchedAt;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.chapterKey = const Value.absent(),
    this.title = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.contentPath = const Value.absent(),
    this.isCached = const Value.absent(),
    this.isVip = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required String id,
    required String bookId,
    this.sourceId = const Value.absent(),
    required String chapterKey,
    required String title,
    required int orderIndex,
    this.contentPath = const Value.absent(),
    this.isCached = const Value.absent(),
    this.isVip = const Value.absent(),
    this.wordCount = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        chapterKey = Value(chapterKey),
        title = Value(title),
        orderIndex = Value(orderIndex);
  static Insertable<Chapter> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? sourceId,
    Expression<String>? chapterKey,
    Expression<String>? title,
    Expression<int>? orderIndex,
    Expression<String>? contentPath,
    Expression<bool>? isCached,
    Expression<bool>? isVip,
    Expression<int>? wordCount,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (sourceId != null) 'source_id': sourceId,
      if (chapterKey != null) 'chapter_key': chapterKey,
      if (title != null) 'title': title,
      if (orderIndex != null) 'order_index': orderIndex,
      if (contentPath != null) 'content_path': contentPath,
      if (isCached != null) 'is_cached': isCached,
      if (isVip != null) 'is_vip': isVip,
      if (wordCount != null) 'word_count': wordCount,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<String?>? sourceId,
      Value<String>? chapterKey,
      Value<String>? title,
      Value<int>? orderIndex,
      Value<String?>? contentPath,
      Value<bool>? isCached,
      Value<bool>? isVip,
      Value<int>? wordCount,
      Value<DateTime?>? fetchedAt,
      Value<int>? rowid}) {
    return ChaptersCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      sourceId: sourceId ?? this.sourceId,
      chapterKey: chapterKey ?? this.chapterKey,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      contentPath: contentPath ?? this.contentPath,
      isCached: isCached ?? this.isCached,
      isVip: isVip ?? this.isVip,
      wordCount: wordCount ?? this.wordCount,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (chapterKey.present) {
      map['chapter_key'] = Variable<String>(chapterKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (contentPath.present) {
      map['content_path'] = Variable<String>(contentPath.value);
    }
    if (isCached.present) {
      map['is_cached'] = Variable<bool>(isCached.value);
    }
    if (isVip.present) {
      map['is_vip'] = Variable<bool>(isVip.value);
    }
    if (wordCount.present) {
      map['word_count'] = Variable<int>(wordCount.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('sourceId: $sourceId, ')
          ..write('chapterKey: $chapterKey, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('contentPath: $contentPath, ')
          ..write('isCached: $isCached, ')
          ..write('isVip: $isVip, ')
          ..write('wordCount: $wordCount, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookSourcesTable extends BookSources
    with TableInfo<$BookSourcesTable, BookSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
      'source_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceNameMeta =
      const VerificationMeta('sourceName');
  @override
  late final GeneratedColumn<String> sourceName = GeneratedColumn<String>(
      'source_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookKeyMeta =
      const VerificationMeta('bookKey');
  @override
  late final GeneratedColumn<String> bookKey = GeneratedColumn<String>(
      'book_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isPrimaryMeta =
      const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
      'is_primary', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.5));
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
      'score', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lastCheckMeta =
      const VerificationMeta('lastCheck');
  @override
  late final GeneratedColumn<DateTime> lastCheck = GeneratedColumn<DateTime>(
      'last_check', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastAvailableMeta =
      const VerificationMeta('lastAvailable');
  @override
  late final GeneratedColumn<DateTime> lastAvailable =
      GeneratedColumn<DateTime>('last_available', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _chapterCountMeta =
      const VerificationMeta('chapterCount');
  @override
  late final GeneratedColumn<int> chapterCount = GeneratedColumn<int>(
      'chapter_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        sourceId,
        sourceName,
        bookKey,
        isPrimary,
        confidence,
        score,
        lastCheck,
        lastAvailable,
        chapterCount,
        enabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_sources';
  @override
  VerificationContext validateIntegrity(Insertable<BookSource> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_name')) {
      context.handle(
          _sourceNameMeta,
          sourceName.isAcceptableOrUnknown(
              data['source_name']!, _sourceNameMeta));
    } else if (isInserting) {
      context.missing(_sourceNameMeta);
    }
    if (data.containsKey('book_key')) {
      context.handle(_bookKeyMeta,
          bookKey.isAcceptableOrUnknown(data['book_key']!, _bookKeyMeta));
    } else if (isInserting) {
      context.missing(_bookKeyMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(_isPrimaryMeta,
          isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
          _scoreMeta, score.isAcceptableOrUnknown(data['score']!, _scoreMeta));
    }
    if (data.containsKey('last_check')) {
      context.handle(_lastCheckMeta,
          lastCheck.isAcceptableOrUnknown(data['last_check']!, _lastCheckMeta));
    }
    if (data.containsKey('last_available')) {
      context.handle(
          _lastAvailableMeta,
          lastAvailable.isAcceptableOrUnknown(
              data['last_available']!, _lastAvailableMeta));
    }
    if (data.containsKey('chapter_count')) {
      context.handle(
          _chapterCountMeta,
          chapterCount.isAcceptableOrUnknown(
              data['chapter_count']!, _chapterCountMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookSource(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_id'])!,
      sourceName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_name'])!,
      bookKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_key'])!,
      isPrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_primary'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      score: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score'])!,
      lastCheck: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_check']),
      lastAvailable: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_available']),
      chapterCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_count'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
    );
  }

  @override
  $BookSourcesTable createAlias(String alias) {
    return $BookSourcesTable(attachedDatabase, alias);
  }
}

class BookSource extends DataClass implements Insertable<BookSource> {
  /// 主键ID
  final String id;

  /// 书籍ID
  final String bookId;

  /// 书源ID
  final String sourceId;

  /// 书源名称
  final String sourceName;

  /// 书源中的书籍键值
  final String bookKey;

  /// 是否为主要书源
  final bool isPrimary;

  /// 置信度 (0.0 - 1.0)
  final double confidence;

  /// 评分
  final double score;

  /// 最后检查时间
  final DateTime? lastCheck;

  /// 最后可用时间
  final DateTime? lastAvailable;

  /// 章节数量
  final int chapterCount;

  /// 是否启用
  final bool enabled;
  const BookSource(
      {required this.id,
      required this.bookId,
      required this.sourceId,
      required this.sourceName,
      required this.bookKey,
      required this.isPrimary,
      required this.confidence,
      required this.score,
      this.lastCheck,
      this.lastAvailable,
      required this.chapterCount,
      required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['source_id'] = Variable<String>(sourceId);
    map['source_name'] = Variable<String>(sourceName);
    map['book_key'] = Variable<String>(bookKey);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['confidence'] = Variable<double>(confidence);
    map['score'] = Variable<double>(score);
    if (!nullToAbsent || lastCheck != null) {
      map['last_check'] = Variable<DateTime>(lastCheck);
    }
    if (!nullToAbsent || lastAvailable != null) {
      map['last_available'] = Variable<DateTime>(lastAvailable);
    }
    map['chapter_count'] = Variable<int>(chapterCount);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  BookSourcesCompanion toCompanion(bool nullToAbsent) {
    return BookSourcesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      sourceId: Value(sourceId),
      sourceName: Value(sourceName),
      bookKey: Value(bookKey),
      isPrimary: Value(isPrimary),
      confidence: Value(confidence),
      score: Value(score),
      lastCheck: lastCheck == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCheck),
      lastAvailable: lastAvailable == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAvailable),
      chapterCount: Value(chapterCount),
      enabled: Value(enabled),
    );
  }

  factory BookSource.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookSource(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sourceName: serializer.fromJson<String>(json['sourceName']),
      bookKey: serializer.fromJson<String>(json['bookKey']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      confidence: serializer.fromJson<double>(json['confidence']),
      score: serializer.fromJson<double>(json['score']),
      lastCheck: serializer.fromJson<DateTime?>(json['lastCheck']),
      lastAvailable: serializer.fromJson<DateTime?>(json['lastAvailable']),
      chapterCount: serializer.fromJson<int>(json['chapterCount']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'sourceId': serializer.toJson<String>(sourceId),
      'sourceName': serializer.toJson<String>(sourceName),
      'bookKey': serializer.toJson<String>(bookKey),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'confidence': serializer.toJson<double>(confidence),
      'score': serializer.toJson<double>(score),
      'lastCheck': serializer.toJson<DateTime?>(lastCheck),
      'lastAvailable': serializer.toJson<DateTime?>(lastAvailable),
      'chapterCount': serializer.toJson<int>(chapterCount),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  BookSource copyWith(
          {String? id,
          String? bookId,
          String? sourceId,
          String? sourceName,
          String? bookKey,
          bool? isPrimary,
          double? confidence,
          double? score,
          Value<DateTime?> lastCheck = const Value.absent(),
          Value<DateTime?> lastAvailable = const Value.absent(),
          int? chapterCount,
          bool? enabled}) =>
      BookSource(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        sourceId: sourceId ?? this.sourceId,
        sourceName: sourceName ?? this.sourceName,
        bookKey: bookKey ?? this.bookKey,
        isPrimary: isPrimary ?? this.isPrimary,
        confidence: confidence ?? this.confidence,
        score: score ?? this.score,
        lastCheck: lastCheck.present ? lastCheck.value : this.lastCheck,
        lastAvailable:
            lastAvailable.present ? lastAvailable.value : this.lastAvailable,
        chapterCount: chapterCount ?? this.chapterCount,
        enabled: enabled ?? this.enabled,
      );
  BookSource copyWithCompanion(BookSourcesCompanion data) {
    return BookSource(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceName:
          data.sourceName.present ? data.sourceName.value : this.sourceName,
      bookKey: data.bookKey.present ? data.bookKey.value : this.bookKey,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      score: data.score.present ? data.score.value : this.score,
      lastCheck: data.lastCheck.present ? data.lastCheck.value : this.lastCheck,
      lastAvailable: data.lastAvailable.present
          ? data.lastAvailable.value
          : this.lastAvailable,
      chapterCount: data.chapterCount.present
          ? data.chapterCount.value
          : this.chapterCount,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookSource(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceName: $sourceName, ')
          ..write('bookKey: $bookKey, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('confidence: $confidence, ')
          ..write('score: $score, ')
          ..write('lastCheck: $lastCheck, ')
          ..write('lastAvailable: $lastAvailable, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      bookId,
      sourceId,
      sourceName,
      bookKey,
      isPrimary,
      confidence,
      score,
      lastCheck,
      lastAvailable,
      chapterCount,
      enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookSource &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.sourceId == this.sourceId &&
          other.sourceName == this.sourceName &&
          other.bookKey == this.bookKey &&
          other.isPrimary == this.isPrimary &&
          other.confidence == this.confidence &&
          other.score == this.score &&
          other.lastCheck == this.lastCheck &&
          other.lastAvailable == this.lastAvailable &&
          other.chapterCount == this.chapterCount &&
          other.enabled == this.enabled);
}

class BookSourcesCompanion extends UpdateCompanion<BookSource> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<String> sourceId;
  final Value<String> sourceName;
  final Value<String> bookKey;
  final Value<bool> isPrimary;
  final Value<double> confidence;
  final Value<double> score;
  final Value<DateTime?> lastCheck;
  final Value<DateTime?> lastAvailable;
  final Value<int> chapterCount;
  final Value<bool> enabled;
  final Value<int> rowid;
  const BookSourcesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceName = const Value.absent(),
    this.bookKey = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.confidence = const Value.absent(),
    this.score = const Value.absent(),
    this.lastCheck = const Value.absent(),
    this.lastAvailable = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookSourcesCompanion.insert({
    required String id,
    required String bookId,
    required String sourceId,
    required String sourceName,
    required String bookKey,
    this.isPrimary = const Value.absent(),
    this.confidence = const Value.absent(),
    this.score = const Value.absent(),
    this.lastCheck = const Value.absent(),
    this.lastAvailable = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        sourceId = Value(sourceId),
        sourceName = Value(sourceName),
        bookKey = Value(bookKey);
  static Insertable<BookSource> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<String>? sourceId,
    Expression<String>? sourceName,
    Expression<String>? bookKey,
    Expression<bool>? isPrimary,
    Expression<double>? confidence,
    Expression<double>? score,
    Expression<DateTime>? lastCheck,
    Expression<DateTime>? lastAvailable,
    Expression<int>? chapterCount,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceName != null) 'source_name': sourceName,
      if (bookKey != null) 'book_key': bookKey,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (confidence != null) 'confidence': confidence,
      if (score != null) 'score': score,
      if (lastCheck != null) 'last_check': lastCheck,
      if (lastAvailable != null) 'last_available': lastAvailable,
      if (chapterCount != null) 'chapter_count': chapterCount,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookSourcesCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<String>? sourceId,
      Value<String>? sourceName,
      Value<String>? bookKey,
      Value<bool>? isPrimary,
      Value<double>? confidence,
      Value<double>? score,
      Value<DateTime?>? lastCheck,
      Value<DateTime?>? lastAvailable,
      Value<int>? chapterCount,
      Value<bool>? enabled,
      Value<int>? rowid}) {
    return BookSourcesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      sourceId: sourceId ?? this.sourceId,
      sourceName: sourceName ?? this.sourceName,
      bookKey: bookKey ?? this.bookKey,
      isPrimary: isPrimary ?? this.isPrimary,
      confidence: confidence ?? this.confidence,
      score: score ?? this.score,
      lastCheck: lastCheck ?? this.lastCheck,
      lastAvailable: lastAvailable ?? this.lastAvailable,
      chapterCount: chapterCount ?? this.chapterCount,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceName.present) {
      map['source_name'] = Variable<String>(sourceName.value);
    }
    if (bookKey.present) {
      map['book_key'] = Variable<String>(bookKey.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (lastCheck.present) {
      map['last_check'] = Variable<DateTime>(lastCheck.value);
    }
    if (lastAvailable.present) {
      map['last_available'] = Variable<DateTime>(lastAvailable.value);
    }
    if (chapterCount.present) {
      map['chapter_count'] = Variable<int>(chapterCount.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookSourcesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceName: $sourceName, ')
          ..write('bookKey: $bookKey, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('confidence: $confidence, ')
          ..write('score: $score, ')
          ..write('lastCheck: $lastCheck, ')
          ..write('lastAvailable: $lastAvailable, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadProgressTableTable extends ReadProgressTable
    with TableInfo<$ReadProgressTableTable, ReadProgressTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pageIndexMeta =
      const VerificationMeta('pageIndex');
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
      'page_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _charOffsetMeta =
      const VerificationMeta('charOffset');
  @override
  late final GeneratedColumn<int> charOffset = GeneratedColumn<int>(
      'char_offset', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _scrollOffsetMeta =
      const VerificationMeta('scrollOffset');
  @override
  late final GeneratedColumn<double> scrollOffset = GeneratedColumn<double>(
      'scroll_offset', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _readingTimeMeta =
      const VerificationMeta('readingTime');
  @override
  late final GeneratedColumn<int> readingTime = GeneratedColumn<int>(
      'reading_time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastReadAtMeta =
      const VerificationMeta('lastReadAt');
  @override
  late final GeneratedColumn<DateTime> lastReadAt = GeneratedColumn<DateTime>(
      'last_read_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _progressPercentMeta =
      const VerificationMeta('progressPercent');
  @override
  late final GeneratedColumn<double> progressPercent = GeneratedColumn<double>(
      'progress_percent', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        bookId,
        chapterIndex,
        pageIndex,
        charOffset,
        scrollOffset,
        readingTime,
        lastReadAt,
        progressPercent
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_progress_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReadProgressTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    }
    if (data.containsKey('page_index')) {
      context.handle(_pageIndexMeta,
          pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta));
    }
    if (data.containsKey('char_offset')) {
      context.handle(
          _charOffsetMeta,
          charOffset.isAcceptableOrUnknown(
              data['char_offset']!, _charOffsetMeta));
    }
    if (data.containsKey('scroll_offset')) {
      context.handle(
          _scrollOffsetMeta,
          scrollOffset.isAcceptableOrUnknown(
              data['scroll_offset']!, _scrollOffsetMeta));
    }
    if (data.containsKey('reading_time')) {
      context.handle(
          _readingTimeMeta,
          readingTime.isAcceptableOrUnknown(
              data['reading_time']!, _readingTimeMeta));
    }
    if (data.containsKey('last_read_at')) {
      context.handle(
          _lastReadAtMeta,
          lastReadAt.isAcceptableOrUnknown(
              data['last_read_at']!, _lastReadAtMeta));
    }
    if (data.containsKey('progress_percent')) {
      context.handle(
          _progressPercentMeta,
          progressPercent.isAcceptableOrUnknown(
              data['progress_percent']!, _progressPercentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  ReadProgressTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadProgressTableData(
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
      pageIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_index'])!,
      charOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}char_offset'])!,
      scrollOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}scroll_offset'])!,
      readingTime: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reading_time'])!,
      lastReadAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_read_at'])!,
      progressPercent: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}progress_percent'])!,
    );
  }

  @override
  $ReadProgressTableTable createAlias(String alias) {
    return $ReadProgressTableTable(attachedDatabase, alias);
  }
}

class ReadProgressTableData extends DataClass
    implements Insertable<ReadProgressTableData> {
  /// 书籍ID（主键）
  final String bookId;

  /// 当前章节索引
  final int chapterIndex;

  /// 当前页索引
  final int pageIndex;

  /// 字符偏移量
  final int charOffset;

  /// 滚动偏移量
  final double scrollOffset;

  /// 累计阅读时间（秒）
  final int readingTime;

  /// 最后阅读时间
  final DateTime lastReadAt;

  /// 阅读进度百分比
  final double progressPercent;
  const ReadProgressTableData(
      {required this.bookId,
      required this.chapterIndex,
      required this.pageIndex,
      required this.charOffset,
      required this.scrollOffset,
      required this.readingTime,
      required this.lastReadAt,
      required this.progressPercent});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['page_index'] = Variable<int>(pageIndex);
    map['char_offset'] = Variable<int>(charOffset);
    map['scroll_offset'] = Variable<double>(scrollOffset);
    map['reading_time'] = Variable<int>(readingTime);
    map['last_read_at'] = Variable<DateTime>(lastReadAt);
    map['progress_percent'] = Variable<double>(progressPercent);
    return map;
  }

  ReadProgressTableCompanion toCompanion(bool nullToAbsent) {
    return ReadProgressTableCompanion(
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      pageIndex: Value(pageIndex),
      charOffset: Value(charOffset),
      scrollOffset: Value(scrollOffset),
      readingTime: Value(readingTime),
      lastReadAt: Value(lastReadAt),
      progressPercent: Value(progressPercent),
    );
  }

  factory ReadProgressTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadProgressTableData(
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      charOffset: serializer.fromJson<int>(json['charOffset']),
      scrollOffset: serializer.fromJson<double>(json['scrollOffset']),
      readingTime: serializer.fromJson<int>(json['readingTime']),
      lastReadAt: serializer.fromJson<DateTime>(json['lastReadAt']),
      progressPercent: serializer.fromJson<double>(json['progressPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'charOffset': serializer.toJson<int>(charOffset),
      'scrollOffset': serializer.toJson<double>(scrollOffset),
      'readingTime': serializer.toJson<int>(readingTime),
      'lastReadAt': serializer.toJson<DateTime>(lastReadAt),
      'progressPercent': serializer.toJson<double>(progressPercent),
    };
  }

  ReadProgressTableData copyWith(
          {String? bookId,
          int? chapterIndex,
          int? pageIndex,
          int? charOffset,
          double? scrollOffset,
          int? readingTime,
          DateTime? lastReadAt,
          double? progressPercent}) =>
      ReadProgressTableData(
        bookId: bookId ?? this.bookId,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        pageIndex: pageIndex ?? this.pageIndex,
        charOffset: charOffset ?? this.charOffset,
        scrollOffset: scrollOffset ?? this.scrollOffset,
        readingTime: readingTime ?? this.readingTime,
        lastReadAt: lastReadAt ?? this.lastReadAt,
        progressPercent: progressPercent ?? this.progressPercent,
      );
  ReadProgressTableData copyWithCompanion(ReadProgressTableCompanion data) {
    return ReadProgressTableData(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      charOffset:
          data.charOffset.present ? data.charOffset.value : this.charOffset,
      scrollOffset: data.scrollOffset.present
          ? data.scrollOffset.value
          : this.scrollOffset,
      readingTime:
          data.readingTime.present ? data.readingTime.value : this.readingTime,
      lastReadAt:
          data.lastReadAt.present ? data.lastReadAt.value : this.lastReadAt,
      progressPercent: data.progressPercent.present
          ? data.progressPercent.value
          : this.progressPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadProgressTableData(')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('charOffset: $charOffset, ')
          ..write('scrollOffset: $scrollOffset, ')
          ..write('readingTime: $readingTime, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('progressPercent: $progressPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, chapterIndex, pageIndex, charOffset,
      scrollOffset, readingTime, lastReadAt, progressPercent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadProgressTableData &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.pageIndex == this.pageIndex &&
          other.charOffset == this.charOffset &&
          other.scrollOffset == this.scrollOffset &&
          other.readingTime == this.readingTime &&
          other.lastReadAt == this.lastReadAt &&
          other.progressPercent == this.progressPercent);
}

class ReadProgressTableCompanion
    extends UpdateCompanion<ReadProgressTableData> {
  final Value<String> bookId;
  final Value<int> chapterIndex;
  final Value<int> pageIndex;
  final Value<int> charOffset;
  final Value<double> scrollOffset;
  final Value<int> readingTime;
  final Value<DateTime> lastReadAt;
  final Value<double> progressPercent;
  final Value<int> rowid;
  const ReadProgressTableCompanion({
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.charOffset = const Value.absent(),
    this.scrollOffset = const Value.absent(),
    this.readingTime = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadProgressTableCompanion.insert({
    required String bookId,
    this.chapterIndex = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.charOffset = const Value.absent(),
    this.scrollOffset = const Value.absent(),
    this.readingTime = const Value.absent(),
    this.lastReadAt = const Value.absent(),
    this.progressPercent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId);
  static Insertable<ReadProgressTableData> custom({
    Expression<String>? bookId,
    Expression<int>? chapterIndex,
    Expression<int>? pageIndex,
    Expression<int>? charOffset,
    Expression<double>? scrollOffset,
    Expression<int>? readingTime,
    Expression<DateTime>? lastReadAt,
    Expression<double>? progressPercent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (pageIndex != null) 'page_index': pageIndex,
      if (charOffset != null) 'char_offset': charOffset,
      if (scrollOffset != null) 'scroll_offset': scrollOffset,
      if (readingTime != null) 'reading_time': readingTime,
      if (lastReadAt != null) 'last_read_at': lastReadAt,
      if (progressPercent != null) 'progress_percent': progressPercent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadProgressTableCompanion copyWith(
      {Value<String>? bookId,
      Value<int>? chapterIndex,
      Value<int>? pageIndex,
      Value<int>? charOffset,
      Value<double>? scrollOffset,
      Value<int>? readingTime,
      Value<DateTime>? lastReadAt,
      Value<double>? progressPercent,
      Value<int>? rowid}) {
    return ReadProgressTableCompanion(
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      pageIndex: pageIndex ?? this.pageIndex,
      charOffset: charOffset ?? this.charOffset,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      readingTime: readingTime ?? this.readingTime,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      progressPercent: progressPercent ?? this.progressPercent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (charOffset.present) {
      map['char_offset'] = Variable<int>(charOffset.value);
    }
    if (scrollOffset.present) {
      map['scroll_offset'] = Variable<double>(scrollOffset.value);
    }
    if (readingTime.present) {
      map['reading_time'] = Variable<int>(readingTime.value);
    }
    if (lastReadAt.present) {
      map['last_read_at'] = Variable<DateTime>(lastReadAt.value);
    }
    if (progressPercent.present) {
      map['progress_percent'] = Variable<double>(progressPercent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadProgressTableCompanion(')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('charOffset: $charOffset, ')
          ..write('scrollOffset: $scrollOffset, ')
          ..write('readingTime: $readingTime, ')
          ..write('lastReadAt: $lastReadAt, ')
          ..write('progressPercent: $progressPercent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _charOffsetMeta =
      const VerificationMeta('charOffset');
  @override
  late final GeneratedColumn<int> charOffset = GeneratedColumn<int>(
      'char_offset', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#FFC107'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, bookId, chapterIndex, charOffset, label, color, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<Bookmark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('char_offset')) {
      context.handle(
          _charOffsetMeta,
          charOffset.isAcceptableOrUnknown(
              data['char_offset']!, _charOffsetMeta));
    } else if (isInserting) {
      context.missing(_charOffsetMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
      charOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}char_offset'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  /// 主键ID
  final String id;

  /// 书籍ID
  final String bookId;

  /// 章节索引
  final int chapterIndex;

  /// 字符偏移量
  final int charOffset;

  /// 书签标签
  final String label;

  /// 书签颜色
  final String color;

  /// 创建时间
  final DateTime createdAt;
  const Bookmark(
      {required this.id,
      required this.bookId,
      required this.chapterIndex,
      required this.charOffset,
      required this.label,
      required this.color,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['char_offset'] = Variable<int>(charOffset);
    map['label'] = Variable<String>(label);
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      charOffset: Value(charOffset),
      label: Value(label),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory Bookmark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      charOffset: serializer.fromJson<int>(json['charOffset']),
      label: serializer.fromJson<String>(json['label']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'charOffset': serializer.toJson<int>(charOffset),
      'label': serializer.toJson<String>(label),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bookmark copyWith(
          {String? id,
          String? bookId,
          int? chapterIndex,
          int? charOffset,
          String? label,
          String? color,
          DateTime? createdAt}) =>
      Bookmark(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        charOffset: charOffset ?? this.charOffset,
        label: label ?? this.label,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
      );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      charOffset:
          data.charOffset.present ? data.charOffset.value : this.charOffset,
      label: data.label.present ? data.label.value : this.label,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('charOffset: $charOffset, ')
          ..write('label: $label, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, bookId, chapterIndex, charOffset, label, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.charOffset == this.charOffset &&
          other.label == this.label &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> chapterIndex;
  final Value<int> charOffset;
  final Value<String> label;
  final Value<String> color;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.charOffset = const Value.absent(),
    this.label = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String id,
    required String bookId,
    required int chapterIndex,
    required int charOffset,
    this.label = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        chapterIndex = Value(chapterIndex),
        charOffset = Value(charOffset);
  static Insertable<Bookmark> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? chapterIndex,
    Expression<int>? charOffset,
    Expression<String>? label,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (charOffset != null) 'char_offset': charOffset,
      if (label != null) 'label': label,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<int>? chapterIndex,
      Value<int>? charOffset,
      Value<String>? label,
      Value<String>? color,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      charOffset: charOffset ?? this.charOffset,
      label: label ?? this.label,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (charOffset.present) {
      map['char_offset'] = Variable<int>(charOffset.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('charOffset: $charOffset, ')
          ..write('label: $label, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
      'book_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _chapterIndexMeta =
      const VerificationMeta('chapterIndex');
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
      'chapter_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startOffsetMeta =
      const VerificationMeta('startOffset');
  @override
  late final GeneratedColumn<int> startOffset = GeneratedColumn<int>(
      'start_offset', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endOffsetMeta =
      const VerificationMeta('endOffset');
  @override
  late final GeneratedColumn<int> endOffset = GeneratedColumn<int>(
      'end_offset', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('#FFC107'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        bookId,
        chapterIndex,
        startOffset,
        endOffset,
        content,
        note,
        color,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<Note> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(_bookIdMeta,
          bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta));
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
          _chapterIndexMeta,
          chapterIndex.isAcceptableOrUnknown(
              data['chapter_index']!, _chapterIndexMeta));
    } else if (isInserting) {
      context.missing(_chapterIndexMeta);
    }
    if (data.containsKey('start_offset')) {
      context.handle(
          _startOffsetMeta,
          startOffset.isAcceptableOrUnknown(
              data['start_offset']!, _startOffsetMeta));
    } else if (isInserting) {
      context.missing(_startOffsetMeta);
    }
    if (data.containsKey('end_offset')) {
      context.handle(_endOffsetMeta,
          endOffset.isAcceptableOrUnknown(data['end_offset']!, _endOffsetMeta));
    } else if (isInserting) {
      context.missing(_endOffsetMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      bookId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}book_id'])!,
      chapterIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_index'])!,
      startOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_offset'])!,
      endOffset: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_offset'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  /// 主键ID
  final String id;

  /// 书籍ID
  final String bookId;

  /// 章节索引
  final int chapterIndex;

  /// 起始偏移量
  final int startOffset;

  /// 结束偏移量
  final int endOffset;

  /// 选中的内容
  final String? content;

  /// 笔记内容
  final String note;

  /// 颜色
  final String color;

  /// 创建时间
  final DateTime createdAt;
  const Note(
      {required this.id,
      required this.bookId,
      required this.chapterIndex,
      required this.startOffset,
      required this.endOffset,
      this.content,
      required this.note,
      required this.color,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['book_id'] = Variable<String>(bookId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    map['start_offset'] = Variable<int>(startOffset);
    map['end_offset'] = Variable<int>(endOffset);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['note'] = Variable<String>(note);
    map['color'] = Variable<String>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      chapterIndex: Value(chapterIndex),
      startOffset: Value(startOffset),
      endOffset: Value(endOffset),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      note: Value(note),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      bookId: serializer.fromJson<String>(json['bookId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      startOffset: serializer.fromJson<int>(json['startOffset']),
      endOffset: serializer.fromJson<int>(json['endOffset']),
      content: serializer.fromJson<String?>(json['content']),
      note: serializer.fromJson<String>(json['note']),
      color: serializer.fromJson<String>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'bookId': serializer.toJson<String>(bookId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'startOffset': serializer.toJson<int>(startOffset),
      'endOffset': serializer.toJson<int>(endOffset),
      'content': serializer.toJson<String?>(content),
      'note': serializer.toJson<String>(note),
      'color': serializer.toJson<String>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Note copyWith(
          {String? id,
          String? bookId,
          int? chapterIndex,
          int? startOffset,
          int? endOffset,
          Value<String?> content = const Value.absent(),
          String? note,
          String? color,
          DateTime? createdAt}) =>
      Note(
        id: id ?? this.id,
        bookId: bookId ?? this.bookId,
        chapterIndex: chapterIndex ?? this.chapterIndex,
        startOffset: startOffset ?? this.startOffset,
        endOffset: endOffset ?? this.endOffset,
        content: content.present ? content.value : this.content,
        note: note ?? this.note,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
      );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      startOffset:
          data.startOffset.present ? data.startOffset.value : this.startOffset,
      endOffset: data.endOffset.present ? data.endOffset.value : this.endOffset,
      content: data.content.present ? data.content.value : this.content,
      note: data.note.present ? data.note.value : this.note,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('content: $content, ')
          ..write('note: $note, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, chapterIndex, startOffset,
      endOffset, content, note, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.chapterIndex == this.chapterIndex &&
          other.startOffset == this.startOffset &&
          other.endOffset == this.endOffset &&
          other.content == this.content &&
          other.note == this.note &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> bookId;
  final Value<int> chapterIndex;
  final Value<int> startOffset;
  final Value<int> endOffset;
  final Value<String?> content;
  final Value<String> note;
  final Value<String> color;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.startOffset = const Value.absent(),
    this.endOffset = const Value.absent(),
    this.content = const Value.absent(),
    this.note = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String bookId,
    required int chapterIndex,
    required int startOffset,
    required int endOffset,
    this.content = const Value.absent(),
    this.note = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        bookId = Value(bookId),
        chapterIndex = Value(chapterIndex),
        startOffset = Value(startOffset),
        endOffset = Value(endOffset);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? bookId,
    Expression<int>? chapterIndex,
    Expression<int>? startOffset,
    Expression<int>? endOffset,
    Expression<String>? content,
    Expression<String>? note,
    Expression<String>? color,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (startOffset != null) 'start_offset': startOffset,
      if (endOffset != null) 'end_offset': endOffset,
      if (content != null) 'content': content,
      if (note != null) 'note': note,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith(
      {Value<String>? id,
      Value<String>? bookId,
      Value<int>? chapterIndex,
      Value<int>? startOffset,
      Value<int>? endOffset,
      Value<String?>? content,
      Value<String>? note,
      Value<String>? color,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return NotesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      startOffset: startOffset ?? this.startOffset,
      endOffset: endOffset ?? this.endOffset,
      content: content ?? this.content,
      note: note ?? this.note,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (startOffset.present) {
      map['start_offset'] = Variable<int>(startOffset.value);
    }
    if (endOffset.present) {
      map['end_offset'] = Variable<int>(endOffset.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('startOffset: $startOffset, ')
          ..write('endOffset: $endOffset, ')
          ..write('content: $content, ')
          ..write('note: $note, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $BookSourcesTable bookSources = $BookSourcesTable(this);
  late final $ReadProgressTableTable readProgressTable =
      $ReadProgressTableTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final BookDao bookDao = BookDao(this as AppDatabase);
  late final ChapterDao chapterDao = ChapterDao(this as AppDatabase);
  late final ProgressDao progressDao = ProgressDao(this as AppDatabase);
  late final BookSourceDao bookSourceDao = BookSourceDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [books, chapters, bookSources, readProgressTable, bookmarks, notes];
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  required String id,
  required String title,
  Value<String> author,
  Value<String?> coverPath,
  Value<String?> intro,
  Value<String?> category,
  Value<String> type,
  Value<String?> localPath,
  Value<String> format,
  Value<int> totalChapters,
  Value<int> wordCount,
  Value<int> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> groupId,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> author,
  Value<String?> coverPath,
  Value<String?> intro,
  Value<String?> category,
  Value<String> type,
  Value<String?> localPath,
  Value<String> format,
  Value<int> totalChapters,
  Value<int> wordCount,
  Value<int> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> groupId,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverPath => $composableBuilder(
      column: $table.coverPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get intro =>
      $composableBuilder(column: $table.intro, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get totalChapters => $composableBuilder(
      column: $table.totalChapters, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$BooksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
    Book,
    PrefetchHooks Function()> {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<int> totalChapters = const Value.absent(),
            Value<int> wordCount = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BooksCompanion(
            id: id,
            title: title,
            author: author,
            coverPath: coverPath,
            intro: intro,
            category: category,
            type: type,
            localPath: localPath,
            format: format,
            totalChapters: totalChapters,
            wordCount: wordCount,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            groupId: groupId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> author = const Value.absent(),
            Value<String?> coverPath = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> localPath = const Value.absent(),
            Value<String> format = const Value.absent(),
            Value<int> totalChapters = const Value.absent(),
            Value<int> wordCount = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BooksCompanion.insert(
            id: id,
            title: title,
            author: author,
            coverPath: coverPath,
            intro: intro,
            category: category,
            type: type,
            localPath: localPath,
            format: format,
            totalChapters: totalChapters,
            wordCount: wordCount,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            groupId: groupId,
            sortOrder: sortOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BooksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BooksTable,
    Book,
    $$BooksTableFilterComposer,
    $$BooksTableOrderingComposer,
    $$BooksTableAnnotationComposer,
    $$BooksTableCreateCompanionBuilder,
    $$BooksTableUpdateCompanionBuilder,
    (Book, BaseReferences<_$AppDatabase, $BooksTable, Book>),
    Book,
    PrefetchHooks Function()>;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  required String id,
  required String bookId,
  Value<String?> sourceId,
  required String chapterKey,
  required String title,
  required int orderIndex,
  Value<String?> contentPath,
  Value<bool> isCached,
  Value<bool> isVip,
  Value<int> wordCount,
  Value<DateTime?> fetchedAt,
  Value<int> rowid,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<String?> sourceId,
  Value<String> chapterKey,
  Value<String> title,
  Value<int> orderIndex,
  Value<String?> contentPath,
  Value<bool> isCached,
  Value<bool> isVip,
  Value<int> wordCount,
  Value<DateTime?> fetchedAt,
  Value<int> rowid,
});

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chapterKey => $composableBuilder(
      column: $table.chapterKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentPath => $composableBuilder(
      column: $table.contentPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCached => $composableBuilder(
      column: $table.isCached, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVip => $composableBuilder(
      column: $table.isVip, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chapterKey => $composableBuilder(
      column: $table.chapterKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentPath => $composableBuilder(
      column: $table.contentPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCached => $composableBuilder(
      column: $table.isCached, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVip => $composableBuilder(
      column: $table.isVip, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wordCount => $composableBuilder(
      column: $table.wordCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get chapterKey => $composableBuilder(
      column: $table.chapterKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<String> get contentPath => $composableBuilder(
      column: $table.contentPath, builder: (column) => column);

  GeneratedColumn<bool> get isCached =>
      $composableBuilder(column: $table.isCached, builder: (column) => column);

  GeneratedColumn<bool> get isVip =>
      $composableBuilder(column: $table.isVip, builder: (column) => column);

  GeneratedColumn<int> get wordCount =>
      $composableBuilder(column: $table.wordCount, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChaptersTable,
    Chapter,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (Chapter, BaseReferences<_$AppDatabase, $ChaptersTable, Chapter>),
    Chapter,
    PrefetchHooks Function()> {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<String?> sourceId = const Value.absent(),
            Value<String> chapterKey = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<String?> contentPath = const Value.absent(),
            Value<bool> isCached = const Value.absent(),
            Value<bool> isVip = const Value.absent(),
            Value<int> wordCount = const Value.absent(),
            Value<DateTime?> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChaptersCompanion(
            id: id,
            bookId: bookId,
            sourceId: sourceId,
            chapterKey: chapterKey,
            title: title,
            orderIndex: orderIndex,
            contentPath: contentPath,
            isCached: isCached,
            isVip: isVip,
            wordCount: wordCount,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            Value<String?> sourceId = const Value.absent(),
            required String chapterKey,
            required String title,
            required int orderIndex,
            Value<String?> contentPath = const Value.absent(),
            Value<bool> isCached = const Value.absent(),
            Value<bool> isVip = const Value.absent(),
            Value<int> wordCount = const Value.absent(),
            Value<DateTime?> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChaptersCompanion.insert(
            id: id,
            bookId: bookId,
            sourceId: sourceId,
            chapterKey: chapterKey,
            title: title,
            orderIndex: orderIndex,
            contentPath: contentPath,
            isCached: isCached,
            isVip: isVip,
            wordCount: wordCount,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChaptersTable,
    Chapter,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (Chapter, BaseReferences<_$AppDatabase, $ChaptersTable, Chapter>),
    Chapter,
    PrefetchHooks Function()>;
typedef $$BookSourcesTableCreateCompanionBuilder = BookSourcesCompanion
    Function({
  required String id,
  required String bookId,
  required String sourceId,
  required String sourceName,
  required String bookKey,
  Value<bool> isPrimary,
  Value<double> confidence,
  Value<double> score,
  Value<DateTime?> lastCheck,
  Value<DateTime?> lastAvailable,
  Value<int> chapterCount,
  Value<bool> enabled,
  Value<int> rowid,
});
typedef $$BookSourcesTableUpdateCompanionBuilder = BookSourcesCompanion
    Function({
  Value<String> id,
  Value<String> bookId,
  Value<String> sourceId,
  Value<String> sourceName,
  Value<String> bookKey,
  Value<bool> isPrimary,
  Value<double> confidence,
  Value<double> score,
  Value<DateTime?> lastCheck,
  Value<DateTime?> lastAvailable,
  Value<int> chapterCount,
  Value<bool> enabled,
  Value<int> rowid,
});

class $$BookSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastCheck => $composableBuilder(
      column: $table.lastCheck, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAvailable => $composableBuilder(
      column: $table.lastAvailable, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterCount => $composableBuilder(
      column: $table.chapterCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));
}

class $$BookSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceId => $composableBuilder(
      column: $table.sourceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookKey => $composableBuilder(
      column: $table.bookKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
      column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get score => $composableBuilder(
      column: $table.score, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastCheck => $composableBuilder(
      column: $table.lastCheck, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAvailable => $composableBuilder(
      column: $table.lastAvailable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterCount => $composableBuilder(
      column: $table.chapterCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));
}

class $$BookSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookSourcesTable> {
  $$BookSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceName => $composableBuilder(
      column: $table.sourceName, builder: (column) => column);

  GeneratedColumn<String> get bookKey =>
      $composableBuilder(column: $table.bookKey, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get lastCheck =>
      $composableBuilder(column: $table.lastCheck, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAvailable => $composableBuilder(
      column: $table.lastAvailable, builder: (column) => column);

  GeneratedColumn<int> get chapterCount => $composableBuilder(
      column: $table.chapterCount, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);
}

class $$BookSourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookSourcesTable,
    BookSource,
    $$BookSourcesTableFilterComposer,
    $$BookSourcesTableOrderingComposer,
    $$BookSourcesTableAnnotationComposer,
    $$BookSourcesTableCreateCompanionBuilder,
    $$BookSourcesTableUpdateCompanionBuilder,
    (BookSource, BaseReferences<_$AppDatabase, $BookSourcesTable, BookSource>),
    BookSource,
    PrefetchHooks Function()> {
  $$BookSourcesTableTableManager(_$AppDatabase db, $BookSourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<String> sourceId = const Value.absent(),
            Value<String> sourceName = const Value.absent(),
            Value<String> bookKey = const Value.absent(),
            Value<bool> isPrimary = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<DateTime?> lastCheck = const Value.absent(),
            Value<DateTime?> lastAvailable = const Value.absent(),
            Value<int> chapterCount = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookSourcesCompanion(
            id: id,
            bookId: bookId,
            sourceId: sourceId,
            sourceName: sourceName,
            bookKey: bookKey,
            isPrimary: isPrimary,
            confidence: confidence,
            score: score,
            lastCheck: lastCheck,
            lastAvailable: lastAvailable,
            chapterCount: chapterCount,
            enabled: enabled,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required String sourceId,
            required String sourceName,
            required String bookKey,
            Value<bool> isPrimary = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<double> score = const Value.absent(),
            Value<DateTime?> lastCheck = const Value.absent(),
            Value<DateTime?> lastAvailable = const Value.absent(),
            Value<int> chapterCount = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookSourcesCompanion.insert(
            id: id,
            bookId: bookId,
            sourceId: sourceId,
            sourceName: sourceName,
            bookKey: bookKey,
            isPrimary: isPrimary,
            confidence: confidence,
            score: score,
            lastCheck: lastCheck,
            lastAvailable: lastAvailable,
            chapterCount: chapterCount,
            enabled: enabled,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookSourcesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookSourcesTable,
    BookSource,
    $$BookSourcesTableFilterComposer,
    $$BookSourcesTableOrderingComposer,
    $$BookSourcesTableAnnotationComposer,
    $$BookSourcesTableCreateCompanionBuilder,
    $$BookSourcesTableUpdateCompanionBuilder,
    (BookSource, BaseReferences<_$AppDatabase, $BookSourcesTable, BookSource>),
    BookSource,
    PrefetchHooks Function()>;
typedef $$ReadProgressTableTableCreateCompanionBuilder
    = ReadProgressTableCompanion Function({
  required String bookId,
  Value<int> chapterIndex,
  Value<int> pageIndex,
  Value<int> charOffset,
  Value<double> scrollOffset,
  Value<int> readingTime,
  Value<DateTime> lastReadAt,
  Value<double> progressPercent,
  Value<int> rowid,
});
typedef $$ReadProgressTableTableUpdateCompanionBuilder
    = ReadProgressTableCompanion Function({
  Value<String> bookId,
  Value<int> chapterIndex,
  Value<int> pageIndex,
  Value<int> charOffset,
  Value<double> scrollOffset,
  Value<int> readingTime,
  Value<DateTime> lastReadAt,
  Value<double> progressPercent,
  Value<int> rowid,
});

class $$ReadProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReadProgressTableTable> {
  $$ReadProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get charOffset => $composableBuilder(
      column: $table.charOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readingTime => $composableBuilder(
      column: $table.readingTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progressPercent => $composableBuilder(
      column: $table.progressPercent,
      builder: (column) => ColumnFilters(column));
}

class $$ReadProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadProgressTableTable> {
  $$ReadProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageIndex => $composableBuilder(
      column: $table.pageIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get charOffset => $composableBuilder(
      column: $table.charOffset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readingTime => $composableBuilder(
      column: $table.readingTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progressPercent => $composableBuilder(
      column: $table.progressPercent,
      builder: (column) => ColumnOrderings(column));
}

class $$ReadProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadProgressTableTable> {
  $$ReadProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<int> get charOffset => $composableBuilder(
      column: $table.charOffset, builder: (column) => column);

  GeneratedColumn<double> get scrollOffset => $composableBuilder(
      column: $table.scrollOffset, builder: (column) => column);

  GeneratedColumn<int> get readingTime => $composableBuilder(
      column: $table.readingTime, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReadAt => $composableBuilder(
      column: $table.lastReadAt, builder: (column) => column);

  GeneratedColumn<double> get progressPercent => $composableBuilder(
      column: $table.progressPercent, builder: (column) => column);
}

class $$ReadProgressTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadProgressTableTable,
    ReadProgressTableData,
    $$ReadProgressTableTableFilterComposer,
    $$ReadProgressTableTableOrderingComposer,
    $$ReadProgressTableTableAnnotationComposer,
    $$ReadProgressTableTableCreateCompanionBuilder,
    $$ReadProgressTableTableUpdateCompanionBuilder,
    (
      ReadProgressTableData,
      BaseReferences<_$AppDatabase, $ReadProgressTableTable,
          ReadProgressTableData>
    ),
    ReadProgressTableData,
    PrefetchHooks Function()> {
  $$ReadProgressTableTableTableManager(
      _$AppDatabase db, $ReadProgressTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadProgressTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadProgressTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> bookId = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<int> charOffset = const Value.absent(),
            Value<double> scrollOffset = const Value.absent(),
            Value<int> readingTime = const Value.absent(),
            Value<DateTime> lastReadAt = const Value.absent(),
            Value<double> progressPercent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadProgressTableCompanion(
            bookId: bookId,
            chapterIndex: chapterIndex,
            pageIndex: pageIndex,
            charOffset: charOffset,
            scrollOffset: scrollOffset,
            readingTime: readingTime,
            lastReadAt: lastReadAt,
            progressPercent: progressPercent,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String bookId,
            Value<int> chapterIndex = const Value.absent(),
            Value<int> pageIndex = const Value.absent(),
            Value<int> charOffset = const Value.absent(),
            Value<double> scrollOffset = const Value.absent(),
            Value<int> readingTime = const Value.absent(),
            Value<DateTime> lastReadAt = const Value.absent(),
            Value<double> progressPercent = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadProgressTableCompanion.insert(
            bookId: bookId,
            chapterIndex: chapterIndex,
            pageIndex: pageIndex,
            charOffset: charOffset,
            scrollOffset: scrollOffset,
            readingTime: readingTime,
            lastReadAt: lastReadAt,
            progressPercent: progressPercent,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadProgressTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadProgressTableTable,
    ReadProgressTableData,
    $$ReadProgressTableTableFilterComposer,
    $$ReadProgressTableTableOrderingComposer,
    $$ReadProgressTableTableAnnotationComposer,
    $$ReadProgressTableTableCreateCompanionBuilder,
    $$ReadProgressTableTableUpdateCompanionBuilder,
    (
      ReadProgressTableData,
      BaseReferences<_$AppDatabase, $ReadProgressTableTable,
          ReadProgressTableData>
    ),
    ReadProgressTableData,
    PrefetchHooks Function()>;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required String id,
  required String bookId,
  required int chapterIndex,
  required int charOffset,
  Value<String> label,
  Value<String> color,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<int> chapterIndex,
  Value<int> charOffset,
  Value<String> label,
  Value<String> color,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get charOffset => $composableBuilder(
      column: $table.charOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get charOffset => $composableBuilder(
      column: $table.charOffset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<int> get charOffset => $composableBuilder(
      column: $table.charOffset, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
    Bookmark,
    PrefetchHooks Function()> {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
            Value<int> charOffset = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            bookId: bookId,
            chapterIndex: chapterIndex,
            charOffset: charOffset,
            label: label,
            color: color,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required int chapterIndex,
            required int charOffset,
            Value<String> label = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion.insert(
            id: id,
            bookId: bookId,
            chapterIndex: chapterIndex,
            charOffset: charOffset,
            label: label,
            color: color,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTable,
    Bookmark,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (Bookmark, BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark>),
    Bookmark,
    PrefetchHooks Function()>;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required String bookId,
  required int chapterIndex,
  required int startOffset,
  required int endOffset,
  Value<String?> content,
  Value<String> note,
  Value<String> color,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String> bookId,
  Value<int> chapterIndex,
  Value<int> startOffset,
  Value<int> endOffset,
  Value<String?> content,
  Value<String> note,
  Value<String> color,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startOffset => $composableBuilder(
      column: $table.startOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endOffset => $composableBuilder(
      column: $table.endOffset, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bookId => $composableBuilder(
      column: $table.bookId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startOffset => $composableBuilder(
      column: $table.startOffset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endOffset => $composableBuilder(
      column: $table.endOffset, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookId =>
      $composableBuilder(column: $table.bookId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
      column: $table.chapterIndex, builder: (column) => column);

  GeneratedColumn<int> get startOffset => $composableBuilder(
      column: $table.startOffset, builder: (column) => column);

  GeneratedColumn<int> get endOffset =>
      $composableBuilder(column: $table.endOffset, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
    Note,
    PrefetchHooks Function()> {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> bookId = const Value.absent(),
            Value<int> chapterIndex = const Value.absent(),
            Value<int> startOffset = const Value.absent(),
            Value<int> endOffset = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            bookId: bookId,
            chapterIndex: chapterIndex,
            startOffset: startOffset,
            endOffset: endOffset,
            content: content,
            note: note,
            color: color,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String bookId,
            required int chapterIndex,
            required int startOffset,
            required int endOffset,
            Value<String?> content = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> color = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            bookId: bookId,
            chapterIndex: chapterIndex,
            startOffset: startOffset,
            endOffset: endOffset,
            content: content,
            note: note,
            color: color,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
    Note,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$BookSourcesTableTableManager get bookSources =>
      $$BookSourcesTableTableManager(_db, _db.bookSources);
  $$ReadProgressTableTableTableManager get readProgressTable =>
      $$ReadProgressTableTableTableManager(_db, _db.readProgressTable);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
}
