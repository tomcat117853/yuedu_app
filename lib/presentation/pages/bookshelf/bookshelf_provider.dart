import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/book.dart';
import '../../../domain/models/chapter.dart';
import '../../../domain/models/read_progress.dart';
import '../../../data/repositories/book_repository.dart';
import '../../../data/parsers/epub_parser.dart';
import '../../../data/parsers/txt_parser.dart';
import '../../../providers.dart';

/// 书架视图模式
enum BookshelfViewMode { grid, list }

/// 书架排序方式
enum BookshelfSortOrder {
  custom,       // 自定义排序
  titleAsc,     // 标题升序
  titleDesc,    // 标题降序
  authorAsc,   // 作者升序
  authorDesc,  // 作者降序
  createdAtAsc, // 添加时间升序（先添加的在前）
  createdAtDesc, // 添加时间降序（最新添加的在前）
  updatedAtAsc, // 阅读时间升序
  updatedAtDesc, // 阅读时间降序
  progressAsc,  // 阅读进度升序（进度少的在前）
  progressDesc, // 阅读进度降序（进度多的在前）
}

/// 书架状态
class BookshelfState {
  final List<Book> books;
  final List<String> groups;
  final bool isLoading;
  final String? error;
  final String currentGroup;
  final String searchQuery;
  final Map<String, ReadProgress> progressMap;
  final BookshelfViewMode viewMode;
  final BookshelfSortOrder sortOrder;
  final bool showArchived; // 是否显示归档书籍

  const BookshelfState({
    this.books = const [],
    this.groups = const [],
    this.isLoading = false,
    this.error,
    this.currentGroup = 'all',
    this.searchQuery = '',
    this.progressMap = const {},
    this.viewMode = BookshelfViewMode.grid,
    this.sortOrder = BookshelfSortOrder.custom,
    this.showArchived = false,
  });

  BookshelfState copyWith({
    List<Book>? books,
    List<String>? groups,
    bool? isLoading,
    String? error,
    String? currentGroup,
    String? searchQuery,
    Map<String, ReadProgress>? progressMap,
    BookshelfViewMode? viewMode,
    BookshelfSortOrder? sortOrder,
    bool? showArchived,
  }) {
    return BookshelfState(
      books: books ?? this.books,
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentGroup: currentGroup ?? this.currentGroup,
      searchQuery: searchQuery ?? this.searchQuery,
      progressMap: progressMap ?? this.progressMap,
      viewMode: viewMode ?? this.viewMode,
      sortOrder: sortOrder ?? this.sortOrder,
      showArchived: showArchived ?? this.showArchived,
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

  /// 切换视图模式
  void toggleViewMode() {
    final newMode = state.viewMode == BookshelfViewMode.grid
        ? BookshelfViewMode.list
        : BookshelfViewMode.grid;
    state = state.copyWith(viewMode: newMode);
  }

  /// 设置视图模式
  void setViewMode(BookshelfViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// 切换排序方式
  void toggleSortOrder() {
    final orders = BookshelfSortOrder.values;
    final currentIndex = orders.indexOf(state.sortOrder);
    final nextIndex = (currentIndex + 1) % orders.length;
    state = state.copyWith(sortOrder: orders[nextIndex]);
    _sortBooks();
  }

  /// 设置排序方式
  void setSortOrder(BookshelfSortOrder order) {
    state = state.copyWith(sortOrder: order);
    _sortBooks();
  }

  /// 对书籍列表进行排序
  void _sortBooks() {
    final sortedBooks = List<Book>.from(state.books);
    switch (state.sortOrder) {
      case BookshelfSortOrder.custom:
        // 自定义排序：按 sortOrder 字段
        sortedBooks.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        break;
      case BookshelfSortOrder.titleAsc:
        sortedBooks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case BookshelfSortOrder.titleDesc:
        sortedBooks.sort((a, b) => b.title.compareTo(a.title));
        break;
      case BookshelfSortOrder.authorAsc:
        sortedBooks.sort((a, b) => (a.author ?? '').compareTo(b.author ?? ''));
        break;
      case BookshelfSortOrder.authorDesc:
        sortedBooks.sort((a, b) => (b.author ?? '').compareTo(a.author ?? ''));
        break;
      case BookshelfSortOrder.createdAtAsc:
        sortedBooks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case BookshelfSortOrder.createdAtDesc:
        sortedBooks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case BookshelfSortOrder.updatedAtAsc:
        sortedBooks.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case BookshelfSortOrder.updatedAtDesc:
        sortedBooks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case BookshelfSortOrder.progressAsc:
        sortedBooks.sort((a, b) {
          final progressA = state.progressMap[a.id]?.progressPercent ?? 0;
          final progressB = state.progressMap[b.id]?.progressPercent ?? 0;
          return progressA.compareTo(progressB);
        });
        break;
      case BookshelfSortOrder.progressDesc:
        sortedBooks.sort((a, b) {
          final progressA = state.progressMap[a.id]?.progressPercent ?? 0;
          final progressB = state.progressMap[b.id]?.progressPercent ?? 0;
          return progressB.compareTo(progressA);
        });
        break;
    }
    state = state.copyWith(books: sortedBooks);
  }

  /// 创建分组
  Future<bool> createGroup(String name) async {
    if (name.trim().isEmpty) return false;
    try {
      // 检查是否已存在
      if (state.groups.contains(name)) return false;
      await _bookRepository.createGroup(name);
      await _loadGroups();
      return true;
    } catch (e) {
      debugPrint('创建分组失败: $e');
      return false;
    }
  }

  /// 删除分组
  Future<bool> deleteGroup(String groupId) async {
    if (groupId == 'default' || groupId == 'all') return false;
    try {
      await _bookRepository.deleteGroup(groupId);
      // 如果当前在删除的分组，则切换到全部
      if (state.currentGroup == groupId) {
        state = state.copyWith(currentGroup: 'all');
      }
      await _loadGroups();
      await _loadBooks();
      return true;
    } catch (e) {
      debugPrint('删除分组失败: $e');
      return false;
    }
  }

  /// 重命名分组
  Future<bool> renameGroup(String oldName, String newName) async {
    if (newName.trim().isEmpty) return false;
    try {
      await _bookRepository.renameGroup(oldName, newName);
      await _loadGroups();
      return true;
    } catch (e) {
      debugPrint('重命名分组失败: $e');
      return false;
    }
  }

  /// 移动书籍到指定分组
  Future<void> moveBookToGroup(String bookId, String groupId) async {
    try {
      await _bookRepository.updateBookGroup(bookId, groupId);
      await _loadBooks();
    } catch (e) {
      debugPrint('移动书籍到分组失败: $e');
    }
  }

  /// 更新书籍排序顺序
  Future<void> updateBookSortOrder(String bookId, int newOrder) async {
    try {
      await _bookRepository.updateBookSortOrder(bookId, newOrder);
      await _loadBooks();
    } catch (e) {
      debugPrint('更新书籍排序失败: $e');
    }
  }

  /// 切换归档状态
  Future<void> toggleArchive(String bookId) async {
    try {
      final book = state.books.where((b) => b.id == bookId).firstOrNull;
      if (book == null) return;
      final newStatus = book.status == 2 ? 0 : 2; // 2=archived, 0=reading
      await _bookRepository.updateBookStatus(bookId, newStatus);
      await _loadBooks();
    } catch (e) {
      debugPrint('切换归档状态失败: $e');
    }
  }

  /// 加载分组列表
  Future<void> _loadGroups() async {
    try {
      final groups = await _bookRepository.getAllGroups();
      state = state.copyWith(groups: groups);
    } catch (e) {
      debugPrint('加载分组列表失败: $e');
    }
  }

  /// 刷新
  Future<void> refresh() async {
    await _loadBooks();
    await _loadGroups();
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
