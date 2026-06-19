import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/source_repository.dart';
import '../../domain/models/book.dart';
import '../../domain/models/read_progress.dart';

/// 同步数据包装
class SyncPayload {
  final List<Map<String, dynamic>> books;
  final List<Map<String, dynamic>> progress;
  final List<Map<String, dynamic>> sources;
  final DateTime timestamp;

  SyncPayload({
    required this.books,
    required this.progress,
    required this.sources,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'books': books,
        'progress': progress,
        'sources': sources,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SyncPayload.fromJson(Map<String, dynamic> json) {
    return SyncPayload(
      books: (json['books'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      progress: (json['progress'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      sources: (json['sources'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  factory SyncPayload.fromJsonString(String str) {
    return SyncPayload.fromJson(jsonDecode(str) as Map<String, dynamic>);
  }
}

/// 同步冲突解决策略
enum ConflictStrategy {
  /// 保留最新
  keepLatest,

  /// 保留本地
  keepLocal,

  /// 保留远程
  keepRemote,

  /// 合并
  merge,
}

/// 同步状态
enum SyncStatus {
  idle,
  syncing,
  success,
  error,
  conflict,
}

/// 云同步管理器
class SyncService {
  final BookRepository bookRepository;
  final SourceRepository sourceRepository;

  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;

  String? _lastError;
  String? get lastError => _lastError;

  /// Supabase 客户端
  SupabaseClient? _supabaseClient;

  /// 用户ID
  String? _userId;

  /// 同步回调
  void Function(SyncStatus status)? onStatusChanged;

  SyncService({
    required this.bookRepository,
    required this.sourceRepository,
  });

  /// 初始化 Supabase 客户端
  Future<void> init({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    try {
      _supabaseClient = SupabaseClient(supabaseUrl, supabaseAnonKey);
      debugPrint('[SyncService] Supabase 客户端初始化成功');
    } catch (e) {
      debugPrint('[SyncService] Supabase 客户端初始化失败: $e');
    }
  }

  /// 设置用户ID
  void setUserId(String userId) {
    _userId = userId;
  }

  /// 生成本地同步数据（导出）
  Future<SyncPayload> exportSyncData() async {
    _setStatus(SyncStatus.syncing);

    try {
      // 导出书籍
      final books = await bookRepository.getAllBooks();
      final bookData = books.map((b) => b.toJson()).toList();

      // 导出进度
      final progressList = await bookRepository.getAllProgress();
      final progressData = progressList.map((p) => p.toJson()).toList();

      // 导出书源
      final sources = await sourceRepository.getAllSources();
      final sourceData = sources.map((s) => s.toJson()).toList();

      final payload = SyncPayload(
        books: bookData,
        progress: progressData,
        sources: sourceData,
        timestamp: DateTime.now(),
      );

      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      return payload;
    } catch (e) {
      _lastError = e.toString();
      _setStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// 从同步数据恢复（导入）
  Future<SyncResult> importSyncData(
    SyncPayload payload, {
    ConflictStrategy strategy = ConflictStrategy.keepLatest,
  }) async {
    _setStatus(SyncStatus.syncing);

    int booksAdded = 0;
    int booksUpdated = 0;
    int progressUpdated = 0;

    try {
      // 恢复书籍
      for (final bookJson in payload.books) {
        final remoteBook = Book.fromJson(bookJson);
        final localBook = await bookRepository.getBookById(remoteBook.id);

        if (localBook == null) {
          await bookRepository.insertBook(remoteBook);
          booksAdded++;
        } else {
          final shouldUpdate = _shouldUpdate(
            localBook.updatedAt,
            remoteBook.updatedAt,
            strategy,
          );
          if (shouldUpdate) {
            await bookRepository.updateBook(remoteBook);
            booksUpdated++;
          }
        }
      }

      // 恢复进度
      for (final progressJson in payload.progress) {
        final remoteProgress = ReadProgress.fromJson(progressJson);
        final localProgress =
            await bookRepository.getReadProgress(remoteProgress.bookId);

        if (localProgress == null) {
          await bookRepository.saveReadProgress(remoteProgress);
          progressUpdated++;
        } else {
          final shouldUpdate = _shouldUpdate(
            localProgress.lastReadAt,
            remoteProgress.lastReadAt,
            strategy,
          );
          if (shouldUpdate) {
            await bookRepository.saveReadProgress(remoteProgress);
            progressUpdated++;
          }
        }
      }

      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);

      return SyncResult(
        booksAdded: booksAdded,
        booksUpdated: booksUpdated,
        progressUpdated: progressUpdated,
      );
    } catch (e) {
      _lastError = e.toString();
      _setStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// 判断是否应该更新
  bool _shouldUpdate(
    DateTime localTime,
    DateTime remoteTime,
    ConflictStrategy strategy,
  ) {
    switch (strategy) {
      case ConflictStrategy.keepLatest:
        return remoteTime.isAfter(localTime);
      case ConflictStrategy.keepLocal:
        return false;
      case ConflictStrategy.keepRemote:
        return true;
      case ConflictStrategy.merge:
        return remoteTime.isAfter(localTime);
    }
  }

  void _setStatus(SyncStatus status) {
    _status = status;
    onStatusChanged?.call(status);
  }

  /// 上传到远程服务器（Supabase BaaS）
  Future<void> uploadToRemote(SyncPayload payload) async {
    if (_supabaseClient == null || _userId == null) {
      throw Exception('Supabase 客户端未初始化或用户未登录');
    }

    try {
      _setStatus(SyncStatus.syncing);

      final dataString = payload.toJsonString();

      // 上传到 Supabase
      final response = await _supabaseClient!
          .from('user_sync')
          .upsert({
            'user_id': _userId,
            'sync_data': dataString,
            'updated_at': DateTime.now().toIso8601String(),
          }, conflictTarget: 'user_id');

      if (response.error != null) {
        throw Exception(response.error!.message);
      }

      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      debugPrint('[SyncService] 上传到远程服务器成功');
    } catch (e) {
      _lastError = e.toString();
      _setStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// 从远程服务器下载
  Future<SyncPayload?> downloadFromRemote() async {
    if (_supabaseClient == null || _userId == null) {
      throw Exception('Supabase 客户端未初始化或用户未登录');
    }

    try {
      _setStatus(SyncStatus.syncing);

      final response = await _supabaseClient!
          .from('user_sync')
          .select()
          .eq('user_id', _userId)
          .maybeSingle();

      if (response == null) {
        _setStatus(SyncStatus.success);
        return null;
      }

      final syncData = response['sync_data'] as String;
      final payload = SyncPayload.fromJsonString(syncData);

      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      debugPrint('[SyncService] 从远程服务器下载成功');

      return payload;
    } catch (e) {
      _lastError = e.toString();
      _setStatus(SyncStatus.error);
      rethrow;
    }
  }

  /// 一键同步：下载远程数据并合并
  Future<SyncResult> syncWithRemote({
    ConflictStrategy strategy = ConflictStrategy.keepLatest,
  }) async {
    final remotePayload = await downloadFromRemote();
    if (remotePayload == null) {
      // 没有远程数据，上传本地数据
      final localPayload = await exportSyncData();
      await uploadToRemote(localPayload);
      return SyncResult(booksAdded: 0, booksUpdated: 0, progressUpdated: 0);
    }

    return importSyncData(remotePayload, strategy: strategy);
  }
}

/// 同步结果
class SyncResult {
  final int booksAdded;
  final int booksUpdated;
  final int progressUpdated;

  SyncResult({
    required this.booksAdded,
    required this.booksUpdated,
    required this.progressUpdated,
  });

  int get totalChanges => booksAdded + booksUpdated + progressUpdated;

  @override
  String toString() =>
      'SyncResult(added: $booksAdded, updated: $booksUpdated, progress: $progressUpdated)';
}
