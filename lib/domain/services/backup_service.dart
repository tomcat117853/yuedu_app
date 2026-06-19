import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/database/database.dart';
import '../models/book.dart';
import '../models/bookmark.dart';
import '../models/book_source.dart';
import '../models/chapter.dart';
import '../models/layout_config.dart';
import '../models/read_progress.dart';

class BackupService {
  final AppDatabase _database;

  BackupService(this._database);

  Future<String> createBackup() async {
    final books = await _database.booksDao.getAllBooks();
    final chapters = await _database.chaptersDao.getAllChapters();
    final sources = await _database.sourcesDao.getAllSources();
    final progresses = await _database.progressesDao.getAllProgresses();
    final bookmarks = await _database.bookmarksDao.getAllBookmarks();

    final layoutConfigs = await _database.layoutConfigsDao.getAllConfigs();

    final backupData = {
      'version': '1.0.0',
      'createdAt': DateTime.now().toIso8601String(),
      'books': books.map((b) => b.toJson()).toList(),
      'chapters': chapters.map((c) => c.toJson()).toList(),
      'sources': sources.map((s) => s.toJson()).toList(),
      'progresses': progresses.map((p) => p.toJson()).toList(),
      'bookmarks': bookmarks.map((b) => b.toJson()).toList(),
      'layoutConfigs': layoutConfigs.map((c) => c.toJson()).toList(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');
    await backupDir.create(recursive: true);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${backupDir.path}/backup_$timestamp.json';

    await File(filePath).writeAsString(json.encode(backupData));

    return filePath;
  }

  Future<void> importBackup(String filePath, {bool merge = false}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('备份文件不存在');
    }

    final content = await file.readAsString();
    final backupData = json.decode(content) as Map<String, dynamic>;

    if (!merge) {
      await _database.transaction(() async {
        await _database.booksDao.deleteAllBooks();
        await _database.chaptersDao.deleteAllChapters();
        await _database.sourcesDao.deleteAllSources();
        await _database.progressesDao.deleteAllProgresses();
        await _database.bookmarksDao.deleteAllBookmarks();
        await _database.layoutConfigsDao.deleteAllConfigs();
      });
    }

    await _database.transaction(() async {
      if (backupData.containsKey('books')) {
        final books = (backupData['books'] as List)
            .map((json) => Book.fromJson(json as Map<String, dynamic>))
            .toList();
        for (final book in books) {
          await _database.booksDao.insertBook(book);
        }
      }

      if (backupData.containsKey('chapters')) {
        final chapters = (backupData['chapters'] as List)
            .map((json) => Chapter.fromJson(json as Map<String, dynamic>))
            .toList();
        for (final chapter in chapters) {
          await _database.chaptersDao.insertChapter(chapter);
        }
      }

      if (backupData.containsKey('sources')) {
        final sources = (backupData['sources'] as List)
            .map((json) => BookSource.fromJson(json as Map<String, dynamic>))
            .toList();
        for (final source in sources) {
          await _database.sourcesDao.insertSource(source);
        }
      }

      if (backupData.containsKey('progresses')) {
        final progresses = (backupData['progresses'] as List)
            .map((json) => ReadProgress.fromJson(json as Map<String, dynamic>))
            .toList();
        for (final progress in progresses) {
          await _database.progressesDao.insertProgress(progress);
        }
      }

      if (backupData.containsKey('bookmarks')) {
        final bookmarks = (backupData['bookmarks'] as List)
            .map((json) => Bookmark.fromJson(json as Map<String, dynamic>))
            .toList();
        for (final bookmark in bookmarks) {
          await _database.bookmarksDao.insertBookmark(bookmark);
        }
      }

      if (backupData.containsKey('layoutConfigs')) {
        final configs = (backupData['layoutConfigs'] as List)
            .map((json) => LayoutConfig.fromJson(json as Map<String, dynamic>))
            .toList();
        for (final config in configs) {
          await _database.layoutConfigsDao.insertConfig(config);
        }
      }
    });
  }

  Future<List<Map<String, dynamic>>> getBackupList() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');

    if (!await backupDir.exists()) {
      return [];
    }

    final files = await backupDir.list().whereType<File>().toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    final backups = <Map<String, dynamic>>[];
    for (final file in files) {
      if (file.path.endsWith('.json')) {
        try {
          final content = await file.readAsString();
          final data = json.decode(content) as Map<String, dynamic>;
          final bookCount = (data['books'] as List?)?.length ?? 0;

          backups.add({
            'path': file.path,
            'name': file.path.split(Platform.pathSeparator).last,
            'createdAt': data['createdAt'] ?? file.lastModifiedSync().toIso8601String(),
            'bookCount': bookCount,
            'version': data['version'] ?? 'unknown',
          });
        } catch (_) {
          // Skip invalid files
        }
      }
    }

    return backups;
  }

  Future<void> deleteBackup(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> shareBackup(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }
}