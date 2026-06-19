import '../models/chapter.dart';

/// 章节映射器 - 管理章节列表与索引的映射关系
class ChapterMapper {
  /// 章节列表
  List<Chapter> _chapters = [];

  /// 章节标题到索引的映射
  final Map<String, int> _titleToIndex = {};

  /// 章节ID到索引的映射
  final Map<String, int> _idToIndex = {};

  /// 总章节数
  int get totalChapters => _chapters.length;

  /// 是否为空
  bool get isEmpty => _chapters.isEmpty;

  /// 是否非空
  bool get isNotEmpty => _chapters.isNotEmpty;

  /// 设置章节列表
  void setChapters(List<Chapter> chapters) {
    _chapters = List.from(chapters);
    _rebuildIndex();
  }

  /// 重建索引映射
  void _rebuildIndex() {
    _titleToIndex.clear();
    _idToIndex.clear();
    for (int i = 0; i < _chapters.length; i++) {
      _titleToIndex[_chapters[i].title] = i;
      _idToIndex[_chapters[i].id] = i;
    }
  }

  /// 根据索引获取章节
  Chapter? getChapterByIndex(int index) {
    if (index < 0 || index >= _chapters.length) return null;
    return _chapters[index];
  }

  /// 根据标题获取章节索引
  int? getIndexByTitle(String title) {
    return _titleToIndex[title];
  }

  /// 根据ID获取章节索引
  int? getIndexById(String id) {
    return _idToIndex[id];
  }

  /// 根据ID获取章节
  Chapter? getChapterById(String id) {
    final index = _idToIndex[id];
    if (index == null) return null;
    return _chapters[index];
  }

  /// 获取章节标题列表
  List<String> getChapterTitles() {
    return _chapters.map((c) => c.title).toList();
  }

  /// 获取指定范围的章节
  List<Chapter> getChaptersInRange(int start, int end) {
    if (start < 0) start = 0;
    if (end > _chapters.length) end = _chapters.length;
    if (start >= end) return [];
    return _chapters.sublist(start, end);
  }

  /// 搜索章节标题
  List<Chapter> searchChapters(String query) {
    final lowerQuery = query.toLowerCase();
    return _chapters
        .where((c) => c.title.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 获取已缓存的章节列表
  List<Chapter> getCachedChapters() {
    return _chapters.where((c) => c.isCached).toList();
  }

  /// 获取未缓存的章节列表
  List<Chapter> getUncachedChapters() {
    return _chapters.where((c) => !c.isCached).toList();
  }

  /// 获取VIP章节列表
  List<Chapter> getVipChapters() {
    return _chapters.where((c) => c.isVip).toList();
  }

  /// 计算阅读进度百分比
  double calculateProgress(int currentChapterIndex) {
    if (_chapters.isEmpty) return 0.0;
    return ((currentChapterIndex + 1) / _chapters.length * 100).clamp(0.0, 100.0);
  }

  /// 获取下一章索引
  int? nextChapterIndex(int currentIndex) {
    if (currentIndex < _chapters.length - 1) {
      return currentIndex + 1;
    }
    return null;
  }

  /// 获取上一章索引
  int? previousChapterIndex(int currentIndex) {
    if (currentIndex > 0) {
      return currentIndex - 1;
    }
    return null;
  }

  /// 清空
  void clear() {
    _chapters.clear();
    _titleToIndex.clear();
    _idToIndex.clear();
  }
}
