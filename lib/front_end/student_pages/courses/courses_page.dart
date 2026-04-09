import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Courses
import 'package:e_learning_app/front_end/student_pages/courses/basic_computer_parts.dart';
import 'package:e_learning_app/front_end/student_pages/courses/com_repair.dart';
import 'package:e_learning_app/front_end/student_pages/courses/intro_to_comnet.dart';
import 'package:e_learning_app/front_end/student_pages/courses/os_concepts.dart';

// Services & Providers
import 'package:e_learning_app/back_end/services/pages/student/course/course_service.dart';
import 'package:e_learning_app/back_end/providers/user_provider.dart';

// Widgets
import 'package:e_learning_app/front_end/widgets/hamburgMenu.dart';
import '../../widgets/primary_appbar.dart';

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
    final studentId = context.read<UserProvider>().studentId;
    if (studentId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final progress = await _service.fetchCourseProgress(studentId);

    if (mounted) {
      setState(() {
        _courseProgress = progress;
        _isLoading = false;
      });
    }
  }

  double _getProgressNormalized(int courseId) {
    final value = _service.getProgress(_courseProgress, courseId);
    return value / 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final onPrimary = theme.colorScheme.onPrimary;
    final firstName = context.watch<UserProvider>().firstName ?? "Student";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PrimaryAppBar(title: "COURSES"),
      drawer: const AppDrawer(currentRoute: 'courses'),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
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
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: onPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Track your progress and unlock new knowledge.",
                          style: TextStyle(color: onPrimary.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "Your Enrolled Courses",
                    style: theme.textTheme.titleLarge?.copyWith(
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
        'instructor': "Prof. Dela Cruz",
        'page': const BasicComputerPartsPage(),
      },
      {
        'id': 2,
        'title': "Operating System Concepts",
        'instructor': "Prof. Santos",
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: enabled ? theme.cardTheme.color : theme.disabledColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: (enabled && !isDark)
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
                      color: enabled ? theme.textTheme.bodyLarge?.color : theme.disabledColor,
                    ),
                  ),
                ),
                Icon(
                  enabled ? Icons.lock_open : Icons.lock,
                  size: 18,
                  color: enabled ? primaryColor : theme.disabledColor,
                )
              ],
            ),

            const SizedBox(height: 6),

            Text(
              "Instructor: $instructor",
              style: TextStyle(
                fontSize: 13,
                color: enabled ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7) : theme.disabledColor,
              ),
            ),

            const SizedBox(height: 14),

            // Progress Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Progress",
                  style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
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
                backgroundColor: primaryColor.withOpacity(0.1),
                color: enabled ? primaryColor : theme.disabledColor,
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: enabled ? onTap : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: enabled ? primaryColor : theme.disabledColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  enabled
                      ? (progress == 0 ? "Start Course" : "Continue Course")
                      : "Locked",
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
