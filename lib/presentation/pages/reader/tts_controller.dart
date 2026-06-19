import 'package:flutter/material.dart';
import '../../../../domain/services/tts_service.dart';

/// TTS 听读控制器 - 悬浮控制面板
class TtsController extends StatefulWidget {
  final TtsService ttsService;
  final String currentText;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onClose;

  const TtsController({
    super.key,
    required this.ttsService,
    required this.currentText,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onClose,
  });

  @override
  State<TtsController> createState() => _TtsControllerState();
}

class _TtsControllerState extends State<TtsController> {
  double _speechRate = 1.0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _speechRate = widget.ttsService.speechRate;
    _isPlaying = widget.ttsService.isPlaying;
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await widget.ttsService.pause();
    } else {
      if (widget.ttsService.currentOffset > 0) {
        await widget.ttsService.resume();
      } else {
        await widget.ttsService.speak(widget.currentText);
      }
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _stop() async {
    await widget.ttsService.stop();
    setState(() => _isPlaying = false);
  }

  void _changeSpeed(double delta) async {
    final newRate = (_speechRate + delta).clamp(0.5, 2.0);
    await widget.ttsService.setSpeechRate(newRate);
    setState(() => _speechRate = newRate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上一页
          _buildButton(
            icon: Icons.skip_previous,
            onPressed: widget.onPreviousPage,
            tooltip: '上一页',
          ),

          // 播放/暂停
          _buildButton(
            icon: _isPlaying ? Icons.pause : Icons.play_arrow,
            onPressed: _togglePlay,
            tooltip: _isPlaying ? '暂停' : '播放',
            size: 44,
          ),

          // 停止
          _buildButton(
            icon: Icons.stop,
            onPressed: _stop,
            tooltip: '停止',
          ),

          // 下一页
          _buildButton(
            icon: Icons.skip_next,
            onPressed: widget.onNextPage,
            tooltip: '下一页',
          ),

          const SizedBox(width: 8),

          // 语速控制
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _changeSpeed(-0.25),
                  child: const Icon(Icons.remove, color: Colors.white70, size: 16),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${_speechRate.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
                InkWell(
                  onTap: () => _changeSpeed(0.25),
                  child: const Icon(Icons.add, color: Colors.white70, size: 16),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          // 关闭
          _buildButton(
            icon: Icons.close,
            onPressed: () {
              _stop();
              widget.onClose();
            },
            tooltip: '关闭',
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? tooltip,
    double size = 36,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: size * 0.6),
        ),
      ),
    );
  }
}
