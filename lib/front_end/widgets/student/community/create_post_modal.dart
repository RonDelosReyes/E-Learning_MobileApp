import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../back_end/controllers/student/community/community_controller.dart';
import '../../../../back_end/providers/user_provider.dart';
import '../../../../back_end/utils/post_storage_service.dart';
import '../../../../models/student/community_hub/community_model.dart';
import '../../../../back_end/utils/debug_logger.dart';

class CreatePostModal extends StatefulWidget {
  final VoidCallback onSuccess;
  const CreatePostModal({super.key, required this.onSuccess});

  static void show(BuildContext context, VoidCallback onSuccess) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostModal(onSuccess: onSuccess),
    );
  }

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  final CommunityController _controller = CommunityController();
  final PostStorageService _storageService = PostStorageService();
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  File? _selectedFile;
  List<CommunityCategory> _categories = [];
  int? _selectedCategoryId;
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _controller.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
        await DebugLogger.log('CREATE_POST: File selected: ${_selectedFile!.path}');
      }
    } catch (e) {
      await DebugLogger.log('CREATE_POST: Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking file: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Create Community Post",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                )
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Dropdown
                  Text(
                    "Select Category",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoadingCategories
                      ? const LinearProgressIndicator()
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                            color: theme.cardColor,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedCategoryId,
                              isExpanded: true,
                              hint: const Text("Choose category"),
                              items: _categories.map((c) {
                                return DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(c.name, style: const TextStyle(fontFamily: 'Poppins')),
                                );
                              }).toList(),
                              onChanged: (val) => setState(() => _selectedCategoryId = val),
                            ),
                          ),
                        ),
                  
                  const SizedBox(height: 24),

                  // Title Input
                  Text(
                    "Post Title",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      hintText: "Enter an eye-catching title",
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Content Input
                  Text(
                    "Content",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: "Share your thoughts or questions here...",
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Media Selection
                  Text(
                    "Attach Media (Optional)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.primary,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickFile,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_upload_outlined, color: colorScheme.primary),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedFile != null 
                                ? _selectedFile!.path.split(Platform.pathSeparator).last 
                                : "Choose image or video to upload",
                              style: const TextStyle(fontFamily: 'Poppins'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_selectedFile != null)
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _selectedFile = null),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Post to Community",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins'),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    await DebugLogger.log('CREATE_POST: Submitting post. Title: $title, CategoryId: $_selectedCategoryId');

    if (title.isEmpty || content.isEmpty || _selectedCategoryId == null) {
      await DebugLogger.log('CREATE_POST: Validation failed. Some fields are empty.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId!;
      await DebugLogger.log('CREATE_POST: User ID: $userId');

      String? mediaUrl;
      if (_selectedFile != null) {
        await DebugLogger.log('CREATE_POST: Uploading media...');
        mediaUrl = await _storageService.uploadPostMedia(
          userId: userId,
          file: _selectedFile!,
        );
        await DebugLogger.log('CREATE_POST: Media uploaded. URL/Path: $mediaUrl');
      }

      await DebugLogger.log('CREATE_POST: Creating post record in DB...');
      await _controller.createPost(
        userId,
        title,
        content,
        _selectedCategoryId!,
        mediaUrl,
      );
      await DebugLogger.log('CREATE_POST: Post created successfully.');
      
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      await DebugLogger.log('CREATE_POST: Error during submission: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
}
