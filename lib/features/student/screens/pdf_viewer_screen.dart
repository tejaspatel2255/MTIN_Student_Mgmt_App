import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/constants/constants.dart';

class PdfViewerScreen extends StatelessWidget {
  final String assetPath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: PdfViewer.asset(
        assetPath,
        params: const PdfViewerParams(
          enableTextSelection: true,
          maxScale: 8,
        ),
      ),
    );
  }
}
