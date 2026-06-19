import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database/app_database.dart';
import 'data/repositories/book_repository.dart';
import 'data/repositories/source_repository.dart';
import 'domain/engine/anti_crawl.dart';
import 'domain/engine/source_engine.dart';
import 'domain/engine/source_matcher.dart';
import 'domain/models/source_definition.dart';
import 'domain/services/book_service.dart';
import 'domain/services/backup_service.dart';
import 'domain/services/chapter_cache_service.dart';
import 'domain/services/read_engine.dart';
import 'domain/services/source_importer.dart';
import 'domain/services/source_service.dart';
import 'domain/services/sync_service.dart';
import 'domain/services/tts_service.dart';
import 'platform/file_service.dart';
import 'platform/path_service.dart';

/// 数据库 Provider（全局单例）
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// 书籍仓库 Provider
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BookRepository(db);
});

/// 书源仓库 Provider
final sourceRepositoryProvider = Provider<SourceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SourceRepository(db);
});

/// 书籍服务 Provider
final bookServiceProvider = Provider<BookService>((ref) {
  final repo = ref.watch(bookRepositoryProvider);
  return BookService(repo);
});

/// 备份服务 Provider
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final bookRepo = ref.watch(bookRepositoryProvider);
  final sourceRepo = ref.watch(sourceRepositoryProvider);
  return BackupService(
    db,
    bookRepo,
    sourceRepo,
  );
});

/// 反爬虫管理器 Provider
final antiCrawlProvider = Provider<AntiCrawlManager>((ref) {
  final manager = AntiCrawlManager();
  ref.onDispose(() => manager.clearAllCookies());
  return manager;
});

/// 书源执行引擎 Provider
final sourceEngineProvider = Provider<SourceEngine>((ref) {
  final antiCrawl = ref.watch(antiCrawlProvider);
  final engine = SourceEngine(antiCrawl: antiCrawl);
  ref.onDispose(() => engine.dispose());
  return engine;
});

/// 书源匹配器 Provider
final sourceMatcherProvider = Provider<SourceMatcher>((ref) {
  return SourceMatcher();
});

/// 书源导入导出服务 Provider
final sourceImporterProvider = Provider<SourceImporter>((ref) {
  final pathService = ref.watch(pathServiceProvider);
  return SourceImporter(pathService);
});

/// 章节缓存服务 Provider
final chapterCacheServiceProvider = Provider<ChapterCacheService>((ref) {
  final fileService = ref.watch(fileServiceProvider);
  final bookRepository = ref.watch(bookRepositoryProvider);
  final sourceEngine = ref.watch(sourceEngineProvider);
  final sourceRepository = ref.watch(sourceRepositoryProvider);
  return ChapterCacheService(
    fileService: fileService,
    bookRepository: bookRepository,
    sourceEngine: sourceEngine,
    sourceRepository: sourceRepository,
  );
});

/// 书源服务 Provider（包含引擎能力）
final sourceServiceProvider = Provider<SourceService>((ref) {
  final repo = ref.watch(sourceRepositoryProvider);
  final engine = ref.watch(sourceEngineProvider);
  final matcher = ref.watch(sourceMatcherProvider);
  return SourceService(repo, engine: engine, matcher: matcher);
});

/// 阅读引擎 Provider
final readEngineProvider = Provider<ReadEngine>((ref) {
  final bookRepo = ref.watch(bookRepositoryProvider);
  return ReadEngine(bookRepo);
});

/// 文件服务 Provider
final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

/// 路径服务 Provider
final pathServiceProvider = Provider<PathService>((ref) {
  return PathService();
});

/// SharedPreferences Provider（异步）
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences 需要通过 SharedPreferences.init() 异步初始化后覆盖');
});

/// 书源定义列表 Provider（全局书源配置，非书籍关联的书源）
final sourceDefinitionsProvider =
    StateNotifierProvider<SourceDefinitionsNotifier, List<SourceDefinition>>(
        (ref) {
  return SourceDefinitionsNotifier();
});

/// 书源定义管理
class SourceDefinitionsNotifier extends StateNotifier<List<SourceDefinition>> {
  SourceDefinitionsNotifier() : super([]);

  void addSource(SourceDefinition def) {
    state = [...state, def];
  }

  void removeSource(String sourceId) {
    state = state.where((s) => s.id != sourceId).toList();
  }

  void updateSource(SourceDefinition def) {
    state = [
      for (final s in state)
        if (s.id == def.id) def else s,
    ];
  }

  void setSources(List<SourceDefinition> sources) {
    state = sources;
  }
}

/// TTS 服务 Provider
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 同步服务 Provider
final syncServiceProvider = Provider<SyncService>((ref) {
  final bookRepository = ref.watch(bookRepositoryProvider);
  final sourceRepository = ref.watch(sourceRepositoryProvider);
  return SyncService(
    bookRepository: bookRepository,
    sourceRepository: sourceRepository,
  );
});