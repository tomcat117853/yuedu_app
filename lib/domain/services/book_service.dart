import '../models/book.dart';
import '../models/chapter.dart';
import '../models/chapter_content.dart';
import '../models/read_progress.dart';
import '../../data/repositories/book_repository.dart';

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
      return book.title.toLowerCase().contains(lowerQuery) ||
          book.author.toLowerCase().contains(lowerQuery);
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
      await _bookRepository.updateBook(
        book.copyWith(status: status, updatedAt: DateTime.now()),
      );
    }
  }
}
