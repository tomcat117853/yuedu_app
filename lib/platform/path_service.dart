import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 路径服务 - 管理应用各目录路径
class PathService {
  /// 应用根目录
  String? _rootPath;

  /// 获取应用根目录
  Future<String> getRootPath() async {
    if (_rootPath != null) return _rootPath!;
    final dir = await getApplicationDocumentsDirectory();
    _rootPath = dir.path;
    return _rootPath!;
  }

  /// 获取数据库路径
  Future<String> getDatabasePath(String dbName) async {
    final root = await getRootPath();
    return '$root/$dbName';
  }

  /// 获取书籍存储路径
  Future<String> getBookStoragePath() async {
    final root = await getRootPath();
    final path = '$root/books';
    await _ensureDirectory(path);
    return path;
  }

  /// 获取封面存储路径
  Future<String> getCoverStoragePath() async {
    final root = await getRootPath();
    final path = '$root/covers';
    await _ensureDirectory(path);
    return path;
  }

  /// 获取章节缓存路径
  Future<String> getChapterCachePath(String bookId) async {
    final root = await getRootPath();
    final path = '$root/cache/chapters/$bookId';
    await _ensureDirectory(path);
    return path;
  }

  /// 获取临时文件路径
  Future<String> getTempPath() async {
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  /// 获取日志文件路径
  Future<String> getLogPath() async {
    final root = await getRootPath();
    final path = '$root/logs';
    await _ensureDirectory(path);
    return path;
  }

  /// 获取导出文件路径
  Future<String> getExportPath() async {
    final root = await getRootPath();
    final path = '$root/exports';
    await _ensureDirectory(path);
    return path;
  }

  /// 确保目录存在
  Future<void> _ensureDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  /// 构建完整路径
  String buildPath(List<String> segments) {
    return segments.join(Platform.pathSeparator);
  }

  /// 获取文件扩展名
  String getExtension(String filePath) {
    final dotIndex = filePath.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return filePath.substring(dotIndex + 1).toLowerCase();
  }

  /// 获取文件名（不含扩展名）
  String getBaseName(String filePath) {
    final separator = Platform.pathSeparator;
    final lastSeparator = filePath.lastIndexOf(separator);
    final fileName = lastSeparator >= 0
        ? filePath.substring(lastSeparator + 1)
        : filePath;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return fileName;
    return fileName.substring(0, dotIndex);
  }
}
