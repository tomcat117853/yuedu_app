import 'package:flutter/material.dart';
import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

/// 分页文本阅读组件
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
        horizontal: layoutConfig.pagePaddingValue,
        vertical: layoutConfig.pagePaddingValue * 0.5,
      ),
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
    );
  }
}