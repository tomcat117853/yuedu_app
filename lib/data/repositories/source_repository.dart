import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/book_source.dart';
import '../../domain/models/search_result.dart';
import '../database/app_database.dart' as db;

const _uuid = Uuid();

/// 书源仓库
class SourceRepository {
  final db.AppDatabase _db;

  SourceRepository(this._db);

  /// 生成唯一ID
  String generateId() => _uuid.v4();

  /// 根据书籍ID获取书源列表
  Future<List<BookSource>> getSourcesByBookId(String bookId) async {
    final entities = await _db.bookSourceDao.getSourcesByBookId(bookId);
    return entities.map(_entityToModel).toList();
  }

  /// 根据ID获取书源
  Future<BookSource?> getSourceById(String id) async {
    final entity = await _db.bookSourceDao.getSourceById(id);
    return entity != null ? _entityToModel(entity) : null;
  }

  /// 获取所有书源
  Future<List<BookSource>> getAllSources() async {
    final entities = await _db.bookSourceDao.getAllSources();
    return entities.map(_entityToModel).toList();
  }

  /// 获取所有启用的书源
  Future<List<BookSource>> getEnabledSources() async {
    final entities = await _db.bookSourceDao.getEnabledSources();
    return entities.map(_entityToModel).toList();
  }

  /// 获取书籍的主书源
  Future<BookSource?> getPrimarySource(String bookId) async {
    final entity = await _db.bookSourceDao.getPrimarySource(bookId);
    return entity != null ? _entityToModel(entity) : null;
  }

  /// 插入书源
  Future<void> insertSource(BookSource source) async {
    await _db.bookSourceDao.insertSource(_modelToCompanion(source));
  }

  /// 更新书源
  Future<void> updateSource(BookSource source) async {
    await _db.bookSourceDao.updateSource(_modelToCompanion(source));
  }

  /// 删除书源
  Future<void> deleteSource(String id) async {
    await _db.bookSourceDao.deleteSource(id);
  }

  /// 删除书籍的所有书源
  Future<void> deleteSourcesByBookId(String bookId) async {
    await _db.bookSourceDao.deleteSourcesByBookId(bookId);
  }

  /// 搜索书籍（后续由 SourceEngine 实现）
  Future<List<SearchResult>> searchBook(String query) async {
    // 由 SourceEngine 层处理实际搜索
    return [];
  }

  /// 检查书源可用性（后续由 SourceEngine 实现）
  Future<bool> checkAvailability(BookSource source) async {
    // 由 SourceEngine 层处理实际检查
    return source.enabled;
  }

  /// 监听书源变化
  Stream<List<BookSource>> watchSourcesByBookId(String bookId) {
    return _db.bookSourceDao.watchSourcesByBookId(bookId).map(
          (entities) => entities.map(_entityToModel).toList(),
        );
  }

  // ==================== 转换方法 ====================

  /// 数据库实体转领域模型
  /// 使用 dynamic 参数以避免 Drift 生成类型与领域模型的命名冲突
  BookSource _entityToModel(dynamic entity) {
    return BookSource(
      id: entity.id as String,
      bookId: entity.bookId as String,
      sourceId: entity.sourceId as String,
      sourceName: entity.sourceName as String,
      bookKey: entity.bookKey as String,
      isPrimary: entity.isPrimary as bool,
      confidence: (entity.confidence as num?)?.toDouble() ?? 0.5,
      score: (entity.score as num?)?.toDouble() ?? 0.0,
      lastCheck: entity.lastCheck as DateTime?,
      lastAvailable: entity.lastAvailable as DateTime?,
      chapterCount: entity.chapterCount as int? ?? 0,
      enabled: entity.enabled as bool? ?? true,
    );
  }

  /// 领域模型转数据库Companion
  db.BookSourcesCompanion _modelToCompanion(BookSource source) {
    return db.BookSourcesCompanion(
      id: Value(source.id),
      bookId: Value(source.bookId),
      sourceId: Value(source.sourceId),
      sourceName: Value(source.sourceName),
      bookKey: Value(source.bookKey),
      isPrimary: Value(source.isPrimary),
      confidence: Value(source.confidence),
      score: Value(source.score),
      lastCheck: Value(source.lastCheck),
      lastAvailable: Value(source.lastAvailable),
      chapterCount: Value(source.chapterCount),
      enabled: Value(source.enabled),
    );
  }
}
