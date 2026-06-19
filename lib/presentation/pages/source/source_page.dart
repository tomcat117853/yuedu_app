import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'source_provider.dart';

/// 书源管理页面
class SourcePage extends ConsumerStatefulWidget {
  const SourcePage({super.key});

  @override
  ConsumerState<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends ConsumerState<SourcePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sourcePageProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('书源管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSourceDialog,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.sources.isEmpty
              ? _buildEmptyState()
              : _buildSourceList(state),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.source_outlined,
            size: 80,
            color: theme.hintColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无书源',
            style: TextStyle(color: theme.hintColor, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 添加或通过菜单导入',
            style: TextStyle(color: theme.hintColor, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showAddSourceDialog,
            child: const Text('添加书源'),
          ),
        ],
      ),
    );
  }

  /// 书源列表
  Widget _buildSourceList(SourcePageState state) {
    return Column(
      children: [
        if (state.isChecking)
          const LinearProgressIndicator(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.sources.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final source = state.sources[index];
              return Dismissible(
                key: Key(source.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('确认删除'),
                      content: Text('确定要删除书源 "${source.bookSourceName}" 吗？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('删除',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (_) {
                  ref
                      .read(sourcePageProvider.notifier)
                      .removeSource(source.id);
                },
                child: SwitchListTile(
                  title: Text(
                    source.bookSourceName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    source.bookSourceUrl,
                    style: TextStyle(
                        fontSize: 12, color: Theme.of(context).hintColor),
                  ),
                  secondary: source.bookSourceGroup.isNotEmpty
                      ? Chip(
                          label: Text(
                            source.bookSourceGroup,
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.zero,
                        )
                      : null,
                  value: source.enabled,
                  onChanged: (value) {
                    ref
                        .read(sourcePageProvider.notifier)
                        .toggleSource(source.id, value);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 显示添加书源对话框
  void _showAddSourceDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('添加书源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '粘贴书源 JSON 配置：',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '{"bookSourceName":"...","bookSourceUrl":"..."}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              final success = ref
                  .read(sourcePageProvider.notifier)
                  .addSourceFromJson(text);

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '书源添加成功' : '添加失败：JSON 格式无效'),
                ),
              );
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  /// 导入书源
  Future<void> _importSources() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      final content = await File(filePath).readAsString();
      final count = ref.read(sourcePageProvider.notifier).importFromJson(content);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(count > 0 ? '成功导入 $count 个书源' : '没有可导入的书源'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  /// 导出书源
  Future<void> _exportSources() async {
    final filePath = await ref.read(sourcePageProvider.notifier).exportToFile();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(filePath != null ? '已导出到 $filePath' : '导出失败'),
        ),
      );
    }
  }

  /// 检查所有书源
  void _checkAllSources() {
    ref.read(sourcePageProvider.notifier).checkAllSources();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在检查书源可用性...')),
    );
  }
}
