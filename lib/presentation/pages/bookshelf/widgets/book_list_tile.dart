import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/models/book.dart';
import '../../../../domain/models/read_progress.dart';

/// 书籍列表项组件（用于列表视图）- Apple-style design
class BookListTile extends StatelessWidget {
  final Book book;
  final ReadProgress? progress;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BookListTile({
    super.key,
    required this.book,
    this.progress,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 封面 (60x80, borderRadius 8pt)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 80,
                child: book.coverPath != null && File(book.coverPath!).existsSync()
                    ? Image.file(
                        File(book.coverPath!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: _getCoverColor(book),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            book.title.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // 书籍信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (fontSize 17, fontWeight semibold - iOS headline)
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.author != null && book.author!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    // Author (fontSize 15, gray color)
                    Text(
                      book.author!,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  // 进度条 (refined with thin track)
                  if (progress != null && progress!.progressPercent > 0) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(1.5),
                            child: LinearProgressIndicator(
                              value: progress!.progressPercent / 100,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              minHeight: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${progress!.progressPercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                  // 底部元数据行 (footnote size)
                  Row(
                    children: [
                      _buildStatusChip(context),
                      const SizedBox(width: 8),
                      // Format badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          book.format.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Chapter count (footnote)
                      Text(
                        '${book.totalChapters} 章',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String label;

    switch (book.status) {
      case 0:
        color = Colors.blue;
        label = '阅读中';
        break;
      case 1:
        color = Colors.green;
        label = '已读完';
        break;
      case 2:
        color = Colors.grey;
        label = '已归档';
        break;
      default:
        color = Colors.blue;
        label = '阅读中';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
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
