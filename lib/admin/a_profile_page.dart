import 'package:e_learning_app/login_pages/login_form.dart';
import 'package:e_learning_app/widget/admin/hamburg_menu_main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import '../widget/logout_dialog.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Admin Profile',
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
      drawer: AdminAppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 30),
              _buildAdminDetails(user, context),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- Admin Header --------------------
  Widget _buildProfileHeader(UserProvider user) {
    String fullName = [
      user.firstName ?? '',
      user.middleInitial ?? '',
      user.lastName ?? ''
    ].where((s) => s.isNotEmpty).join(' ');

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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => debugPrint("Edit Profile Clicked"),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF33A1E0),
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/profile_placeholder.png'),
                  backgroundColor: Color(0xFFE3F2FD),
                ),
                const SizedBox(height: 16),
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Admin",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Admin Details --------------------
  Widget _buildAdminDetails(UserProvider user, BuildContext context) {
    final List<ProfileInfoItem> profileItems = [
      ProfileInfoItem(icon: Icons.email, label: "Email", value: user.email ?? ""),
      ProfileInfoItem(icon: Icons.person, label: "First Name", value: user.firstName ?? ""),
      ProfileInfoItem(icon: Icons.person, label: "Middle Initial", value: user.middleInitial ?? ""),
      ProfileInfoItem(icon: Icons.person, label: "Last Name", value: user.lastName ?? ""),
      ProfileInfoItem(icon: Icons.phone, label: "Contact No", value: user.contactNo ?? ""),
      ProfileInfoItem(icon: Icons.calendar_today, label: "Date Created", value: user.dateCreated ?? ""),
    ];

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
            "Admin Information",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 16),
          ...profileItems.map((item) => _infoTile(item)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => debugPrint("Edit Profile Clicked"),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  "Edit Profile",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF33A1E0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  LogoutDialog.show(
                    context: context,
                    onLogout: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LogInForm()),
                      );
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                Text(item.label,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54)),
                const SizedBox(height: 4),
                Text(item.value,
                    style: const TextStyle(fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Profile Info Model --------------------
class ProfileInfoItem {
  final IconData icon;
  final String label;
  final String value;

  ProfileInfoItem({required this.icon, required this.label, required this.value});
}