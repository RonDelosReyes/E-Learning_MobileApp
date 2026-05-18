import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_learning_app/back_end/services/pages/student/tech_library/techlib_service.dart';
import 'package:e_learning_app/models/student/tech_library/resource_model.dart';
import 'package:e_learning_app/front_end/widgets/hamburgMenu.dart';
import 'package:e_learning_app/front_end/widgets/pdf_viewer_page.dart';
import 'package:e_learning_app/front_end/widgets/media_viewer_page.dart';

class TechLibraryPage extends StatefulWidget {
  const TechLibraryPage({super.key});

  @override
  State<TechLibraryPage> createState() => _TechLibraryPageState();
}

class _TechLibraryPageState extends State<TechLibraryPage> {
  final TechLibraryService _service = TechLibraryService();
  List<ResourceType> _types = [];
  List<ResourceModel> _resources = [];
  int? _selectedTypeId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _service.fetchResourceTypes(),
      _service.fetchResources(typeId: _selectedTypeId),
    ]);
    if (mounted) {
      setState(() {
        _types = results[0] as List<ResourceType>;
        _resources = results[1] as List<ResourceModel>;
        _isLoading = false;
      });
    }
  }

  void _openResource(ResourceModel resource) {
    final type = resource.type.toLowerCase();
    if (type.contains('pdf')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerPage(url: resource.fileUrl, title: resource.title)));
    } else if (type.contains('video')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerPage(url: resource.fileUrl, title: resource.title, type: 'video')));
    } else if (type.contains('image')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => MediaViewerPage(url: resource.fileUrl, title: resource.title, type: 'image')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Format not supported for direct viewing.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        title: const Text(
          'Tech Library',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'Poppins',
            letterSpacing: 1.2,
          ),
        ),
      ),
      drawer: const AppDrawer(currentRoute: 'techlib'),
      body: Column(
        children: [
          // Banner Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "Learning Resources 📚",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Access modules, references, and study materials.",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontFamily: 'Poppins'),
                  ),
                ],
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip(context, "All", _selectedTypeId == null, () {
                  setState(() => _selectedTypeId = null);
                  _loadData();
                }),
                ..._types.map((type) => _buildFilterChip(context, type.type, _selectedTypeId == type.id, () {
                  setState(() => _selectedTypeId = type.id);
                  _loadData();
                })),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: primaryColor,
                    child: _resources.isEmpty
                        ? const Center(child: Text("No resources found.", style: TextStyle(fontFamily: 'Poppins')))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _resources.length,
                            itemBuilder: (context, index) {
                              return _buildResourceCard(_resources[index], theme);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(ResourceModel res, ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: InkWell(
        onTap: () => _openResource(res),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_getIconForType(res.type), color: primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      res.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Poppins'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "By: ${res.uploaderName}",
                      style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7), fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _tag(res.category, Colors.blue),
                        _tag(res.type, Colors.orange),
                        Text(
                          DateFormat('MMM dd, yyyy').format(res.dateUploaded),
                          style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 20, color: Colors.grey.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
      ),
    );
  }

  IconData _getIconForType(String type) {
    type = type.toLowerCase();
    if (type.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (type.contains('video')) return Icons.play_circle_fill_rounded;
    if (type.contains('image')) return Icons.image_rounded;
    return Icons.description_rounded;
  }
}
