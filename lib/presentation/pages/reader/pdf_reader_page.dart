import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfReaderPage extends StatelessWidget {
  final String filePath;

  const PdfReaderPage({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF阅读'),
      ),
      body: PDFView(
        filePath: filePath,
        autoSpacing: true,
        pageSnap: true,
        enableSwipe: true,
        swipeHorizontal: true,
        nightMode: false,
      ),
    );
  }
}