import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/parsers/pdf_parser.dart';

/// PDF 阅读页面
///
/// 使用简化的 PDF 渲染方式。完整功能需要集成 syncfusion_flutter_pdfviewer
/// 或 flutter_pdfview 等第三方库。
class PdfReaderPage extends ConsumerStatefulWidget {
  final String bookId;
  final String filePath;

  const PdfReaderPage({
    super.key,
    required this.bookId,
    required this.filePath,
  });

  @override
  ConsumerState<PdfReaderPage> createState() => _PdfReaderPageState();
}

class _PdfReaderPageState extends ConsumerState<PdfReaderPage> {
  PdfParseResult? _parseResult;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final parser = PdfParser();
      final result = await parser.parse(widget.filePath);
      if (mounted) {
        setState(() {
          _parseResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'PDF 加载失败: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_parseResult?.book.title ?? 'PDF 阅读'),
        actions: [
          if (_parseResult != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_currentPage + 1}/${_parseResult!.pageCount}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadPdf();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // PDF 内容展示区域
    // 注意：完整的 PDF 渲染需要集成 syncfusion_flutter_pdfviewer 或类似库
    // 这里提供一个占位 UI，表示 PDF 页面导航功能
    return Column(
      children: [
        // PDF 页面占位区域
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    '第 ${_currentPage + 1} 页',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PDF 渲染需要集成 PDF 查看器库',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '请在 pubspec.yaml 中添加 syncfusion_flutter_pdfviewer',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 页面导航
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
              ),
              Expanded(
                child: Slider(
                  value: _parseResult != null && _parseResult!.pageCount > 1
                      ? _currentPage / (_parseResult!.pageCount - 1)
                      : 0,
                  onChanged: (value) {
                    if (_parseResult != null) {
                      setState(() {
                        _currentPage =
                            (value * (_parseResult!.pageCount - 1)).round();
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _parseResult != null &&
                        _currentPage < _parseResult!.pageCount - 1
                    ? () => setState(() => _currentPage++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
