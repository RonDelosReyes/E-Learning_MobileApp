import 'package:flutter/material.dart';
import '../widget/student/hamburg_menu_stud.dart';

class KnowledgeLabPage extends StatefulWidget {
  const KnowledgeLabPage({super.key});

  @override
  State<KnowledgeLabPage> createState() => _KnowledgeLabPageState();
}

class _KnowledgeLabPageState extends State<KnowledgeLabPage> {
  int _selectedIndex = 0;

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
          title: const Text(
            'Knowledge Lab',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        drawer: const AppDrawer(),
        body: _buildBody(),
      ),
    );
  }

  // Body Section
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _categoryButton("All", 0),
              _categoryButton("Hardware Basics", 1),
              _categoryButton("Troubleshooting", 2),
              _categoryButton("Assembly", 3),
            ],
          ),

          const SizedBox(height: 20),

          // Placeholder Content
          Expanded(
            child: Center(
              child: Text(
                "Selected: ${[
                  "All",
                  "Hardware Basics",
                  "Troubleshooting",
                  "Assembly"
                ][_selectedIndex]}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Category Buttons
  Widget _categoryButton(String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedIndex = index;
            });
            debugPrint("Category selected: $label");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
            isSelected ? const Color(0xFF1565C0) : Colors.white,
            foregroundColor:
            isSelected ? Colors.white : const Color(0xFF1565C0),
            side: const BorderSide(color: Color(0xFF1565C0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            elevation: isSelected ? 3 : 0,
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
