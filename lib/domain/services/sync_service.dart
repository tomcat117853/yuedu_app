import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/source_repository.dart';
import '../models/book.dart';
import '../models/read_progress.dart';

class SyncPayload {
  final List<Map<String, dynamic>> books, progress, sources;
  final DateTime timestamp;
  SyncPayload({required this.books, required this.progress, required this.sources, required this.timestamp});
  Map<String, dynamic> toJson() => {'books': books, 'progress': progress, 'sources': sources, 'timestamp': timestamp.toIso8601String()};
  factory SyncPayload.fromJson(Map<String, dynamic> json) => SyncPayload(books: (json['books'] as List).map((e) => e as Map<String, dynamic>).toList(), progress: (json['progress'] as List).map((e) => e as Map<String, dynamic>).toList(), sources: (json['sources'] as List).map((e) => e as Map<String, dynamic>).toList(), timestamp: DateTime.parse(json['timestamp'] as String));
  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
  factory SyncPayload.fromJsonString(String str) => SyncPayload.fromJson(jsonDecode(str) as Map<String, dynamic>);
}

enum ConflictStrategy { keepLatest, keepLocal, keepRemote, merge }
enum SyncStatus { idle, syncing, success, error, conflict }

class SyncService {
  final BookRepository bookRepository;
  final SourceRepository sourceRepository;
  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;
  DateTime? _lastSyncTime;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? _lastError;
  String? get lastError => _lastError;
  void Function(SyncStatus status)? onStatusChanged;

  SyncService({required this.bookRepository, required this.sourceRepository});

  Future<SyncPayload> exportSyncData() async {
    _setStatus(SyncStatus.syncing);
    try {
      final books = await bookRepository.getAllBooks();
      final bookData = books.map((b) => b.toJson()).toList();
      final progressList = await bookRepository.getAllProgress();
      final progressData = progressList.map((p) => p.toJson()).toList();
      final sources = await sourceRepository.getAllSources();
      final sourceData = sources.map((s) => s.toJson()).toList();
      final payload = SyncPayload(books: bookData, progress: progressData, sources: sourceData, timestamp: DateTime.now());
      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      return payload;
    } catch (e) { _lastError = e.toString(); _setStatus(SyncStatus.error); rethrow; }
  }

  Future<SyncResult> importSyncData(SyncPayload payload, {ConflictStrategy strategy = ConflictStrategy.keepLatest}) async {
    _setStatus(SyncStatus.syncing);
    int booksAdded = 0, booksUpdated = 0, progressUpdated = 0;
    try {
      for (final bookJson in payload.books) {
        final remoteBook = Book.fromJson(bookJson);
        final localBook = await bookRepository.getBookById(remoteBook.id);
        if (localBook == null) { await bookRepository.insertBook(remoteBook); booksAdded++; }
        else { final shouldUpdate = _shouldUpdate(localBook.updatedAt, remoteBook.updatedAt, strategy); if (shouldUpdate) { await bookRepository.updateBook(remoteBook); booksUpdated++; } }
      }
      for (final progressJson in payload.progress) {
        final remoteProgress = ReadProgress.fromJson(progressJson);
        final localProgress = await bookRepository.getReadProgress(remoteProgress.bookId);
        if (localProgress == null) { await bookRepository.saveReadProgress(remoteProgress); progressUpdated++; }
        else { final shouldUpdate = _shouldUpdate(localProgress.lastReadAt, remoteProgress.lastReadAt, strategy); if (shouldUpdate) { await bookRepository.saveReadProgress(remoteProgress); progressUpdated++; } }
      }
      _lastSyncTime = DateTime.now();
      _setStatus(SyncStatus.success);
      return SyncResult(booksAdded: booksAdded, booksUpdated: booksUpdated, progressUpdated: progressUpdated);
    } catch (e) { _lastError = e.toString(); _setStatus(SyncStatus.error); rethrow; }
  }

  bool _shouldUpdate(DateTime localTime, DateTime remoteTime, ConflictStrategy strategy) { switch (strategy) { case ConflictStrategy.keepLatest: return remoteTime.isAfter(localTime); case ConflictStrategy.keepLocal: return false; case ConflictStrategy.keepRemote: return true; case ConflictStrategy.merge: return remoteTime.isAfter(localTime); }}
  void _setStatus(SyncStatus status) { _status = status; onStatusChanged?.call(status); }
  Future<void> uploadToRemote(SyncPayload payload) async { debugPrint('[SyncService] 上传到远程服务器（待实现）'); }
  Future<SyncPayload?> downloadFromRemote() async { debugPrint('[SyncService] 从远程服务器下载（待实现）'); return null; }
}

class SyncResult { final int booksAdded, booksUpdated, progressUpdated; SyncResult({required this.booksAdded, required this.booksUpdated, required this.progressUpdated}); int get totalChanges => booksAdded + booksUpdated + progressUpdated; @override String toString() => 'SyncResult(added: $booksAdded, updated: $booksUpdated, progress: $progressUpdated)'; }