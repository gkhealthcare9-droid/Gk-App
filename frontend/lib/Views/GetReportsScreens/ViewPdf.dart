import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:sales_grow/Views/Widgets/CustomAppBar.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String reportNumber;

  const PDFViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.reportNumber,
  });

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLoading = false;

  Future<void> _downloadAndSharePdf() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        if (kIsWeb) {
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => bytes,
            name: 'Installation Report-${widget.reportNumber}.pdf',
          );
        } else {
          final dir = await getTemporaryDirectory();
          final file = io.File(
              '${dir.path}/Installation Report-${widget.reportNumber}.pdf');
          await file.writeAsBytes(bytes);

          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Installation Report #${widget.reportNumber}',
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF shared successfully')),
          );
        }
      } else {
        _showErrorDialog('Failed to download PDF');
      }
    } catch (e) {
      _showErrorDialog('Error sharing PDF: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Report #${widget.reportNumber}',
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.share),
            onPressed: _isLoading ? null : _downloadAndSharePdf,
            tooltip: 'Share PDF',
          ),
        ],
       // backgroundColor: Theme.of(context).primaryColor,
       // elevation: 4,
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfUrl,
            onDocumentLoadFailed: (details) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Failed to Load PDF'),
                  content: Text('Error: ${details.description}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {}); // Retry loading
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
            onDocumentLoaded: (details) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF loaded successfully')),
              );
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}