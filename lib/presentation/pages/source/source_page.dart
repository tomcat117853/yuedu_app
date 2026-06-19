import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// 书源管理页面
class SourcePage extends StatefulWidget {
  const SourcePage({super.key});

  @override
  State<SourcePage> createState() => _SourcePageState();
}

class _SourcePageState extends State<SourcePage> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _sources = [];

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    setState(() => _isLoading = true);
    // 模拟加载书源
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
      _sources.addAll([
        {'name': '书源1', 'url': 'https://example1.com', 'enabled': true, 'count': 1000},
        {'name': '书源2', 'url': 'https://example2.com', 'enabled': true, 'count': 800},
        {'name': '书源3', 'url': 'https://example3.com', 'enabled': false, 'count': 500},
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('书源管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSourceDialog,
          ),
          PopupMenuButton<String>(
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
              const PopupMenuItem(value: 'import', child: Text('导入书源')),
              const PopupMenuItem(value: 'export', child: Text('导出书源')),
              const PopupMenuItem(value: 'check', child: Text('检查可用性')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sources.isEmpty
              ? _buildEmptyState()
              : _buildSourceList(),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.source_outlined,
            size: 80,
            color: AppTheme.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无书源',
            style: TextStyle(color: AppTheme.textHint, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _showAddSourceDialog,
            child: const Text('添加书源'),
          ),
        ],
      ),
    );
  }

  /// 书源列表
  Widget _buildSourceList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sources.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final source = _sources[index];
        return SwitchListTile(
          title: Text(
            source['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            source['url'] as String,
            style: TextStyle(fontSize: 12, color: AppTheme.textHint),
          ),
          secondary: Text(
            '${source['count']}本',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          value: source['enabled'] as bool,
          onChanged: (value) {
            setState(() {
              _sources[index]['enabled'] = value;
            });
          },
        );
      },
    );
  }

  /// 显示添加书源对话框
  void _showAddSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加书源'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: '书源名称',
                hintText: '请输入书源名称',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: '书源地址',
                hintText: '请输入书源URL',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  /// 导入书源
  void _importSources() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入功能开发中')),
    );
  }

  /// 导出书源
  void _exportSources() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导出功能开发中')),
    );
  }

  /// 检查所有书源
  void _checkAllSources() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在检查书源可用性...')),
    );
  }
}
