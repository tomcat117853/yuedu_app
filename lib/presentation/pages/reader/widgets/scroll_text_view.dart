import 'package:flutter/material.dart';

import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

class ScrollTextView extends StatelessWidget {
  final String text;
  final LayoutConfig layoutConfig;
  final ReaderTheme theme;

  const ScrollTextView({
    super.key,
    required this.text,
    required this.layoutConfig,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      padding: EdgeInsets.all(layoutConfig.pagePadding.toDouble()),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: TextStyle(
            fontSize: layoutConfig.fontSize.toDouble(),
            fontWeight: _intToFontWeight(layoutConfig.fontWeight),
            color: theme.textColor,
            height: layoutConfig.lineHeight,
            letterSpacing: layoutConfig.letterSpacing,
          ),
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
                fontWeight: _intToFontWeight(layoutConfig.fontWeight),
              ),
              textAlign: TextAlign.justify,
            ),
          );
        },
      ),
    );
  }

  static FontWeight _intToFontWeight(int index) {
    switch (index) {
      case 1:
        return FontWeight.bold;
      case 2:
        return FontWeight.w100;
      case 3:
        return FontWeight.w200;
      case 4:
        return FontWeight.w300;
      case 5:
        return FontWeight.w400;
      case 6:
        return FontWeight.w500;
      case 7:
        return FontWeight.w600;
      case 8:
        return FontWeight.w700;
      case 9:
        return FontWeight.w800;
      default:
        return FontWeight.normal;
    }
  }

  /// 将 int 转换为 FontWeight
  static FontWeight _intToFontWeight(int index) {
    switch (index) {
      case 1: return FontWeight.bold;
      case 2: return FontWeight.w100;
      case 3: return FontWeight.w200;
      case 4: return FontWeight.w300;
      case 5: return FontWeight.w400;
      case 6: return FontWeight.w500;
      case 7: return FontWeight.w600;
      case 8: return FontWeight.w700;
      case 9: return FontWeight.w800;
      default: return FontWeight.normal;
    }
  }
}
