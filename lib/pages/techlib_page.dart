import 'package:flutter/material.dart';
import '../courses/basic_computer_parts.dart';
import '../widget/student/hamburg_menu_stud.dart';
import 'pdf_viewer_page.dart';

class TechLibraryPage extends StatefulWidget {
  const TechLibraryPage({super.key});

  @override
  State<TechLibraryPage> createState() => _TechLibraryPageState();
}

class _TechLibraryPageState extends State<TechLibraryPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFF33A1E0),
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Search files...",
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                )
              : const Text(
                  'Tech Library',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
          actions: [
            _isSearching
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _stopSearch,
                  )
                : IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _startSearch,
                  ),
          ],
        ),
        drawer: const AppDrawer(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final allFiles = [
      {
        "fileName": "Introduction to Computer Hardware",
        "fileType": "PDF",
        "thumbnailUrl": "https://static.thenounproject.com/png/2221071-200.png",
        "fileUrl":
            "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/Computer%20Parts%20Book.pdf",
      },
      {
        "fileName": "Networking Basics",
        "fileType": "PDF",
        "thumbnailUrl":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4rffhP1hXjkDrHtIMM_RYDrfP8pjaTFNP-Q&s",
        "fileUrl":
            "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/Networking%20Basic.pdf",
      },
      {
        "fileName": "System Unit Components",
        "fileType": "PDF",
        "thumbnailUrl":
            "https://static.vecteezy.com/system/resources/thumbnails/014/523/340/small_2x/computer-system-unit-icon-simple-style-vector.jpg",
        "fileUrl":
            "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/System%20Unit%20Components.pdf",
      },
      {
        "fileName": "Operating Systems Concept Book",
        "fileType": "PDF",
        "thumbnailUrl":
            "https://media.istockphoto.com/id/1328306485/vector/upgrade-of-software-line-icon-computer-system-update-linear-pictogram-download-process-icon.jpg?s=612x612&w=0&k=20&c=LT_vOXGJH6ihpS05imCSr42nxl0KG4EOl-iC3t7O9pY=",
        "fileUrl":
            "https://djnbwuaqjociuehoziqf.supabase.co/storage/v1/object/public/Modules(Courses)/OS%20Concepts.pdf",
      },
    ];

    List<Map<String, dynamic>> filteredFiles = [];
    if (_selectedIndex == 0) {
      filteredFiles = allFiles;
    } else if (_selectedIndex == 1) {
      filteredFiles = allFiles.where((f) => f['fileType'] == 'PDF').toList();
    } else if (_selectedIndex == 2) {
      filteredFiles = allFiles
          .where((f) => f['fileType'] == 'PPTX' || f['fileType'] == 'DOCX')
          .toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _categoryButton("All", 0),
              _categoryButton("PDF", 1),
              _categoryButton("Office Files", 2),
            ],
          ),
          const SizedBox(height: 20),
          filteredFiles.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text(
                      "No files found in this category.",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFiles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    final file = filteredFiles[index];
                    return TechFileCard(
                      fileName: file['fileName'],
                      fileType: file['fileType'],
                      thumbnailUrl: file['thumbnailUrl'],
                      fileUrl: file['fileUrl'],
                      onRead: () {
                        if (file['fileType'] == 'PDF') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerPage(
                                url: file['fileUrl'],
                                title: file['fileName'],
                              ),
                            ),
                          );
                        } else {
                          debugPrint("Cannot open this file type yet.");
                        }
                      },
                      onDownload: () async {
                        final safeName =
                            "${file['fileName'].replaceAll(RegExp(r'[\/:*?"<>|]'), '_')}.${file['fileType'].toLowerCase()}";
                        await downloadFileWithSAF(
                          file['fileUrl'],
                          safeName,
                          context,
                        );
                      },
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _categoryButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ElevatedButton(
          onPressed: () => setState(() => _selectedIndex = index),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFF1565C0)
                : Colors.white,
            foregroundColor: isSelected
                ? Colors.white
                : const Color(0xFF1565C0),
            side: const BorderSide(color: Color(0xFF1565C0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: isSelected ? 3 : 0,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// ==================== TECH FILE CARD ======================
class TechFileCard extends StatelessWidget {
  final String fileName, fileType, thumbnailUrl, fileUrl;
  final VoidCallback onRead;
  final VoidCallback onDownload;

  const TechFileCard({
    super.key,
    required this.fileName,
    required this.fileType,
    required this.thumbnailUrl,
    required this.fileUrl,
    required this.onRead,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                thumbnailUrl,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileType,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onRead,
                  icon: const Icon(Icons.menu_book, color: Color(0xFF1565C0)),
                  tooltip: "Read",
                ),
                IconButton(
                  onPressed: onDownload,
                  icon: const Icon(Icons.download, color: Color(0xFF1565C0)),
                  tooltip: "Download",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
