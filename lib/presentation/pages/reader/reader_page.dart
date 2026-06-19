import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../bookshelf/bookshelf_page.dart';
import 'reader_provider.dart';
import 'widgets/page_text_view.dart';
import 'widgets/reader_settings.dart';
import 'widgets/reader_toc.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String bookId;

  const ReaderPage({super.key, required this.bookId});

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  bool _showSettings = false;
  bool _showToc = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readerProvider.notifier).loadBook(widget.bookId);
    });
  }

  void _toggleSettings() {
    setState(() => _showSettings = !_showSettings);
  }

  void _toggleToc() {
    setState(() => _showToc = !_showToc);
  }

  void _onThemeChanged(dynamic theme) {
    ref.read(readerProvider.notifier).setTheme(theme);
    setState(() => _showSettings = false);
  }

  void _onConfigChanged(dynamic config) {
    ref.read(readerProvider.notifier).updateLayoutConfig(config);
  }

  void _onChapterSelected(int index) {
    ref.read(readerProvider.notifier).jumpToChapter(index);
    setState(() => _showToc = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerProvider);

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GestureDetector(
                  onTap: _toggleSettings,
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      ref.read(readerProvider.notifier).prevPage();
                    } else if (details.primaryVelocity! < 0) {
                      ref.read(readerProvider.notifier).nextPage();
                    }
                  },
                  child: PageTextView(
                    text: state.currentPageText,
                    layoutConfig: state.layoutConfig,
                    theme: state.theme,
                  ),
                ),
                if (_showSettings)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ReaderSettings(
                      config: state.layoutConfig,
                      theme: state.theme,
                      onConfigChanged: _onConfigChanged,
                      onThemeChanged: _onThemeChanged,
                    ),
                  ),
                if (_showToc)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: ReaderToc(
                      chapters: state.chapters,
                      currentIndex: state.currentChapterIndex,
                      onChapterSelected: _onChapterSelected,
                    ),
                  ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.list),
                        color: state.theme.textColor,
                        onPressed: _toggleToc,
                      ),
                      Text(
                        '${state.currentPage + 1} / ${state.totalPages}',
                        style: TextStyle(color: state.theme.textColor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        color: state.theme.textColor,
                        onPressed: _toggleSettings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}