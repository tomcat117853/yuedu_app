import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/book_source.dart';
import '../../../domain/services/source_service.dart';

final sourcePageProvider = NotifierProvider<SourcePageProvider, SourcePageState>(
  () => throw UnimplementedError(),
);

class SourcePageProvider extends Notifier<SourcePageState> {
  late final SourceService _sourceService;

  @override
  SourcePageState build() {
    _sourceService = ref.read(sourceServiceProvider);
    return SourcePageState(
      sources: [],
      isLoading: false,
    );
  }

  Future<void> loadSources() async {
    state = state.copyWith(isLoading: true);
    try {
      final sources = await _sourceService.getAllSources();
      state = state.copyWith(
        sources: sources,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleSource(String sourceId, bool enabled) async {
    await _sourceService.toggleSource(sourceId, enabled);
    await loadSources();
  }

  Future<void> deleteSource(String sourceId) async {
    await _sourceService.deleteSource(sourceId);
    await loadSources();
  }

  Future<void> addSource() async {
    final newSource = BookSource(
      id: '',
      name: '新书源',
      url: '',
      enabled: true,
      orderIndex: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _sourceService.insertSource(newSource);
    await loadSources();
  }
}

class SourcePageState {
  final List<BookSource> sources;
  final bool isLoading;

  SourcePageState({
    required this.sources,
    required this.isLoading,
  });

  SourcePageState copyWith({
    List<BookSource>? sources,
    bool? isLoading,
  }) {
    return SourcePageState(
      sources: sources ?? this.sources,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}