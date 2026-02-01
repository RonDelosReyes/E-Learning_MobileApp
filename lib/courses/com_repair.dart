import 'package:flutter/material.dart';
import 'package:e_learning_app/pages/pdf_viewer_page.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class ComputerRepairPage extends StatelessWidget {
  const ComputerRepairPage({super.key});

  final List<Map<String, dynamic>> _modules = const [
    {
      'title': 'Module 1: Introduction to Computer Troubleshooting',
      'lessons': [
        'Lesson 1: Understanding PC Problems',
        'Lesson 2: Troubleshooting Philosophy',
        'Lesson 3: Basic Troubleshooting Process',
      ],
    },
    {
      'title': 'Module 2: Quick Fixes and Problem Solving Tools',
      'lessons': [
        'Lesson 1: Quick Fix Techniques',
        'Lesson 2: Common Tools for Troubleshooting',
        'Lesson 3: Online and External Support',
      ],
    },
    {
      'title': 'Module 3: Diagnosing and Repairing Hardware Issues',
      'lessons': [
        'Lesson 1: Startup Problems',
        'Lesson 2: Hardware Components and Issues',
        'Lesson 3: Disk and Storage Troubleshooting',
      ],
    },
    {
      'title': 'Module 4: Software and System Troubleshooting',
      'lessons': [
        'Lesson 1: Operating System Issues',
        'Lesson 2: Software Conflicts and Errors',
        'Lesson 3: Networking and Internet Problems',
      ],
    },
    {
      'title': 'Module 5: Maintenance and PC Optimization',
      'lessons': [
        'Lesson 1: Regular Maintenance Practices',
        'Lesson 2: Security and Protection',
        'Lesson 3: Extending the Life of an Old PC',
      ],
    },
  ];

  // Example PDF resource for Computer Troubleshooting & Repair
  final String resourceTitle = "Computer Troubleshooting & Repair";
  final String resourceUrl =
      "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/Computer%20Troubleshooting%20&%20Repair.pdf";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF33A1E0),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const Text(
          'Computer Troubleshooting & Repair',
          style: TextStyle(
            fontSize: 20,
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
                    leading: const Icon(Icons.build_circle_outlined,
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
