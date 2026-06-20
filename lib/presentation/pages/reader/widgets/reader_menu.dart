import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../../domain/models/book.dart';
import '../../../../domain/models/reader_theme.dart';

/// 阅读器菜单 - 顶部和底部工具栏 (Apple-style frosted glass)
class ReaderMenu extends StatelessWidget {
  final Book? book;
  final int currentChapter;
  final int totalChapters;
  final int currentPage;
  final int totalPages;
  final ReaderTheme readerTheme;
  final VoidCallback onBack;
  final VoidCallback onToggleMenu;
  final VoidCallback onShowSettings;
  final VoidCallback onShowChapterList;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleMode;
  final VoidCallback onSwitchSource;
  final void Function(double value)? onPageSliderChanged;
  final void Function(double value)? onPageSliderChangeEnd;

  const ReaderMenu({
    super.key,
    required this.book,
    required this.currentChapter,
    required this.totalChapters,
    required this.currentPage,
    required this.totalPages,
    required this.readerTheme,
    required this.onBack,
    required this.onToggleMenu,
    required this.onShowSettings,
    required this.onShowChapterList,
    required this.onPreviousChapter,
    required this.onNextChapter,
    required this.onToggleTheme,
    required this.onToggleMode,
    required this.onSwitchSource,
    this.onPageSliderChanged,
    this.onPageSliderChangeEnd,
  });

  /// Whether the current reader theme is considered "dark"
  bool get _isDarkTheme {
    // Use luminance to decide — dark background means dark theme
    return readerTheme.backgroundColor.computeLuminance() < 0.4;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部工具栏 - frosted glass
        _buildTopToolbar(),

        const Spacer(),

        // 底部进度栏 - frosted glass
        _buildBottomToolbar(),
      ],
    );
  }

  /// 顶部工具栏 - 毛玻璃效果
  Widget _buildTopToolbar() {
    final isDark = _isDarkTheme;
    final bgColor = isDark
        ? Colors.black.withOpacity(0.70)
        : Colors.white.withOpacity(0.70);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: bgColor,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          book?.title ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        if (totalChapters > 0)
                          Text(
                            '${currentChapter + 1}/$totalChapters 章',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    onPressed: onSwitchSource,
                    tooltip: '切换书源',
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: onShowSettings,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 底部工具栏 - 毛玻璃效果
  Widget _buildBottomToolbar() {
    final isDark = _isDarkTheme;
    final bgColor = isDark
        ? Colors.black.withOpacity(0.80)
        : Colors.white.withOpacity(0.80);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          color: bgColor,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 进度条
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Text(
                        '$currentPage',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.24),
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            trackHeight: 2,
                            overlayColor: Colors.white.withOpacity(0.12),
                          ),
                          child: Slider(
                            value: totalPages > 1
                                ? (currentPage - 1) / (totalPages - 1)
                                : 0,
                            onChanged: (value) {
                              onPageSliderChanged?.call(value);
                            },
                            onChangeEnd: (value) {
                              onPageSliderChangeEnd?.call(value);
                            },
                            min: 0,
                            max: 1,
                          ),
                        ),
                      ),
                      Text(
                        '$totalPages',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // 底部操作栏
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomButton(
                        icon: Icons.list,
                        label: '目录',
                        onTap: onShowChapterList,
                      ),
                      _buildBottomButton(
                        icon: Icons.brightness_medium,
                        label: '主题',
                        onTap: onToggleTheme,
                      ),
                      _buildBottomButton(
                        icon: Icons.swap_horiz,
                        label: '翻/滚',
                        onTap: onToggleMode,
                      ),
                      _buildBottomButton(
                        icon: Icons.keyboard_arrow_left,
                        label: '上一章',
                        onTap: onPreviousChapter,
                      ),
                      _buildBottomButton(
                        icon: Icons.keyboard_arrow_right,
                        label: '下一章',
                        onTap: onNextChapter,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建底部按钮
  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
