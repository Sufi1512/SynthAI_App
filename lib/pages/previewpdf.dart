import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Add this package to pubspec.yaml

class PreviewPDF extends StatelessWidget {
  final File file;

  const PreviewPDF({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        backgroundColor: Colors.deepPurple,
      ),
      body: PDFView(
        filePath: file.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading PDF: $error')),
          );
        },
        onRender: (pages) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Document has $pages pages')),
          );
        },
      ),
    );
  }
}
