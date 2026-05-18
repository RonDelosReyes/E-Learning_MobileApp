import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Models & Controllers
import 'package:e_learning_app/models/student/course/course_model.dart';
import 'package:e_learning_app/back_end/controllers/student/course/course_controller.dart';
import 'package:e_learning_app/back_end/services/pages/student/course/course_service.dart';

// Pages
import 'package:e_learning_app/front_end/student_pages/courses/course_details_page.dart';

// Providers
import 'package:e_learning_app/back_end/providers/user_provider.dart';

// Widgets
import 'package:e_learning_app/front_end/widgets/hamburgMenu.dart';
import '../../widgets/primary_appbar.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final CourseController _controller = CourseController();
  final CoursesService _service = CoursesService();
  
  bool _isLoading = true;
  List<CourseModel> _allCourses = [];
  List<Map<String, dynamic>> _courseProgress = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final userProvider = context.read<UserProvider>();
      final userId = userProvider.userId;
      
      // Fetch both all courses and the user's progress
      final results = await Future.wait([
        _service.fetchAllCourses(),
        if (userId != null) _controller.getCourseProgress(userId) else Future.value(<Map<String, dynamic>>[]),
      ]);

      if (mounted) {
        setState(() {
          _allCourses = results[0] as List<CourseModel>;
          _courseProgress = results[1] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading courses: $e");
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Track your progress and unlock new knowledge.",
                            style: TextStyle(
                              color: onPrimary.withAlpha(179),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      "Your Enrolled Courses",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_allCourses.isEmpty)
                      const Center(child: Text("No courses available at the moment."))
                    else
                      ..._buildCourseList(),
                  ],
                ),
              ),
      ),
    );
  }

  List<Widget> _buildCourseList() {
    // Determine the order for unlocking (by ID for now, or you can add an order column to tbl_course)
    final List<int> courseOrder = _allCourses.map((c) => c.id).toList()..sort();

    return _allCourses.map((course) {
      final bool enabled = _controller.isUnlocked(course.id, _courseProgress, courseOrder);
      final double progress = _controller.calculateProgress(_courseProgress, course.id);

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ModernCourseCard(
          title: course.title,
          instructor: course.instructor,
          progress: progress,
          enabled: enabled,
          onTap: () {
            if (enabled) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourseDetailsPage(courseId: course.id),
                ),
              ).then((_) => _loadData()); // Refresh on return to update progress
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
          color: enabled ? (isDark ? const Color(0xFF1B263B) : theme.cardColor) : theme.disabledColor.withAlpha(26),
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
                      fontFamily: 'Poppins',
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
                fontFamily: 'Poppins',
                color: enabled ? theme.textTheme.bodyMedium?.color?.withAlpha(179) : theme.disabledColor,
              ),
            ),

            const SizedBox(height: 14),

            // Progress Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Progress",
                  style: TextStyle(
                    fontSize: 13, 
                    fontFamily: 'Poppins',
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
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
                backgroundColor: primaryColor.withAlpha(26),
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
                  style: const TextStyle(
                    fontSize: 14, 
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
