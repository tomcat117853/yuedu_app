import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// 个人中心页面
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        children: [
          // 用户信息卡片
          _buildUserCard(context),

          const SizedBox(height: 16),

          // 阅读统计
          _buildReadingStats(),

          const SizedBox(height: 16),

          // 设置列表
          _buildSettingsList(context),
        ],
      ),
    );
  }

  /// 用户信息卡片
  Widget _buildUserCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 头像
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          // 用户名和简介
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
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // 编辑按钮
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  /// 阅读统计
  Widget _buildReadingStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem('3', '在读'),
          _buildStatItem('12', '已读完'),
          _buildStatItem('156', '总阅读时长'),
        ],
      ),
    );
  }

  /// 统计项
  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 设置列表
  Widget _buildSettingsList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.palette_outlined,
            title: '阅读主题',
            subtitle: '日间模式',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.text_fields,
            title: '字体设置',
            subtitle: '系统默认',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.download_outlined,
            title: '缓存管理',
            subtitle: '已使用 0 MB',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.backup_outlined,
            title: '数据备份',
            subtitle: '上次备份: 从未',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '版本 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  /// 设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textHint),
      onTap: onTap,
    );
  }
}
