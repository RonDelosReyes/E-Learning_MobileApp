import 'package:flutter/material.dart';
import 'package:e_learning_app/pages/pdf_viewer_page.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

class FundamentalsOfComputerNetworkingPage extends StatelessWidget {
  const FundamentalsOfComputerNetworkingPage({super.key});

  final List<Map<String, dynamic>> _modules = const [
    {
      'title': 'Module 1: Introduction to Computer Networks',
      'lessons': [
        'Lesson 1.1: What is a Computer Network?',
        'Lesson 1.2: Types of Networks',
        'Lesson 1.3: Network Topologies',
      ],
    },
    {
      'title': 'Module 2: The OSI Model and Data Communication',
      'lessons': [
        'Lesson 2.1: Purpose of the OSI Model',
        'Lesson 2.2: The Seven Layers of the OSI Model',
        'Lesson 2.3: Data Delivery and Reliability',
      ],
    },
    {
      'title': 'Module 3: Network Media and Devices',
      'lessons': [
        'Lesson 3.1: Physical Media Types',
        'Lesson 3.2: Comparison of Media',
        'Lesson 3.3: Networking Devices',
      ],
    },
    {
      'title': 'Module 4: WAN Technologies and Advanced Networking Concepts',
      'lessons': [
        'Lesson 4.1: Wide Area Network (WAN) Technologies',
        'Lesson 4.2: Layer 2 and Layer 3 Switching',
        'Lesson 4.3: Network Security Components',
      ],
    },
    {
      'title': 'Module 5: Summary and Integration',
      'lessons': [
        'Lesson 5.1: Review of Key Concepts',
        'Lesson 5.2: Application and Troubleshooting',
      ],
    },
  ];

  // Example PDF resource for Fundamentals of Computer Networking
  final String resourceTitle = "Fundamentals of Computer Networking";
  final String resourceUrl =
      "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/Networking%20Basic.pdf";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF33A1E0),
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const Text(
          'Fundamentals of Computer Networking',
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
