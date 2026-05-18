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
import '../../widgets/dialog/confirmation_dialog.dart';
import '../ar_lab/ar_activity_page.dart';
import '../ar_lab/ar_lab_page.dart';
import '../courses/courses_page.dart';
import '../courses/course_details_page.dart';

class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  final AnnouncementController _announcementController = AnnouncementController();
  final DashboardController _dashboardController = DashboardController();
  final ArLabController _arLabController = ArLabController();
  
  List<AnnouncementModel> _latestAnnouncements = [];
  List<Map<String, dynamic>> _courseProgress = [];
  int _arHighScore = 0;
  bool _isLoadingAnnouncements = true;
  bool _isLoadingProgress = true;
  bool _isLoadingAR = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // _checkFirstTimerStatus(); // Logic added but not executed yet as requested
  }

  // Logic to handle first-timer prompt (inactive for now)
  // void _checkFirstTimerStatus() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     if (userProvider.isFirstTimer) {
  //       FirstTimerPrompt.show(
  //         context,
  //         onProceed: () {
  //           Navigator.pop(context);
  //           // Navigator.push(
  //           //   context,
  //           //   MaterialPageRoute(builder: (_) => const KnowledgeLabPage(isFirstTimerMode: true)),
  //           // );
  //         },
  //       );
  //     }
  //   });
  // }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAnnouncements = true;
      _isLoadingProgress = true;
      _isLoadingAR = true;
    });
    await Future.wait([
      _fetchAnnouncements(),
      _fetchCourseProgress(),
      _fetchArData(),
    ]);
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
        body: RefreshIndicator(
          onRefresh: _loadData,
          color: primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Welcome Banner =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: gradient ?? LinearGradient(
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

                const SizedBox(height: 32),

                // ===== AR Lab Status Card =====
                if (Provider.of<UserProvider>(context).isArSupported) ...[
                  _buildArStatusCard(theme, primaryColor, cardColor, textColor, subTextColor),
                  const SizedBox(height: 32),
                ],

                // ===== Announcements Title Row =====
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

                const SizedBox(height: 16),

                if (_isLoadingAnnouncements)
                  Center(
                      child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: primaryColor),
                  ))
                else if (_latestAnnouncements.isEmpty)
                  Center(
                      child: Text("No announcements available.", style: TextStyle(color: subTextColor, fontFamily: 'Poppins')))
                else
                  ..._latestAnnouncements.take(2)
                      .map((announcement) => _buildAnnouncementCard(context, announcement, cardColor, primaryColor, textColor, subTextColor)),

                const SizedBox(height: 32),

                // ===== Progress Section =====
                Text(
                  "Your Learning Progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 16),

                if (_isLoadingProgress)
                   Center(child: CircularProgressIndicator(color: primaryColor))
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
                    return _buildProgressCard(context, title, instructor, rate, courseId, cardColor, primaryColor, textColor, subTextColor);
                  }),
              ],
            ),
          ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_stories_outlined, size: 64, color: primaryColor.withAlpha(128)),
          const SizedBox(height: 20),
          Text(
            "Your journey starts here!",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          Text(
            "You haven't started any courses yet. Explore our library to begin learning.",
            textAlign: TextAlign.center,
            style: TextStyle(color: subTextColor, fontSize: 14, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: "Explore Courses",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CoursesPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, String title, String instructor, double rate, int? courseId, Color cardColor, Color primaryColor, Color textColor, Color subTextColor) {
    return GestureDetector(
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
    return GestureDetector(
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
      builder: (context) => Container(
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
      ),
    );
  }
}
