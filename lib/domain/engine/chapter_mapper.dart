import '../models/chapter.dart';

class ChapterMapper {
  List<Chapter> _chapters = [];
  final Map<String, int> _titleToIndex = {};
  final Map<String, int> _idToIndex = {};

  int get totalChapters => _chapters.length;
  bool get isEmpty => _chapters.isEmpty;
  bool get isNotEmpty => _chapters.isNotEmpty;

  void setChapters(List<Chapter> chapters) { _chapters = List.from(chapters); _rebuildIndex(); }

  void _rebuildIndex() {
    _titleToIndex.clear(); _idToIndex.clear();
    for (int i = 0; i < _chapters.length; i++) { _titleToIndex[_chapters[i].title] = i; _idToIndex[_chapters[i].id] = i; }
  }

  Chapter? getChapterByIndex(int index) { if (index < 0 || index >= _chapters.length) return null; return _chapters[index]; }
  int? getIndexByTitle(String title) => _titleToIndex[title];
  int? getIndexById(String id) => _idToIndex[id];
  Chapter? getChapterById(String id) { final index = _idToIndex[id]; if (index == null) return null; return _chapters[index]; }
  List<String> getChapterTitles() => _chapters.map((c) => c.title).toList();
  List<Chapter> getChaptersInRange(int start, int end) { if (start < 0) start = 0; if (end > _chapters.length) end = _chapters.length; if (start >= end) return []; return _chapters.sublist(start, end); }
  List<Chapter> searchChapters(String query) { final lowerQuery = query.toLowerCase(); return _chapters.where((c) => c.title.toLowerCase().contains(lowerQuery)).toList(); }
  List<Chapter> getCachedChapters() => _chapters.where((c) => c.isCached).toList();
  List<Chapter> getUncachedChapters() => _chapters.where((c) => !c.isCached).toList();
  List<Chapter> getVipChapters() => _chapters.where((c) => c.isVip).toList();
  double calculateProgress(int currentChapterIndex) { if (_chapters.isEmpty) return 0.0; return ((currentChapterIndex + 1) / _chapters.length * 100).clamp(0.0, 100.0); }
  int? nextChapterIndex(int currentIndex) => currentIndex < _chapters.length - 1 ? currentIndex + 1 : null;
  int? previousChapterIndex(int currentIndex) => currentIndex > 0 ? currentIndex - 1 : null;
  void clear() { _chapters.clear(); _titleToIndex.clear(); _idToIndex.clear(); }
}