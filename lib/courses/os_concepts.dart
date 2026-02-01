import 'package:flutter/material.dart';
import 'package:e_learning_app/pages/pdf_viewer_page.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class OperatingSystemConceptsPage extends StatelessWidget {
  const OperatingSystemConceptsPage({super.key});

  final List<Map<String, dynamic>> _modules = const [
    {
      'title': 'Module 1: Introduction to Operating Systems',
      'lessons': [
        'Lesson 1.1: Overview of Operating Systems',
        'Lesson 1.2: Operating System Structures',
        'Lesson 1.3: Modern Computing Environments',
      ],
    },
    {
      'title': 'Module 2: Process and Thread Management',
      'lessons': [
        'Lesson 2.1: Processes',
        'Lesson 2.2: Threads and Concurrency',
        'Lesson 2.3: CPU Scheduling',
      ],
    },
    {
      'title': 'Module 3: Process Synchronization and Deadlocks',
      'lessons': [
        'Lesson 3.1: Synchronization Tools',
        'Lesson 3.2: Synchronization in Practice',
        'Lesson 3.3: Deadlocks',
      ],
    },
    {
      'title': 'Module 4: Memory, Storage, and File Management',
      'lessons': [
        'Lesson 4.1: Memory Management',
        'Lesson 4.2: Storage and I/O Systems',
        'Lesson 4.3: File Systems',
      ],
    },
    {
      'title': 'Module 5: Security, Protection, and Advanced Topics',
      'lessons': [
        'Lesson 5.1: Security and Protection',
        'Lesson 5.2: Virtualization and Distributed Systems',
        'Lesson 5.3: Case Studies',
      ],
    },
  ];

  // Example PDF resource for OS Concepts
  final String resourceTitle = "Operating System Concepts";
  final String resourceUrl =
      "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/OS%20Concepts.pdf";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF33A1E0),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const Text(
          'Operating System Concepts',
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
          // Module list
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

          // White box with Read and Download buttons
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
                                  resourceUrl, "$resourceTitle.pdf", context);
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

// Download function using File Picker (SAF)
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
