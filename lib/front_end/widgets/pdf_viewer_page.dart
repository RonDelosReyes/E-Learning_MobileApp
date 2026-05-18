import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({super.key, required this.url, required this.title});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  PdfControllerPinch? _pdfController;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      
      if (response.statusCode == 200) {
        final pdfData = response.bodyBytes;

        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(pdfData),
        );

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception("Failed to download PDF: \${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error loading PDF: \$e");
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to load PDF.";
        });
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.titleLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 24),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: _buildBody(backgroundColor, textColor),
    );
  }

  Widget _buildBody(Color backgroundColor, Color textColor) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: TextStyle(color: textColor, fontFamily: 'Poppins'),
        ),
      );
    }

    if (_pdfController == null) {
      return Center(
        child: Text(
          "Unable to initialize PDF viewer.",
          style: TextStyle(color: textColor, fontFamily: 'Poppins'),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: PdfViewPinch(
        controller: _pdfController!,
        backgroundDecoration: BoxDecoration(color: backgroundColor),
      ),
    );
  }
}
