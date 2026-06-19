import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../reader/reader_page.dart';
import 'bookshelf_provider.dart';
import 'widgets/book_card.dart';
import 'widgets/group_list.dart';

class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends ConsumerState<BookshelfPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookshelfProvider.notifier).loadBooks();
    });
  }

  void _onBookTap(String bookId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderPage(bookId: bookId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookshelfProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的书架'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ref.read(bookshelfProvider.notifier).importBook(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.books.isEmpty
              ? const Center(
                  child: Text('书架为空，请添加书籍'),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: state.books.length,
                  itemBuilder: (context, index) {
                    final book = state.books[index];
                    return BookCard(
                      book: book,
                      onTap: () => _onBookTap(book.id),
                    );
                  },
                ),
    );
  }
}