import 'package:flutter/material.dart';

import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

class PageTextView extends StatelessWidget {
  final String text;
  final LayoutConfig layoutConfig;
  final ReaderTheme theme;

  const PageTextView({
    super.key,
    required this.text,
    required this.layoutConfig,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.backgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: layoutConfig.margin,
        vertical: layoutConfig.margin * 0.5,
      ),
      child: Column(
        children: [
          // 章节标题
          if (chapterTitle.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: layoutConfig.margin,
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
            ),

          // 正文内容
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: paragraphs.map((paragraph) {
                  final trimmed = paragraph.trim();
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
                }).toList(),
              ),
            ),
          ),
        ),
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
