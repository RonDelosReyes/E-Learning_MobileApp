import 'package:flutter/material.dart';
import '../widget/primary_appbar.dart';
import '../widget/student/hamburg_menu_stud.dart';
import 'pdf_viewer_page.dart';

class TechLibraryPage extends StatefulWidget {
  const TechLibraryPage({super.key});

  @override
  State<TechLibraryPage> createState() => _TechLibraryPageState();
}

class _TechLibraryPageState extends State<TechLibraryPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: const PrimaryAppBar(title: "Tech Library"),
      drawer: const AppDrawer(currentRoute: 'techlib'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== Header Banner =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Learning Resources 📚",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Access modules, references, and study materials.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== Category Filter =====
            Row(
              children: [
                _categoryChip("All", 0),
                const SizedBox(width: 10),
                _categoryChip("PDF", 1),
                const SizedBox(width: 10),
                _categoryChip("Office", 2),
              ],
            ),

            const SizedBox(height: 24),

            ..._buildFileList(),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedIndex = index),
      selectedColor: const Color(0xFF1565C0),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF1565C0),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Color(0xFF1565C0)),
      ),
    );
  }

  List<Widget> _buildFileList() {
    final allFiles = [
      {
        "fileName": "Introduction to Computer Hardware",
        "fileType": "PDF",
        "fileUrl":
        "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/Computer%20Parts%20Book.pdf",
      },
      {
        "fileName": "Networking Basics",
        "fileType": "PDF",
        "fileUrl":
        "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/Networking%20Basic.pdf",
      },
      {
        "fileName": "Operating Systems Concept Book",
        "fileType": "PDF",
        "fileUrl":
        "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/OS%20Concepts.pdf",
      },
    ];

    List<Map<String, dynamic>> filtered = [];

    if (_selectedIndex == 0) {
      filtered = allFiles;
    } else if (_selectedIndex == 1) {
      filtered =
          allFiles.where((f) => f['fileType'] == 'PDF').toList();
    } else {
      filtered = [];
    }

    if (filtered.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              "No files found in this category.",
              style: TextStyle(color: Colors.black54),
            ),
          ),
        )
      ];
    }

    return filtered.map((file) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ModernTechFileCard(
          fileName: file['fileName'],
          fileType: file['fileType'],
          onRead: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfViewerPage(
                  url: file['fileUrl'],
                  title: file['fileName'],
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}

// ================= MODERN FILE CARD =================

class ModernTechFileCard extends StatelessWidget {
  final String fileName;
  final String fileType;
  final VoidCallback onRead;

  const ModernTechFileCard({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [

          // File Icon Container
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf,
                color: primaryBlue),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fileType,
                    style: const TextStyle(
                      fontSize: 12,
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onRead,
            icon: const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
