import 'package:flutter/material.dart';
import '../../login_pages/login_form.dart';
import '../../pages/courses_page.dart';
import '../../pages/dashboard_page.dart';
import '../../pages/knowledge_lab_page.dart';
import '../../pages/profile_page.dart';
import '../../pages/techlib_page.dart';
import '../../user_provider.dart';
import '../../widget/alert_dialog.dart';
import '../../widget/logout_dialog.dart';

class AppDrawerBackend {
  final BuildContext context;
  final String currentRoute;

  AppDrawerBackend(this.context, this.currentRoute);

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
          initialChildSize: 0.92,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: const ProfilePage(),
            );
          },
        );
      },
    );
  }

  /// Builds a profile header using data from the UserProvider
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

  /// Navigates to a page replacing current
  void navigate(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Menu items list
  List<DrawerMenuItem> get menuItems => [
    DrawerMenuItem(
      title: 'Home',
      icon: Icons.home_outlined,
      route: 'home',
      onTap: () => navigate(const DashBoardPage()),
    ),
    DrawerMenuItem(
      title: 'Courses',
      icon: Icons.menu_book_outlined,
      route: 'courses',
      onTap: () => navigate(const CoursesPage()),
    ),
    DrawerMenuItem(
      title: 'Tech Library',
      icon: Icons.computer_outlined,
      route: 'techlib',
      onTap: () => navigate(const TechLibraryPage()),
    ),
    DrawerMenuItem(
      title: 'Knowledge Lab',
      icon: Icons.science_outlined,
      route: 'knowledge',
      onTap: () => navigate(const KnowledgeLabPage()),
    ),
    DrawerMenuItem(
      title: 'AR Lab',
      icon: Icons.view_in_ar_outlined,
      route: 'arlab',
      onTap: () => CustomAlertDialog().show(context),
    ),
    DrawerMenuItem(
      title: 'Community Hub',
      icon: Icons.groups_outlined,
      route: 'community',
      onTap: () => CustomAlertDialog().show(context),
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
