import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../domain/models/book.dart';
import '../../../domain/services/book_service.dart';
import '../../../domain/services/source_service.dart';

final bookshelfProvider = NotifierProvider<BookshelfProvider, BookshelfState>(
  () => throw UnimplementedError(),
);

class BookshelfProvider extends Notifier<BookshelfState> {
  late final BookService _bookService;

  @override
  BookshelfState build() {
    _bookService = ref.read(bookServiceProvider);
    return BookshelfState(
      books: [],
      groups: [],
      isLoading: false,
    );
  }

  Future<void> loadBooks() async {
    state = state.copyWith(isLoading: true);
    try {
      final books = await _bookService.getAllBooks();
      state = state.copyWith(
        books: books,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> importBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'epub', 'pdf'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final filePath = result.files.first.path;
    if (filePath == null) {
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      await _bookService.importBook(filePath);
      await loadBooks();
    } catch (e) {
      // Handle error
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> deleteBook(String bookId) async {
    await _bookService.deleteBook(bookId);
    await loadBooks();
  }
}

class BookshelfState {
  final List<Book> books;
  final List<String> groups;
  final bool isLoading;

  BookshelfState({
    required this.books,
    required this.groups,
    required this.isLoading,
  });

  BookshelfState copyWith({
    List<Book>? books,
    List<String>? groups,
    bool? isLoading,
  }) {
    return BookshelfState(
      books: books ?? this.books,
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 书架状态通知器
class BookshelfNotifier extends StateNotifier<BookshelfState> {
  final Ref _ref;

  BookshelfNotifier(this._ref) : super(const BookshelfState()) {
    _loadBooks();
  }

  /// 获取书籍仓库实例
  BookRepository get _bookRepository => _ref.read(bookRepositoryProvider);

  /// 加载书籍列表
  Future<void> _loadBooks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _bookRepository;

      // 根据分组加载书籍
      List<Book> books;
      if (state.currentGroup == 'all') {
        books = await repo.getAllBooks();
      } else {
        books = await repo.getBooksByGroup(groupId: state.currentGroup);
      }

      // 加载所有阅读进度，构建 progressMap
      final allProgress = await repo.getAllProgress();
      final progressMap = <String, ReadProgress>{};
      for (final progress in allProgress) {
        progressMap[progress.bookId] = progress;
      }

      state = state.copyWith(
        isLoading: false,
        books: books,
        progressMap: progressMap,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 切换分组
  void switchGroup(String groupId) {
    state = state.copyWith(currentGroup: groupId);
    _loadBooks();
  }

  /// 搜索书籍
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.isEmpty) {
      // 搜索词为空时重新加载全部书籍
      await _loadBooks();
      return;
    }
    try {
      final books = await _bookRepository.searchBooks(query);
      state = state.copyWith(books: books);
    } catch (e) {
      debugPrint('搜索书籍失败: $e');
    }
  }

  /// 删除书籍
  Future<void> deleteBook(String bookId) async {
    try {
      await _bookRepository.deleteBook(bookId);
      // 删除文件服务中的相关文件
      final book = state.books.where((b) => b.id == bookId).firstOrNull;
      if (book != null) {
        try {
          final fileService = _ref.read(fileServiceProvider);
          await fileService.deleteBookFiles(bookId, book.localPath);
        } catch (_) {
          // 文件删除失败不影响主流程
        }
      }
      // 重新加载列表
      await _loadBooks();
    } catch (e) {
      debugPrint('删除书籍失败: $e');
    }
  }

  /// 导入本地书籍
  ///
  /// [filePath] 本地文件路径，支持 .txt 和 .epub 格式
  Future<Book?> importLocalBook(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _bookRepository;
      final fileService = _ref.read(fileServiceProvider);
      final pathService = _ref.read(pathServiceProvider);

      // 检测文件格式
      final extension = pathService.getExtension(filePath).toLowerCase();
      final baseName = pathService.getBaseName(filePath);

      Book book;
      List<Chapter> chapters;

      if (extension == 'epub') {
        // ===== EPUB 格式导入 =====
        final parser = EpubParser();
        final result = await parser.parseFile(filePath);

        // 复制文件到书籍目录
        final localPath = await fileService.copyFileToBooks(filePath, 'epub');

        // 使用解析结果中的书籍信息，更新本地路径
        book = result.book.copyWith(localPath: localPath);
        chapters = result.chapters.map((ch) {
          return ch.copyWith(bookId: book.id);
        }).toList();
      } else {
        // ===== TXT 格式导入（默认） =====
        final parser = TxtParser();
        final bookId = repo.generateId();

        // 解析章节
        chapters = await parser.parseFile(filePath, bookId);

        // 获取总字数
        final wordCount = await parser.getWordCount(filePath);

        // 复制文件到书籍目录
        final localPath = await fileService.copyFileToBooks(filePath, 'txt');

        // 构建书籍模型
        book = Book(
          id: bookId,
          title: baseName,
          author: '',
          format: 'txt',
          type: 'local',
          localPath: localPath,
          totalChapters: chapters.length,
          wordCount: wordCount,
        );
      }

      // 插入书籍到数据库
      await repo.insertBook(book);

      // 批量插入章节到数据库
      await repo.insertChapters(chapters);

      // 重新加载书籍列表
      await _loadBooks();

      return book;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '导入失败: $e',
      );
      debugPrint('导入本地书籍失败: $e');
      return null;
    }
  }

  /// 刷新
  Future<void> refresh() async {
    await _loadBooks();
  }
}

/// 书架Provider
final bookshelfProvider =
    StateNotifierProvider<BookshelfNotifier, BookshelfState>((ref) {
  return BookshelfNotifier(ref);
});

/// 书架分组Provider
final bookshelfGroupsProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'id': 'all', 'name': '全部'},
    {'id': 'default', 'name': '默认分组'},
    {'id': 'favorites', 'name': '收藏'},
  ];
});
