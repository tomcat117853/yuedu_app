import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../domain/services/backup_service.dart';
import '../../../providers.dart';

/// 备份设置页面
class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  List<BackupFileInfo> _backupFiles = [];
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  /// 加载备份文件列表
  Future<void> _loadBackupFiles() async {
    setState(() => _isLoading = true);
    try {
      final backupService = ref.read(backupServiceProvider);
      final files = await backupService.getBackupFiles();
      setState(() {
        _backupFiles = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '加载备份列表失败: $e';
      });
    }
  }

  /// 创建备份
  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '正在创建备份...';
    });

    try {
      final backupService = ref.read(backupServiceProvider);
      final filePath = await backupService.exportData();
      
      setState(() {
        _isLoading = false;
        _statusMessage = '备份创建成功';
      });

      // 显示成功对话框
      _showSuccessDialog('备份成功', '备份文件已保存到:\n$filePath\n\n是否分享备份文件？', () {
        backupService.shareBackup(filePath);
      });

      // 刷新备份列表
      await _loadBackupFiles();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '备份失败: $e';
      });
      _showErrorDialog('备份失败', e.toString());
    }
  }

  /// 从文件导入备份
  Future<void> _importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) {
        _showErrorDialog('导入失败', '无法获取文件路径');
        return;
      }

      await _performImport(file.path!);
    } catch (e) {
      _showErrorDialog('导入失败', e.toString());
    }
  }

  /// 执行导入
  Future<void> _performImport(String filePath, {bool merge = false}) async {
    // 显示确认对话框
    final confirmed = await _showConfirmDialog(
      '导入备份',
      merge 
        ? '是否合并导入数据？\n合并模式会保留现有数据。'
        : '导入将覆盖现有数据！\n此操作不可撤销，是否继续？',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _statusMessage = '正在导入备份...';
    });

    try {
      final backupService = ref.read(backupServiceProvider);
      final result = await backupService.importData(filePath, merge: merge);

      setState(() {
        _isLoading = false;
        _statusMessage = result.success ? '导入成功' : '导入失败: ${result.message}';
      });

      if (result.success) {
        _showSuccessDialog(
          '导入成功',
          '已导入:\n'
          '• ${result.booksImported} 本书籍\n'
          '• ${result.chaptersImported} 个章节\n'
          '• ${result.sourcesImported} 个书源\n'
          '• ${result.progressImported} 条阅读进度\n'
          '• ${result.bookmarksImported} 个书签',
          null,
        );
      } else {
        _showErrorDialog('导入失败', result.message);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '导入失败: $e';
      });
      _showErrorDialog('导入失败', e.toString());
    }
  }

  /// 删除备份文件
  Future<void> _deleteBackup(BackupFileInfo fileInfo) async {
    final confirmed = await _showConfirmDialog(
      '删除备份',
      '是否删除此备份文件？\n${fileInfo.path}',
    );

    if (!confirmed) return;

    try {
      final backupService = ref.read(backupServiceProvider);
      await backupService.deleteBackup(fileInfo.path);
      await _loadBackupFiles();
      
      setState(() {
        _statusMessage = '备份已删除';
      });
    } catch (e) {
      _showErrorDialog('删除失败', e.toString());
    }
  }

  /// 显示成功对话框
  void _showSuccessDialog(String title, String message, VoidCallback? onShare) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onShare != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onShare();
              },
              child: const Text('分享'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示错误对话框
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示确认对话框
  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据备份'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 状态消息
                  if (_statusMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusMessage!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),

                  // 操作按钮区域
                  _buildSectionTitle('备份操作'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _createBackup,
                          icon: const Icon(Icons.backup),
                          label: const Text('创建备份'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _importFromFile,
                          icon: const Icon(Icons.restore),
                          label: const Text('导入备份'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 备份文件列表
                  _buildSectionTitle('备份历史'),
                  const SizedBox(height: 8),
                  
                  if (_backupFiles.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          '暂无备份文件',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _backupFiles.length,
                      itemBuilder: (context, index) {
                        final fileInfo = _backupFiles[index];
                        return _buildBackupFileItem(fileInfo);
                      },
                    ),

                  const SizedBox(height: 24),

                  // 说明区域
                  _buildSectionTitle('说明'),
                  const SizedBox(height: 8),
                  const Text(
                    '• 备份包含：书籍、章节、书源、阅读进度、书签和设置\n'
                    '• 备份文件格式：JSON\n'
                    '• 导入备份会覆盖现有数据，请谨慎操作\n'
                    '• 建议定期备份，防止数据丢失',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 构建备份文件列表项
  Widget _buildBackupFileItem(BackupFileInfo fileInfo) {
    final fileName = fileInfo.path.split(Platform.pathSeparator).last;
    final dateStr = '${fileInfo.createdAt.year}-${fileInfo.createdAt.month.toString().padLeft(2, '0')}-${fileInfo.createdAt.day.toString().padLeft(2, '0')}';
    final timeStr = '${fileInfo.createdAt.hour.toString().padLeft(2, '0')}:${fileInfo.createdAt.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.file_present, color: Colors.blue),
        title: Text(fileName),
        subtitle: Text(
          '$dateStr $timeStr · ${fileInfo.bookCount} 本书籍 · v${fileInfo.version}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'import') {
              _performImport(fileInfo.path);
            } else if (value == 'merge') {
              _performImport(fileInfo.path, merge: true);
            } else if (value == 'share') {
              ref.read(backupServiceProvider).shareBackup(fileInfo.path);
            } else if (value == 'delete') {
              _deleteBackup(fileInfo);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'import',
              child: Text('覆盖导入'),
            ),
            const PopupMenuItem(
              value: 'merge',
              child: Text('合并导入'),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Text('分享'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('删除'),
            ),
          ],
        ),
      ),
    );
  }
}