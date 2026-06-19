import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers.dart';
import '../../../domain/models/book_source.dart';
import '../../../domain/models/chapter.dart';
import '../../../domain/models/reader_theme.dart';
import '../../../domain/models/layout_config.dart';
import '../../../domain/models/reader_state.dart';
import 'reader_provider.dart';
import 'widgets/page_text_view.dart';
import 'widgets/scroll_text_view.dart';
import 'widgets/reader_settings.dart';
import 'widgets/chapter_list_sheet.dart';
import 'widgets/reader_menu.dart';
import 'widgets/reader_toc.dart';
import 'source_switch_sheet.dart';

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

  void _onThemeChanged(ReaderTheme theme) {
    ref.read(readerProvider.notifier).setTheme(theme);
    setState(() => _showSettings = false);
  }

  void _onConfigChanged(LayoutConfig config) {
    ref.read(readerProvider.notifier).updateLayoutConfig(config);
  }

  void _onChapterSelected(int index) {
    ref.read(readerProvider.notifier).jumpToChapter(index);
    setState(() => _showToc = false);
  }

  /// 处理点击事件
  void _handleTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.localPosition.dx;

    // 左侧区域：上一页
    if (tapX < screenWidth * 0.3) {
      ref.read(readerProvider.notifier).previousPage();
    }
    // 右侧区域：下一页
    else if (tapX > screenWidth * 0.7) {
      ref.read(readerProvider.notifier).nextPage();
    }
    // 中间区域：显示/隐藏菜单
    else {
      ref.read(readerProvider.notifier).toggleMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerProvider);

    return Scaffold(
      backgroundColor: state.readerTheme.backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // 阅读内容区域
            GestureDetector(
              onTapDown: (details) => _handleTap(details),
              child: state.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: state.readerTheme.textColor.withOpacity(0.5),
                      ),
                    )
                  : state.readMode == 0
                      ? PageTextView(
                          text: state.currentPageText,
                          theme: state.readerTheme,
                          layoutConfig: state.layoutConfig,
                        )
                      : ScrollTextView(
                          text: state.currentPageText,
                          theme: state.readerTheme,
                          layoutConfig: state.layoutConfig,
                        ),
            ),

            // 阅读菜单
            if (state.showMenu)
              ReaderMenu(
                book: state.book,
                currentChapter: state.currentChapterIndex,
                totalChapters: state.chapters.length,
                currentPage: state.currentPageIndex + 1,
                totalPages: state.totalPages,
                readerTheme: state.readerTheme,
                onBack: () {
                  ref.read(readerProvider.notifier).toggleMenu();
                  context.pop();
                },
                onToggleMenu: () {
                  ref.read(readerProvider.notifier).toggleMenu();
                },
                onShowSettings: () {},
                onShowChapterList: () => _showChapterList(state),
                onPreviousChapter: () {
                  ref.read(readerProvider.notifier).previousChapter();
                },
                onNextChapter: () {
                  ref.read(readerProvider.notifier).nextChapter();
                },
                onToggleTheme: () {
                  ref.read(readerProvider.notifier).cycleTheme();
                },
                onToggleMode: () {
                  ref.read(readerProvider.notifier).toggleReadMode();
                },
                onSwitchSource: () => _showSourceSwitch(state),
                onPageSliderChanged: (value) {
                  if (state.totalPages > 1) {
                    final pageIndex = (value * (state.totalPages - 1)).round();
                    ref.read(readerProvider.notifier).jumpToPage(pageIndex);
                  }
                },
                onPageSliderChangeEnd: (value) {},
              ),

            // 设置面板
            if (_showSettings)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width * 0.7,
                child: ReaderSettings(
                  theme: state.readerTheme,
                  layoutConfig: state.layoutConfig,
                  onIncreaseFontSize: () {
                    ref.read(readerProvider.notifier).increaseFontSize();
                  },
                  onDecreaseFontSize: () {
                    ref.read(readerProvider.notifier).decreaseFontSize();
                  },
                  onIncreaseLineHeight: () {
                    ref.read(readerProvider.notifier).increaseLineHeight();
                  },
                  onDecreaseLineHeight: () {
                    ref.read(readerProvider.notifier).decreaseLineHeight();
                  },
                  onParagraphSpacingChanged: (value) {
                    final newConfig = state.layoutConfig.copyWith(
                      paragraphSpacing: value,
                    );
                    ref.read(readerProvider.notifier).updateLayoutConfig(newConfig);
                  },
                  onMarginChanged: (value) {
                    // 将double值转换为PagePadding枚举
                    PagePadding newPadding;
                    if (value <= 18.0) {
                      newPadding = PagePadding.narrow;
                    } else if (value <= 30.0) {
                      newPadding = PagePadding.normal;
                    } else {
                      newPadding = PagePadding.wide;
                    }
                    final newConfig = state.layoutConfig.copyWith(
                      padding: newPadding,
                    );
                    ref.read(readerProvider.notifier).updateLayoutConfig(newConfig);
                  },
                  onLetterSpacingChanged: (value) {
                    // 将double值转换为LetterSpacing枚举
                    LetterSpacing newSpacing;
                    if (value < -0.25) {
                      newSpacing = LetterSpacing.tight;
                    } else if (value > 0.5) {
                      newSpacing = LetterSpacing.loose;
                    } else {
                      newSpacing = LetterSpacing.normal;
                    }
                    final newConfig = state.layoutConfig.copyWith(
                      letterSpacing: newSpacing,
                    );
                    ref.read(readerProvider.notifier).updateLayoutConfig(newConfig);
                  },
                  onThemeChanged: (newTheme) {
                    ref.read(readerProvider.notifier).setTheme(newTheme);
                  },
                ),
              ),

            // 目录面板
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

            // 底部控制栏
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.list),
                    color: state.readerTheme.textColor,
                    onPressed: _toggleToc,
                  ),
                  Text(
                    '${state.currentPageIndex + 1} / ${state.totalPages}',
                    style: TextStyle(color: state.readerTheme.textColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: state.readerTheme.textColor,
                    onPressed: _toggleSettings,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示书源切换弹窗
  void _showSourceSwitch(ReaderState state) {
    // 获取当前书源列表
    final sourceService = ref.read(sourceServiceProvider);
    sourceService.getSourcesByBookId(widget.bookId).then((sources) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SourceSwitchSheet(
          book: state.book,
          currentSources: sources,
          currentChapterIndex: state.currentChapterIndex,
          onSwitch: (newSource, chapters) {
            _handleSourceSwitch(state, newSource, chapters);
          },
        ),
      );
    });
  }

  /// 处理书源切换
  void _handleSourceSwitch(
    ReaderState state,
    BookSource newSource,
    List<Chapter> newChapters,
  ) {
    if (newChapters.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已切换到 ${newSource.sourceName}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 显示章节列表
  void _showChapterList(ReaderState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChapterListSheet(
        chapters: state.chapters,
        currentChapterIndex: state.currentChapterIndex,
        theme: state.readerTheme,
        onChapterTap: (index) {
          Navigator.pop(context);
          ref.read(readerProvider.notifier).jumpToChapter(index);
        },
      ),
    );
  }
}