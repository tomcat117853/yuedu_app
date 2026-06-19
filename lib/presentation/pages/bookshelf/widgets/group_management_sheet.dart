import 'package:flutter/material.dart';

/// 分组管理底部弹窗
class GroupManagementSheet extends StatefulWidget {
  final List<String> groups;
  final Future<bool> Function(String name) onCreateGroup;
  final Future<bool> Function(String name) onDeleteGroup;
  final Future<bool> Function(String oldName, String newName) onRenameGroup;

  const GroupManagementSheet({
    super.key,
    required this.groups,
    required this.onCreateGroup,
    required this.onDeleteGroup,
    required this.onRenameGroup,
  });

  @override
  State<GroupManagementSheet> createState() => _GroupManagementSheetState();
}

class _GroupManagementSheetState extends State<GroupManagementSheet> {
  final _controller = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '分组管理',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 创建分组
            if (_isCreating)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: '输入分组名称',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _createGroup(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: _createGroup,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _isCreating = false;
                        _controller.clear();
                      });
                    },
                  ),
                ],
              )
            else
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('创建新分组'),
                onTap: () => setState(() => _isCreating = true),
                contentPadding: EdgeInsets.zero,
              ),

            const SizedBox(height: 16),
            const Divider(),

            // 分组列表标题
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '我的分组',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),

            // 分组列表
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: widget.groups.map((group) {
                  return ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(group),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => _showRenameDialog(group),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                          onPressed: () => _confirmDeleteGroup(group),
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final success = await widget.onCreateGroup(name);
    if (success && mounted) {
      _controller.clear();
      setState(() => _isCreating = false);
    }
  }

  void _showRenameDialog(String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名分组'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入新名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == oldName) {
                Navigator.pop(context);
                return;
              }
              final success = await widget.onRenameGroup(oldName, newName);
              if (success && mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(String groupName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分组'),
        content: Text('确定要删除分组 "$groupName" 吗？分组内的书籍将移至"默认分组"。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.onDeleteGroup(groupName);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
