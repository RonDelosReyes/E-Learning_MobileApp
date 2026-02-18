import 'dart:io';

import 'package:e_learning_app/login_pages/login_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../services/faculty/edit_faculty_modal.dart';
import '../services/pages/profile_service.dart';
import '../services/pages/profile_storage_service.dart';
import '../user_provider.dart';
import '../widget/logout_dialog.dart';
import 'package:e_learning_app/widget/faculty/hamburg_menu_facul.dart';

class FacultyProfilePage extends StatefulWidget {
  const FacultyProfilePage({super.key});

  @override
  State<FacultyProfilePage> createState() => _FacultyProfilePageState();
}

class _FacultyProfilePageState extends State<FacultyProfilePage> {
  final ProfileService _profileService = ProfileService();
  bool _isFetchingProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<UserProvider>();

    if (!_isFetchingProfile && user.userId != null) {
      _fetchProfileImage(user.userId!);
    }
  }

  Future<void> _fetchProfileImage(int userId) async {
    _isFetchingProfile = true;
    final profile = await _profileService.fetchProfileFile(userId: userId);
    if (!mounted) return;

    if (profile?.filePath != null) {
      final publicUrl = ProfileStorageService().getPublicUrl(profile!.filePath);
      context.read<UserProvider>().setProfileImage(publicUrl);
    } else {
      context.read<UserProvider>().setProfileImage('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FA),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: const Text(
              'Faculty Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: const Color(0xFF1565C0),
            iconTheme: const IconThemeData(color: Colors.white, size: 28),
          ),
          drawer: const FacultyAppDrawer(currentRoute: 'profile'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ===== Gradient Header with Profile Image =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileAvatarUploader(userId: user.userId!, radius: 50),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Faculty Member",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ===== Profile Details Section =====
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Faculty Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ===== Info Cards =====
                      _buildInfoCard(Icons.email, "Email", user.email ?? ""),
                      _buildInfoCard(Icons.phone, "Contact No", user.contactNo ?? ""),
                      _buildInfoCard(Icons.school, "Department", user.department ?? ""),
                      _buildInfoCard(Icons.book, "Specialization", user.specialization ?? ""),
                      _buildInfoCard(Icons.calendar_today, "Joined", user.dateCreated ?? "NO DATE"),

                      const SizedBox(height: 24),

                      // ===== Action Buttons =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await EditFacultyModal.show(context, user);
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              "Edit Profile",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              LogoutDialog.show(
                                context: context,
                                onLogout: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const LogInForm()),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.logout, color: Color(0xFF1565C0)),
                            label: const Text(
                              "Logout",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, color: Color(0xFF1565C0)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1565C0), width: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===== Modern Info Card with Accent Line =====
  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFF1565C0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black54,
                      )),
                  const SizedBox(height: 6),
                  Text(value,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Profile Avatar Uploader with Image Picker & Upload =====
class ProfileAvatarUploader extends StatefulWidget {
  final int userId;
  final double radius;

  const ProfileAvatarUploader({super.key, required this.userId, required this.radius});

  @override
  State<ProfileAvatarUploader> createState() => _ProfileAvatarUploaderState();
}

class _ProfileAvatarUploaderState extends State<ProfileAvatarUploader> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final userProvider = context.read<UserProvider>();

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final file = File(pickedFile.path);

      // Upload to Supabase Storage
      final storageService = ProfileStorageService();
      final uploadedPath = await storageService.uploadProfileImage(
        userId: widget.userId,
        file: file,
      );

      final publicUrl = storageService.getPublicUrl(uploadedPath!);

      userProvider.setProfileImage(publicUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully!')),
      );
    } catch (e) {
      debugPrint("Error uploading profile image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile image')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Stack(
      children: [
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: const Color(0xFFE3F2FD),
          backgroundImage: user.profileImagePath.isNotEmpty
              ? NetworkImage(user.profileImagePath)
              : const AssetImage('assets/profile_placeholder.png') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isUploading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
