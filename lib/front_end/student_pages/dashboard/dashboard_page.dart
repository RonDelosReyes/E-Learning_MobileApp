import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../back_end/providers/user_provider.dart';
import '../../../back_end/controllers/announcement_controller.dart';
import '../../../back_end/controllers/student/dashboard/dashboard_controller.dart';
import '../../../back_end/controllers/student/ar_lab/ar_lab_controller.dart';
import '../../../models/announcement_model.dart';
import '../../widgets/hamburgMenu.dart';
import '../../widgets/announcement_modal.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/modern_course_card.dart';
import '../courses/courses_page.dart';
import '../courses/course_details_page.dart';
import '../ar_lab/ar_activity_page.dart';
import '../../widgets/dialog/confirmation_dialog.dart';
import '../../widgets/skeleton_widgets.dart';
import '../../widgets/empty_state_widget.dart';

class DashBoardPage extends StatefulWidget {
  final bool isInsideShell;
  const DashBoardPage({super.key, this.isInsideShell = false});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> with TickerProviderStateMixin {
  final DashboardController _dashboardController = DashboardController();
  final ArLabController _arLabController = ArLabController();
  final AnnouncementController _announcementController = AnnouncementController();

  List<AnnouncementModel> _latestAnnouncements = [];
  List<Map<String, dynamic>> _courseProgress = [];
  List<Map<String, dynamic>> _recommendedCourses = [];
  int _arHighScore = 0;

  bool _isLoadingAnnouncements = true;
  bool _isLoadingProgress = true;
  bool _isLoadingAR = true;
  bool _isLoadingRecommendations = true;

  late AnimationController _staggerController;
  final List<Animation<double>> _staggerAnimations = [];
  static const int _itemCount = 6; // Welcome, AR, Recommended, Announcements title, Announcements, Progress title, Progress

  @override
  void initState() {
    super.initState();
    _loadData();

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    for (int i = 0; i < _itemCount; i++) {
      _staggerAnimations.add(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            (i * 0.1).clamp(0.0, 1.0),
            ((i * 0.1) + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    }
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  // Staggered animation builder
  Widget _buildStaggeredItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _staggerAnimations[index],
      builder: (context, child) {
        return Opacity(
          opacity: _staggerAnimations[index].value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _staggerAnimations[index].value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAnnouncements = true;
      _isLoadingProgress = true;
      _isLoadingAR = true;
      _isLoadingRecommendations = true;
    });
    await Future.wait([
      _fetchAnnouncements(),
      _fetchCourseProgress(),
      _fetchArData(),
      _fetchRecommendations(),
    ]);
  }

  Future<void> _fetchRecommendations() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userId != null) {
        final recommended = await _dashboardController.getRecommendedCourses(userProvider.userId!);
        if (mounted) {
          setState(() {
            _recommendedCourses = recommended;
            _isLoadingRecommendations = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRecommendations = false);
    }
  }

  Future<void> _fetchArData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userId != null) {
        final score = await _arLabController.getBestScore(userProvider.userId!, "AR_Assembly_Challenge");
        if (mounted) {
          setState(() {
            _arHighScore = score;
            _isLoadingAR = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAR = false);
    }
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final announcements = await _announcementController.getLatestAnnouncements();
      if (mounted) {
        setState(() {
          _latestAnnouncements = announcements;
          _isLoadingAnnouncements = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingAnnouncements = false);
    }
  }

  Future<void> _fetchCourseProgress() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;
      if (userId != null) {
        final progress = await _dashboardController.getCourseProgress(userId);
        if (mounted) {
          setState(() {
            _courseProgress = progress;
            _isLoadingProgress = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProgress = false);
    }
  }

  void _showExitDialog(BuildContext context) {
    ConfirmationDialog.show(
      context: context,
      title: 'Exit App',
      message: 'Are you sure you want to exit the application?',
      confirmLabel: 'Yes, Exit',
      cancelLabel: 'No, Stay',
      icon: Icons.exit_to_app_rounded,
    ).then((confirmed) {
      if (confirmed == true) {
        SystemNavigator.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardTheme.color ?? theme.cardColor;
    final onPrimary = theme.colorScheme.onPrimary;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subTextColor = theme.textTheme.bodySmall?.color ?? Colors.white70;
    final gradient = theme.extension<AppGradient>()?.primary;

    final firstName = Provider.of<UserProvider>(context).firstName ?? "Student";

    // Filter courses that are not 100% completed
    final ongoingProgress = _courseProgress.where((p) {
      final rate = (p['progress_rate'] as num?)?.toDouble() ?? 0.0;
      return rate < 1.0;
    }).toList();

    Widget content = RefreshIndicator(
      onRefresh: _loadData,
      color: primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Welcome Banner =====
            _buildStaggeredItem(
              0,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: gradient ??
                      LinearGradient(
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
                      "Welcome back, $firstName",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: onPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Stay updated and continue your learning journey today.",
                      style: TextStyle(
                        color: onPrimary.withAlpha(204),
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ===== AR Lab Status Card =====
            if (Provider.of<UserProvider>(context).isArSupported) ...[
              _buildStaggeredItem(1, _buildArStatusCard(theme, primaryColor, cardColor, textColor, subTextColor)),
              const SizedBox(height: 32),
            ],

            if (_isLoadingRecommendations)
              _buildStaggeredItem(
                2,
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (context, index) => Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 16),
                      child: const CardSkeleton(),
                    ),
                  ),
                ),
              )
            else if (_recommendedCourses.isNotEmpty) ...[
              _buildStaggeredItem(
                2,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recommended for You",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Based on your assessment, we suggest focusing on these areas:",
                      style: TextStyle(
                        fontSize: 12,
                        color: subTextColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recommendedCourses.length,
                        itemBuilder: (context, index) {
                          final course = _recommendedCourses[index];
                          return _buildRecommendedCard(context, course, cardColor, primaryColor, textColor, subTextColor);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            // ===== Announcements Title Row =====
            _buildStaggeredItem(
              3,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Latest Announcements",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => AnnouncementModal.show(context),
                    child: Text(
                      "See All",
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoadingAnnouncements)
              Column(
                children: List.generate(2, (index) => _buildStaggeredItem(4, const ListTileSkeleton())),
              )
            else if (_latestAnnouncements.isEmpty)
              Center(
                  child: Text("No announcements available.",
                      style: TextStyle(color: subTextColor, fontFamily: 'Poppins')))
            else
              ..._latestAnnouncements.take(2).map((announcement) =>
                  _buildStaggeredItem(4, _buildAnnouncementCard(context, announcement, cardColor, primaryColor, textColor, subTextColor))),

            const SizedBox(height: 32),

            // ===== Progress Section =====
            _buildStaggeredItem(
              5,
              Text(
                "Your Learning Progress",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_isLoadingProgress)
              Column(
                children: List.generate(2, (index) => const CardSkeleton()),
              )
            else if (ongoingProgress.isEmpty)
              _buildEmptyProgressPlaceholder(context, cardColor, primaryColor, textColor, subTextColor)
            else
              ...ongoingProgress.map((p) {
                final course = p['tbl_course'];
                final title = course != null ? (course['title'] ?? "Unknown Course") : "Unknown Course";
                final courseId = course != null ? course['course_id'] : null;

                String instructor = "Unknown Instructor";
                if (course != null && course['tbl_admin'] != null) {
                  final admin = course['tbl_admin'];
                  if (admin['tbl_user'] != null) {
                    instructor = "${admin['tbl_user']['firstName']} ${admin['tbl_user']['lastName']}";
                  }
                }

                final rate = (p['progress_rate'] as num?)?.toDouble() ?? 0.0;
                return _buildProgressCard(
                    context, title, instructor, rate, courseId, cardColor, primaryColor, textColor, subTextColor);
              }),
          ],
        ),
      ),
    );

    if (widget.isInsideShell) {
      return content;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          flexibleSpace: gradient != null
              ? Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                  ),
                )
              : null,
          title: Text(
            'CSTA E-Learning',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onPrimary,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: gradient != null ? Colors.transparent : primaryColor,
          iconTheme: IconThemeData(color: onPrimary, size: 28),
        ),
        drawer: const AppDrawer(currentRoute: 'home'),
        body: content,
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, Map<String, dynamic> course, Color cardColor, Color primaryColor, Color textColor, Color subTextColor) {
    final title = course['title'] ?? "Unknown Course";
    final category = course['tbl_category'] != null ? course['tbl_category']['category'] : "General";
    final courseId = course['course_id'];

    return _DashboardInteractiveCard(
      onTap: () {
        if (courseId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(courseId: courseId),
            ),
          ).then((_) => _loadData());
        }
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Recommended for You",
              style: TextStyle(
                color: primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Hero(
                tag: 'course_title_$courseId',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArStatusCard(ThemeData theme, Color primaryColor, Color cardColor, Color textColor, Color subTextColor) {
    final userProvider = Provider.of<UserProvider>(context);
    final isSupported = userProvider.isArSupported;

    return GestureDetector(
      onTap: isSupported
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArActivityPage()),
              );
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    "AR features are not supported on this device",
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
      child: Opacity(
        opacity: isSupported ? 1.0 : 0.5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSupported ? Icons.view_in_ar_outlined : Icons.lock_outline,
                  color: isSupported ? primaryColor : Colors.grey,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AR Assembly Lab",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSupported ? textColor : textColor.withOpacity(0.5),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      !isSupported
                          ? "Incompatible Device"
                          : _isLoadingAR
                              ? "Loading stats..."
                              : "Personal Best: $_arHighScore",
                      style: TextStyle(
                        fontSize: 13,
                        color: isSupported ? subTextColor : subTextColor.withOpacity(0.5),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSupported ? Icons.chevron_right : Icons.lock_outline,
                color: subTextColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyProgressPlaceholder(BuildContext context, Color cardColor, Color primaryColor, Color textColor, Color subTextColor) {
    return EmptyStateWidget(
      icon: Icons.auto_stories_outlined,
      title: "Your journey starts here!",
      description: "You haven't started any courses yet. Explore our library to begin learning.",
      actionLabel: "Explore Courses",
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CoursesPage()),
        );
      },
    );
  }

  Widget _buildProgressCard(BuildContext context, String title, String instructor, double rate, int? courseId, Color cardColor, Color primaryColor, Color textColor, Color subTextColor) {
    return _DashboardInteractiveCard(
      onTap: () {
        if (courseId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseDetailsPage(courseId: courseId),
            ),
          ).then((_) => _loadData());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Hero(
                    tag: 'course_title_$courseId',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  "${(rate * 100).toInt()}%",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: rate,
                minHeight: 8,
                backgroundColor: textColor.withAlpha(20),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Instructor: $instructor",
              style: TextStyle(
                color: subTextColor.withAlpha(150),
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(BuildContext context, AnnouncementModel announcement, Color cardColor, Color primaryColor, Color textColor, Color subTextColor) {
    return _DashboardInteractiveCard(
      onTap: () => _showAnnouncementDetail(announcement),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Colored Bar (Dynamic Theme)
              Container(
                width: 4,
                color: announcement.isPinned ? Colors.orange : primaryColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (announcement.isPinned) ...[
                            const Icon(Icons.push_pin_rounded, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                          ],
                          Expanded(
                            child: Text(
                              announcement.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        announcement.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(announcement.createdAt),
                        style: TextStyle(
                          color: subTextColor.withAlpha(100),
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnnouncementDetail(AnnouncementModel announcement) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subTextColor = theme.textTheme.bodySmall?.color ?? Colors.white70;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AnnouncementDetailModal(announcement: announcement),
    );
  }
}

class _DashboardInteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _DashboardInteractiveCard({required this.child, required this.onTap});

  @override
  State<_DashboardInteractiveCard> createState() => _DashboardInteractiveCardState();
}

class _DashboardInteractiveCardState extends State<_DashboardInteractiveCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _AnnouncementDetailModal extends StatelessWidget {
  final AnnouncementModel announcement;
  const _AnnouncementDetailModal({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final subTextColor = theme.textTheme.bodySmall?.color ?? Colors.white70;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textColor.withAlpha(51),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (announcement.isPinned)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.push_pin_rounded, size: 12, color: Colors.orange.shade800),
                              const SizedBox(width: 4),
                              Text("PINNED",
                                  style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(announcement.createdAt),
                        style: TextStyle(color: subTextColor.withAlpha(150), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    announcement.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: primaryColor.withAlpha(51),
                        child: Icon(Icons.person, size: 14, color: primaryColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        announcement.authorName ?? 'Admin',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (announcement.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        announcement.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    announcement.content,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 16,
                      height: 1.6,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Got it",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
