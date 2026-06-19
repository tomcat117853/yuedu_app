import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../config/theme.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';
import '../../../domain/services/read_engine.dart';
import '../../../providers.dart';

/// 个人中心页面
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  int _readingCount = 0;
  int _finishedCount = 0;
  int _totalReadingMinutes = 0;
  int _cacheSize = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final bookRepository = ref.read(bookRepositoryProvider);
      final allBooks = await bookRepository.getAllBooks();
      final allProgress = await bookRepository.getAllProgress();

      int reading = 0;
      int finished = 0;
      int totalMinutes = 0;

      for (final book in allBooks) {
        if (book.status == 1) {
          finished++;
        } else if (book.status == 0) {
          reading++;
        }
      }

      for (final progress in allProgress) {
        totalMinutes += progress.readingTime;
      }

      // 获取缓存大小
      final fileService = ref.read(fileServiceProvider);
      final cacheDir = await fileService.getCacheDirectory();
      final cacheSize = await fileService.getDirectorySize('$cacheDir/chapters');

      if (mounted) {
        setState(() {
          _readingCount = reading;
          _finishedCount = finished;
          _totalReadingMinutes = totalMinutes;
          _cacheSize = cacheSize;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '${minutes}分钟';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours < 24) return '$hours小时$mins分钟';
    final days = hours ~/ 24;
    return '$days天$hours小时';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          children: [
            // 用户信息卡片
            _buildUserCard(context),
            const SizedBox(height: 16),

            // 阅读统计
            _buildReadingStats(context),
            const SizedBox(height: 16),

            // 设置列表
            _buildSettingsList(context),
          ],
        ),
      ),
    );
  }

  /// 用户信息卡片
  Widget _buildUserCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: const Icon(Icons.person, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '阅读者',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '阅读是一种生活方式',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 阅读统计
  Widget _buildReadingStats(BuildContext context) {
    if (_isLoadingStats) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem(context, '$_readingCount', '在读'),
          _buildStatItem(context, '$_finishedCount', '已读完'),
          _buildStatItem(
            context,
            _formatDuration(_totalReadingMinutes),
            '总阅读时长',
          ),
        ],
      ),
    );
  }

  /// 统计项
  Widget _buildStatItem(BuildContext context, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 设置列表
  Widget _buildSettingsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context: context,
            icon: Icons.palette_outlined,
            title: '阅读主题',
            subtitle: Theme.of(context).brightness == Brightness.dark
                ? '夜间模式'
                : '日间模式',
            onTap: () => _showThemeDialog(context),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            context: context,
            icon: Icons.text_fields,
            title: '字体设置',
            subtitle: '系统默认',
            onTap: () => _showFontSettings(context),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            context: context,
            icon: Icons.download_outlined,
            title: '缓存管理',
            subtitle: '已使用 ${_formatCacheSize(_cacheSize)}',
            onTap: () => _showCacheManagement(context),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            context: context,
            icon: Icons.backup_outlined,
            title: '数据备份',
            subtitle: '本地备份',
            onTap: () => _backupData(context),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            context: context,
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '版本 ${AppConstants.appVersion}',
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  String _formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 设置项
  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
      onTap: onTap,
    );
  }

  /// 显示主题选择对话框
  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('跟随系统'),
              value: 'system',
              groupValue: _getThemeModeString(),
              onChanged: (v) {
                _setThemeMode(v!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('日间模式'),
              value: 'light',
              groupValue: _getThemeModeString(),
              onChanged: (v) {
                _setThemeMode(v!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('夜间模式'),
              value: 'dark',
              groupValue: _getThemeModeString(),
              onChanged: (v) {
                _setThemeMode(v!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeString() {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? 'dark' : 'light';
  }

  void _setThemeMode(String mode) async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(AppConstants.keyThemeMode, mode);
    } catch (_) {
      // SharedPreferences 未初始化时忽略
    }
    // 通知 app 层更新主题（通过 InheritedWidget 或 Provider）
    if (mounted) setState(() {});
  }

  /// 字体设置
  void _showFontSettings(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('字体设置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('系统默认'),
              leading: Icon(Icons.check, color: colorScheme.primary),
              onTap: () => Navigator.pop(dialogContext),
            ),
            ListTile(
              title: const Text('思源宋体'),
              leading: const Icon(Icons.circle_outlined),
              onTap: () => Navigator.pop(dialogContext),
            ),
            ListTile(
              title: const Text('方正楷体'),
              leading: const Icon(Icons.circle_outlined),
              onTap: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
      ),
    );
  }

  /// 缓存管理
  void _showCacheManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('缓存管理'),
        content: Text('当前缓存大小: ${_formatCacheSize(_cacheSize)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final fileService = ref.read(fileServiceProvider);
              await fileService.clearCache();
              if (mounted) {
                setState(() => _cacheSize = 0);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清理')),
                );
              }
            },
            child: const Text('清理缓存', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 数据备份
  void _backupData(BuildContext context) {
    context.push(AppRoutes.backup);
  }

  /// 关于
  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '全平台本地阅读App',
    );
  }
}
