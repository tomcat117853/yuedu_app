import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';
import '../../../providers.dart';

/// 个人中心页面 - iOS grouped settings style
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
    if (minutes < 60) return '$minutes分钟';
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
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // 用户信息卡片
            _buildUserCard(context),
            const SizedBox(height: 16),

            // 阅读统计
            _buildReadingStats(context),

            // 设置分组列表
            _buildSettingsGroup1(context),
            _buildSettingsGroup2(context),
            _buildSettingsGroup3(context),
          ],
        ),
      ),
    );
  }

  /// 用户信息卡片 - Apple style (no gradient, surface color, subtle shadow)
  Widget _buildUserCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const systemBlue = Color(0xFF007AFF);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: systemBlue.withOpacity(0.1),
            ),
            child: const Icon(Icons.person, size: 32, color: systemBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '阅读者',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '阅读是一种生活方式',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 阅读统计 - Cleaner style in a rounded container with dividers
  Widget _buildReadingStats(BuildContext context) {
    if (_isLoadingStats) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildStatItem(context, '$_readingCount', '在读'),
            _buildVerticalDivider(),
            _buildStatItem(context, '$_finishedCount', '已读完'),
            _buildVerticalDivider(),
            _buildStatItem(
              context,
              _formatDuration(_totalReadingMinutes),
              '总阅读时长',
            ),
          ],
        ),
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 垂直分隔线
  Widget _buildVerticalDivider() {
    return Container(
      width: 0.5,
      height: 36,
      color: Colors.grey.withOpacity(0.3),
    );
  }

  // ------------------------------------------------------------------
  // Settings groups - iOS Inset Grouped style
  // ------------------------------------------------------------------

  /// Section header widget
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Group wrapper with rounded container
  Widget _buildGroupContainer(List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  /// Group 1: 阅读偏好
  Widget _buildSettingsGroup1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('阅读偏好'),
        _buildGroupContainer([
          _buildSettingItem(
            context: context,
            icon: Icons.palette_outlined,
            iconBgColor: const Color(0xFFFF9500),
            title: '阅读主题',
            subtitle: Theme.of(context).brightness == Brightness.dark
                ? '夜间模式'
                : '日间模式',
            onTap: () => _showThemeDialog(context),
          ),
          _buildItemDivider(),
          _buildSettingItem(
            context: context,
            icon: Icons.text_fields,
            iconBgColor: const Color(0xFF5856D6),
            title: '字体设置',
            subtitle: '系统默认',
            onTap: () => _showFontSettings(context),
          ),
        ]),
      ],
    );
  }

  /// Group 2: 数据管理
  Widget _buildSettingsGroup2(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('数据管理'),
        _buildGroupContainer([
          _buildSettingItem(
            context: context,
            icon: Icons.download_outlined,
            iconBgColor: const Color(0xFF34C759),
            title: '缓存管理',
            subtitle: '已使用 ${_formatCacheSize(_cacheSize)}',
            onTap: () => _showCacheManagement(context),
          ),
          _buildItemDivider(),
          _buildSettingItem(
            context: context,
            icon: Icons.backup_outlined,
            iconBgColor: const Color(0xFF007AFF),
            title: '数据备份',
            subtitle: '本地备份',
            onTap: () => _backupData(context),
          ),
        ]),
      ],
    );
  }

  /// Group 3: 其他
  Widget _buildSettingsGroup3(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('其他'),
        _buildGroupContainer([
          _buildSettingItem(
            context: context,
            icon: Icons.info_outline,
            iconBgColor: const Color(0xFF8E8E93),
            title: '关于',
            subtitle: '版本 ${Constants.version}',
            onTap: () => _showAbout(context),
          ),
        ]),
      ],
    );
  }

  String _formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// 设置项 - iOS style with icon in rounded colored square
  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: iconBgColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: iconBgColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
        size: 20,
      ),
      onTap: onTap,
    );
  }

  /// Divider between items within a group
  Widget _buildItemDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56),
      child: Container(
        height: 0.5,
        color: Colors.grey.withOpacity(0.3),
      ),
    );
  }

  /// 显示主题选择对话框 - iOS style
  void _showThemeDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const systemBlue = Color(0xFF007AFF);
    final currentValue = _getThemeModeString();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '选择主题',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              label: '跟随系统',
              value: 'system',
              groupValue: currentValue,
              colorScheme: colorScheme,
              onTap: () {
                _setThemeMode('system');
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              label: '日间模式',
              value: 'light',
              groupValue: currentValue,
              colorScheme: colorScheme,
              onTap: () {
                _setThemeMode('light');
                Navigator.pop(dialogContext);
              },
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              label: '夜间模式',
              value: 'dark',
              groupValue: currentValue,
              colorScheme: colorScheme,
              onTap: () {
                _setThemeMode('dark');
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: systemBlue,
                textStyle: const TextStyle(fontSize: 17),
              ),
              child: const Text('取消'),
            ),
          ),
        ],
      ),
    );
  }

  /// iOS-style rounded radio option for theme dialog
  Widget _buildThemeOption({
    required String label,
    required String value,
    required String groupValue,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    const systemBlue = Color(0xFF007AFF);
    final isSelected = value == groupValue;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? systemBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? systemBlue.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? systemBlue : Colors.grey.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: systemBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                color: isSelected ? systemBlue : null,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
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
      await prefs.setString('theme_mode', mode);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '字体设置',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: const Text('系统默认'),
              leading: Icon(Icons.check_circle, color: colorScheme.primary),
              onTap: () => Navigator.pop(dialogContext),
            ),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: const Text('思源宋体'),
              leading: Icon(Icons.circle_outlined, color: Colors.grey[400]),
              onTap: () => Navigator.pop(dialogContext),
            ),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: const Text('方正楷体'),
              leading: Icon(Icons.circle_outlined, color: Colors.grey[400]),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          '缓存管理',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '当前缓存大小: ${_formatCacheSize(_cacheSize)}',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 17),
            ),
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle: const TextStyle(fontSize: 17),
            ),
            child: const Text('清理缓存'),
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
      applicationName: Constants.appName,
      applicationVersion: Constants.version,
      applicationLegalese: '全平台本地阅读App',
    );
  }
}
