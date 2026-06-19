import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/database/app_database.dart';
import 'data/repositories/book_repository.dart';
import 'data/repositories/source_repository.dart';
import 'domain/services/book_service.dart';
import 'domain/services/source_service.dart';
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

/// 书源服务 Provider
final sourceServiceProvider = Provider<SourceService>((ref) {
  final repo = ref.watch(sourceRepositoryProvider);
  return SourceService(repo);
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
