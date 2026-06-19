import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text('阅读设置'),
            subtitle: Text('字体、主题、排版等'),
          ),
          const ListTile(
            title: Text('存储设置'),
            subtitle: Text('缓存路径、存储空间'),
          ),
          const ListTile(
            title: Text('更新设置'),
            subtitle: Text('检查更新'),
          ),
        ],
      ),
    );
  }
}