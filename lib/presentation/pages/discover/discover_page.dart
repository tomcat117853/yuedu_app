import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../bookshelf/bookshelf_page.dart';
import 'discover_provider.dart';
import 'widgets/search_bar.dart';
import 'widgets/search_result_item.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoverProvider.notifier).loadHotBooks();
    });
  }

  void _onSearch(String keyword) {
    if (keyword.isNotEmpty) {
      ref.read(discoverProvider.notifier).searchBooks(keyword);
    }
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
    final state = ref.watch(discoverProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
      ),
      body: Column(
        children: [
          SearchBar(
            controller: _searchController,
            onSearch: _onSearch,
          ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: state.searchResults.length,
                    itemBuilder: (context, index) {
                      final result = state.searchResults[index];
                      return SearchResultItem(
                        result: result,
                        onTap: () => _onBookTap(result.bookId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}