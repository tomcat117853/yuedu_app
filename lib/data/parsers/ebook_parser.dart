import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';

/// 电子书解析器 - 支持 MOBI, AZW, AZW3, AZW4, PDB 格式
///
/// 基于 PDB 容器格式解析，提取元数据和章节内容。
/// - MOBI: PalmDoc 格式，Amazon Kindle 早期使用
/// - AZW: Amazon Kindle 格式，本质是 MOBI
/// - AZW3 (KF8): Kindle Format 8，MOBI 的升级版本
/// - AZW4: Kindle PrintReplica，用于打印输出
/// - PDB: PalmOS 通用格式，如 TPZ, eReader 等
class EbookParser {
  /// 根据文件扩展名解析电子书
  Future<EbookParseResult> parse(String filePath) async {
    final extension = _getFormat(filePath);
    switch (extension) {
      case 'azw':
      case 'azw3':
      case 'azw4':
      case 'mobi':
        return _parseMobiFormat(filePath, extension);
      case 'pdb':
      case 'tpz':
      case 'ereader':
        return _parsePdbFormat(filePath, extension);
      default:
        throw Exception('不支持的电子书格式: $extension');
    }
  }

  /// 从文件路径获取格式
  String _getFormat(String filePath) {
    final fileName = filePath.toLowerCase();
    if (fileName.endsWith('.azw4')) return 'azw4';
    if (fileName.endsWith('.azw3')) return 'azw3';
    if (fileName.endsWith('.azw')) return 'azw';
    if (fileName.endsWith('.mobi')) return 'mobi';
    if (fileName.endsWith('.pdb')) return 'pdb';
    if (fileName.endsWith('.tpz')) return 'tpz';
    if (fileName.endsWith('.ereader')) return 'ereader';
    return '';
  }

  /// 解析 MOBI/AZW 系列格式
  Future<EbookParseResult> _parseMobiFormat(String filePath, String format) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final bytes = await file.readAsBytes();
      final data = ByteData.sublistView(Uint8List.fromList(bytes));

      // 验证 PDB 头部
      final pdbName = _readString(data, 0, 32).trim();
      final type = _readUint32(data, 60);
      final creator = _readUint32(data, 64);

      // 检查是否为有效的 MOBI/KF8 格式
      // MOBI type = 0x424F4F4B ('BOOK'), creator = 'MOBI' (0x4D4F4249)
      // KF8 (AZW3) creator = 'KF8M' (0x4B46384D) 或 'MOBI'
      final isMobiFormat = type == 0x424F4F4B;
      final isKindleFormat = creator == 0x4B46384D || creator == 0x4D4F4249;

      if (!isMobiFormat && !isKindleFormat) {
        throw Exception('不是有效的 MOBI/AZW 格式文件');
      }

      // 读取记录数量
      final numRecords = _readUint16(data, 76);
      if (numRecords < 2) {
        throw Exception('文件记录数不足');
      }

      // 读取第一条记录偏移（MOBI header 所在位置）
      final firstRecordOffset = _readUint32(data, 78);

      // 读取 MOBI header
      final headerLength = _readUint32(data, firstRecordOffset + 16);
      if (headerLength == 0) {
        throw Exception('无效的 MOBI header');
      }

      // 提取标题
      final extractedTitle = _extractMobiTitle(data, firstRecordOffset, headerLength);

      // 提取作者（从 EXTH header）
      final extractedAuthor = _extractExthField(data, firstRecordOffset, 100);

      // 获取书籍基本信息
      final fileName = filePath.split(Platform.pathSeparator).last;
      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      // 检测是否为 AZW3 (KF8) 格式
      final isKf8 = format == 'azw3' || creator == 0x4B46384D;
      final detectedFormat = isKf8 ? 'azw3' : (format == 'azw4' ? 'azw4' : format);

      final book = Book(
        id: '',
        title: (extractedTitle ?? '').isNotEmpty ? extractedTitle! : baseName,
        author: extractedAuthor.isNotEmpty ? extractedAuthor : '未知作者',
        localPath: filePath,
        format: detectedFormat,
        type: 'local',
        totalChapters: 1,
      );

      // 提取章节列表（如果有的话）
      final chapters = _extractChapters(data, firstRecordOffset, book.id);

      return EbookParseResult(
        book: book,
        chapters: chapters,
        rawText: '',
      );
    } catch (e) {
      debugPrint('[EbookParser] 解析 MOBI/AZW 失败: $e');
      rethrow;
    }
  }

  /// 解析 PDB 格式
  Future<EbookParseResult> _parsePdbFormat(String filePath, String format) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final bytes = await file.readAsBytes();
      final data = ByteData.sublistView(Uint8List.fromList(bytes));

      // 验证 PDB 头部
      final pdbName = _readString(data, 0, 32).trim();
      final type = _readString(data, 60, 4);
      final creator = _readString(data, 64, 4);

      // PDB 格式标识
      // TEXt = 0x54455874, BOOK = 0x424F4F4B
      final typeVal = _readUint32(data, 60);
      final isTextFormat = typeVal == 0x54455874 || type == 'TEXt';
      final isBookFormat = typeVal == 0x424F4F4B || type == 'BOOK';

      if (!isTextFormat && !isBookFormat) {
        throw Exception('不是有效的 PDB/eReader 格式文件');
      }

      // 读取记录数量
      final numRecords = _readUint16(data, 76);
      if (numRecords < 1) {
        throw Exception('文件记录数不足');
      }

      // 提取标题（通常在 PDB 名称中）
      final fileName = filePath.split(Platform.pathSeparator).last;
      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      // 尝试从文档中提取标题
      String title = baseName;
      String author = '未知作者';

      // 如果有第一个记录，尝试从中提取元数据
      if (numRecords >= 2) {
        final firstRecordOffset = _readUint32(data, 78);
        // 跳过文本头，尝试读取标题
        if (firstRecordOffset < data.lengthInBytes - 100) {
          // 读取文档开始的文本，查找标题信息
          final docStart = _readString(data, firstRecordOffset, 200);
          title = _extractTitleFromText(docStart) ?? title;
          author = _extractAuthorFromText(docStart) ?? author;
        }
      }

      final book = Book(
        id: '',
        title: title,
        author: author,
        localPath: filePath,
        format: format,
        type: 'local',
        totalChapters: 1,
      );

      final chapters = [
        Chapter(
          id: '',
          bookId: '',
          chapterKey: 'full_text',
          title: title,
          orderIndex: 0,
        ),
      ];

      return EbookParseResult(
        book: book,
        chapters: chapters,
        rawText: '',
      );
    } catch (e) {
      debugPrint('[EbookParser] 解析 PDB 失败: $e');
      rethrow;
    }
  }

  /// 从 MOBI header 提取标题
  String? _extractMobiTitle(ByteData data, int headerOffset, int headerLength) {
    try {
      // 标题在 MOBI header 中的偏移位置
      final titleOffset = _readUint32(data, headerOffset + 84);
      final titleLength = _readUint32(data, headerOffset + 88);

      if (titleOffset > 0 && titleLength > 0) {
        return _readString(data, headerOffset + titleOffset, titleLength);
      }
    } catch (_) {}
    return null;
  }

  /// 从 EXTH header 提取字段
  String _extractExthField(ByteData data, int mobiHeaderOffset, int fieldType) {
    try {
      final exthOffset = _readUint32(data, mobiHeaderOffset + 204);
      if (exthOffset == 0xFFFFFFFF || exthOffset == 0) {
        return '';
      }

      final exthStart = mobiHeaderOffset + exthOffset;
      // EXTH 头部: 'EXTH' (4) + headerLength (4) + recordCount (4)
      final recordCount = _readUint32(data, exthStart + 8);

      int offset = exthStart + 12;
      for (int i = 0; i < recordCount && offset < data.lengthInBytes - 8; i++) {
        final recordType = _readUint32(data, offset);
        final recordLength = _readUint32(data, offset + 4);

        if (recordType == fieldType) {
          return _readString(data, offset + 8, recordLength - 8).trim();
        }

        offset += recordLength;
      }
    } catch (_) {}
    return '';
  }

  /// 从文本内容中提取标题
  String? _extractTitleFromText(String text) {
    // 尝试匹配常见的标题格式
    final patterns = [
      RegExp(r'^《(.+?)》', multiLine: true),
      RegExp(r'^"(.*?)"', multiLine: true),
      RegExp(r'^(.+?)\n'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    return null;
  }

  /// 从文本内容中提取作者
  String? _extractAuthorFromText(String text) {
    // 尝试匹配常见的作者格式
    final patterns = [
      RegExp(r'作者[：:]\s*(.+)', multiLine: true),
      RegExp(r'by\s+(.+)', multiLine: true),
      RegExp(r'^(.+?)\s*[-_]\s*.+?$', multiLine: true),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }
    return null;
  }

  /// 提取章节列表（简化实现）
  List<Chapter> _extractChapters(ByteData data, int headerOffset, String bookId) {
    // 完整的章节提取需要解析 MOBI 的 HUFF/CDIC 压缩
    // 这里返回单一章节，实际阅读时整个文件作为一个章节处理
    return [
      Chapter(
        id: '',
        bookId: bookId,
        chapterKey: 'full_text',
        title: '全文',
        orderIndex: 0,
      ),
    ];
  }

  // ==================== 二进制读取辅助方法 ====================

  int _readUint16(ByteData data, int offset) {
    if (offset + 2 > data.lengthInBytes) return 0;
    return data.getUint16(offset, Endian.big);
  }

  int _readUint32(ByteData data, int offset) {
    if (offset + 4 > data.lengthInBytes) return 0;
    return data.getUint32(offset, Endian.big);
  }

  String _readString(ByteData data, int offset, int length) {
    if (offset + length > data.lengthInBytes) return '';
    if (length <= 0) return '';
    final bytes = Uint8List.view(
      data.buffer,
      data.offsetInBytes + offset,
      length,
    );
    try {
      return String.fromCharCodes(bytes).replaceAll('\x00', '').trim();
    } catch (_) {
      return '';
    }
  }
}

/// 电子书解析结果
class EbookParseResult {
  final Book book;
  final List<Chapter> chapters;
  final String rawText;

  EbookParseResult({
    required this.book,
    required this.chapters,
    required this.rawText,
  });
}
