import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../domain/models/book_source_protocol.dart';
import '../../../domain/models/search_result.dart';
import '../../../domain/models/source_definition.dart';
import '../../../providers.dart';
import 'discover_provider.dart';

/// 书籍详情页 - 展示在线书籍的完整信息
class BookDetailPage extends ConsumerStatefulWidget {
  final SearchResult result;
  final SourceDefinition sourceDef;

  const BookDetailPage({
    super.key,
    required this.result,
    required this.sourceDef,
  });

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  BookDetail? _detail;
  List<ChapterInfo> _chapters = [];
  bool _isLoading = true;
  bool _isAdding = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final notifier = ref.read(discoverProvider.notifier);

    try {
      // 加载详情
      final detail = await notifier.getBookDetail(
        widget.sourceDef,
        widget.result.bookKey,
      );

      if (!mounted) return;

      if (detail != null) {
        setState(() => _detail = detail);

        // 加载章节列表
        final chapters = await notifier.getChapterList(
          widget.sourceDef,
          detail.bookKey,
        );

        if (!mounted) return;
        setState(() {
          _chapters = chapters;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = '获取书籍详情失败';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = '加载失败: $e';
        });
      }
    }
  }

  Future<void> _addToBookshelf() async {
    if (_detail == null || _isAdding) return;

    setState(() => _isAdding = true);

    try {
      final notifier = ref.read(discoverProvider.notifier);
      final book = await notifier.addToBookshelf(
        detail: _detail!,
        sourceDef: widget.sourceDef,
        chapters: _chapters,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('《${book.title}》已加入书架'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加入书架失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadDetail();
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final detail = _detail;
    if (detail == null) return const SizedBox.shrink();

    return CustomScrollView(
      slivers: [
        // 头部封面区域
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.8),
                    AppTheme.primaryDark,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 封面
                    _buildCover(detail.coverUrl),
                    const SizedBox(width: 16),
                    // 书籍信息
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            detail.author,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (detail.category != null &&
                                  detail.category!.isNotEmpty)
                                _buildTag(detail.category!),
                              if (detail.status != null &&
                                  detail.status!.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                _buildTag(detail.status!),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '来源: ${detail.sourceName}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 简介
        if (detail.intro.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '简介',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.intro,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 加入书架按钮
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAdding ? null : _addToBookshelf,
                icon: _isAdding
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_isAdding ? '加入中...' : '加入书架'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ),

        // 章节列表标题
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '章节目录 (${_chapters.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_chapters.isNotEmpty)
                  Text(
                    '最新: ${_chapters.last.title}',
                    style: const TextStyle(
                      color: AppTheme.textHint,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),

        // 章节列表
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= _chapters.length) return null;
              final chapter = _chapters[index];
              return ListTile(
                dense: true,
                title: Text(
                  chapter.title,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: chapter.isVip
                    ? const Text(
                        'VIP',
                        style: TextStyle(
                          color: AppTheme.accentColor,
                          fontSize: 11,
                        ),
                      )
                    : null,
              );
            },
            childCount: _chapters.length,
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildCover(String? coverUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 100,
        height: 140,
        child: coverUrl != null && coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.dividerColor,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.dividerColor,
                  child: const Icon(Icons.book, size: 40),
                ),
              )
            : Container(
                color: AppTheme.dividerColor,
                child: const Icon(Icons.book, size: 40),
              ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
