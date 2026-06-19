import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 文件服务 - 处理文件操作
class FileService {
  static const _uuid = Uuid();

  /// 获取应用文档目录
  Future<String> getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// 获取应用缓存目录
  Future<String> getCacheDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  /// 获取书籍存储目录
  Future<String> getBooksDirectory() async {
    final baseDir = await getDocumentsDirectory();
    final booksDir = Directory('$baseDir/books');
    if (!await booksDir.exists()) {
      await booksDir.create(recursive: true);
    }
    return booksDir.path;
  }

  /// 获取封面存储目录
  Future<String> getCoversDirectory() async {
    final baseDir = await getDocumentsDirectory();
    final coversDir = Directory('$baseDir/covers');
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir.path;
  }

  /// 获取章节缓存目录
  Future<String> getChapterCacheDirectory(String bookId) async {
    final baseDir = await getCacheDirectory();
    final chapterDir = Directory('$baseDir/chapters/$bookId');
    if (!await chapterDir.exists()) {
      await chapterDir.create(recursive: true);
    }
    return chapterDir.path;
  }

  /// 复制文件到指定目录
  Future<String> copyFileToBooks(String sourcePath, String format) async {
    final booksDir = await getBooksDirectory();
    final fileName = '${_uuid.v4()}.$format';
    final destPath = '$booksDir/$fileName';
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  /// 保存封面图片
  Future<String> saveCoverImage(List<int> bytes, String bookId) async {
    final coversDir = await getCoversDirectory();
    final fileName = '${bookId}_cover.jpg';
    final filePath = '$coversDir/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// 保存章节内容到缓存
  Future<String> saveChapterContent(
    String bookId,
    int chapterIndex,
    String content,
  ) async {
    final cacheDir = await getChapterCacheDirectory(bookId);
    final fileName = 'chapter_$chapterIndex.txt';
    final filePath = '$cacheDir/$fileName';
    final file = File(filePath);
    await file.writeAsString(content);
    return filePath;
  }

  /// 从缓存读取章节内容
  Future<String?> readChapterContent(
    String bookId,
    int chapterIndex,
  ) async {
    final cacheDir = await getChapterCacheDirectory(bookId);
    final fileName = 'chapter_$chapterIndex.txt';
    final filePath = '$cacheDir/$fileName';
    final file = File(filePath);
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  /// 删除书籍相关文件
  Future<void> deleteBookFiles(String bookId, String? localPath) async {
    // 删除本地文件
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // 删除封面
    final coversDir = await getCoversDirectory();
    final coverFile = File('$coversDir/${bookId}_cover.jpg');
    if (await coverFile.exists()) {
      await coverFile.delete();
    }

    // 删除章节缓存
    final cacheDir = await getCacheDirectory();
    final chapterDir = Directory('$cacheDir/chapters/$bookId');
    if (await chapterDir.exists()) {
      await chapterDir.delete(recursive: true);
    }
  }

  /// 获取文件大小
  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return await file.length();
  }

  /// 检查文件是否存在
  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// 计算目录大小
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

  /// 清理缓存
  Future<void> clearCache() async {
    final cacheDir = await getCacheDirectory();
    final dir = Directory(cacheDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      await dir.create(recursive: true);
    }
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
