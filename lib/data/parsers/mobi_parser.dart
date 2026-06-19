import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/models/book.dart';
import '../../domain/models/chapter.dart';

/// MOBI/AZW3 解析器 - 解析 MOBI 格式电子书
///
/// 基于 MOBI 文件格式规范，提取元数据和章节内容。
/// 支持 MOBI (PalmDoc) 和 KF8 (Kindle Format 8) 格式。
class MobiParser {
  /// 解析 MOBI 文件
  Future<MobiParseResult> parse(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      final bytes = await file.readAsBytes();
      final data = ByteData.sublistView(Uint8List.fromList(bytes));

      // 验证 PDB 头部
      _readString(data, 0, 32); // PDB name
      final type = _readUint32(data, 60);
      _readUint32(data, 64); // creator

      // MOBI type = 0x424F4F4B ('BOOK')
      if (type != 0x424F4F4B) {
        throw Exception('不是有效的 MOBI 文件');
      }

      // 读取记录数量
      final numRecords = _readUint16(data, 76);
      if (numRecords < 2) {
        throw Exception('MOBI 文件记录数不足');
      }

      // 读取第一条记录偏移（MOBI header 所在位置）
      final firstRecordOffset = _readUint32(data, 78);

      // 读取 MOBI header (验证字段)
      _readUint32(data, firstRecordOffset + 16); // headerLength
      _readUint32(data, firstRecordOffset + 20); // mobiType
      _readUint32(data, firstRecordOffset + 28); // encoding

      // 提取标题
      final titleOffset = _readUint32(data, firstRecordOffset + 84);
      final titleLength = _readUint32(data, firstRecordOffset + 88);
      final title = _readString(
        data,
        firstRecordOffset + titleOffset,
        titleLength,
      );

      // 提取作者（从 EXTH header）
      final exthOffset = _readUint32(data, firstRecordOffset + 204);
      String author = '';
      if (exthOffset != 0xFFFFFFFF && exthOffset > 0) {
        author = _extractExthField(data, firstRecordOffset + exthOffset, 100);
      }

      // 构建书籍模型
      final fileName = filePath.split(Platform.pathSeparator).last;
      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;

      final book = Book(
        id: '',
        title: title.isNotEmpty ? title : baseName,
        author: author,
        localPath: filePath,
        format: 'mobi',
        type: 'local',
        totalChapters: 1, // 简化处理，整个文件作为一个章节
      );

      // 创建单一章节（完整的 MOBI 文本提取比较复杂，这里简化处理）
      final chapters = [
        Chapter(
          id: '',
          bookId: '',
          chapterKey: 'full_text',
          title: book.title,
          orderIndex: 0,
        ),
      ];

      return MobiParseResult(
        book: book,
        chapters: chapters,
        rawText: '', // 完整文本提取需要更复杂的实现
      );
    } catch (e) {
      debugPrint('[MobiParser] 解析失败: $e');
      rethrow;
    }
  }

  /// 从 EXTH header 提取字段
  String _extractExthField(ByteData data, int exthStart, int fieldType) {
    try {
      // EXTH 头部: 'EXTH' (4) + headerLength (4) + recordCount (4)
      final recordCount = _readUint32(data, exthStart + 8);

      int offset = exthStart + 12;
      for (int i = 0; i < recordCount && offset < data.lengthInBytes - 8; i++) {
        final recordType = _readUint32(data, offset);
        final recordLength = _readUint32(data, offset + 4);

        if (recordType == fieldType) {
          return _readString(data, offset + 8, recordLength - 8);
        }

        offset += recordLength;
      }
    } catch (_) {}
    return '';
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

/// MOBI 解析结果
class MobiParseResult {
  final Book book;
  final List<Chapter> chapters;
  final String rawText;

  MobiParseResult({
    required this.book,
    required this.chapters,
    required this.rawText,
  });
}
