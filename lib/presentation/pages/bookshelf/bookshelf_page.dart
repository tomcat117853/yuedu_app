import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../../config/routes.dart';
import '../../../domain/models/book.dart';
import '../reader/reader_page.dart';
import 'bookshelf_provider.dart';
import 'widgets/book_card.dart';
import 'widgets/book_list_tile.dart';
import 'widgets/group_management_sheet.dart';

class BookshelfPage extends ConsumerStatefulWidget {
  const BookshelfPage({super.key});

  @override
  ConsumerState<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends ConsumerState<BookshelfPage> {
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookshelfProvider.notifier).refresh();
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
          // 视图切换按钮
          IconButton(
            icon: Icon(
              state.viewMode == BookshelfViewMode.grid
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
            onPressed: () => ref.read(bookshelfProvider.notifier).toggleViewMode(),
            tooltip: state.viewMode == BookshelfViewMode.grid ? '列表视图' : '网格视图',
          ),
          // 排序按钮
          PopupMenuButton<BookshelfSortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: '排序',
            onSelected: (order) => ref.read(bookshelfProvider.notifier).setSortOrder(order),
            itemBuilder: (context) => [
              _buildSortMenuItem(BookshelfSortOrder.custom, '自定义排序', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.titleAsc, '标题 ↑', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.titleDesc, '标题 ↓', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.authorAsc, '作者 ↑', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.authorDesc, '作者 ↓', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.createdAtDesc, '最近添加', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.createdAtAsc, '最早添加', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.updatedAtDesc, '最近阅读', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.progressDesc, '阅读进度 ↓', state.sortOrder),
              _buildSortMenuItem(BookshelfSortOrder.progressAsc, '阅读进度 ↑', state.sortOrder),
            ],
          ),
          // 分组管理按钮
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: () => _showGroupManagementDialog(context),
            tooltip: '分组管理',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBookDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 分组选择器
          if (state.groups.isNotEmpty) _buildGroupSelector(state),
          // 书籍列表
          Expanded(
            child: DropTarget(
              onDragDone: (detail) => _handleFileDrop(detail),
              onDragEntered: (detail) => setState(() => _isDragging = true),
              onDragExited: (detail) => setState(() => _isDragging = false),
              child: Stack(
                children: [
                  _buildBookList(context, state),
                  if (_isDragging) _buildDropOverlay(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建排序菜单项
  PopupMenuItem<BookshelfSortOrder> _buildSortMenuItem(
    BookshelfSortOrder order,
    String label,
    BookshelfSortOrder currentOrder,
  ) {
    return PopupMenuItem(
      value: order,
      child: Row(
        children: [
          if (currentOrder == order)
            const Icon(Icons.check, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  /// 构建分组选择器
  Widget _buildGroupSelector(BookshelfState state) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 全部
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('全部'),
              selected: state.currentGroup == 'all',
              onSelected: (_) => ref.read(bookshelfProvider.notifier).switchGroup('all'),
            ),
          ),
          // 用户分组
          ...state.groups.map((group) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(group),
                selected: state.currentGroup == group,
                onSelected: (_) => ref.read(bookshelfProvider.notifier).switchGroup(group),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 显示分组管理对话框
  void _showGroupManagementDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => GroupManagementSheet(
        groups: ref.read(bookshelfProvider).groups,
        onCreateGroup: (name) => ref.read(bookshelfProvider.notifier).createGroup(name),
        onDeleteGroup: (name) => ref.read(bookshelfProvider.notifier).deleteGroup(name),
        onRenameGroup: (oldName, newName) => ref.read(bookshelfProvider.notifier).renameGroup(oldName, newName),
      ),
    );
  }
  
  /// 构建拖拽提示覆盖层
  Widget _buildDropOverlay() {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.file_download,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                '释放文件以导入书籍',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '支持 TXT、EPUB 格式',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 处理文件拖拽
  Future<void> _handleFileDrop(DropDoneDetails detail) async {
    setState(() => _isDragging = false);
    
    final validExtensions = ['.txt', '.epub'];
    int importCount = 0;
    
    for (final file in detail.files) {
      final path = file.path;
      final extension = path.toLowerCase();
      
      // 检查文件扩展名
      if (!validExtensions.any((ext) => extension.endsWith(ext))) {
        continue;
      }
      
      try {
        await ref.read(bookshelfProvider.notifier).importLocalBook(path);
        importCount++;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('导入失败: $e')),
          );
        }
      }
    }
    
    if (importCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功导入 $importCount 本书籍')),
      );
    } else if (detail.files.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未找到支持的文件格式')),
      );
    }
  }

  /// 构建书籍列表
  Widget _buildBookList(BuildContext context, BookshelfState state) {
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
              onPressed: () => ref.read(bookshelfProvider.notifier).refresh(),
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
              color: theme.hintColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '书架空空如也',
              style: TextStyle(color: theme.hintColor, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '点击 + 或拖拽文件添加书籍',
              style: TextStyle(color: theme.hintColor, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '支持 TXT、EPUB 格式',
              style: TextStyle(color: theme.hintColor.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(bookshelfProvider.notifier).refresh(),
      child: state.viewMode == BookshelfViewMode.grid
          ? _buildGridView(context, state)
          : _buildListView(context, state),
    );
  }

  /// 构建网格视图
  Widget _buildGridView(BuildContext context, BookshelfState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: state.books.length,
      itemBuilder: (context, index) {
        final book = state.books[index];
        final progress = state.progressMap[book.id];
        return BookCard(
          book: book,
          progress: progress,
          onTap: () => _onBookTap(book.id),
          onLongPress: () => _showBookOptionsMenu(context, book),
        );
      },
    );
  }

  /// 构建列表视图
  Widget _buildListView(BuildContext context, BookshelfState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.books.length,
      itemBuilder: (context, index) {
        final book = state.books[index];
        final progress = state.progressMap[book.id];
        return BookListTile(
          book: book,
          progress: progress,
          onTap: () => _onBookTap(book.id),
          onLongPress: () => _showBookOptionsMenu(context, book),
        );
      },
    );
  }

  /// 显示书籍操作菜单
  void _showBookOptionsMenu(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('移动到分组'),
              onTap: () {
                Navigator.pop(context);
                _showMoveToGroupDialog(context, book);
              },
            ),
            ListTile(
              leading: Icon(book.status == 2 ? Icons.unarchive : Icons.archive),
              title: Text(book.status == 2 ? '取消归档' : '归档'),
              onTap: () {
                Navigator.pop(context);
                ref.read(bookshelfProvider.notifier).toggleArchive(book.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('删除', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteBook(context, book);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示移动到分组对话框
  void _showMoveToGroupDialog(BuildContext context, Book book) {
    final groups = ref.read(bookshelfProvider).groups;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移动到分组'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: groups.map((group) {
            return ListTile(
              title: Text(group),
              selected: book.groupId == group,
              onTap: () {
                Navigator.pop(context);
                ref.read(bookshelfProvider.notifier).moveBookToGroup(book.id, group);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 确认删除书籍
  void _confirmDeleteBook(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除书籍'),
        content: Text('确定要删除《${book.title}》吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(bookshelfProvider.notifier).deleteBook(book.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示搜索
  void _showSearch(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('搜索书籍'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入书名或作者',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(bookshelfProvider.notifier).search(controller.text);
              Navigator.pop(context);
            },
            child: const Text('搜索'),
          ),
        ],
      ),
    );
  }

  /// 显示添加书籍对话框
  void _showAddBookDialog(BuildContext context) {
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
                  await _importLocalFile(context);
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
  Future<void> _importLocalFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'epub'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      // 显示加载指示器
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 导入书籍
      await ref.read(bookshelfProvider.notifier).importLocalBook(filePath);

      if (mounted) {
        Navigator.pop(context); // 关闭加载指示器
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('书籍导入成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // 关闭加载指示器
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }
}