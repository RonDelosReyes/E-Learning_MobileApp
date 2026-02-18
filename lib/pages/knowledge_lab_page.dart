import 'package:flutter/material.dart';
import '../widget/primary_appbar.dart';
import '../widget/student/hamburg_menu_stud.dart';

class KnowledgeLabPage extends StatefulWidget {
  const KnowledgeLabPage({super.key});

  @override
  State<KnowledgeLabPage> createState() => _KnowledgeLabPageState();
}

class _KnowledgeLabPageState extends State<KnowledgeLabPage> {
  int _selectedCategory = 0;

  final categories = ["All", "Hardware", "Troubleshooting", "Assembly"];

  final quizzes = [
    {
      "title": "Computer Hardware Fundamentals",
      "category": "Hardware",
      "author": "Prof. Dela Cruz",
      "items": 20,
    },
    {
      "title": "PC Troubleshooting Mastery",
      "category": "Troubleshooting",
      "author": "TechLibrary App",
      "items": 15,
    },
    {
      "title": "Step-by-Step PC Assembly",
      "category": "Assembly",
      "author": "Prof. Santos",
      "items": 25,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: const PrimaryAppBar(title: "Knowledge Lab"),
      drawer: const AppDrawer(currentRoute: 'knowledge'),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // ===== CATEGORY FILTER =====
          SizedBox(
            height: 45,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;

                return ChoiceChip(
                  label: Text(categories[index]),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = index);
                  },
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
              },
            ),
          ),

          const SizedBox(height: 20),

          // ===== QUIZ LIST =====
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: quizzes.length,
              itemBuilder: (context, index) {
                final quiz = quizzes[index];

                if (_selectedCategory != 0 &&
                    quiz["category"] != categories[_selectedCategory]) {
                  return const SizedBox();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _QuizCard(
                    title: quiz["title"] as String,
                    category: quiz["category"] as String,
                    author: quiz["author"] as String,
                    totalItems: quiz["items"] as int,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= QUIZ CARD =================

class _QuizCard extends StatelessWidget {
  final String title;
  final String category;
  final String author;
  final int totalItems;

  const _QuizCard({
    required this.title,
    required this.category,
    required this.author,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category,
              style: const TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // Author + Items
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(author, style: const TextStyle(color: Colors.grey)),
              ),
              const Icon(Icons.list_alt, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "$totalItems Items",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                debugPrint("Start quiz: $title");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                elevation: 3,
                shadowColor: primaryBlue.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Start Quiz",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
