import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../../config/routes.dart';
import '../reader/reader_page.dart';
import 'bookshelf_provider.dart';
import 'widgets/book_card.dart';

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
      body: DropTarget(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBookDialog(context),
        child: const Icon(Icons.add),
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
      child: GridView.builder(
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
          return BookCard(
            book: book,
            onTap: () => _onBookTap(book.id),
          );
        },
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