import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_learning_app/back_end/providers/user_provider.dart';
import 'package:e_learning_app/back_end/providers/theme_provider.dart';
import 'package:e_learning_app/back_end/services/login/login_service.dart';
import 'package:e_learning_app/front_end/widgets/dialog/logout_dialog.dart';

// Pages
import 'package:e_learning_app/front_end/student_pages/dashboard/dashboard_page.dart';
import 'package:e_learning_app/front_end/student_pages/courses/courses_page.dart';
import 'package:e_learning_app/front_end/student_pages/tech_library/techlib_page.dart';
import 'package:e_learning_app/front_end/student_pages/knowledge_lab/knowledge_lab_page.dart';
import 'package:e_learning_app/front_end/student_pages/community/community_hub_page.dart';
import 'package:e_learning_app/front_end/student_pages/ar_lab/ar_lab_page.dart';
import 'package:e_learning_app/front_end/student_pages/ar_lab/ar_activity_page.dart';
import 'package:e_learning_app/front_end/widgets/dialog/ar_compatibility_dialog.dart';
import 'package:e_learning_app/front_end/profile/profile_page.dart';
import 'package:e_learning_app/front_end/login/login_page.dart';

import 'package:e_learning_app/front_end/widgets/main_shell.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final bool isInsideShell;

  const AppDrawer({
    super.key, 
    required this.currentRoute,
    this.isInsideShell = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, ThemeProvider>(
      builder: (context, userProvider, themeProvider, child) {
        final backend = AppDrawerBackend(context, currentRoute, themeProvider, isInsideShell);

        return Drawer(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Reactive Profile Header - Clicking this opens the profile
                GestureDetector(
                  onTap: backend.openProfileOverlay,
                  child: backend.buildProfileHeader(userProvider),
                ),

                const SizedBox(height: 30),

                // Main menu items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: backend.buildMenu(context),
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
  final ThemeProvider themeProvider;
  final bool isInsideShell;

  AppDrawerBackend(this.context, this.currentRoute, this.themeProvider, this.isInsideShell);

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
    debugPrint("DEBUG: AppDrawer building profile image with path: $path");
    if (path.startsWith('http')) {
      return SizedBox.expand(
        child: Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("DEBUG: AppDrawer Image.network error: $error");
            return _fallbackAvatar(name, iconColor);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
        ),
      );
    } else if (path.startsWith('assets/')) {
      return SizedBox.expand(
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackAvatar(name, iconColor),
        ),
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
  Widget buildDrawerItem(DrawerMenuItem item, bool isSelected, {bool isSubItem = false}) {
    final theme = Theme.of(context);
    final Color primaryColor = theme.colorScheme.primary;
    final Color errorColor = theme.colorScheme.error;

    final Color iconColor = item.isLogout
        ? errorColor
        : !item.isEnabled
            ? Colors.grey.withOpacity(0.5)
            : isSelected
                ? primaryColor
                : theme.iconTheme.color ?? Colors.grey;

    final Color textColor = item.isLogout
        ? errorColor
        : !item.isEnabled
            ? Colors.grey.withOpacity(0.5)
            : isSelected
                ? primaryColor
                : theme.textTheme.bodyMedium?.color ?? Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: item.isEnabled ? item.onTap : null,
        child: Container(
          padding: EdgeInsets.fromLTRB(isSubItem ? 32 : 16, 12, 16, 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: iconColor, size: isSubItem ? 20 : 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: isSubItem ? 14 : 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (!item.isEnabled)
                      Text(
                        "Not supported on this device",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.withOpacity(0.7),
                          fontFamily: 'Poppins',
                        ),
                      ),
                  ],
                ),
              ),
              if (!item.isLogout && item.route != 'theme' && item.isEnabled)
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.withOpacity(0.3)),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigates to a page replacing current
  void navigate(Widget page, String route) {
    if (isInsideShell) {
      final shell = MainShell.of(context);
      if (shell != null) {
        shell.navigateTo(route);
        return;
      }
    }

    if (currentRoute == 'home') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page)).then((_) {
        // This runs when returning to Home from another page (like AR Lab)
      });
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  List<Widget> buildMenu(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bool isArSelected = currentRoute == 'arlab_activity';

    return [
      buildDrawerItem(DrawerMenuItem(title: 'Home', icon: Icons.home_outlined, route: 'home', onTap: () => navigate(const DashBoardPage(), 'home')), currentRoute == 'home'),
      buildDrawerItem(DrawerMenuItem(title: 'Courses', icon: Icons.menu_book_outlined, route: 'courses', onTap: () => navigate(const CoursesPage(), 'courses')), currentRoute == 'courses'),
      buildDrawerItem(DrawerMenuItem(title: 'Tech Library', icon: Icons.computer_outlined, route: 'techlib', onTap: () => navigate(const TechLibraryPage(), 'techlib')), currentRoute == 'techlib'),
      buildDrawerItem(DrawerMenuItem(title: 'Knowledge Lab', icon: Icons.science_outlined, route: 'knowledge', onTap: () => navigate(const KnowledgeLabPage(), 'knowledge')), currentRoute == 'knowledge'),
      
      // AR Lab Dropdown-like Expansion
      GestureDetector(
        onTap: userProvider.isArSupported ? null : () => ArCompatibilityDialog.show(context),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: isArSelected,
            enabled: userProvider.isArSupported,
            leading: Icon(
              Icons.view_in_ar_outlined,
              color: !userProvider.isArSupported 
                  ? Colors.grey.withOpacity(0.5) 
                  : isArSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).iconTheme.color ?? Colors.grey),
            ),
            title: Text(
              'AR Lab',
              style: TextStyle(
                fontSize: 16,
                fontWeight: isArSelected ? FontWeight.w600 : FontWeight.w500,
                color: !userProvider.isArSupported 
                    ? Colors.grey.withOpacity(0.5) 
                    : isArSelected ? Theme.of(context).colorScheme.primary : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black87),
                fontFamily: 'Poppins',
              ),
            ),
            children: [
              buildDrawerItem(
                DrawerMenuItem(
                  title: 'AR Activity', 
                  icon: Icons.play_circle_outline, 
                  route: 'arlab_activity', 
                  isEnabled: userProvider.isArSupported,
                  onTap: () {
                    // AR activity usually stays as a full screen push
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ArActivityPage()));
                  }
                ), 
                currentRoute == 'arlab_activity',
                isSubItem: true
              ),
            ],
          ),
        ),
      ),

      buildDrawerItem(DrawerMenuItem(title: 'Community Hub', icon: Icons.groups_outlined, route: 'community', onTap: () => navigate(const CommunityHubPage(), 'community')), currentRoute == 'community'),
    ];
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
      onLogout: () async {
        try {
          await AuthService().signOut();
          if (!context.mounted) return;
          Provider.of<UserProvider>(context, listen: false).clearUser();
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LogInForm()),
            (route) => false,
          );
        } catch (e) {
          debugPrint("Logout Error: $e");
        }
      },
    );
  }
}

class DrawerMenuItem {
  final String title;
  final IconData icon;
  final String route;
  final VoidCallback onTap;
  final bool isLogout;
  final bool isEnabled;

  const DrawerMenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.onTap,
    this.isLogout = false,
    this.isEnabled = true,
  });
}
