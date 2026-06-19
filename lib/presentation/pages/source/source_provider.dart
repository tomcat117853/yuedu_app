import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/source_definition.dart';
import '../../../domain/services/source_importer.dart';
import '../../../providers.dart';

/// 书源管理页面状态
class SourcePageState {
  final List<SourceDefinition> sources;
  final bool isLoading;
  final bool isChecking;
  final String? error;

  SourcePageState({
    this.sources = const [],
    this.isLoading = false,
    this.isChecking = false,
    this.error,
  });

  SourcePageState copyWith({
    List<SourceDefinition>? sources,
    bool? isLoading,
    bool? isChecking,
    String? error,
  }) {
    return SourcePageState(
      sources: sources ?? this.sources,
      isLoading: isLoading ?? this.isLoading,
      isChecking: isChecking ?? this.isChecking,
      error: error,
    );
  }
}

/// 书源管理页面 Provider
class SourcePageNotifier extends StateNotifier<SourcePageState> {
  final Ref _ref;

  SourcePageNotifier(this._ref) : super(SourcePageState()) {
    _loadSources();
  }

  SourceImporter get _importer => _ref.read(sourceImporterProvider);

  /// 加载书源列表
  Future<void> _loadSources() async {
    state = state.copyWith(isLoading: true);
    try {
      final definitions = _ref.read(sourceDefinitionsProvider);
      state = state.copyWith(sources: definitions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 刷新
  Future<void> refresh() async {
    await _loadSources();
  }

  /// 添加书源
  void addSource(SourceDefinition source) {
    _ref.read(sourceDefinitionsProvider.notifier).addSource(source);
    state = state.copyWith(
      sources: _ref.read(sourceDefinitionsProvider),
    );
  }

  /// 删除书源
  void removeSource(String sourceId) {
    _ref.read(sourceDefinitionsProvider.notifier).removeSource(sourceId);
    state = state.copyWith(
      sources: _ref.read(sourceDefinitionsProvider),
    );
  }

  /// 切换书源启用状态
  void toggleSource(String sourceId, bool enabled) {
    final sources = _ref.read(sourceDefinitionsProvider);
    final target = sources.firstWhere(
      (s) => s.id == sourceId,
      orElse: () => throw StateError('Source not found'),
    );
    final updated = SourceDefinition(
      bookSourceName: target.bookSourceName,
      bookSourceUrl: target.bookSourceUrl,
      bookSourceGroup: target.bookSourceGroup,
      bookSourceType: target.bookSourceType,
      bookSourceComment: target.bookSourceComment,
      enabled: enabled,
      weight: target.weight,
      searchUrl: target.searchUrl,
      searchRule: target.searchRule,
      detailRule: target.detailRule,
      chapterListRule: target.chapterListRule,
      contentRule: target.contentRule,
      loginUrl: target.loginUrl,
      loginRule: target.loginRule,
    );
    _ref.read(sourceDefinitionsProvider.notifier).updateSource(updated);
    state = state.copyWith(
      sources: _ref.read(sourceDefinitionsProvider),
    );
  }

  /// 从 JSON 字符串导入书源
  int importFromJson(String jsonStr) {
    final imported = _importer.importFromJsonArray(jsonStr);
    if (imported.isEmpty) return 0;

    final existing = _ref.read(sourceDefinitionsProvider);
    final existingIds = existing.map((s) => s.id).toSet();
    final newSources = imported.where((s) => !existingIds.contains(s.id)).toList();

    for (final source in newSources) {
      _ref.read(sourceDefinitionsProvider.notifier).addSource(source);
    }

    state = state.copyWith(
      sources: _ref.read(sourceDefinitionsProvider),
    );
    return newSources.length;
  }

  /// 导出所有书源为 JSON
  String exportAll() {
    final sources = _ref.read(sourceDefinitionsProvider);
    return _importer.exportToJsonString(sources);
  }

  /// 导出书源到文件
  Future<String?> exportToFile() async {
    try {
      final sources = _ref.read(sourceDefinitionsProvider);
      if (sources.isEmpty) return null;
      return await _importer.exportToFile(sources);
    } catch (e) {
      debugPrint('[SourcePage] 导出失败: $e');
      return null;
    }
  }

  /// 检查所有书源可用性
  Future<void> checkAllSources() async {
    if (state.isChecking) return;
    state = state.copyWith(isChecking: true);

    final engine = _ref.read(sourceEngineProvider);
    final sources = _ref.read(sourceDefinitionsProvider);

    for (final source in sources) {
      try {
        final healthy = await engine.executeHealthCheck(source);
        if (!mounted) return;
        if (!healthy) {
          // 标记为禁用
          toggleSource(source.id, false);
        }
      } catch (e) {
        debugPrint('[SourcePage] 检查书源 ${source.bookSourceName} 失败: $e');
      }
    }

    if (mounted) {
      state = state.copyWith(isChecking: false);
    }
  }

  /// 通过 URL 添加书源（从 JSON 文本解析）
  bool addSourceFromJson(String jsonText) {
    final source = _importer.importFromJsonString(jsonText);
    if (source == null) return false;

    final existing = _ref.read(sourceDefinitionsProvider);
    if (existing.any((s) => s.id == source.id)) return false;

    addSource(source);
    return true;
  }
}

/// 书源页面 Provider
final sourcePageProvider =
    StateNotifierProvider<SourcePageNotifier, SourcePageState>((ref) {
  return SourcePageNotifier(ref);
});
