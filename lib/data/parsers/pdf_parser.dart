import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';

/// PDF 解析器 - 解析 PDF 文件的元数据和内容
class PdfParser {
  /// 解析 PDF 文件，返回书籍模型和章节列表
  Future<PdfParseResult> parse(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final bytes = await file.readAsBytes();
      final content = String.fromCharCodes(bytes);

      // 提取 PDF 元数据（简化版本）
      final title = _extractMetadata(content, '/Title') ??
          _extractFileName(filePath);
      final author = _extractMetadata(content, '/Author') ?? '';
      final pageCount = _countPages(content);

      // 为每一页创建一个章节
      final chapters = <Chapter>[];
      for (int i = 0; i < pageCount; i++) {
        chapters.add(Chapter(
          id: '',
          bookId: '',
          chapterKey: 'page_$i',
          title: '第 ${i + 1} 页',
          orderIndex: i,
        ));
      }

      final book = Book(
        id: '',
        title: title,
        author: author,
        localPath: filePath,
        format: 'pdf',
        type: 'local',
        totalChapters: pageCount,
      );

      return PdfParseResult(book: book, chapters: chapters, pageCount: pageCount);
    } catch (e) {
      debugPrint('[PdfParser] 解析失败: $e');
      rethrow;
    }
  }

  /// 提取 PDF 元数据字段
  String? _extractMetadata(String content, String key) {
    try {
      final pattern = '$key (';
      final startIdx = content.indexOf(pattern);
      if (startIdx == -1) return null;

      final valueStart = startIdx + pattern.length;
      final valueEnd = content.indexOf(')', valueStart);
      if (valueEnd == -1) return null;

      return content.substring(valueStart, valueEnd).trim();
    } catch (_) {
      return null;
    }
  }

  /// 统计 PDF 页数（通过 /Type /Page 模式计数）
  int _countPages(String content) {
    final pattern = RegExp(r'/Type\s*/Page[^s]');
    return pattern.allMatches(content).length.clamp(1, 9999);
  }

  /// 从文件路径提取文件名
  String _extractFileName(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
  }
}

/// PDF 解析结果
class PdfParseResult {
  final Book book;
  final List<Chapter> chapters;
  final int pageCount;

  PdfParseResult({
    required this.book,
    required this.chapters,
    required this.pageCount,
  });
}
