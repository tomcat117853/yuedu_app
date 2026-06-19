import 'dart:io';
import 'package:path/path.dart' as p;

import '../models/book.dart';
import '../models/chapter.dart';
import '../models/chapter_content.dart';
import '../models/read_progress.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/parsers/txt_parser.dart';

/// 书籍服务 - 处理书籍相关的业务逻辑
class BookService {
  final BookRepository _bookRepository;

  BookService(this._bookRepository);

  /// 获取书架上的所有书籍
  Future<List<Book>> getBookshelfBooks({String? groupId}) async {
    return _bookRepository.getBooksByGroup(groupId: groupId);
  }

  /// 获取最近阅读的书籍
  Future<List<Book>> getRecentBooks({int limit = 10}) async {
    final books = await _bookRepository.getAllBooks();
    books.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return books.take(limit).toList();
  }

  /// 添加本地书籍
  Future<Book> addLocalBook({
    required String title,
    required String author,
    required String localPath,
    required String format,
    String? coverPath,
    String? intro,
    String? category,
  }) async {
    final book = Book(
      id: _bookRepository.generateId(),
      title: title,
      author: author,
      localPath: localPath,
      format: format,
      type: 'local',
      coverPath: coverPath,
      intro: intro,
      category: category,
    );
    await _bookRepository.insertBook(book);
    return book;
  }

  /// 导入书籍（根据文件类型解析并添加到书架）
  Future<Book> importBook(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('文件不存在: $filePath');
    }

    final extension = p.extension(filePath).toLowerCase().replaceFirst('.', '');
    final fileName = p.basenameWithoutExtension(filePath);

    // 生成书籍ID（提前生成，确保书籍和章节ID一致）
    final bookId = _bookRepository.generateId();

    // 解析文件获取书籍信息
    List<Chapter> chapters = [];
    String? intro;
    int wordCount = 0;

    if (extension == 'txt') {
      final parser = TxtParser();
      chapters = await parser.parseFile(filePath, bookId);
      wordCount = chapters.fold(0, (sum, ch) => sum + (ch.wordCount ?? 0));
    } else if (extension == 'epub') {
      // EPUB解析暂时使用简化逻辑
      chapters = [
        Chapter(
          id: '${bookId}_ch_0',
          bookId: bookId,
          title: '目录',
          orderIndex: 0,
        ),
      ];
    } else if (extension == 'pdf') {
      chapters = [
        Chapter(
          id: '${bookId}_ch_0',
          bookId: bookId,
          title: '首页',
          orderIndex: 0,
        ),
      ];
    } else {
      throw Exception('不支持的文件格式: $extension');
    }

    // 解析书名和作者（假设格式为 "书名 - 作者" 或直接是 "书名"）
    String title = fileName;
    String author = '未知作者';

    if (fileName.contains(' - ')) {
      final parts = fileName.split(' - ');
      if (parts.length >= 2) {
        title = parts[0].trim();
        author = parts.sublist(1).join(', ').trim();
      }
    }

    // 创建书籍记录
    final book = Book(
      id: bookId,
      title: title,
      author: author,
      localPath: filePath,
      format: extension,
      type: 'local',
      intro: intro,
      totalChapters: chapters.length,
      wordCount: wordCount,
    );

    // 更新章节的bookId
    final updatedChapters = chapters.map((ch) => Chapter(
      id: '${bookId}_ch_${ch.orderIndex}',
      bookId: bookId,
      title: ch.title,
      orderIndex: ch.orderIndex,
      chapterKey: ch.chapterKey,
      contentPath: ch.contentPath,
      isCached: ch.isCached,
      isVip: ch.isVip,
      wordCount: ch.wordCount,
      fetchedAt: ch.fetchedAt,
    )).toList();

    // 保存书籍和章节
    await _bookRepository.insertBook(book);
    if (updatedChapters.isNotEmpty) {
      await _bookRepository.insertChapters(updatedChapters);
    }

    return book;
  }

  /// 删除书籍及其所有数据
  Future<void> deleteBook(String bookId) async {
    await _bookRepository.deleteBook(bookId);
  }

  /// 更新书籍信息
  Future<void> updateBook(Book book) async {
    await _bookRepository.updateBook(book);
  }

  /// 获取书籍详情
  Future<Book?> getBookById(String bookId) async {
    return _bookRepository.getBookById(bookId);
  }

  /// 获取书籍的章节列表
  Future<List<Chapter>> getBookChapters(String bookId) async {
    return _bookRepository.getChaptersByBookId(bookId);
  }

  /// 获取章节内容
  Future<ChapterContent> getChapterContent(String bookId, int chapterIndex) async {
    return _bookRepository.getChapterContent(bookId, chapterIndex);
  }

  /// 保存阅读进度
  Future<void> saveReadProgress(ReadProgress progress) async {
    await _bookRepository.saveReadProgress(progress);
  }

  /// 获取阅读进度
  Future<ReadProgress?> getReadProgress(String bookId) async {
    return _bookRepository.getReadProgress(bookId);
  }

  /// 搜索书籍
  Future<List<Book>> searchBooks(String query) async {
    final books = await _bookRepository.getAllBooks();
    final lowerQuery = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(lowerQuery) || book.author.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 按分组获取书籍数量
  Future<Map<String, int>> getBookCountByGroup() async {
    final books = await _bookRepository.getAllBooks();
    final Map<String, int> counts = {};
    for (final book in books) {
      counts[book.groupId] = (counts[book.groupId] ?? 0) + 1;
    }
    return counts;
  }

  /// 移动书籍到指定分组
  Future<void> moveBookToGroup(String bookId, String groupId) async {
    final book = await _bookRepository.getBookById(bookId);
    if (book != null) {
      await _bookRepository.updateBook(book.copyWith(groupId: groupId));
    }
  }

  /// 更新书籍阅读状态
  Future<void> updateBookStatus(String bookId, int status) async {
    final book = await _bookRepository.getBookById(bookId);
    if (book != null) {
      await _bookRepository.updateBook(book.copyWith(status: status, updatedAt: DateTime.now()));
    }
  }
}