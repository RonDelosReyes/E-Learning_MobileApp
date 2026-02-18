import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pages/profile_edit_service.dart';
import '../services/pages/profile_service.dart';
import '../services/pages/profile_storage_service.dart';
import '../services/student/edit_profile_modal.dart';
import '../user_provider.dart';
import '../widget/logout_dialog.dart';
import '../login_pages/login_form.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
              'My Profile',
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ===== Profile Header with Gradient =====
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
                      ProfileAvatarUploader(
                        userId: user.userId!,
                        radius: 50,
                      ),
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
                      Text(
                        user.role ?? "Student",
                        style: const TextStyle(
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
                        "Profile Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ===== Info Cards =====
                      _buildInfoCard(Icons.email, "Email", user.email ?? ""),
                      _buildInfoCard(Icons.person_2, "Role", user.role ?? ""),
                      if (user.role == "Student") ...[
                        _buildInfoCard(Icons.school, "Year Level", user.yearLevel ?? ""),
                        _buildInfoCard(Icons.badge, "Student Number", user.studentNumber ?? ""),
                      ],
                      _buildInfoCard(Icons.calendar_today, "Joined", user.dateCreated ?? "NO DATE"),

                      const SizedBox(height: 24),

                      // ===== Action Buttons =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              await EditProfileModal.show(context, user);
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