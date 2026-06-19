import 'dart:io';
import 'package:flutter/material.dart';

import '../../../../domain/models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final Function() onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Expanded(
              child: book.coverPath != null && book.coverPath!.isNotEmpty
                  ? Image.file(
                      File(book.coverPath!),
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.book, size: 64),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}