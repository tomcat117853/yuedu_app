import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

/// 阅读器设置面板 (Apple-style design with frosted glass)
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
  final void Function(PageTransition)? onPageTransitionChanged;
  final void Function(String)? onFontFamilyChanged;
  final void Function(int)? onReadModeChanged;

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
    this.onPageTransitionChanged,
    this.onFontFamilyChanged,
    this.onReadModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Material(
          color: theme.backgroundColor.withOpacity(0.85),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                const SizedBox(height: 8),

                // iOS-style grabber
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.hintColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 字体大小
                _buildSettingRow(
                  label: '字体大小',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                            fontSize: 18,
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

                const SizedBox(height: 20),

                // 行距
                _buildSettingRow(
                  label: '行距',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                            fontSize: 18,
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

                const SizedBox(height: 20),

                // 主题选择 - 基础主题
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                      ...ReaderTheme.presets.take(4).map((preset) {
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
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : Border.all(
                                      color: theme.hintColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // 主题选择 - 扩展主题
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '更多',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      ...ReaderTheme.extendedPresets.take(6).map((preset) {
                        final isSelected = preset.themeIndex == theme.themeIndex;
                        return GestureDetector(
                          onTap: () {
                            if (onThemeChanged != null) {
                              onThemeChanged!(preset);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: preset.backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : Border.all(
                                      color: theme.hintColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                    value: layoutConfig.letterSpacingValue,
                    min: -1.0,
                    max: 2.0,
                    divisions: 15,
                    displayValue: layoutConfig.letterSpacingValue.toStringAsFixed(1),
                    onChanged: onLetterSpacingChanged!,
                  ),

                const SizedBox(height: 16),

                // 字体选择 - horizontal scrollable chips
                _buildSettingRow(
                  label: '字体',
                  child: _buildFontSelector(),
                ),

                const SizedBox(height: 16),

                // 阅读模式
                _buildSettingRow(
                  label: '模式',
                  child: _buildReadModeSelector(),
                ),

                const SizedBox(height: 16),

                // 翻页效果
                if (onPageTransitionChanged != null)
                  _buildSettingRow(
                    label: '翻页',
                    child: _buildPageTransitionSelector(),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建设置行
  Widget _buildSettingRow({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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

  /// 构建圆形按钮 (40x40, Apple-style)
  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.textColor.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 22, color: theme.textColor),
      ),
    );
  }

  /// 构建滑块行 (refined Apple-style)
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: theme.textColor,
                inactiveTrackColor: theme.textColor.withOpacity(0.3),
                thumbColor: theme.textColor,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                trackHeight: 2,
                overlayColor: theme.textColor.withOpacity(0.12),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
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

  /// 字体选择器 - horizontal scrollable chips
  Widget _buildFontSelector() {
    return SizedBox(
      height: 32,
      width: 200,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: BuiltInFonts.options.map((font) {
            final isSelected = layoutConfig.fontFamily == font.fontFamily;
            return GestureDetector(
              onTap: () {
                onFontFamilyChanged?.call(font.fontFamily);
              },
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.textColor.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? theme.textColor
                        : theme.hintColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  font.displayName,
                  style: TextStyle(
                    fontFamily: font.fontFamily == 'system' ? null : font.fontFamily,
                    color: isSelected ? theme.textColor : theme.hintColor,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 阅读模式选择器 - pill buttons
  Widget _buildReadModeSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.hintColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModePill(
            icon: Icons.menu_book,
            label: '翻页',
            isSelected: layoutConfig.readMode == 0,
            onTap: () => onReadModeChanged?.call(0),
          ),
          _buildModePill(
            icon: Icons.swap_vert,
            label: '滚动',
            isSelected: layoutConfig.readMode == 1,
            onTap: () => onReadModeChanged?.call(1),
          ),
        ],
      ),
    );
  }

  /// 模式按钮 - pill style
  Widget _buildModePill({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.textColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? theme.textColor : theme.hintColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.textColor : theme.hintColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 翻页效果选择器 - small pill buttons
  Widget _buildPageTransitionSelector() {
    final transitions = [
      (PageTransition.none, '无'),
      (PageTransition.simulation, '仿真'),
      (PageTransition.slide, '滑动'),
      (PageTransition.fade, '淡入'),
      (PageTransition.curl, '卷曲'),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: transitions.map((t) {
        final isSelected = layoutConfig.pageTransition == t.$1;
        return GestureDetector(
          onTap: () => onPageTransitionChanged?.call(t.$1),
          child: Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.textColor.withOpacity(0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? theme.textColor
                    : theme.hintColor.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              t.$2,
              style: TextStyle(
                color: isSelected ? theme.textColor : theme.hintColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
