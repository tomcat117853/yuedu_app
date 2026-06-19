import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/models/source_definition.dart';
import '../../../providers.dart';
import 'discover_provider.dart';
import 'book_detail_page.dart';

/// 发现页面 - 在线书籍搜索和推荐
class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    // 初始加载推荐
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoverProvider.notifier).loadRecommendations();
    });
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      ref.read(discoverProvider.notifier).loadRecommendations();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _executeSearch(String query) {
    if (query.trim().isEmpty) return;
    ref.read(discoverProvider.notifier).search(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoverProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '排行'),
            Tab(text: '分类'),
            Tab(text: '搜索'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendTab(),
          _buildRankTab(),
          _buildCategoryTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  /// 推荐标签页
  Widget _buildRecommendTab() {
    final state = ref.watch(discoverProvider);
    final recommendations = state.recommendations;

    if (state.isLoading && recommendations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recommendations.isEmpty) {
      final theme = Theme.of(context);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore_outlined,
                size: 80, color: theme.hintColor),
            const SizedBox(height: 16),
            Text('暂无推荐，请先添加书源',
                style: TextStyle(color: theme.hintColor)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(discoverProvider.notifier).loadRecommendations();
              },
              child: const Text('刷新'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('热门推荐'),
        const SizedBox(height: 12),
        _buildRecommendCards(recommendations.take(10).toList()),
        const SizedBox(height: 24),
        _buildSectionHeader('最近更新'),
        const SizedBox(height: 12),
        _buildUpdateList(recommendations.skip(5).take(10).toList()),
      ],
    );
  }

  /// 排行标签页
  Widget _buildRankTab() {
    final state = ref.watch(discoverProvider);
    final recommendations = state.recommendations;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('热度榜'),
        const SizedBox(height: 12),
        if (recommendations.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('暂无数据，请先添加书源',
                  style: TextStyle(color: Theme.of(context).hintColor)),
            ),
          )
        else
          _buildRankList(recommendations),
      ],
    );
  }

  /// 分类标签页
  Widget _buildCategoryTab() {
    final categories = [
      '玄幻', '武侠', '都市', '历史', '科幻',
      '游戏', '悬疑', '言情', '轻小说', '经典',
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Card(
          child: InkWell(
            onTap: () {
              _searchController.text = categories[index];
              _tabController.animateTo(3);
              _executeSearch(categories[index]);
            },
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                categories[index],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 搜索标签页
  Widget _buildSearchTab() {
    final state = ref.watch(discoverProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索书名或作者',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(discoverProvider.notifier).clearSearch();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: _executeSearch,
        ),
        const SizedBox(height: 16),
        if (state.isSearching)
          const Center(child: CircularProgressIndicator())
        else if (state.searchResults.isNotEmpty)
          _buildSearchResults(state)
        else if (state.error != null)
          Center(
            child: Text(state.error!,
                style: const TextStyle(color: Colors.red)),
          )
        else ...[
          _buildSectionHeader('热门搜索'),
          const SizedBox(height: 12),
          _buildHotSearchTags(),
        ],
      ],
    );
  }

  /// 搜索结果列表
  Widget _buildSearchResults(DiscoverState state) {
    return Column(
      children: state.searchResults
          .map((result) => _buildBookListItem(result))
          .toList(),
    );
  }

  Widget _buildBookListItem(AggregatedResult result) {
    return ListTile(
      leading: _buildSmallCover(result.coverUrl),
      title: Text(result.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${result.author} | ${result.sources.length}个书源',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        final sourceId = result.bestSourceId;
        final definitions = ref.read(sourceDefinitionsProvider);
        final sourceDef = definitions.firstWhere(
          (d) => d.id == sourceId,
          orElse: () => definitions.first,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPage(
              result: result.sources.first,
              sourceDef: sourceDef,
            ),
          ),
        );
      },
    );
  }

  /// 构建分区标题
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// 构建推荐卡片
  Widget _buildRecommendCards(List<dynamic> items) {
    return SizedBox(
      height: 180,
      child: items.isEmpty
          ? const Center(child: Text('暂无推荐'))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final title = item is Map ? item['title'] as String? ?? '' : (item.title as String? ?? '');
                final coverUrl = item is Map
                    ? item['coverUrl'] as String?
                    : (item.coverUrl as String?);
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: coverUrl != null && coverUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: coverUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorWidget: (_, __, ___) => Container(
                                    color: Theme.of(context).dividerColor,
                                    child: const Icon(Icons.book, size: 40),
                                  ),
                                )
                              : Container(
                                  color: Theme.of(context).dividerColor,
                                  child: const Center(
                                    child: Icon(Icons.book, size: 40),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  /// 构建更新列表
  Widget _buildUpdateList(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无数据'),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item is Map ? item['title'] as String? ?? '' : (item.title as String? ?? '');
        final author = item is Map ? item['author'] as String? ?? '' : (item.author as String? ?? '');
        return ListTile(
          leading: _buildSmallCover(
              item is Map ? item['coverUrl'] as String? : item.coverUrl as String?),
          title: Text(title),
          subtitle: Text(author),
        );
      },
    );
  }

  /// 构建排行列表
  Widget _buildRankList(List<dynamic> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length > 10 ? 10 : items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = items[index];
        final title = item is Map ? item['title'] as String? ?? '' : (item.title as String? ?? '');
        final author = item is Map ? item['author'] as String? ?? '' : (item.author as String? ?? '');
        return ListTile(
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: index < 3 ? Theme.of(context).colorScheme.secondary : Theme.of(context).dividerColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: index < 3 ? Colors.white : Theme.of(context).hintColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text(title),
          subtitle: Text(author),
        );
      },
    );
  }

  Widget _buildSmallCover(String? coverUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 50,
        height: 70,
        child: coverUrl != null && coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: Theme.of(context).dividerColor,
                  child: const Icon(Icons.book, size: 24),
                ),
              )
            : Container(
                color: Theme.of(context).dividerColor,
                child: const Icon(Icons.book, size: 24),
              ),
      ),
    );
  }

  /// 构建热门搜索标签
  Widget _buildHotSearchTags() {
    final tags = ['斗破苍穹', '凡人修仙传', '遮天', '完美世界', '诡秘之主'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return ActionChip(
          label: Text(tag),
          onPressed: () {
            _searchController.text = tag;
            _executeSearch(tag);
          },
        );
      }).toList(),
    );
  }
}
