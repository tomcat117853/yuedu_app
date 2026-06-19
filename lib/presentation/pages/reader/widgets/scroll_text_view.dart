import 'package:flutter/material.dart';
import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

/// 滚动文本阅读组件
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
      padding: EdgeInsets.all(layoutConfig.pagePaddingValue),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: TextStyle(
            fontSize: layoutConfig.fontSize,
            fontWeight: layoutConfig.fontWeight,
            color: theme.textColor,
            height: layoutConfig.lineHeight,
            letterSpacing: layoutConfig.letterSpacing == LetterSpacing.tight
                ? -0.5
                : layoutConfig.letterSpacing == LetterSpacing.loose
                    ? 1.0
                    : 0.0,
          ),
        ),
      ),
    );
  }
}