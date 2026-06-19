import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'reader_provider.dart';
import 'widgets/page_text_view.dart';
import 'widgets/scroll_text_view.dart';
import 'widgets/reader_menu.dart';
import 'widgets/reader_settings.dart';
import 'widgets/chapter_list_sheet.dart';

/// 阅读器页面 - 全屏沉浸式阅读
class ReaderPage extends ConsumerStatefulWidget {
  final String bookId;

  const ReaderPage({super.key, required this.bookId});

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _enterImmersiveMode();
  }

  @override
  void dispose() {
    _exitImmersiveMode();
    _focusNode.dispose();
    super.dispose();
  }

  /// 进入沉浸式模式
  void _enterImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// 退出沉浸式模式
  void _exitImmersiveMode() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// 处理点击事件
  void _handleTap(TapDownDetails details, ReaderState state) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final tapX = details.localPosition.dx;
    final tapY = details.localPosition.dy;

    // 中间区域点击 - 呼出/隐藏菜单
    final isCenterArea = tapX > screenWidth * 0.3 && tapX < screenWidth * 0.7;
    if (isCenterArea) {
      ref.read(readerProvider(widget.bookId).notifier).toggleMenu();
      return;
    }

    // 左侧1/3 - 上一页
    if (tapX < screenWidth * 0.3) {
      ref.read(readerProvider(widget.bookId).notifier).previousPage();
      return;
    }

    // 右侧1/3 - 下一页
    if (tapX > screenWidth * 0.7) {
      ref.read(readerProvider(widget.bookId).notifier).nextPage();
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerProvider(widget.bookId));

    return Scaffold(
      backgroundColor: state.readerTheme.backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // 阅读内容区域
            GestureDetector(
              onTapDown: (details) => _handleTap(details, state),
              child: state.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: state.readerTheme.textColor.withValues(alpha: 0.5),
                      ),
                    )
                  : state.readMode == 0
                      ? PageTextView(
                          text: state.currentPageText,
                          theme: state.readerTheme,
                          layoutConfig: state.layoutConfig,
                          currentPage: state.currentPageIndex + 1,
                          totalPages: state.totalPages,
                          chapterTitle: state.chapters.isNotEmpty
                              ? state.chapters[state.currentChapterIndex].title
                              : '',
                        )
                      : ScrollTextView(
                          text: state.currentPageText,
                          theme: state.readerTheme,
                          layoutConfig: state.layoutConfig,
                          chapterTitle: state.chapters.isNotEmpty
                              ? state.chapters[state.currentChapterIndex].title
                              : '',
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
                  ref.read(readerProvider(widget.bookId).notifier).toggleMenu();
                  context.pop();
                },
                onToggleMenu: () {
                  ref
                      .read(readerProvider(widget.bookId).notifier)
                      .toggleMenu();
                },
                onShowSettings: () => _showSettingsSheet(state),
                onShowChapterList: () => _showChapterList(state),
                onPreviousChapter: () {
                  ref
                      .read(readerProvider(widget.bookId).notifier)
                      .previousChapter();
                },
                onNextChapter: () {
                  ref
                      .read(readerProvider(widget.bookId).notifier)
                      .nextChapter();
                },
                onToggleTheme: () {
                  ref
                      .read(readerProvider(widget.bookId).notifier)
                      .cycleTheme();
                },
                onToggleMode: () {
                  ref
                      .read(readerProvider(widget.bookId).notifier)
                      .toggleReadMode();
                },
              ),

            // 设置面板
            if (state.showMenu)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ReaderSettings(
                  theme: state.readerTheme,
                  layoutConfig: state.layoutConfig,
                  onIncreaseFontSize: () {
                    ref
                        .read(readerProvider(widget.bookId).notifier)
                        .increaseFontSize();
                  },
                  onDecreaseFontSize: () {
                    ref
                        .read(readerProvider(widget.bookId).notifier)
                        .decreaseFontSize();
                  },
                  onIncreaseLineHeight: () {
                    ref
                        .read(readerProvider(widget.bookId).notifier)
                        .increaseLineHeight();
                  },
                  onDecreaseLineHeight: () {
                    ref
                        .read(readerProvider(widget.bookId).notifier)
                        .decreaseLineHeight();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 显示设置面板
  void _showSettingsSheet(ReaderState state) {
    // 设置面板已集成在底部
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
          ref.read(readerProvider(widget.bookId).notifier).jumpToChapter(index);
        },
      ),
    );
  }
}
