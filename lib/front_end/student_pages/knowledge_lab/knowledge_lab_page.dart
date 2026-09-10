import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../back_end/providers/knowledge_lab_provider.dart';
import '../../../back_end/providers/user_provider.dart';
import '../../../models/student/knowledge_lab/assessment_model.dart';
import 'quiz_taking_page.dart';
import '../../widgets/primary_appbar.dart';
import '../../widgets/hamburgMenu.dart';
import '../../widgets/skeleton_widgets.dart';
import '../../widgets/empty_state_widget.dart';

class KnowledgeLabPage extends StatefulWidget {
  final bool isInsideShell;
  const KnowledgeLabPage({super.key, this.isInsideShell = false});

  @override
  State<KnowledgeLabPage> createState() => _KnowledgeLabPageState();
}

class _KnowledgeLabPageState extends State<KnowledgeLabPage> {
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final provider = Provider.of<KnowledgeLabProvider>(context, listen: false);
    await provider.loadData(
      categoryId: _selectedCategoryId, 
      userId: userProvider.userId,
      forceRefresh: forceRefresh
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    Widget content = Consumer<KnowledgeLabProvider>(
      builder: (context, provider, child) {
        final categories = provider.categories;
        final assessments = provider.assessments;
        final isLoading = provider.isLoading;

        // Reorder assessments: Unlocked first, Locked last
        final List<Assessment> displayList = List<Assessment>.from(assessments);
        displayList.sort((a, b) {
          bool aLocked = false;
          if (a.courseNo != null) {
            final progress = provider.courseProgress[a.courseNo] ?? 0.0;
            if (progress < 1.0) aLocked = true;
          }

          bool bLocked = false;
          if (b.courseNo != null) {
            final progress = provider.courseProgress[b.courseNo] ?? 0.0;
            if (progress < 1.0) bLocked = true;
          }

          if (aLocked && !bLocked) return 1; // a moves down
          if (!aLocked && bLocked) return -1; // a moves up
          return 0; // maintain relative order
        });

        return Column(
          children: [
            const SizedBox(height: 20),

            // ===== CATEGORY FILTER =====
            SizedBox(
              height: 45,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final category = isAll ? null : categories[index - 1];
                  final isSelected = isAll ? _selectedCategoryId == null : _selectedCategoryId == category?.id;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(isAll ? "All" : category!.name),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategoryId = isAll ? null : category?.id;
                          });
                          _loadData(forceRefresh: true);
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
            ),

            const SizedBox(height: 20),

            // ===== ASSESSMENT LIST =====
            Expanded(
              child: RefreshIndicator(
                      onRefresh: () => _loadData(forceRefresh: true),
                      child: isLoading && displayList.isEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: 3,
                            itemBuilder: (context, index) => const CardSkeleton(),
                          )
                        : displayList.isEmpty
                          ? const EmptyStateWidget(
                              icon: Icons.quiz_outlined,
                              title: "No assessments available",
                              description: "Complete your courses to unlock their associated final assessments.",
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                final assessment = displayList[index];
                                final bestAttempt = provider.bestAttempts[assessment.id];

                                // Lock logic check for the card
                                bool isLocked = false;
                                if (assessment.courseNo != null) {
                                  final progress = provider.courseProgress[assessment.courseNo] ?? 0.0;
                                  if (progress < 1.0) {
                                    isLocked = true;
                                  }
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _AssessmentCard(
                                    assessment: assessment,
                                    bestAttempt: bestAttempt,
                                    isLocked: isLocked,
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        );
      },
    );

    if (widget.isInsideShell) {
      return content;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PrimaryAppBar(title: "Knowledge Lab"),
      drawer: const AppDrawer(currentRoute: 'knowledge'),
      body: content,
    );
  }
}

// ================= ASSESSMENT CARD =================

class _AssessmentCard extends StatefulWidget {
  final Assessment assessment;
  final Map<String, dynamic>? bestAttempt;
  final bool isLocked;

  const _AssessmentCard({
    required this.assessment, 
    this.bestAttempt,
    this.isLocked = false,
  });

  @override
  State<_AssessmentCard> createState() => _AssessmentCardState();
}

class _AssessmentCardState extends State<_AssessmentCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final bool hasAttempt = widget.bestAttempt != null;
    final int? score = widget.bestAttempt?['raw_score'];
    final int? total = widget.bestAttempt?['total_questions'];
    final bool isPassed = widget.bestAttempt?['is_passed'] ?? false;

    return GestureDetector(
      onTapDown: widget.isLocked ? null : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLocked ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.isLocked ? null : () => setState(() => _isPressed = false),
      onTap: widget.isLocked
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizTakingPage(assessment: widget.assessment),
                ),
              ).then((_) {
                // Refresh data after taking quiz
                final provider = Provider.of<KnowledgeLabProvider>(context, listen: false);
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                provider.loadData(userId: userProvider.userId, forceRefresh: true);
              });
            },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDark
                ? null
                : [
                    const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Opacity(
            opacity: widget.isLocked ? 0.7 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.assessment.categoryName ?? 'General',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),

                    if (widget.isLocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_outline, size: 12, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              "LOCKED",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  widget.assessment.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                    fontFamily: 'Poppins',
                  ),
                ),

                if (widget.isLocked) ...[
                  const SizedBox(height: 8),
                  Text(
                    "You must complete the associated course (100%) to unlock this final assessment.",
                    style: TextStyle(
                      color: theme.colorScheme.error.withValues(alpha: 0.8),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                if (!widget.isLocked && hasAttempt) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Highest Score",
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color,
                                fontFamily: 'Poppins',
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "$score / $total",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isPassed ? Colors.green : Colors.red),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPassed ? "PASSED" : "FAILED",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (!widget.isLocked &&
                    widget.assessment.description != null &&
                    widget.assessment.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.assessment.description!,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // Author + Items
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.assessment.authorName ?? 'Admin',
                        style: TextStyle(color: theme.textTheme.bodySmall?.color, fontFamily: 'Poppins'),
                      ),
                    ),
                    Icon(Icons.list_alt, size: 16, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.assessment.questionCount} Items",
                      style: TextStyle(color: theme.textTheme.bodySmall?.color, fontFamily: 'Poppins'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.isLocked
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuizTakingPage(assessment: widget.assessment),
                              ),
                            ).then((_) {
                              // Refresh data after taking quiz
                              final provider = Provider.of<KnowledgeLabProvider>(context, listen: false);
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              provider.loadData(userId: userProvider.userId, forceRefresh: true);
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isLocked ? Colors.grey : primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      widget.isLocked
                          ? "Course Completion Required"
                          : (hasAttempt ? "Retake Assessment" : "Start Assessment"),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
