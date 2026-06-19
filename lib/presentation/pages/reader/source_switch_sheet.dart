import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../../../domain/models/book_source.dart';
import '../../../../domain/models/source_definition.dart';
import '../../../../domain/models/book_source_protocol.dart';
import '../../../../domain/models/chapter.dart';
import '../../../../domain/models/book.dart';
import '../../../../domain/engine/source_matcher.dart';
import '../../../../domain/models/search_result.dart';
import '../../../../providers.dart';

/// 书源切换底部弹窗
class SourceSwitchSheet extends ConsumerStatefulWidget {
  final Book? book;
  final List<BookSource> currentSources;
  final int currentChapterIndex;
  final void Function(BookSource newSource, List<Chapter> chapters) onSwitch;

  const SourceSwitchSheet({
    super.key,
    required this.book,
    required this.currentSources,
    required this.currentChapterIndex,
    required this.onSwitch,
  });

  @override
  ConsumerState<SourceSwitchSheet> createState() => _SourceSwitchSheetState();
}

class _SourceSwitchSheetState extends ConsumerState<SourceSwitchSheet> {
  bool _isSearching = false;
  List<BookSource> _availableSources = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _availableSources = widget.currentSources;
    _searchForSources();
  }

  Future<void> _searchForSources() async {
    if (widget.book == null) return;

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final sourceService = ref.read(sourceServiceProvider);
      final definitions = ref.read(sourceDefinitionsProvider);
      final matcher = ref.read(sourceMatcherProvider);

      // 搜索所有启用的书源定义
      final results = await sourceService.searchBook(
        widget.book!.title,
        sourceDefinitions: definitions.where((d) => d.enabled).toList(),
      );

      if (!mounted) return;

      if (results.isEmpty) {
        setState(() {
          _isSearching = false;
          _error = '未找到其他书源';
        });
        return;
      }

      // 使用 SourceMatcher 匹配
      final matchResult = matcher.matchSource(widget.book!, results);
      final matchedSources = <BookSource>[];

      if (matchResult.matched != null) {
        final matched = matchResult.matched!;
        // 检查是否已在当前书源中
        final exists = widget.currentSources.any(
          (s) => s.sourceId == matched.sourceId,
        );
        if (!exists) {
          matchedSources.add(BookSource(
            id: '',
            bookId: widget.book!.id,
            sourceId: matched.sourceId,
            sourceName: matched.sourceName,
            bookKey: matched.bookKey,
            confidence: matchResult.confidence,
            chapterCount: matched.chapterCount ?? 0,
          ));
        }
      }

      // 添加候选
      for (final candidate in matchResult.candidates) {
        if (matchedSources.any((s) => s.sourceId == candidate.sourceId)) {
          continue;
        }
        if (widget.currentSources.any(
          (s) => s.sourceId == candidate.sourceId,
        )) {
          continue;
        }
        matchedSources.add(BookSource(
          id: '',
          bookId: widget.book!.id,
          sourceId: candidate.sourceId,
          sourceName: candidate.sourceName,
          bookKey: candidate.bookKey,
          confidence: 0.3,
          chapterCount: candidate.chapterCount ?? 0,
        ));
      }

      setState(() {
        _isSearching = false;
        _availableSources = [...widget.currentSources, ...matchedSources];
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _error = '搜索失败: $e';
        });
      }
    }
  }

  Future<void> _switchToSource(BookSource source) async {
    if (source.id.isNotEmpty) {
      // 已有的书源，直接切换
      widget.onSwitch(source, []);
      Navigator.pop(context);
      return;
    }

    // 新书源，需要获取章节列表
    final definitions = ref.read(sourceDefinitionsProvider);
    final sourceDef = definitions.firstWhere(
      (d) => d.id == source.sourceId,
      orElse: () => throw StateError('书源定义未找到'),
    );

    Navigator.pop(context);

    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final engine = ref.read(sourceEngineProvider);
      final chapterInfos = await engine.executeChapterList(
        sourceDef,
        source.bookKey,
      );

      final chapters = chapterInfos
          .map((ci) => Chapter(
                id: '',
                bookId: widget.book!.id,
                sourceId: sourceDef.id,
                chapterKey: ci.chapterKey,
                title: ci.title,
                orderIndex: ci.orderIndex,
                isVip: ci.isVip,
              ))
          .toList();

      if (mounted) {
        Navigator.pop(context); // 关闭加载对话框
      }

      widget.onSwitch(source, chapters);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('切换失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Text(
                  '书源切换',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _isSearching ? null : _searchForSources,
                  tooltip: '搜索更多书源',
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          if (_isSearching && _availableSources.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else if (_error != null && _availableSources.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _availableSources.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final source = _availableSources[index];
                  final isCurrent = widget.currentSources.any(
                    (s) => s.sourceId == source.sourceId,
                  );
                  return _buildSourceItem(source, isCurrent);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSourceItem(BookSource source, bool isCurrent) {
    return ListTile(
      title: Text(
        source.sourceName,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        '章节: ${source.chapterCount > 0 ? source.chapterCount : "未知"} | '
        '置信度: ${(source.confidence * 100).toInt()}%',
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: isCurrent
          ? const Chip(
              label: Text('当前', style: TextStyle(fontSize: 11)),
              backgroundColor: AppTheme.primaryColor,
              padding: EdgeInsets.zero,
            )
          : const Icon(Icons.swap_horiz),
      onTap: isCurrent ? null : () => _switchToSource(source),
    );
  }
}
