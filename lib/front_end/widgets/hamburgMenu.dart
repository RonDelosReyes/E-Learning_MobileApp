import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../back_end/providers/user_provider.dart';
import '../../back_end/providers/theme_provider.dart';
import 'dialog/alert_dialog.dart';
import 'dialog/logout_dialog.dart';

// Pages
import '../student_pages/dashboard/dashboard_page.dart';
import '../student_pages/courses/courses_page.dart';
import '../student_pages/tech_library/techlib_page.dart';
import '../student_pages/knowledge_lab/knowledge_lab_page.dart';
import '../student_pages/community/community_hub_page.dart';
import '../profile/profile_page.dart';
import '../login/login_page.dart';

// Faculty Pages
import '../faculty_pages/dashboard/f_dashboard_page.dart';
import '../faculty_pages/user_manager/f_user_manager_page.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, ThemeProvider>(
      builder: (context, userProvider, themeProvider, child) {
        final String role = userProvider.role ?? 'Student';
        final backend = AppDrawerBackend(context, currentRoute, role, themeProvider);

        return Drawer(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Reactive Profile Header
                GestureDetector(
                  onTap: backend.openProfileOverlay,
                  child: backend.buildProfileHeader(userProvider),
                ),

                const SizedBox(height: 30),

                // Main menu items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: backend.mainMenuItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = backend.mainMenuItems[index];
                      final isSelected = currentRoute == item.route;
                      return backend.buildDrawerItem(item, isSelected);
                    },
                  ),
                ),

                // Fixated bottom items
                const Divider(height: 1, indent: 20, endIndent: 20),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      backend.buildDrawerItem(backend.themeItem, false),
                      const SizedBox(height: 12),
                      backend.buildDrawerItem(backend.logoutItem, false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AppDrawerBackend {
  final BuildContext context;
  final String currentRoute;
  final String role;
  final ThemeProvider themeProvider;

  AppDrawerBackend(this.context, this.currentRoute, this.role, this.themeProvider);

  /// Opens profile page as a slide-up modal
  void openProfileOverlay() {
    const Widget profilePage = ProfilePage();

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
              child: profilePage,
            );
          },
        );
      },
    );
  }

  /// Builds a profile header using data from the UserProvider
  Widget buildProfileHeader(UserProvider user) {
    final theme = Theme.of(context);
    final fullName = user.fullName.isNotEmpty ? user.fullName : 'Profile';
    final profilePic = user.profileImagePath;

    return Column(
      children: [
        // Profile Image Container
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: _buildProfileImage(profilePic, fullName, theme.colorScheme.primary),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? "No Email",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(String path, String name, Color iconColor) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackAvatar(name, iconColor),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackAvatar(name, iconColor),
      );
    } else {
      return _fallbackAvatar(name, iconColor);
    }
  }

  Widget _fallbackAvatar(String name, Color iconColor) {
    return Image.network(
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=random&color=fff',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: iconColor),
    );
  }

  /// Builds a single drawer item
  Widget buildDrawerItem(DrawerMenuItem item, bool isSelected) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color errorColor = theme.colorScheme.error;

    final Color iconColor = item.isLogout
        ? errorColor
        : isSelected
            ? primaryColor
            : theme.iconTheme.color ?? Colors.grey;

    final Color textColor = item.isLogout
        ? errorColor
        : isSelected
            ? primaryColor
            : theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.08) : Colors.transparent,
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
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (!item.isLogout && item.route != 'theme')
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.withOpacity(0.5)),
            if (item.route == 'theme')
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                activeColor: primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  /// Navigates to a page replacing current
  void navigate(Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Menu items list depends on role
  List<DrawerMenuItem> get mainMenuItems {
    if (role == 'Faculty') {
      return [
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
          title: 'Community Hub',
          icon: Icons.groups_outlined,
          route: 'community',
          onTap: () => navigate(const CommunityHubPage()),
        ),
        DrawerMenuItem(
          title: 'My Profile',
          icon: Icons.person_outline,
          route: 'profile',
          onTap: () => navigate(const ProfilePage()),
        ),
      ];
    } else {
      // Student Menu
      return [
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
          onTap: () => navigate(const CommunityHubPage()),
        ),
      ];
    }
  }

  DrawerMenuItem get themeItem => DrawerMenuItem(
        title: themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
        icon: themeProvider.isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        route: 'theme',
        onTap: () => themeProvider.toggleTheme(),
      );

  DrawerMenuItem get logoutItem => DrawerMenuItem(
        title: 'Log Out',
        icon: Icons.logout,
        route: 'logout',
        isLogout: true,
        onTap: _handleLogout,
      );

  void _handleLogout() {
    LogoutDialog.show(
      context: context,
      onLogout: () {
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (_) => const LogInForm()),
        );
      },
    );
  }
}

/// Drawer menu item models
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
