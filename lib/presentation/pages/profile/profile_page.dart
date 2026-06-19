import 'package:flutter/material.dart';

import '../../../config/routes.dart';

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
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('数据备份'),
            onTap: () => Navigator.pushNamed(context, Routes.backup),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            onTap: () => Navigator.pushNamed(context, Routes.settings),
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('书源管理'),
            onTap: () => Navigator.pushNamed(context, Routes.source),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            onTap: () => _showAbout(context),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于'),
        content: const Text('Yuedu App - 全平台本地阅读应用'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}