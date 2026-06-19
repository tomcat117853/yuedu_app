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
}