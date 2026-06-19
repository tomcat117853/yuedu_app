import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// 发现页面 - 在线书籍搜索和推荐
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 热门推荐
        _buildSectionTitle('热门推荐'),
        const SizedBox(height: 12),
        _buildRecommendCards(),
        const SizedBox(height: 24),

        // 最近更新
        _buildSectionTitle('最近更新'),
        const SizedBox(height: 12),
        _buildUpdateList(),
      ],
    );
  }

  /// 排行标签页
  Widget _buildRankTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('点击榜'),
        const SizedBox(height: 12),
        _buildRankList(),
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
          child: Center(
            child: Text(
              categories[index],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  /// 搜索标签页
  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索书名或作者',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _searchController.clear(),
              ),
            ),
            onSubmitted: (query) {
              // 执行搜索
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('热门搜索'),
          const SizedBox(height: 12),
          _buildHotSearchTags(),
        ],
      ),
    );
  }

  /// 构建分区标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 构建推荐卡片
  Widget _buildRecommendCards() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.book, size: 40, color: AppTheme.textHint),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '推荐书籍 ${index + 1}',
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
  Widget _buildUpdateList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text('更新书籍 ${index + 1}'),
          subtitle: Text('更新到第${100 - index}章'),
          trailing: const Text('最新', style: TextStyle(color: AppTheme.accentColor)),
        );
      },
    );
  }

  /// 构建排行列表
  Widget _buildRankList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: index < 3 ? AppTheme.accentColor : AppTheme.dividerColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: index < 3 ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          title: Text('排行书籍 ${index + 1}'),
          subtitle: Text('作者 ${index + 1}'),
          trailing: Text(
            '${(100 - index * 5)}.${index}万',
            style: const TextStyle(color: AppTheme.textHint, fontSize: 12),
          ),
        );
      },
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
          },
        );
      }).toList(),
    );
  }
}
