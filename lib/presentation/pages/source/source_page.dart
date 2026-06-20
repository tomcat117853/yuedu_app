import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../config/design_tokens.dart';
import '../../../domain/models/source_definition.dart';
import '../../widgets/common_widgets.dart';
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
        title: const Text('书源'),
        scrolledUnderElevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSourceDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              switch (value) {
                case 'import':
                  _importSources();
                  break;
                case 'export':
                  _exportSources();
                  break;
                case 'check':
                  _checkAllSources();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.file_download_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('从文件导入'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_upload_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('导出书源'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'check',
                child: Row(
                  children: [
                    Icon(Icons.health_and_safety_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('检查更新'),
                  ],
                ),
              ),
            ],
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
    return EmptyStateWidget(
      icon: Icons.source_outlined,
      title: '还没有书源',
      subtitle: '导入书源后即可搜索和阅读书籍',
      actionLabel: '导入书源',
      onAction: _importSources,
    );
  }

  /// 书源列表 - iOS Inset Grouped 风格
  Widget _buildSourceList(SourcePageState state) {
    final enabledSources = state.sources.where((s) => s.enabled).toList();
    final disabledSources = state.sources.where((s) => !s.enabled).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (state.isChecking)
          const LinearProgressIndicator(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            children: [
              // 已启用分组
              if (enabledSources.isNotEmpty) ...[
                _buildGroupHeader('已启用 (${enabledSources.length})'),
                const SizedBox(height: AppSpacing.sm),
                _buildSourceGroup(
                  enabledSources,
                  isDark: isDark,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              // 已禁用分组
              if (disabledSources.isNotEmpty) ...[
                _buildGroupHeader('已禁用 (${disabledSources.length})'),
                const SizedBox(height: AppSpacing.sm),
                _buildSourceGroup(
                  disabledSources,
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 分组标题
  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xxs),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: AppFontWeight.medium,
          color: AppColors.gray6,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 书源分组容器 - iOS Inset Grouped 卡片
  Widget _buildSourceGroup(List<SourceDefinition> sources, {required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: AppGroupedBackground.groupBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: List.generate(sources.length, (index) {
          final source = sources[index];
          final isLast = index == sources.length - 1;
          return Column(
            children: [
              _buildSourceItem(source),
              if (!isLast)
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  indent: 56,
                  color: isDark ? AppColors.darkGray3 : AppColors.gray2,
                ),
            ],
          );
        }),
      ),
    );
  }

  /// 单个书源项
  Widget _buildSourceItem(SourceDefinition source) {
    return Dismissible(
      key: Key(source.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.systemRed,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      confirmDismiss: (direction) async {
        return await showConfirmDialog(
          context: context,
          title: '确认删除',
          content: '确定要删除书源 "${source.bookSourceName}" 吗？',
          confirmText: '删除',
          isDangerous: true,
        );
      },
      onDismissed: (_) {
        ref.read(sourcePageProvider.notifier).removeSource(source.id);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          source.bookSourceName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: AppFontWeight.medium,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (source.bookSourceGroup.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.systemBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.button),
                          ),
                          child: Text(
                            source.bookSourceGroup,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: AppFontWeight.medium,
                              color: AppColors.systemBlue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    source.bookSourceUrl,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray6,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Switch(
              value: source.enabled,
              onChanged: (value) {
                ref
                    .read(sourcePageProvider.notifier)
                    .toggleSource(source.id, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 显示添加书源对话框 - iOS 风格
  void _showAddSourceDialog() {
    final controller = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '添加书源',
          style: TextStyle(
            fontWeight: AppFontWeight.semibold,
            fontSize: 17,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '粘贴书源 JSON 配置：',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: '{"bookSourceName":"...","bookSourceUrl":"..."}',
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              '取消',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: AppFontWeight.regular,
              ),
            ),
          ),
          FilledButton(
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
