import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_learning_app/models/student/course/course_model.dart';
import 'package:e_learning_app/back_end/controllers/student/course/course_controller.dart';
import 'package:e_learning_app/back_end/services/pages/student/course/course_service.dart';
import 'package:e_learning_app/front_end/student_pages/courses/course_details_page.dart';
import 'package:e_learning_app/back_end/providers/user_provider.dart';
import 'package:e_learning_app/front_end/widgets/modern_course_card.dart';
import '../../widgets/primary_appbar.dart';
import '../../widgets/hamburgMenu.dart';
import '../../widgets/skeleton_widgets.dart';
import '../../widgets/empty_state_widget.dart';

class CoursesPage extends StatefulWidget {
  final bool isInsideShell;
  const CoursesPage({super.key, this.isInsideShell = false});
  @override
  State<CoursesPage> createState() => _CoursesPageState();
}
class _CoursesPageState extends State<CoursesPage> {
  final CourseController _controller = CourseController();
  final CoursesService _service = CoursesService();
  bool _isLoading = true;
  List<CourseModel> _allCourses = [];
  List<CourseModel> _recommendedCourses = [];
  String? _weakestCategory;
  int? _weakestCategoryId;
  List<Map<String, dynamic>> _courseProgress = [];
  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;

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
      
      final results = await Future.wait([
        _service.fetchAllCourses(),
        userId != null ? _controller.getCourseProgress(userId) : Future.value(<Map<String, dynamic>>[]),
        userId != null ? _controller.getRecommendationData(userId) : Future.value({'courses': <CourseModel>[], 'focusCategory': null, 'focusCategoryId': null}),
        _service.fetchCategories(),
      ]);

      if (mounted) {
        final recommendationData = results[2] as Map<String, dynamic>;
        setState(() {
          _allCourses = results[0] as List<CourseModel>;
          _courseProgress = results[1] as List<Map<String, dynamic>>;
          _recommendedCourses = recommendationData['courses'] as List<CourseModel>;
          _weakestCategory = recommendationData['focusCategory'] as String?;
          _weakestCategoryId = recommendationData['focusCategoryId'] as int?;
          _categories = results[3] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading courses: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<CourseModel> get _filteredCourses {
    if (_selectedCategoryId == null) return _allCourses;
    return _allCourses.where((c) => c.categoryId == _selectedCategoryId).toList();
  }

  bool get _hasAnyProgress {
    return _courseProgress.any((p) => (p['progress_rate'] ?? 0.0) > 0);
  }

  Widget _buildCategoryFilter() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : _categories[index - 1];
          final categoryId = category?['cat_id'];
          final categoryName = isAll ? "All" : category?['category'] ?? "";
          final isSelected = _selectedCategoryId == categoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(categoryName),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedCategoryId = isAll ? null : categoryId;
                  });
                }
              },
              selectedColor: primaryColor,
              backgroundColor: theme.cardTheme.color,
              labelStyle: TextStyle(
                color: isSelected ? onPrimary : primaryColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: primaryColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialRecommendation() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (_weakestCategory == null) return const SizedBox.shrink();

    final String recommendationText = "Based on your First Time Assessment, you should focus on $_weakestCategory. This course is a great place to start!";

    // Check if the recommended course actually matches the weakest category
    final bool hasCourseForWeakest = _recommendedCourses.isNotEmpty && _recommendedCourses.first.categoryId == _weakestCategoryId;
    
    final CourseModel? displayCourse = _recommendedCourses.isNotEmpty ? _recommendedCourses.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  recommendationText,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!hasCourseForWeakest) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "No specialized courses currently available for this category.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              "Recommended for you instead:",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.grey, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
          ],
          if (displayCourse != null) ...[
            if (displayCourse.categoryName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  displayCourse.categoryName!.toUpperCase(),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              displayCourse.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Instructor: ${displayCourse.instructor}",
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodySmall?.color,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailsPage(courseId: displayCourse.id),
                    ),
                  ).then((_) => _loadData());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Start Recommended Course",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("All available courses completed!", style: TextStyle(fontFamily: 'Poppins'))),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCourseList() {
    return _filteredCourses.map((course) {
      final double progress = _controller.calculateProgress(_courseProgress, course.id);
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: ModernCourseCard(
          courseId: course.id,
          title: course.title,
          instructor: course.instructor,
          category: course.categoryName,
          progress: progress,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsPage(courseId: course.id))).then((_) => _loadData());
          },
        ),
      );
    }).toList();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final onPrimary = theme.colorScheme.onPrimary;
    final firstName = context.watch<UserProvider>().firstName ?? "Student";

    Widget content = RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    const BannerSkeleton()
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_hasAnyProgress ? "Continue Learning, $firstName" : "Start Learning, $firstName",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: onPrimary,
                                  fontFamily: 'Poppins')),
                          const SizedBox(height: 6),
                          Text(
                              _hasAnyProgress
                                  ? "Track your progress and unlock new knowledge."
                                  : "Begin your journey by exploring our available courses.",
                              style: TextStyle(color: onPrimary.withOpacity(0.7), fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Skeleton(height: 45, width: double.infinity)
                  else
                    _buildCategoryFilter(),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const CardSkeleton()
                  else if (_recommendedCourses.isNotEmpty) ...[
                    _buildSpecialRecommendation(),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    _selectedCategoryId == null ? "All Available Courses" : "Filtered Courses",
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    Column(children: List.generate(2, (index) => const CardSkeleton()))
                  else if (_filteredCourses.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.search_off_rounded,
                      title: "No courses found",
                      description: "We couldn't find any courses matching your criteria. Try adjusting your filters.",
                      actionLabel: "Clear Filters",
                      onAction: () {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    )
                  else
                    ..._buildCourseList(),
                ],
              ),
            ),
    );

    if (widget.isInsideShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PrimaryAppBar(title: "COURSES"),
      drawer: const AppDrawer(currentRoute: 'courses'),
      body: content,
    );
  }
}

