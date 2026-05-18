import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../back_end/providers/knowledge_lab_provider.dart';
import '../../../models/student/knowledge_lab/assessment_model.dart';
import 'quiz_taking_page.dart';
import '../../widgets/primary_appbar.dart';
import '../../widgets/hamburgMenu.dart';

class KnowledgeLabPage extends StatefulWidget {
  const KnowledgeLabPage({super.key});

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
    final provider = Provider.of<KnowledgeLabProvider>(context, listen: false);
    await provider.loadData(categoryId: _selectedCategoryId, forceRefresh: forceRefresh);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PrimaryAppBar(title: "Knowledge Lab"),
      drawer: const AppDrawer(currentRoute: 'knowledge'),
      body: Consumer<KnowledgeLabProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;
          final assessments = provider.assessments;
          final isLoading = provider.isLoading;

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
                    final isSelected = isAll 
                        ? _selectedCategoryId == null 
                        : _selectedCategoryId == category?.id;

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
                child: isLoading && assessments.isEmpty
                    ? Center(child: CircularProgressIndicator(color: primaryColor))
                    : RefreshIndicator(
                        onRefresh: () => _loadData(forceRefresh: true),
                        child: assessments.isEmpty
                            ? ListView(
                                children: const [
                                  SizedBox(height: 100),
                                  Center(child: Text("No assessments found for this category.")),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: assessments.length,
                                itemBuilder: (context, index) {
                                  final assessment = assessments[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _AssessmentCard(assessment: assessment),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================= ASSESSMENT CARD =================

class _AssessmentCard extends StatelessWidget {
  final Assessment assessment;

  const _AssessmentCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark ? null : [
          const BoxShadow(
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
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              assessment.categoryName ?? 'General',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            assessment.title,
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
              fontFamily: 'Poppins',
            ),
          ),

          if (assessment.description != null && assessment.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              assessment.description!,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
              maxLines: 2,
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
                  assessment.authorName ?? 'Admin', 
                  style: TextStyle(color: theme.textTheme.bodySmall?.color, fontFamily: 'Poppins'),
                ),
              ),
              Icon(Icons.list_alt, size: 16, color: theme.textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text(
                "${assessment.questionCount} Items",
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontFamily: 'Poppins'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Start Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizTakingPage(assessment: assessment),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Start Assessment",
                style: TextStyle(
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
    );
  }
}
