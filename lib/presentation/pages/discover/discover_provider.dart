import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/search_result.dart';
import '../../../domain/services/source_service.dart';

final discoverProvider = NotifierProvider<DiscoverProvider, DiscoverState>(
  () => throw UnimplementedError(),
);

class DiscoverProvider extends Notifier<DiscoverState> {
  late final SourceService _sourceService;

  @override
  DiscoverState build() {
    _sourceService = ref.read(sourceServiceProvider);
    return DiscoverState(
      searchResults: [],
      hotBooks: [],
      isLoading: false,
    );
  }

  Future<void> searchBooks(String keyword) async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _sourceService.searchBooks(keyword);
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadHotBooks() async {
    state = state.copyWith(isLoading: true);
    try {
      final results = await _sourceService.getHotBooks();
      state = state.copyWith(
        hotBooks: results,
        searchResults: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

class DiscoverState {
  final List<SearchResult> searchResults;
  final List<SearchResult> hotBooks;
  final bool isLoading;

  DiscoverState({
    required this.searchResults,
    required this.hotBooks,
    required this.isLoading,
  });

  DiscoverState copyWith({
    List<SearchResult>? searchResults,
    List<SearchResult>? hotBooks,
    bool? isLoading,
  }) {
    return DiscoverState(
      searchResults: searchResults ?? this.searchResults,
      hotBooks: hotBooks ?? this.hotBooks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}