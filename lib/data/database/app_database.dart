import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import '../../config/constants.dart';
import 'tables/books.dart';
import 'tables/chapters.dart';
import 'tables/book_sources.dart';
import 'tables/read_progress.dart';
import 'tables/bookmarks.dart';
import 'daos/book_dao.dart';
import 'daos/chapter_dao.dart';
import 'daos/progress_dao.dart';
import 'daos/book_source_dao.dart';

part 'app_database.g.dart';

/// 应用数据库
@DriftDatabase(
  tables: [Books, Chapters, BookSources, ReadProgressTable, Bookmarks, Notes],
  daos: [BookDao, ChapterDao, ProgressDao, BookSourceDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => AppConstants.databaseVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // 未来版本迁移逻辑
          if (from < 2) {
            // 示例: 添加新列
          }
        },
        beforeOpen: (details) async {
          // 启用外键约束
          await customStatement('PRAGMA foreign_keys = ON');
          // WAL模式提升性能
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );
}

/// 打开数据库连接
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.databaseName));

    // 在移动平台上使用 sqlite3_flutter_libs 加载原生库
    if (Platform.isAndroid || Platform.isIOS) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    return NativeDatabase.createInBackground(file);
  });
}
