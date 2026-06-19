import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/models/book.dart';
import '../../../../domain/models/read_progress.dart';

/// 书籍卡片组件（网格视图）
class BookCard extends StatelessWidget {
  final Book book;
  final ReadProgress? progress;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BookCard({
    super.key,
    required this.book,
    this.progress,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _getCoverColor(book),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 封面图片或默认
                  if (book.coverPath != null && File(book.coverPath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(book.coverPath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: _getCoverColor(book),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book,
                                size: 32,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  book.title,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 进度条
                  if (progress != null && progress!.progressPercent > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: LinearProgressIndicator(
                          value: progress!.progressPercent / 100,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),

                  // 归档标签
                  if (book.status == 2)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '已归档',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 书名
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // 作者
          if (book.author != null && book.author!.isNotEmpty)
            Text(
              book.author!,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Color _getCoverColor(Book book) {
    final colors = [
      const Color(0xFF1E88E5), // Blue
      const Color(0xFF43A047), // Green
      const Color(0xFFFB8C00), // Orange
      const Color(0xFFE53935), // Red
      const Color(0xFF8E24AA), // Purple
      const Color(0xFF00ACC1), // Cyan
    ];
    // 根据书名生成稳定的颜色
    final index = book.title.hashCode.abs() % colors.length;
    return colors[index];
  }
}
