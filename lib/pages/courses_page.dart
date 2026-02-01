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


class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

final List<int> courseOrder = [1, 2, 3, 4];

class _CoursesPageState extends State<CoursesPage> {
  final CoursesService _service = CoursesService();

  bool _isSearching = false;
  bool _isLoading = true;

  List<Map<String, dynamic>> _courseProgress = [];
  final TextEditingController _searchController = TextEditingController();

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

  // Normalized progress 0.0 - 1.0 for progress bar
  double _getProgressNormalized(int courseId) {
    final value = _service.getProgress(_courseProgress, courseId);
    return value / 100; // convert 0-100 to 0-1
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: _buildAppBar(),
        drawer: const AppDrawer(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: const Color(0xFF33A1E0),
      iconTheme: const IconThemeData(color: Colors.white, size: 30),
      title: _isSearching
          ? TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: "Search courses...",
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
      )
          : const Text(
        "Courses",
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
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        )
            : IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            setState(() => _isSearching = true);
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              'Enrolled Courses',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            _buildCourseList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Course definitions
    final List<Map<String, dynamic>> courses = [
      {
        'id': 1,
        'title': "Basic Computer Parts",
        'instructor': "Mr. Smith",
        'imageUrl':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRuCRX1MimMNvfrDz0sVYB10Ld2ecrXLIdsVw&s',
        'page': const BasicComputerPartsPage(),
      },
      {
        'id': 2,
        'title': "Operating System Concepts",
        'instructor': "Dr. Rivera",
        'imageUrl':
        'https://thumbs.dreamstime.com/b/outline-operating-system-vector-icon-isolated-black-simple-line-element-illustration-electronic-devices-concept-editable-144280733.jpg',
        'page': const OperatingSystemConceptsPage(),
      },
      {
        'id': 3,
        'title': "Intro to Computer Networking",
        'instructor': "Ms. Garcia",
        'imageUrl':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR41p1ogsKZvsAZhq21cXKkyuu3Ble4pB7ZFQ&s',
        'page': const FundamentalsOfComputerNetworkingPage(),
      },
      {
        'id': 4,
        'title': "Computer Troubleshooting & Repair",
        'instructor': "Prof. Tan",
        'imageUrl':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcStAbXmDmEyQmMy70NUafJPcHm8o6ndpKbo0Q&s',
        'page': const ComputerRepairPage(),
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, index) {
        final course = courses[index];
        final courseId = course['id'] as int;

        // Unlock logic uses raw 0-100 progress
        final enabled =
        _service.isCourseUnlocked(courseId, _courseProgress, courseOrder);

        // Progress for progress bar normalized 0-1
        final progressNormalized = _getProgressNormalized(courseId);

        return CourseCard(
          enabled: enabled,
          imageUrl: course['imageUrl'],
          courseTitle: course['title'],
          instructor: course['instructor'],
          progress: progressNormalized,
          onContinue: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => course['page']),
          ),
        );
      },
    );
  }

  Widget drawerButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== COURSE CARD ======================
class CourseCard extends StatelessWidget {
  final String imageUrl;
  final String courseTitle;
  final String instructor;
  final double progress;
  final VoidCallback onContinue;
  final bool enabled;

  const CourseCard({
    super.key,
    required this.imageUrl,
    required this.courseTitle,
    required this.instructor,
    required this.progress,
    required this.onContinue,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF33A1E0);
    final Color deepBlue = const Color(0xFF1565C0);
    final Color disabledColor = primaryBlue.withValues(alpha: 0.5);

    return Opacity(
      opacity: enabled ? 1.0 : 0.8,
      child: Card(
        color: Colors.white,
        elevation: enabled ? 3 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  colorFilter: enabled
                      ? null
                      : ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.2),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: enabled ? Colors.black : deepBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Instructor: $instructor",
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? Colors.black54 : deepBlue.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: primaryBlue.withValues(alpha: 0.2),
                      color: enabled ? primaryBlue : disabledColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Progress: ${(progress * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled ? Colors.black87 : deepBlue.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: enabled ? onContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: enabled ? deepBlue : disabledColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        enabled ? (progress == 0 ? "Start" : "Continue") : "Locked",
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}