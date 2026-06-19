import 'package:flutter/material.dart';

import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

/// 阅读器设置面板
class ReaderSettings extends StatelessWidget {
  final LayoutConfig layoutConfig;
  final ReaderTheme theme;
  final VoidCallback onIncreaseFontSize;
  final VoidCallback onDecreaseFontSize;
  final VoidCallback onIncreaseLineHeight;
  final VoidCallback onDecreaseLineHeight;
  final void Function(double value)? onParagraphSpacingChanged;
  final void Function(double value)? onMarginChanged;
  final void Function(double value)? onLetterSpacingChanged;
  final void Function(ReaderTheme readerTheme)? onThemeChanged;

  const ReaderSettings({
    super.key,
    required this.layoutConfig,
    required this.theme,
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
                      style: TextStyle(
                        color: theme.textColor,
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

            const SizedBox(height: 16),

            // 行距
            _buildSettingRow(
              label: '行距',
              child: Row(
                children: [
                  _buildCircleButton(
                    icon: Icons.remove,
                    onTap: onDecreaseLineHeight,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      layoutConfig.lineHeight.toStringAsFixed(1),
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCircleButton(
                    icon: Icons.add,
                    onTap: onIncreaseLineHeight,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 主题选择
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    '主题',
                    style: TextStyle(
                      color: theme.textColor,
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

            const SizedBox(height: 24),

            // 段距滑块
            if (onParagraphSpacingChanged != null)
              _buildSliderRow(
                label: '段距',
                value: layoutConfig.paragraphSpacing,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                displayValue: layoutConfig.paragraphSpacing.toStringAsFixed(1),
                onChanged: onParagraphSpacingChanged!,
              ),

            const SizedBox(height: 8),

            // 页边距滑块
            if (onMarginChanged != null)
              _buildSliderRow(
                label: '边距',
                value: layoutConfig.margin,
                min: 8.0,
                max: 48.0,
                divisions: 20,
                displayValue: '${layoutConfig.margin.toInt()}',
                onChanged: onMarginChanged!,
              ),

            const SizedBox(height: 8),

            // 字间距滑块
            if (onLetterSpacingChanged != null)
              _buildSliderRow(
                label: '字距',
                value: layoutConfig.letterSpacing,
                min: 0.0,
                max: 3.0,
                divisions: 15,
                displayValue: layoutConfig.letterSpacing.toStringAsFixed(1),
                onChanged: onLetterSpacingChanged!,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建设置行
  Widget _buildSettingRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.textColor,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }

  /// 构建圆形按钮
  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.textColor.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 20, color: theme.textColor),
      ),
    );
  }

  /// 构建滑块行
  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
              activeColor: theme.textColor,
              inactiveColor: theme.textColor.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              displayValue,
              style: TextStyle(
                color: theme.textColor,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
