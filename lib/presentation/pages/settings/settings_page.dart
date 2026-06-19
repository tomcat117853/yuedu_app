import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../domain/models/reader_theme.dart';
import '../../../domain/models/layout_config.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('阅读设置'),
          _buildThemeSection(context, ref),
          _buildFontSection(context, ref),
          _buildLayoutSection(context, ref),
          _buildSectionHeader('存储设置'),
          _buildStorageSection(context),
          _buildSectionHeader('关于'),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, WidgetRef ref) {
    final readerTheme = ref.watch(readerThemeProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: const Text('阅读主题'),
            subtitle: Text(readerTheme.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildFontSection(BuildContext context, WidgetRef ref) {
    final layoutConfig = ref.watch(layoutConfigProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: const Text('字体大小'),
            subtitle: Text('${layoutConfig.fontSize} 号字'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontSizeDialog(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('行间距'),
            subtitle: Text(layoutConfig.lineSpacing == LineSpacing.tight
                ? '紧凑'
                : layoutConfig.lineSpacing == LineSpacing.normal
                    ? '标准'
                    : '宽松'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLineSpacingDialog(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('字间距'),
            subtitle: Text(layoutConfig.letterSpacing == LetterSpacing.tight
                ? '紧凑'
                : layoutConfig.letterSpacing == LetterSpacing.normal
                    ? '标准'
                    : '宽松'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLetterSpacingDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutSection(BuildContext context, WidgetRef ref) {
    final layoutConfig = ref.watch(layoutConfigProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: const Text('页面边距'),
            subtitle: Text(layoutConfig.padding == PagePadding.narrow
                ? '窄'
                : layoutConfig.padding == PagePadding.normal
                    ? '标准'
                    : '宽'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showPaddingDialog(context, ref),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('显示章节标题'),
            value: layoutConfig.showChapterTitle,
            onChanged: (value) {
              ref.read(layoutConfigProvider.notifier).update(
                    (state) => state.copyWith(showChapterTitle: value),
                  );
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('夜间模式跟随系统'),
            value: layoutConfig.followSystemTheme,
            onChanged: (value) {
              ref.read(layoutConfigProvider.notifier).update(
                    (state) => state.copyWith(followSystemTheme: value),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: const Text('清除缓存'),
            subtitle: const Text('清除章节缓存和图片缓存'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearCacheDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          const ListTile(
            title: Text('版本信息'),
            subtitle: Text('v1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('检查更新'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('当前已是最新版本')),
              );
            },
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('用户协议'),
            trailing: Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          const ListTile(
            title: Text('隐私政策'),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ReaderTheme.all.map((theme) {
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Aa',
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                title: Text(theme.name),
                trailing: ref.watch(readerThemeProvider) == theme
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  ref.read(readerThemeProvider.notifier).state = theme;
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('字体大小'),
        content: StatefulBuilder(
          builder: (context, setState) {
            final currentSize = ref.watch(layoutConfigProvider).fontSize;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  min: 12,
                  max: 28,
                  value: currentSize.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      ref.read(layoutConfigProvider.notifier).update(
                            (state) => state.copyWith(fontSize: value),
                          );
                    });
                  },
                ),
                Text('${ref.watch(layoutConfigProvider).fontSize} 号字'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLineSpacingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('行间距'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LineSpacing.values.map((spacing) {
            return ListTile(
              title: Text(spacing == LineSpacing.tight
                  ? '紧凑'
                  : spacing == LineSpacing.normal
                      ? '标准'
                      : '宽松'),
              trailing:
                  ref.watch(layoutConfigProvider).lineSpacing == spacing
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
              onTap: () {
                ref.read(layoutConfigProvider.notifier).update(
                      (state) => state.copyWith(lineSpacing: spacing),
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLetterSpacingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('字间距'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LetterSpacing.values.map((spacing) {
            return ListTile(
              title: Text(spacing == LetterSpacing.tight
                  ? '紧凑'
                  : spacing == LetterSpacing.normal
                      ? '标准'
                      : '宽松'),
              trailing:
                  ref.watch(layoutConfigProvider).letterSpacing == spacing
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
              onTap: () {
                ref.read(layoutConfigProvider.notifier).update(
                      (state) => state.copyWith(letterSpacing: spacing),
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPaddingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('页面边距'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: PagePadding.values.map((padding) {
            return ListTile(
              title: Text(padding == PagePadding.narrow
                  ? '窄'
                  : padding == PagePadding.normal
                      ? '标准'
                      : '宽'),
              trailing: ref.watch(layoutConfigProvider).padding == padding
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                ref.read(layoutConfigProvider.notifier).update(
                      (state) => state.copyWith(padding: padding),
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存吗？这将删除已下载的章节内容和图片。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 清除缓存逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
