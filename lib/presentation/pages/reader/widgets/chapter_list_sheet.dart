import 'package:flutter/material.dart';
import '../../../../domain/models/chapter.dart';
import '../../../../domain/models/reader_theme.dart';

/// 章节列表底部弹窗
class ChapterListSheet extends StatelessWidget {
  final List<Chapter> chapters;
  final int currentChapterIndex;
  final ReaderTheme theme;
  final ValueChanged<int> onChapterTap;

  const ChapterListSheet({
    super.key,
    required this.chapters,
    required this.currentChapterIndex,
    required this.theme,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  '目录',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '共 ${chapters.length} 章',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // 搜索框
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索章节',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white38, size: 20),
                filled: true,
                fillColor: const Color(0xFF3C3C3C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (query) {
                // 搜索过滤
              },
            ),
          ),

          // 章节列表
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final isCurrent = index == currentChapterIndex;

                return ListTile(
                  dense: true,
                  title: Text(
                    chapter.title,
                    style: TextStyle(
                      color: isCurrent
                          ? theme.textColor
                          : Colors.white70,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: chapter.wordCount > 0
                      ? Text(
                          '${chapter.wordCount}字',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  trailing: isCurrent
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.textColor,
                          ),
                        )
                      : null,
                  onTap: () => onChapterTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
