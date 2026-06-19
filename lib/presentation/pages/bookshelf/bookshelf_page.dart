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
      body: Column(
        children: [
          // 分组标签栏
          _buildGroupTabs(context, ref, groups, state.currentGroup),
          // 书籍列表
          Expanded(
            child: _buildBookList(context, ref, state),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建分组标签栏
  Widget _buildGroupTabs(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, String>> groups,
    String currentGroup,
  ) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final isSelected = group['id'] == currentGroup;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(group['name']!),
              selected: isSelected,
              onSelected: (_) {
                ref.read(bookshelfProvider.notifier).switchGroup(group['id']!);
              },
              selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建书籍列表
  Widget _buildBookList(BuildContext context, WidgetRef ref, BookshelfState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(bookshelfProvider.notifier).refresh(),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (state.books.isEmpty) {
      final theme = Theme.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 80,
              color: theme.hintColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '书架空空如也',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右上角添加书籍',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // 过滤搜索结果
    final filteredBooks = state.searchQuery.isEmpty
        ? state.books
        : state.books
            .where((book) =>
                book.title.contains(state.searchQuery) ||
                book.author.contains(state.searchQuery))
            .toList();

    if (filteredBooks.isEmpty) {
      return Center(
        child: Text(
          '没有找到匹配的书籍',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bookshelfProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredBooks.length,
        itemBuilder: (context, index) {
          final book = filteredBooks[index];
          final progress = state.progressMap[book.id];
          return BookCard(
            book: book,
            progress: progress,
            onTap: () {
              context.push('/reader/${book.id}');
            },
            onLongPress: () => _showBookOptions(context, ref, book),
          );
        },
      ),
    );
  }

  /// 显示搜索
  void _showSearch(BuildContext context, WidgetRef ref) {
    showSearch(
      context: context,
      delegate: _BookSearchDelegate(ref),
    );
  }

  /// 显示添加书籍对话框
  void _showAddBookDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '添加书籍',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.folder_open),
                title: const Text('从本地导入'),
                subtitle: const Text('支持 TXT、EPUB 格式'),
                onTap: () async {
                  Navigator.pop(context);
                  await _importLocalFile(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('搜索在线书籍'),
                subtitle: const Text('从书源搜索添加'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.discover);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 导入本地文件
  Future<void> _importLocalFile(BuildContext context, WidgetRef ref) async {
    try {
      // 打开文件选择器，限制为 TXT 和 EPUB 格式
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'epub'],
      );

      if (result == null || result.files.isEmpty) {
        // 用户取消了选择
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) return;

      // 显示加载指示器对话框
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PopScope(
          canPop: false,
          child: Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在解析书籍...'),
                  ],
                ),
    );
  }
}