import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_learning_app/login_pages/login_form.dart';
import 'package:e_learning_app/widget/alert_dialog.dart';
import 'package:e_learning_app/widget/logout_dialog.dart';

import '../../faculty/f_dashboard_page.dart';
import '../../faculty/f_profile_page.dart';
import '../../faculty/f_user_management.dart';
import '../../user_provider.dart';

class FacultyAppDrawer extends StatelessWidget {
  final String currentRoute;

  const FacultyAppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final backend = FacultyDrawerBackend(context, currentRoute);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: FacultyDrawerBackend.iconDefault),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 10),

            // Reactive Profile Header
            Consumer<UserProvider>(
              builder: (context, user, child) {
                return GestureDetector(
                  onTap: backend.openProfileOverlay,
                  child: backend.buildProfileHeader(user),
                );
              },
            ),

            const SizedBox(height: 30),

            // Menu items
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: backend.menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = backend.menuItems[index];
                  final isSelected = currentRoute == item.route;
                  return backend.buildDrawerItem(item, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------------------- Backend Logic --------------------
class FacultyDrawerBackend {
  final BuildContext context;
  final String currentRoute;

  FacultyDrawerBackend(this.context, this.currentRoute);

  static const Color primaryBlue = Color(0xFF33A1E0);
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color iconDefault = Color(0xFF555555);
  static const Color arrowColor = Color(0xFF9E9E9E);
  static const Color logoutRed = Color(0xFFE53935);

  /// Opens profile page as a slide-up modal
  void openProfileOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: const FacultyProfilePage(),
            );
          },
        );
      },
    );
  }

  /// Builds a profile header using UserProvider data
  Widget buildProfileHeader(UserProvider user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundImage: user.profileImagePath.isNotEmpty
              ? NetworkImage(user.profileImagePath)
              : const AssetImage('assets/profile_pic.png') as ImageProvider,
        ),
        const SizedBox(height: 12),
        Text(
          user.fullName.isNotEmpty ? user.fullName : "No Name",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? "No Email",
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  /// Builds a single drawer item
  Widget buildDrawerItem(DrawerMenuItem item, bool isSelected) {
    final Color iconColor = item.isLogout
        ? logoutRed
        : isSelected
        ? primaryBlue
        : iconDefault;

    final Color textColor = item.isLogout
        ? logoutRed
        : isSelected
        ? primaryBlue
        : textPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: arrowColor),
          ],
        ),
      ),
    );
  }

  /// Navigation helper
  void navigate(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Menu items list (kept exactly as original)
  List<DrawerMenuItem> get menuItems => [
    DrawerMenuItem(
      title: 'Home',
      icon: Icons.home_outlined,
      route: 'home',
      onTap: () => navigate(const FacultyDashBoardPage()),
    ),
    DrawerMenuItem(
      title: 'Courses',
      icon: Icons.menu_book_outlined,
      route: 'courses',
      onTap: () => CustomAlertDialog().show(context),
    ),
    DrawerMenuItem(
      title: 'Tech Library',
      icon: Icons.computer_outlined,
      route: 'techlib',
      onTap: () => CustomAlertDialog().show(context),
    ),
    DrawerMenuItem(
      title: 'Knowledge Lab',
      icon: Icons.science_outlined,
      route: 'knowledge',
      onTap: () => CustomAlertDialog().show(context),
    ),
    DrawerMenuItem(
      title: 'User Manager',
      icon: Icons.manage_accounts_outlined,
      route: 'user_manager',
      onTap: () => navigate(const FacultyUserManagerPage()),
    ),
    DrawerMenuItem(
      title: 'My Profile',
      icon: Icons.person_outline,
      route: 'profile',
      onTap: () => navigate(const FacultyProfilePage()),
    ),
    DrawerMenuItem(
      title: 'Log Out',
      icon: Icons.logout,
      route: 'logout',
      isLogout: true,
      onTap: () {
        LogoutDialog.show(
          context: context,
          onLogout: () {
            Navigator.of(context, rootNavigator: true).pushReplacement(
              MaterialPageRoute(builder: (_) => const LogInForm()),
            );
          },
        );
      },
    ),
  ];
}

/// Drawer menu item model
class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String route;
  final VoidCallback onTap;
  final bool isLogout;

  const DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.onTap,
    this.isLogout = false,
  });
}