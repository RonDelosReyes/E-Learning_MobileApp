import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/primary_appbar.dart';
import '../../widgets/hamburgMenu.dart';
import '../../widgets/pdf_viewer_page.dart';
import '../../../back_end/services/pages/student/tech_library/techlib_service.dart';
import '../../../models/student/tech_library/resource_model.dart';

class TechLibraryPage extends StatefulWidget {
  const TechLibraryPage({super.key});

  @override
  State<TechLibraryPage> createState() => _TechLibraryPageState();
}

class _TechLibraryPageState extends State<TechLibraryPage> {
  final TechLibraryService _service = TechLibraryService();
  
  List<ResourceType> _types = [];
  List<ResourceModel> _resources = [];
  int? _selectedTypeId; // null means "All"
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final types = await _service.fetchResourceTypes();
      final resources = await _service.fetchResources(typeId: _selectedTypeId);
      
      if (mounted) {
        setState(() {
          _types = types;
          _resources = resources;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("TECH_LIB_ERROR: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const PrimaryAppBar(title: "Tech Library"),
      drawer: const AppDrawer(currentRoute: 'techlib'),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header Banner =====
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Learning Resources 📚",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: onPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Access modules, references, and study materials.",
                      style: TextStyle(color: onPrimary.withOpacity(0.7), fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== Category Filter =====
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryChip("All", null),
                    ..._types.map((type) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: _categoryChip(type.type, type.id),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_isLoading)
                Center(child: CircularProgressIndicator(color: primaryColor))
              else if (_resources.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text("No resources found.", style: TextStyle(fontFamily: 'Poppins'))),
                )
              else
                ..._resources.map((res) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ModernTechFileCard(
                    resource: res,
                    onRead: () {
                      if (res.type.toUpperCase() == 'PDF') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerPage(
                              url: res.fileUrl,
                              title: res.title,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Opening ${res.type} is not supported yet.")),
                        );
                      }
                    },
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String label, int? typeId) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final bool isSelected = _selectedTypeId == typeId;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (val) {
        if (val) {
          setState(() => _selectedTypeId = typeId);
          _loadData();
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
    );
  }
}

// ================= MODERN FILE CARD =================

class ModernTechFileCard extends StatelessWidget {
  final ResourceModel resource;
  final VoidCallback onRead;

  const ModernTechFileCard({
    super.key,
    required this.resource,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    IconData getIcon() {
      switch (resource.type.toUpperCase()) {
        case 'PDF': return Icons.picture_as_pdf;
        case 'VIDEO': return Icons.video_library;
        case 'IMAGE': return Icons.image;
        case 'PPTX': return Icons.slideshow;
        case 'DOCX': return Icons.description;
        case 'XLSX': return Icons.table_chart;
        default: return Icons.insert_drive_file;
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark ? null : const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // File Icon Container
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(getIcon(), color: primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "By: ${resource.uploaderName}",
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12, fontFamily: 'Poppins'),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRead,
                icon: Icon(Icons.arrow_forward_ios,
                    size: 18, color: theme.textTheme.bodySmall?.color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _infoBadge(resource.category, Colors.blue),
                  const SizedBox(width: 8),
                  _infoBadge(resource.type, Colors.orange),
                ],
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(resource.dateUploaded),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11, fontFamily: 'Poppins'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
