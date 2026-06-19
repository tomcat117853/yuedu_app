import 'package:flutter/material.dart';
import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

/// 滚动模式文本视图
class ScrollTextView extends StatelessWidget {
  final String text;
  final ReaderTheme theme;
  final LayoutConfig layoutConfig;
  final String chapterTitle;

  const ScrollTextView({
    super.key,
    required this.text,
    required this.theme,
    required this.layoutConfig,
    required this.chapterTitle,
  });

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split(RegExp(r'\n+'));

    return Container(
      color: theme.backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: layoutConfig.margin,
        vertical: layoutConfig.margin * 0.5,
      ),
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: layoutConfig.margin,
          bottom: layoutConfig.margin * 2,
        ),
        itemCount: paragraphs.length + 1,
        itemBuilder: (context, index) {
          // 章节标题
          if (index == 0 && chapterTitle.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: layoutConfig.paragraphGap,
              ),
              child: Text(
                chapterTitle,
                style: TextStyle(
                  fontSize: layoutConfig.fontSize + 4,
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  height: layoutConfig.lineHeight,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final paragraphIndex = chapterTitle.isNotEmpty ? index - 1 : index;
          if (paragraphIndex < 0 || paragraphIndex >= paragraphs.length) {
            return const SizedBox.shrink();
          }

          final trimmed = paragraphs[paragraphIndex].trim();
          if (trimmed.isEmpty) {
            return SizedBox(height: layoutConfig.paragraphGap);
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: layoutConfig.paragraphGap * 0.5,
            ),
            child: Text(
              '${_buildIndent()}$trimmed',
              style: TextStyle(
                fontSize: layoutConfig.fontSize,
                color: theme.textColor,
                height: layoutConfig.lineHeight,
                letterSpacing: layoutConfig.letterSpacing,
                fontFamily: layoutConfig.fontFamily,
                fontWeight: layoutConfig.fontWeight,
              ),
              textAlign: TextAlign.justify,
            ),
          );
        },
      ),
    );
  }

  /// 构建首行缩进
  String _buildIndent() {
    return '\u3000' * layoutConfig.indentChars;
  }
}
