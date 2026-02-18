import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Courses
import 'package:e_learning_app/courses/basic_computer_parts.dart';
import 'package:e_learning_app/courses/com_repair.dart';
import 'package:e_learning_app/courses/intro_to_comnet.dart';
import 'package:e_learning_app/courses/os_concepts.dart';

// Services & Providers
import 'package:e_learning_app/services/pages/courses_service.dart';
import 'package:e_learning_app/user_provider.dart';

// Widgets
import 'package:e_learning_app/widget/student/hamburg_menu_stud.dart';

import '../widget/primary_appbar.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

final List<int> courseOrder = [1, 2, 3, 4];

class _CoursesPageState extends State<CoursesPage> {
  final CoursesService _service = CoursesService();

  bool _isLoading = true;
  List<Map<String, dynamic>> _courseProgress = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final studentId = context.read<UserProvider>().studentId!;
    final progress = await _service.fetchCourseProgress(studentId);

    setState(() {
      _courseProgress = progress;
      _isLoading = false;
    });
  }

  double _getProgressNormalized(int courseId) {
    final value = _service.getProgress(_courseProgress, courseId);
    return value / 100;
  }

  @override
  Widget build(BuildContext context) {
    final firstName =
        context.watch<UserProvider>().firstName ?? "Student";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: const PrimaryAppBar(title: "Courses"),
      drawer: const AppDrawer(currentRoute: 'courses'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== Header Card =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Continue Learning, $firstName 👋",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Track your progress and unlock new knowledge.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Your Enrolled Courses",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            ..._buildCourseList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCourseList() {
    final List<Map<String, dynamic>> courses = [
      {
        'id': 1,
        'title': "Basic Computer Parts",
        'instructor': "Mr. Smith",
        'page': const BasicComputerPartsPage(),
      },
      {
        'id': 2,
        'title': "Operating System Concepts",
        'instructor': "Dr. Rivera",
        'page': const OperatingSystemConceptsPage(),
      },
      {
        'id': 3,
        'title': "Intro to Computer Networking",
        'instructor': "Ms. Garcia",
        'page': const FundamentalsOfComputerNetworkingPage(),
      },
      {
        'id': 4,
        'title': "Computer Troubleshooting & Repair",
        'instructor': "Prof. Tan",
        'page': const ComputerRepairPage(),
      },
    ];

    return courses.map((course) {
      final int courseId = course['id'];
      final bool enabled =
      _service.isCourseUnlocked(courseId, _courseProgress, courseOrder);

      final double progress = _getProgressNormalized(courseId);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ModernCourseCard(
          title: course['title'],
          instructor: course['instructor'],
          progress: progress,
          enabled: enabled,
          onTap: () {
            if (enabled) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => course['page']),
              );
            }
          },
        ),
      );
    }).toList();
  }
}

// ================= MODERN COURSE CARD =================

class ModernCourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final double progress;
  final bool enabled;
  final VoidCallback onTap;

  const ModernCourseCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1565C0);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Title + Lock
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: enabled ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                Icon(
                  enabled ? Icons.lock_open : Icons.lock,
                  size: 18,
                  color: enabled ? primaryBlue : Colors.grey,
                )
              ],
            ),

            const SizedBox(height: 6),

            Text(
              "Instructor: $instructor",
              style: TextStyle(
                fontSize: 13,
                color: enabled ? Colors.black54 : Colors.grey,
              ),
            ),

            const SizedBox(height: 14),

            // Progress Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Progress",
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryBlue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE3F2FD),
                color: enabled ? primaryBlue : Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enabled ? onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  enabled ? primaryBlue : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                  const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  enabled
                      ? (progress == 0 ? "Start Course" : "Continue Course")
                      : "Locked",
                  style: const TextStyle(
                      fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
