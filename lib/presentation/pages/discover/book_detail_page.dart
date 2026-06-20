import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/models/book_source_protocol.dart';
import '../../../domain/models/search_result.dart';
import '../../../domain/models/source_definition.dart';
import 'discover_provider.dart';

/// 书籍详情页 - Apple App Store style
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
  bool _isDescriptionExpanded = false;
  bool _isChapterReversed = false;

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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(context)
              : _buildContent(context, colorScheme),
    );
  }

  Widget _buildError(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: colorScheme.onSurfaceVariant)),
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

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    final detail = _detail;
    if (detail == null) return const SizedBox.shrink();

    const systemBlue = Color(0xFF007AFF);
    const systemIndigo = Color(0xFF5856D6);

    return CustomScrollView(
      slivers: [
        // 头部区域 - clean SliverAppBar with cover background
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withOpacity(0.7),
                    colorScheme.primary.withOpacity(0.9),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 封面 - 120x160 with borderRadius 12 and shadow
                      _buildCover(detail.coverUrl, colorScheme),
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              detail.author,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (detail.category != null &&
                                    detail.category!.isNotEmpty)
                                  _buildTag(detail.category!, systemIndigo),
                                if (detail.status != null &&
                                    detail.status!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  _buildTag(detail.status!, systemIndigo),
                                ],
                              ],
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
        ),

        // Action buttons row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isAdding ? null : _addToBookshelf,
                    style: FilledButton.styleFrom(
                      backgroundColor: systemBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: _isAdding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '开始阅读',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _isAdding ? null : _addToBookshelf,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(
                      _isAdding ? '加入中...' : '加入书架',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 简介 - iOS grouped card style
        if (detail.intro.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '简介',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedCrossFade(
                      firstChild: Text(
                        detail.intro,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 15,
                          height: 1.6,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      secondChild: Text(
                        detail.intro,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      crossFadeState: _isDescriptionExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                    if (detail.intro.length > 100)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _isDescriptionExpanded ? '收起' : '展开',
                            style: const TextStyle(
                              color: systemBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

        // 元数据信息 - iOS grouped card style
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMetaRow(
                    '字数',
                    detail.wordCount ?? '未知',
                    colorScheme,
                  ),
                  if (detail.status != null && detail.status!.isNotEmpty) ...[
                    _buildMetaDivider(),
                    _buildMetaRow('状态', detail.status!, colorScheme),
                  ],
                  if (detail.lastChapter != null &&
                      detail.lastChapter!.isNotEmpty) ...[
                    _buildMetaDivider(),
                    _buildMetaRow(
                      '最新',
                      detail.lastChapter!,
                      colorScheme,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // 章节目录 header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '目录',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_chapters.length} 章',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isChapterReversed = !_isChapterReversed;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: systemBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isChapterReversed ? '倒序' : '正序',
                          style: const TextStyle(
                            color: systemBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // 章节列表 - iOS list style
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: List.generate(
                  _chapters.length > 20 ? 20 : _chapters.length,
                  (index) {
                    final actualIndex = _isChapterReversed
                        ? _chapters.length - 1 - index
                        : index;
                    if (actualIndex < 0 || actualIndex >= _chapters.length) {
                      return const SizedBox.shrink();
                    }
                    final chapter = _chapters[actualIndex];
                    return Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 0,
                          ),
                          title: Text(
                            chapter.title,
                            style: const TextStyle(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: chapter.isVip
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: systemIndigo.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'VIP',
                                    style: TextStyle(
                                      color: systemIndigo,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        if (index < (_chapters.length > 20 ? 20 : _chapters.length) - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Container(
                              height: 0.5,
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // Show more chapters hint
        if (_chapters.length > 20)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Center(
                child: Text(
                  '还有 ${_chapters.length - 20} 章...',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),

        // Source section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: systemIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.source_outlined,
                      size: 18,
                      color: systemIndigo,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '当前来源',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _detail?.sourceName ?? widget.sourceDef.bookSourceName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      // Source switching logic would go here
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '换源',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _buildCover(String? coverUrl, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 120,
          height: 160,
          child: coverUrl != null && coverUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: coverUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: colorScheme.outlineVariant,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: colorScheme.outlineVariant,
                    child: const Icon(Icons.book, size: 48),
                  ),
                )
              : Container(
                  color: colorScheme.outlineVariant,
                  child: const Icon(Icons.book, size: 48),
                ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color tagColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMetaRow(
    String label,
    String value,
    ColorScheme colorScheme, {
    int? maxLines,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaDivider() {
    return Container(
      height: 0.5,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}
