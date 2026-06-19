import 'package:flutter/material.dart';

import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

class ReaderSettings extends StatelessWidget {
  final LayoutConfig config;
  final ReaderTheme theme;
  final LayoutConfig layoutConfig;
  final VoidCallback onIncreaseFontSize;
  final VoidCallback onDecreaseFontSize;
  final VoidCallback onIncreaseLineHeight;
  final VoidCallback onDecreaseLineHeight;
  final void Function(double value)? onParagraphSpacingChanged;
  final void Function(double value)? onMarginChanged;
  final void Function(double value)? onLetterSpacingChanged;
  final void Function(ReaderTheme theme)? onThemeChanged;

  const ReaderSettings({
    super.key,
    required this.config,
    required this.theme,
    required this.layoutConfig,
    required this.onIncreaseFontSize,
    required this.onDecreaseFontSize,
    required this.onIncreaseLineHeight,
    required this.onDecreaseLineHeight,
    this.onParagraphSpacingChanged,
    this.onMarginChanged,
    this.onLetterSpacingChanged,
    this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.backgroundColor,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 8),

            // 拖动指示条
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 字体大小
            _buildSettingRow(
              label: '字体大小',
              child: Row(
                children: [
                  _buildCircleButton(
                    icon: Icons.remove,
                    onTap: onDecreaseFontSize,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '${layoutConfig.fontSize.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCircleButton(
                    icon: Icons.add,
                    onTap: onIncreaseFontSize,
                  ),
                ],
              ),
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

            const SizedBox(height: 12),

            // 段间距滑块
            _buildSliderRow(
              label: '段距',
              value: layoutConfig.paragraphSpacing,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              displayValue: layoutConfig.paragraphSpacing.toStringAsFixed(1),
              onChanged: onParagraphSpacingChanged,
            ),

            const SizedBox(height: 8),

            // 页边距滑块
            _buildSliderRow(
              label: '边距',
              value: layoutConfig.margin,
              min: 8.0,
              max: 48.0,
              divisions: 20,
              displayValue: '${layoutConfig.margin.toInt()}',
              onChanged: onMarginChanged,
            ),

            const SizedBox(height: 8),

            // 字间距滑块
            _buildSliderRow(
              label: '字距',
              value: layoutConfig.letterSpacing,
              min: 0.0,
              max: 3.0,
              divisions: 15,
              displayValue: layoutConfig.letterSpacing.toStringAsFixed(1),
              onChanged: onLetterSpacingChanged,
            ),

            const SizedBox(height: 12),

            // 主题选择
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text(
                    '主题',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  ...ReaderTheme.presets.map((preset) {
                    final isSelected = preset.themeIndex == theme.themeIndex;
                    return GestureDetector(
                      onTap: () {
                        if (onThemeChanged != null) {
                          onThemeChanged!(preset);
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 12),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: preset.backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            preset.name,
                            style: TextStyle(
                              color: preset.textColor,
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),
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

  /// 构建滑块设置行
  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required String displayValue,
    void Function(double)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              activeColor: Colors.white,
              inactiveColor: Colors.white24,
              onChanged: onChanged ?? (_) {},
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建圆形按钮
  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
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