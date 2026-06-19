import 'dart:io';
import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:image/image.dart' as img;
import '../../domain/models/chapter.dart';
import '../../domain/models/book.dart';

/// EPUB文件解析器
///
/// 使用 epubx 库解析 EPUB 格式电子书
class EpubParser {
  /// 解析EPUB文件，提取书籍信息和章节列表
  Future<EpubParseResult> parseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('EPUB文件不存在: $filePath');
    }

    final bytes = await file.readAsBytes();
    return _parseBytes(bytes, filePath);
  }

  /// 从字节数据解析EPUB
  Future<EpubParseResult> _parseBytes(Uint8List bytes, String filePath) async {
    // 解析EPUB文件
    final epubBook = await EpubReader.readBook(bytes);

    // 提取书籍信息
    final title = epubBook.Title ?? '未知书名';
    final author = epubBook.Author ?? '未知作者';
    const description = ''; // epubx EpubBook 不提供 Description 属性

    // 提取封面图片
    String? coverPath;
    if (epubBook.CoverImage != null) {
      coverPath = filePath.replaceAll('.epub', '_cover.jpg');
      final coverFile = File(coverPath);
      await coverFile.writeAsBytes(img.encodeJpg(epubBook.CoverImage!));
    }

    // 提取章节列表
    final chapters = <Chapter>[];
    final bookId = filePath.hashCode.toRadixString(36);

    if (epubBook.Chapters != null) {
      const int orderIndex = 0;
      _extractChaptersFromNav(epubBook.Chapters!, bookId, chapters, orderIndex);
    }

    // 计算总字数
    int totalWordCount = 0;
    for (final chapter in chapters) {
      totalWordCount += chapter.wordCount;
    }

    // 构建书籍模型
    final book = Book(
      id: bookId,
      title: title,
      author: author,
      coverPath: coverPath,
      intro: description,
      format: 'epub',
      type: 'local',
      localPath: filePath,
      totalChapters: chapters.length,
      wordCount: totalWordCount,
    );

    return EpubParseResult(
      book: book,
      chapters: chapters,
      epubBook: epubBook,
    );
  }

  /// 递归提取章节
  void _extractChaptersFromNav(
    List<EpubChapter> epubChapters,
    String bookId,
    List<Chapter> chapters,
    int startIndex,
  ) {
    int orderIndex = startIndex;
    for (final epubChapter in epubChapters) {
      final title = epubChapter.Title?.trim() ?? '';
      final chapterId = '${bookId}_ch_$orderIndex';

      // 获取章节内容
      String content = '';
      int wordCount = 0;

      if (epubChapter.HtmlContent != null) {
        content = epubChapter.HtmlContent!;
        // 移除HTML标签计算纯文本字数
        wordCount = content
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll(RegExp(r'\s+'), '')
            .length;
      }

      chapters.add(Chapter(
        id: chapterId,
        bookId: bookId,
        chapterKey: epubChapter.ContentFileName ?? '$orderIndex',
        title: title.isEmpty ? '第${orderIndex + 1}章' : title,
        orderIndex: orderIndex,
        wordCount: wordCount,
        isCached: true, // EPUB内容已包含在文件中
      ));
      orderIndex++;

      // 递归处理子章节
      if (epubChapter.SubChapters != null &&
          epubChapter.SubChapters!.isNotEmpty) {
        _extractChaptersFromNav(
          epubChapter.SubChapters!,
          bookId,
          chapters,
          orderIndex,
        );
        orderIndex += epubChapter.SubChapters!.length;
      }
    }
  }

  /// 获取指定章节的内容
  Future<String> getChapterContent(
    EpubBook epubBook,
    int chapterIndex,
  ) async {
    if (epubBook.Chapters == null) return '';

    final flatChapters = <EpubChapter>[];
    _flattenChapters(epubBook.Chapters!, flatChapters);

    if (chapterIndex < 0 || chapterIndex >= flatChapters.length) return '';

    final chapter = flatChapters[chapterIndex];
    return chapter.HtmlContent ?? '';
  }

  /// 获取指定章节的纯文本内容
  Future<String> getChapterPlainText(
    EpubBook epubBook,
    int chapterIndex,
  ) async {
    final html = await getChapterContent(epubBook, chapterIndex);
    return _htmlToPlainText(html);
  }

  /// 将HTML转换为纯文本
  String _htmlToPlainText(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<p[^>]*>'), '\n')
        .replaceAll(RegExp(r'</p>'), '')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&nbsp;'), ' ')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// 递归展平章节列表
  void _flattenChapters(
    List<EpubChapter> chapters,
    List<EpubChapter> result,
  ) {
    for (final chapter in chapters) {
      result.add(chapter);
      if (chapter.SubChapters != null) {
        _flattenChapters(chapter.SubChapters!, result);
      }
    }
  }

  /// 获取书籍总字数
  Future<int> getWordCount(String filePath) async {
    final result = await parseFile(filePath);
    return result.book.wordCount;
  }
}

/// EPUB解析结果
class EpubParseResult {
  final Book book;
  final List<Chapter> chapters;
  final EpubBook epubBook;

  EpubParseResult({
    required this.book,
    required this.chapters,
    required this.epubBook,
  });
}
