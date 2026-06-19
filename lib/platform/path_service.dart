import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 路径服务 - 管理应用各目录路径
class PathService {
  String? _rootPath;

  Future<String> getRootPath() async {
    if (_rootPath != null) return _rootPath!;
    final dir = await getApplicationDocumentsDirectory();
    _rootPath = dir.path;
    return _rootPath!;
  }

  Future<String> getDatabasePath(String dbName) async {
    final root = await getRootPath();
    return '$root/$dbName';
  }

  Future<String> getBookStoragePath() async {
    final root = await getRootPath();
    final path = '$root/books';
    await _ensureDirectory(path);
    return path;
  }

  Future<String> getCoverStoragePath() async {
    final root = await getRootPath();
    final path = '$root/covers';
    await _ensureDirectory(path);
    return path;
  }

  Future<String> getChapterCachePath(String bookId) async {
    final root = await getRootPath();
    final path = '$root/cache/chapters/$bookId';
    await _ensureDirectory(path);
    return path;
  }

  Future<String> getTempPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  Future<String> getLogPath() async {
    final root = await getRootPath();
    final path = '$root/logs';
    await _ensureDirectory(path);
    return path;
  }

  Future<String> getExportPath() async {
    final root = await getRootPath();
    final path = '$root/exports';
    await _ensureDirectory(path);
    return path;
  }

  Future<void> _ensureDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  String buildPath(List<String> segments) {
    return segments.join(Platform.pathSeparator);
  }

  String getExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return filePath.substring(dotIndex + 1).toLowerCase();
  }

  String getBaseName(String filePath) {
    final separator = Platform.pathSeparator;
    final lastSeparator = filePath.lastIndexOf(separator);
    final fileName = lastSeparator >= 0 ? filePath.substring(lastSeparator + 1) : filePath;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return fileName;
    return fileName.substring(0, dotIndex);
  }
}