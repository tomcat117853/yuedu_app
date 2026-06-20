import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/design_tokens.dart';
import '../../../providers.dart';
import '../../widgets/common_widgets.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('发现'),
        scrolledUnderElevation: 0.5,
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
      return EmptyStateWidget(
        icon: Icons.explore_outlined,
        title: '暂无推荐',
        subtitle: '请先添加书源后刷新',
        actionLabel: '刷新',
        onAction: () {
          ref.read(discoverProvider.notifier).loadRecommendations();
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        _buildSectionHeader('热门推荐'),
        const SizedBox(height: AppSpacing.md),
        _buildRecommendCards(recommendations.take(10).toList()),
        const SizedBox(height: AppSpacing.xl),
        _buildSectionHeader('最近更新'),
        const SizedBox(height: AppSpacing.md),
        _buildUpdateList(recommendations.skip(5).take(10).toList()),
      ],
    );
  }

  /// 排行标签页
  Widget _buildRankTab() {
    final state = ref.watch(discoverProvider);
    final recommendations = state.recommendations;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        _buildSectionHeader('热度榜'),
        const SizedBox(height: AppSpacing.md),
        if (recommendations.isEmpty)
          const EmptyStateWidget(
            icon: Icons.leaderboard_outlined,
            title: '暂无数据',
            subtitle: '请先添加书源',
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
    final categoryColors = [
      AppColors.systemPurple,
      AppColors.systemOrange,
      AppColors.systemBlue,
      AppColors.systemIndigo,
      AppColors.systemTeal,
      AppColors.systemGreen,
      AppColors.systemPink,
      AppColors.systemRed,
      AppColors.systemBlue,
      AppColors.systemOrange,
    ];
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final color = categoryColors[index % categoryColors.length];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadow.card(context),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _searchController.text = categories[index];
                _tabController.animateTo(3);
                _executeSearch(categories[index]);
              },
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: AppFontWeight.medium,
                    color: color,
                  ),
                ),
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
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        _buildIOSSearchBar(),
        const SizedBox(height: AppSpacing.base),
        if (state.isSearching)
          const Center(child: CircularProgressIndicator())
        else if (state.searchResults.isNotEmpty)
          _buildSearchResults(state)
        else if (state.error != null)
          EmptyStateWidget(
            icon: Icons.error_outline,
            title: state.error!,
          )
        else ...[
          _buildSectionHeader('热门搜索'),
          const SizedBox(height: AppSpacing.md),
          _buildHotSearchTags(),
        ],
      ],
    );
  }

  /// iOS 风格搜索栏
  Widget _buildIOSSearchBar() {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索书名或作者',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8, right: 4),
            child: SizedBox(
              width: 16,
              height: 16,
              child: Icon(Icons.search, size: 16, color: AppColors.gray5),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 28,
            minHeight: 16,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      ref.read(discoverProvider.notifier).clearSearch();
                      setState(() {});
                    },
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Icon(
                        Icons.cancel,
                        size: 16,
                        color: AppColors.gray5,
                      ),
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 16,
          ),
          filled: true,
          fillColor: AppColors.gray5.withOpacity(0.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.input),
            borderSide: const BorderSide(
              color: AppColors.systemBlue,
              width: 1,
            ),
          ),
        ),
        style: const TextStyle(fontSize: AppFontSize.body),
        onChanged: (_) => setState(() {}),
        onSubmitted: _executeSearch,
      ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadow.card(context),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.card),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _buildSearchCover(result.coverUrl),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          result.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: AppFontWeight.semibold,
                            color: AppColors.gray9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${result.author} \u00B7 ${result.sources.length}个书源',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray6,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.gray4,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 搜索结果封面
  Widget _buildSearchCover(String? coverUrl) {
    return Container(
      width: 50,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.button),
        boxShadow: AppShadow.cover(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: coverUrl != null && coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.gray2,
                  child: const Icon(Icons.book, size: 24, color: AppColors.gray5),
                ),
              )
            : Container(
                color: AppColors.gray2,
                child: const Icon(Icons.book, size: 24, color: AppColors.gray5),
              ),
      ),
    );
  }

  /// 构建分区标题 - iOS titleLarge 风格
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: AppFontWeight.bold,
            ),
      ),
    );
  }

  /// 构建推荐卡片
  Widget _buildRecommendCards(List<dynamic> items) {
    return SizedBox(
      height: 200,
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
                  margin: const EdgeInsets.only(right: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            boxShadow: AppShadow.cover(context),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: coverUrl != null && coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: coverUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.gray2,
                                      child: const Icon(Icons.book, size: 40, color: AppColors.gray5),
                                    ),
                                  )
                                : Container(
                                    color: AppColors.gray2,
                                    child: const Center(
                                      child: Icon(Icons.book, size: 40, color: AppColors.gray5),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: AppFontWeight.medium,
                        ),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppGroupedBackground.groupBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 56,
          color: isDark ? AppColors.darkGray3 : AppColors.gray2,
        ),
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
      ),
    );
  }

  /// 构建排行列表
  Widget _buildRankList(List<dynamic> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppGroupedBackground.groupBackground(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length > 10 ? 10 : items.length,
        separatorBuilder: (_, __) => Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 56,
          color: isDark ? AppColors.darkGray3 : AppColors.gray2,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final title = item is Map ? item['title'] as String? ?? '' : (item.title as String? ?? '');
          final author = item is Map ? item['author'] as String? ?? '' : (item.author as String? ?? '');
          return ListTile(
            leading: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: index < 3
                    ? Theme.of(context).colorScheme.secondary
                    : (isDark ? AppColors.darkGray4 : AppColors.gray3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: index < 3 ? Colors.white : AppColors.gray6,
                    fontWeight: AppFontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: AppFontWeight.medium,
              ),
            ),
            subtitle: Text(author),
          );
        },
      ),
    );
  }

  Widget _buildSmallCover(String? coverUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: SizedBox(
        width: 50,
        height: 70,
        child: coverUrl != null && coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.gray2,
                  child: const Icon(Icons.book, size: 24, color: AppColors.gray5),
                ),
              )
            : Container(
                color: AppColors.gray2,
                child: const Icon(Icons.book, size: 24, color: AppColors.gray5),
              ),
      ),
    );
  }

  /// 构建热门搜索标签 - iOS 风格圆角药丸
  Widget _buildHotSearchTags() {
    final tags = ['斗破苍穹', '凡人修仙传', '遮天', '完美世界', '诡秘之主'];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: tags.map((tag) {
        return ActionChip(
          label: Text(
            tag,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: AppFontWeight.regular,
            ),
          ),
          backgroundColor: AppGroupedBackground.groupBackground(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          onPressed: () {
            _searchController.text = tag;
            _executeSearch(tag);
          },
        );
      }).toList(),
    );
  }
}
