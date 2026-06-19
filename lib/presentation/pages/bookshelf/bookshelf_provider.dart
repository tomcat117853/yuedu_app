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