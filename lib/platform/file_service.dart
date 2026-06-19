import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 文件服务 - 处理文件操作
class FileService {
  static const _uuid = Uuid();

  Future<String> getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> getCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  Future<String> getBooksDirectory() async {
    final baseDir = await getDocumentsDirectory();
    final booksDir = Directory('$baseDir/books');
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    return booksDir.path;
  }

  Future<String> getCoversDirectory() async {
    final baseDir = await getDocumentsDirectory();
    final coversDir = Directory('$baseDir/covers');
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir.path;
  }

  Future<String> getChapterCacheDirectory(String bookId) async {
    final baseDir = await getCacheDirectory();
    final chapterDir = Directory('$baseDir/chapters/$bookId');
    if (!await chapterDir.exists()) {
      await chapterDir.create(recursive: true);
    }
    return chapterDir.path;
  }

  Future<String> copyFileToBooks(String sourcePath, String format) async {
    final booksDir = await getBooksDirectory();
    final fileName = '${_uuid.v4()}.$format';
    final destPath = '$booksDir/$fileName';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<String> saveCoverImage(List<int> bytes, String bookId) async {
    final coversDir = await getCoversDirectory();
    final fileName = '${bookId}_cover.jpg';
    final filePath = '$coversDir/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  Future<String> saveChapterContent(String bookId, int chapterIndex, String content) async {
    final cacheDir = await getChapterCacheDirectory(bookId);
    final fileName = 'chapter_$chapterIndex.txt';
    final filePath = '$cacheDir/$fileName';
    final file = File(filePath);
    await file.writeAsString(content);
    return filePath;
  }

  Future<String?> readChapterContent(String bookId, int chapterIndex) async {
    final cacheDir = await getChapterCacheDirectory(bookId);
    final fileName = 'chapter_$chapterIndex.txt';
    final filePath = '$cacheDir/$fileName';
    final file = File(filePath);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<void> deleteBookFiles(String bookId, String? localPath) async {
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    final coversDir = await getCoversDirectory();
    final coverFile = File('$coversDir/${bookId}_cover.jpg');
    if (await coverFile.exists()) {
      await coverFile.delete();
    }
    final cacheDir = await getCacheDirectory();
    final chapterDir = Directory('$cacheDir/chapters/$bookId');
    if (await chapterDir.exists()) {
      await chapterDir.delete(recursive: true);
    }
  }

  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return await file.length();
  }

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  Future<int> getDirectorySize(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return 0;
    int totalSize = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  Future<void> clearCache() async {
    final cacheDir = await getCacheDirectory();
    final dir = Directory(cacheDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}