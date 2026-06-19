import 'package:flutter/material.dart';

import '../../../../domain/models/search_result.dart';

class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final Function() onTap;

  const SearchResultItem({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: result.coverUrl != null
          ? Image.network(
              result.coverUrl!,
              width: 50,
              height: 70,
              fit: BoxFit.cover,
            )
          : const Icon(Icons.book),
      title: Text(result.title),
      subtitle: Text(result.author ?? '未知作者'),
      onTap: onTap,
    );
  }
}