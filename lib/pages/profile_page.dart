import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/pages/profile_edit_service.dart';
import '../services/pages/profile_service.dart';
import '../services/pages/profile_storage_service.dart';
import '../services/student/edit_profile_modal.dart';
import '../user_provider.dart';
import '../widget/logout_dialog.dart';
import '../widget/student/hamburg_menu_stud.dart';
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

    // Fetch the stored file path (filename) from DB
    final profile = await _profileService.fetchProfileFile(userId: userId);
    if (!mounted) return;

    if (profile?.filePath != null) {
      // Generate a signed URL before updating the Provider
      final signedUrl = await ProfileStorageService().getSignedUrl(
        profile!.filePath,
        expiresInSeconds: 300, // e.g., 5 minutes
      );

      if (signedUrl != null) {
        context.read<UserProvider>().setProfileImage(signedUrl);
      } else {
        debugPrint("Failed to generate signed URL for profile image");
        context.read<UserProvider>().setProfileImage(''); // fallback
      }
    } else {
      context.read<UserProvider>().setProfileImage('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, user, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFE3F2FD),
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'My Profile',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: const Color(0xFF33A1E0),
            iconTheme: const IconThemeData(color: Colors.white, size: 30),
          ),
          drawer: const AppDrawer(),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 30),
                  _buildProfileDetailsSection(context, user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserProvider user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
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
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Student",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileDetailsSection(BuildContext context, UserProvider user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          _infoTile(ProfileInfoItem(icon: Icons.email, label: "Email", value: user.email ?? "")),
          _infoTile(ProfileInfoItem(icon: Icons.person_2, label: "Role", value: user.role ?? "")),
          if (user.role == "Student") ...[
            _infoTile(ProfileInfoItem(icon: Icons.school, label: "Year Level", value: user.yearLevel ?? "")),
            _infoTile(ProfileInfoItem(icon: Icons.badge, label: "Student Number", value: user.studentNumber ?? "")),
          ],
          _infoTile(ProfileInfoItem(icon: Icons.calendar_today, label: "Joined", value: user.dateCreated ?? "NO DATE")),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await EditProfileModal.show(context, user);
                  // No need to reset _profileImageUrl
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF33A1E0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  LogoutDialog.show(
                    context: context,
                    onLogout: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LogInForm()));
                    },
                  );
                },
                icon: const Icon(Icons.logout, color: Color(0xFF33A1E0)),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF33A1E0)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF33A1E0), width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(ProfileInfoItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF33A1E0), width: 1),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: const Color(0xFF33A1E0), size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoItem {
  final IconData icon;
  final String label;
  final String value;

  ProfileInfoItem({required this.icon, required this.label, required this.value});
}
