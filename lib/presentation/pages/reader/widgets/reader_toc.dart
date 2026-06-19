import 'package:flutter/material.dart';

import '../../../../domain/models/chapter.dart';

class ReaderToc extends StatelessWidget {
  final List<Chapter> chapters;
  final int currentIndex;
  final Function(int) onChapterSelected;

  const ReaderToc({
    super.key,
    required this.chapters,
    required this.currentIndex,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            final isCurrent = index == currentIndex;
            return ListTile(
              title: Text(
                chapter.title,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  color: isCurrent ? Colors.blue : Colors.black,
                ),
              ),
              onTap: () => onChapterSelected(index),
            );
          },
        ),
      ),
    );
  }
}