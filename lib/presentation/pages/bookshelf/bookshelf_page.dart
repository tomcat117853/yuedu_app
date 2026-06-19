import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../../domain/models/book.dart';
import 'bookshelf_provider.dart';
import '../../widgets/book_card.dart';

/// 书架页面
class BookshelfPage extends ConsumerWidget {
  const BookshelfPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookshelfProvider);
    final groups = ref.watch(bookshelfGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('书架'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBookDialog(context, ref),
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
              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 80,
              color: AppTheme.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '书架空空如也',
              style: TextStyle(
                color: AppTheme.textHint,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右上角添加书籍',
              style: TextStyle(
                color: AppTheme.textHint,
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
          style: TextStyle(color: AppTheme.textHint),
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
              ),
            ),
          ),
        ),
      );

      // 调用导入方法
      final book =
          await ref.read(bookshelfProvider.notifier).importLocalBook(filePath);

      // 关闭加载对话框
      if (!context.mounted) return;
      Navigator.pop(context);

      // 显示结果提示
      if (!context.mounted) return;
      if (book != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('《${book.title}》导入成功'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error = ref.read(bookshelfProvider).error ?? '未知错误';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // 确保关闭可能存在的加载对话框
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 显示书籍操作菜单
  void _showBookOptions(BuildContext context, WidgetRef ref, Book book) {
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
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('书籍详情'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('编辑信息'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.swap_vert),
                title: const Text('更换书源'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('删除书籍', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(bookshelfProvider.notifier).deleteBook(book.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 书籍搜索代理
class _BookSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  _BookSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          ref.read(bookshelfProvider.notifier).search('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    ref.read(bookshelfProvider.notifier).search(query);
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const SizedBox.shrink();
  }
}
