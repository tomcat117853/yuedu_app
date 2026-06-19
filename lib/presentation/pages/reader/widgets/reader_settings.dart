import 'package:flutter/material.dart';
import '../../../../domain/models/layout_config.dart';
import '../../../../domain/models/reader_theme.dart';

/// 阅读器设置面板
class ReaderSettings extends StatelessWidget {
  final ReaderTheme theme;
  final LayoutConfig layoutConfig;
  final VoidCallback onIncreaseFontSize;
  final VoidCallback onDecreaseFontSize;
  final VoidCallback onIncreaseLineHeight;
  final VoidCallback onDecreaseLineHeight;

  const ReaderSettings({
    super.key,
    required this.theme,
    required this.layoutConfig,
    required this.onIncreaseFontSize,
    required this.onDecreaseFontSize,
    required this.onIncreaseLineHeight,
    required this.onDecreaseLineHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                      style: const TextStyle(
                        color: Colors.white,
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
            style: const TextStyle(
              color: Colors.white70,
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
}
