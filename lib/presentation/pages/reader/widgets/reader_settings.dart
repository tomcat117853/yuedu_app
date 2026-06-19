import 'package:flutter/material.dart';

import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

class ReaderSettings extends StatelessWidget {
  final LayoutConfig config;
  final ReaderTheme theme;
  final Function(LayoutConfig) onConfigChanged;
  final Function(ReaderTheme) onThemeChanged;

  const ReaderSettings({
    super.key,
    required this.config,
    required this.theme,
    required this.onConfigChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.backgroundColor,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              '主题设置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildThemeButton(ReaderTheme.day(), '日间'),
                const SizedBox(width: 8),
                _buildThemeButton(ReaderTheme.night(), '夜间'),
                const SizedBox(width: 8),
                _buildThemeButton(ReaderTheme.eyeCare(), '护眼'),
                const SizedBox(width: 8),
                _buildThemeButton(ReaderTheme.inkScreen(), '墨水屏'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '字体大小',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _updateFontSize(config.fontSize - 2),
                ),
                Expanded(
                  child: Slider(
                    value: config.fontSize.toDouble(),
                    min: 12,
                    max: 36,
                    onChanged: (value) => _updateFontSize(value.toInt()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateFontSize(config.fontSize + 2),
                ),
                const SizedBox(width: 8),
                Text('${config.fontSize}px'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '行距',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _updateLineHeight(config.lineHeight - 0.1),
                ),
                Expanded(
                  child: Slider(
                    value: config.lineHeight,
                    min: 1.2,
                    max: 2.5,
                    onChanged: _updateLineHeight,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${config.lineHeight.toStringAsFixed(1)}'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '段距',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.paragraphSpacing.toDouble(),
                    min: 0,
                    max: 30,
                    onChanged: (value) => _updateParagraphSpacing(value.toInt()),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${config.paragraphSpacing}px'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '页边距',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.pagePadding.toDouble(),
                    min: 10,
                    max: 60,
                    onChanged: (value) => _updatePagePadding(value.toInt()),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${config.pagePadding}px'),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '字间距',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.letterSpacing,
                    min: 0,
                    max: 5,
                    onChanged: _updateLetterSpacing,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${config.letterSpacing.toStringAsFixed(1)}px'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(ReaderTheme themeOption, String label) {
    final isSelected = theme.backgroundColor == themeOption.backgroundColor &&
        theme.textColor == themeOption.textColor;
    return Expanded(
      child: GestureDetector(
        onTap: () => onThemeChanged(themeOption),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: themeOption.backgroundColor,
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: themeOption.textColor),
            ),
          ),
        ),
      ),
    );
  }

  void _updateFontSize(int size) {
    if (size >= 12 && size <= 36) {
      onConfigChanged(config.copyWith(fontSize: size));
    }
  }

  void _updateLineHeight(double height) {
    onConfigChanged(config.copyWith(lineHeight: height));
  }

  void _updateParagraphSpacing(int spacing) {
    onConfigChanged(config.copyWith(paragraphSpacing: spacing));
  }

  void _updatePagePadding(int padding) {
    onConfigChanged(config.copyWith(pagePadding: padding));
  }

  void _updateLetterSpacing(double spacing) {
    onConfigChanged(config.copyWith(letterSpacing: spacing));
  }
}