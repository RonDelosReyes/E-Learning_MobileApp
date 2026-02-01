import 'package:flutter/material.dart';
import 'package:e_learning_app/pages/pdf_viewer_page.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class BasicComputerPartsPage extends StatelessWidget {
  const BasicComputerPartsPage({super.key});

  final List<Map<String, dynamic>> _modules = const [
    {
      'title': 'Module 1: Introduction to Computer Hardware',
      'lessons': [
        'Lesson 1: What is Computer Hardware?',
        'Lesson 2: Types of Computer Systems',
        'Lesson 3: Hardware vs Software',
      ],
    },
    {
      'title': 'Module 2: Basic Computer Components',
      'lessons': [
        'Lesson 1: Input Devices',
        'Lesson 2: Output Devices',
        'Lesson 3: Storage Devices',
        'Lesson 4: Processing Unit (CPU)',
      ],
    },
    {
      'title': 'Module 3: Motherboard and Internal Parts',
      'lessons': [
        'Lesson 1: Motherboard Overview',
        'Lesson 2: RAM and ROM',
        'Lesson 3: Power Supply Unit',
        'Lesson 4: Expansion Slots and Cards',
      ],
    },
    {
      'title': 'Module 4: Assembling and Disassembling',
      'lessons': [
        'Lesson 1: Safety Precautions',
        'Lesson 2: Tools and Equipment',
        'Lesson 3: Step-by-Step Assembly Process',
      ],
    },
  ];

  final String resourceTitle = "Introduction To Computer Hardware";
  final String resourceUrl =
      "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/Computer%20Parts%20Book.pdf";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF33A1E0),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const Text(
          'Basic Computer Parts Course',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Modules
          ..._modules.asMap().entries.map((entry) {
            int moduleIndex = entry.key;
            Map<String, dynamic> module = entry.value;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                backgroundColor: Colors.white,
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                title: Text(
                  module['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1565C0),
                  ),
                ),
                children: ((module['lessons'] as List<String>).map(
                      (lesson) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                    leading: const Icon(Icons.book_outlined,
                        color: Color(0xFF42A5F5)),
                    title: Text(
                      lesson,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming Soon...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ).toList()),
              ),
            );
          }),

          const SizedBox(height: 16),

          // White box with functional Read and Download
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resourceTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Open PDF in PdfViewerPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfViewerPage(
                                    url: resourceUrl,
                                    title: resourceTitle,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Read"),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await downloadFileWithSAF(
                                  resourceUrl,
                                  "$resourceTitle.pdf",
                                  context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1565C0),
                              side: const BorderSide(color: Color(0xFF1565C0)),
                            ),
                            child: const Text("Download"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Download using SAF (file picker)
Future<void> downloadFileWithSAF(
    String url, String fileName, BuildContext context) async {
  try {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No folder selected.")),
      );
      return;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception("Failed to download file");

    final file = File('$selectedDirectory/$fileName');
    await file.writeAsBytes(response.bodyBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Downloaded to $selectedDirectory/$fileName")),
    );
  } catch (e) {
    debugPrint("Download error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error downloading file: $e")),
    );
  }
}
